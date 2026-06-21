/**
 * DROP — Communications Center send engine (Phase 2).
 *
 * Callable `sendBroadcast`: the authoritative broadcast write + push pipeline.
 * Responsibilities:
 *   1. validate the sender's permissions (admin / manager matrix),
 *   2. resolve recipients (all users / a branch / one individual),
 *   3. persist the broadcast doc (`broadcasts/{id}`),
 *   4. fetch the recipients' FCM tokens (`users/{uid}.fcmTokens` [+ legacy
 *      single `fcmToken`]),
 *   5. send the push via the Firebase Admin SDK,
 *   6. prune dead tokens, and
 *   7. return a delivery summary `{ success, recipientCount, ... }`.
 *
 * Recipient-resolution / permission matrix (mirrors `BroadcastPermissions` on
 * the client and the `broadcasts` Firestore rules):
 *   - admin   → allBranches | branch (any) | user (any)
 *   - manager → branch (own only) | user (in own branch only)
 *   - employee → denied
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

const USERS = "users";
const BROADCASTS = "broadcasts";

// `branchId` marker for a direct message — never a real branch id and never ''
// (mirrors BroadcastModel.directBranchMarker), so a DM never appears in a
// branch / all feed query.
const DIRECT_BRANCH_MARKER = "__direct__";

// FCM multicast hard limit per request.
const MULTICAST_CHUNK = 500;

exports.sendBroadcast = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "Please sign in to send a broadcast.");
  }

  const data = request.data || {};
  const title = String(data.title || "").trim();
  const body = String(data.body || data.message || "").trim();
  const category = String(data.category || "general").trim() || "general";
  const audience = String(data.audience || "").trim();
  let branchId = String(data.branchId || "").trim();
  const targetUserId = String(data.targetUserId || "").trim();

  if (!title || !body) {
    throw new HttpsError("invalid-argument", "A broadcast needs a title and a message.");
  }

  // ── Load the sender (role + branch are the authority for permissions) ──
  const senderSnap = await db.collection(USERS).doc(auth.uid).get();
  if (!senderSnap.exists) {
    throw new HttpsError("permission-denied", "Your account profile was not found.");
  }
  const sender = senderSnap.data() || {};
  const senderRole = sender.role || "employee";
  const senderBranch = sender.branchId || "";

  if (senderRole !== "admin" && senderRole !== "manager") {
    throw new HttpsError("permission-denied", "Only managers and admins can send broadcasts.");
  }

  // ── Resolve recipients + validate permissions per audience ──
  let recipientDocs = [];

  if (audience === "allBranches") {
    if (senderRole !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can broadcast to all branches.");
    }
    const snap = await db.collection(USERS).where("isActive", "==", true).get();
    recipientDocs = snap.docs;
    branchId = "";
  } else if (audience === "branch") {
    if (!branchId) {
      throw new HttpsError("invalid-argument", "Pick a branch to broadcast to.");
    }
    if (senderRole === "manager" && branchId !== senderBranch) {
      throw new HttpsError("permission-denied", "Managers can only broadcast to their own branch.");
    }
    const snap = await db
      .collection(USERS)
      .where("branchId", "==", branchId)
      .where("isActive", "==", true)
      .get();
    recipientDocs = snap.docs;
  } else if (audience === "user") {
    if (!targetUserId) {
      throw new HttpsError("invalid-argument", "Pick a recipient.");
    }
    const targetSnap = await db.collection(USERS).doc(targetUserId).get();
    if (!targetSnap.exists) {
      throw new HttpsError("not-found", "That recipient no longer exists.");
    }
    const target = targetSnap.data() || {};
    if (senderRole === "manager" && (target.branchId || "") !== senderBranch) {
      throw new HttpsError("permission-denied", "Managers can only message users inside their own branch.");
    }
    recipientDocs = [targetSnap];
    branchId = DIRECT_BRANCH_MARKER;
  } else {
    throw new HttpsError("invalid-argument", "Unknown broadcast audience.");
  }

  // ── Gather FCM tokens (de-duplicated; remember each token's owner) ──
  const tokens = [];
  const tokenOwner = new Map();
  for (const doc of recipientDocs) {
    const u = doc.data() || {};
    const arr = Array.isArray(u.fcmTokens) ? u.fcmTokens : [];
    for (const t of arr) {
      if (t && !tokenOwner.has(t)) {
        tokenOwner.set(t, doc.id);
        tokens.push(t);
      }
    }
    // Legacy single-token field (pre-Phase-2 docs).
    if (u.fcmToken && !tokenOwner.has(u.fcmToken)) {
      tokenOwner.set(u.fcmToken, doc.id);
      tokens.push(u.fcmToken);
    }
  }

  const recipientCount = recipientDocs.length;
  const senderName = sender.fullName || sender.displayName || sender.email || "DROP";

  // ── Persist the broadcast doc (authoritative — schema matches BroadcastModel) ──
  const broadcastRef = db.collection(BROADCASTS).doc();
  await broadcastRef.set({
    id: broadcastRef.id,
    title,
    message: body,
    category,
    senderId: auth.uid,
    senderName,
    senderRole,
    audience,
    branchId,
    targetUserId: audience === "user" ? targetUserId : "",
    recipientCount,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // ── Push the notification (chunked; prune dead tokens) ──
  let deliveredCount = 0;
  const payload = {
    notification: { title, body },
    // Data values must be strings — they ride along to the tap handler.
    data: {
      type: "broadcast",
      category,
      senderId: auth.uid,
      broadcastId: broadcastRef.id,
      title,
      body,
    },
  };

  for (let i = 0; i < tokens.length; i += MULTICAST_CHUNK) {
    const batch = tokens.slice(i, i + MULTICAST_CHUNK);
    const response = await messaging.sendEachForMulticast({ ...payload, tokens: batch });
    deliveredCount += response.successCount;

    // Remove tokens FCM reports as permanently invalid, per owner.
    const removals = new Map(); // uid -> [badToken]
    response.responses.forEach((r, idx) => {
      if (r.success) return;
      const code = r.error && r.error.code;
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token" ||
        code === "messaging/invalid-argument"
      ) {
        const badToken = batch[idx];
        const owner = tokenOwner.get(badToken);
        if (owner) {
          if (!removals.has(owner)) removals.set(owner, []);
          removals.get(owner).push(badToken);
        }
      }
    });
    await Promise.all(
      Array.from(removals.entries()).map(([uid, bad]) =>
        db
          .collection(USERS)
          .doc(uid)
          .update({ fcmTokens: admin.firestore.FieldValue.arrayRemove(...bad) })
          .catch(() => {}),
      ),
    );
  }

  // Persist the delivery result on the doc so the Communications Center feed /
  // detail can show "delivered N / M" (best-effort; never fails the send).
  await broadcastRef.update({ deliveredCount }).catch(() => {});

  logger.info("broadcast sent", {
    broadcastId: broadcastRef.id,
    audience,
    recipientCount,
    deliveredCount,
    tokenCount: tokens.length,
  });

  return {
    success: true,
    broadcastId: broadcastRef.id,
    recipientCount,
    deliveredCount,
  };
});
