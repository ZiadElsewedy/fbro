# DROP — Release Stabilization QA

**Date:** 2026-06-25 · **Project:** `bazic-d9ad7` (DROPTHESHOP) · **Branch:** `enhancement/ui-refactor`

This is the release-readiness record for the Premium UX/Logic Refactor (§1–§11).
It captures the **production deploy**, the **automated gate**, **static audits**,
and the **manual QA matrix** that a human must execute on a device/emulator across
all three roles (Flutter UI can't be exercised in CI here).

---

## Phase 1 — Deployment ✅ (executed)

Deployed to **production** `bazic-d9ad7` on 2026-06-25:

| Target | Result | Secures |
| --- | --- | --- |
| `firestore:rules` | ✅ compiled + released | **Approved-task lock** (server-side) |
| `storage` | ✅ compiled + released | **Branch media uploads** (`branches/{id}/…`) |
| `functions` | ✅ 5 functions updated | **Broadcast sender self-exclusion** + crons |

- **Cleanup:** two orphaned analytics functions (`onBroadcastOpened`,
  `onNotificationRead` — removed from code in the 2026-06-23 analytics rollback)
  were deleted from production. Final live set = exactly the 5 in code:
  `sendBroadcast`, `onNotificationCreated`, `runBroadcastSchedules`,
  `runTaskReminders`, `broadcastHousekeeping`. **No client/server drift.**
- **Critical checks — all verified live:**
  - ☑ Approved-task lock enforced server-side (rules re-audited: no legitimate
    flow locked out; the review transition *into* approved + admin reopen both pass).
  - ☑ Broadcast sender self-exclusion active (`sendBroadcast` updated).
  - ☑ Branch media uploads permitted (`storage.rules` `branches/{id}` path live).
- **Non-blocking note:** the CLI warned `firebase-functions` is an older major
  version (a future `npm i firebase-functions@latest` is a maintenance item, with
  breaking changes to vet — **not** required for this release).

## Phase 2 — Regression QA

**Automated gate (executed):** `flutter analyze` clean (0 issues) · **183 tests
pass** · `node --check functions/index.js` valid.

**Manual matrix (execute on device — ☐ to be checked by QA):** run each across
**admin · manager · employee**.

### Auth
- ☐ Login (email; Google; phone OTP) → lands on the correct role home
- ☐ Logout → returns to Login; FCM token removed for the device
- ☐ Approval gating: a pending sign-up is confined to Pending Approval; admin
  approval redirects them in real time

### Tasks
- ☐ Assign (create + assignees) → assignee sees it + gets a notification
- ☐ Submit (employee: start → complete w/ proof → submit)
- ☐ Approve → recurring task spawns the next instance (if recurrence set)
- ☐ Reject / Request Rework → employee sees feedback + REWORK badge
- ☐ **Reopen (admin):** an approved task shows the **locked** state (no
  Edit/Assign/Delete); admin Reopen returns it to the workflow; **a manager/admin
  edit/delete of an approved task is blocked** (server-side now too)

### Notifications
- ☐ Broadcast (admin/manager) → recipients receive it; **sender does NOT** (the
  self-exclusion fix — verify the sender's own inbox/push)
- ☐ Direct message → only the recipient receives it
- ☐ Swipe right = mark read (dot fades); swipe left = archive (→ Archived view)
- ☐ Archived view: swipe left = delete; **Clear archived** bulk; **Mark all read**
- ☐ Deep links: every notification opens its destination (task → exact task,
  broadcast → detail) — **no dead notifications**
- ☐ Category pills (All/Tasks/Reviews/Broadcast) + Today/Yesterday/Earlier groups;
  a **critical** (overdue/emergency) shows a stronger unread dot

### Branch media (admin)
- ☐ Upload **logo** (edit a branch → Branch media) → appears on the branch card,
  schedule header, operations hero, swap cards, employee profile branch section
- ☐ Upload **cover** → renders as the 16:9 operations hero background (dark scrim)
- ☐ Fallback: a branch with no logo shows initials; no cover → monochrome hero

> **Document every regression found here**, with role + steps + expected/actual.

## Phase 3 — Performance Audit (static)

- **Image caching — clean.** All refactor `Image.network` (branch avatar, cover
  hero, cover preview, task proof) use `cacheWidth`. The only un-capped one is the
  full-screen attachment **zoom** viewer (intentional full-res).
- **List virtualization:** new drill lists (pending review) are small → non-builder
  `ListView` is fine. The **notifications** list is a non-builder `ListView` bounded
  by 30/page pagination — acceptable for a small ops inbox; convert to
  `ListView.builder` only if histories grow large.
- **Rebuild scope:** post Phase-A–D the app is healthy (scoped `BlocBuilder` /
  `BlocSelector`). One pre-existing hot path remains: `employee_management_screen`
  `context.watch<TaskCubit>()` rebuilds the screen on each task emit — a
  `BlocSelector` candidate (not introduced by this refactor).
- **Cover hero / scroll:** the operations cover hero decodes one `Image.network`
  per branch view (cached); the cockpit list is short (workload cards per branch).

## Phase 4 — Final UX Sweep (static)

- Dynamic text on new surfaces is protected (branch name, pending-review rows,
  notification title use `Expanded` + `maxLines`/ellipsis; body `maxLines: 2`).
- The operations hero stat row uses short fixed labels (fits ≥320 px width).
- **On-device verification still needed for:** the cover-image hero layout (nested
  16:9 `Stack`), notification swipe gestures + haptics, and small-screen rendering —
  none CI-renderable here.

## Release status

Deploy **complete**, automated gate **green**, no client/server drift, static
audits clean. **Outstanding before sign-off:** execute the manual QA matrix above
on a device across the three roles and record any regressions.
