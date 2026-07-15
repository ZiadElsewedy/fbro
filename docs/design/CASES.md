# Cases — private conversations

A **Case** is a private conversation between an employee and their manager and/or an
admin about a specific issue, open until it is resolved.

It is **not** a ticket queue. If the answer is yes/no, that's a
[Request](REQUESTS.md) — see [ADR-008](../decisions/ADR-008-requests-are-approvals.md).
Cases exist for the things that need talking through.

## Shape

```
cases/{caseId}                  ← NO creator uid on this doc
  ├── reporter/identity         ← the creator (owner + admin ONLY)
  └── messages/{messageId}      ← the conversation (immutable)
```

- **6 categories:** Sales · Inventory · Staff · Security · Operations · Personal
- **Privacy:** `normal` | `confidential`
- **`urgent`** — a single bool. It replaced a 4-level severity scale that nobody
  calibrated consistently.
- **Lifecycle:** Open → In Discussion → Waiting Response → Closed (closed =
  read-only)

## The privacy split is the design

The case doc carries **no creator uid**. Identity lives in the private subdoc
`cases/{caseId}/reporter/identity`, readable only by the owner and an admin.
`reporterDisplayName` rides the parent doc **only** when the case is `normal`.

This means a same-branch manager handling a confidential case **cannot resolve who
filed it** — enforced by rules, not by hiding a field in the UI. It is also why
notifications are **server-side** (`onCaseCreated` / `onCaseUpdated` /
`onCaseMessageCreated`): a manager literally cannot read the reporter in order to
notify them.

## Conversation model

The `messages` subcollection is the fix for an earlier reply-sending bug: a reply is
a **single `add`**, not a read-modify-write of an array. It streams realtime for
every role.

`CaseMessage` = `opening` | `message` | `system`, reusing `TaskAttachment`.

Pure `case_thread.dart` (`caseThread`) synthesizes the `opening` message from the
case doc when the server-written one hasn't arrived yet, and suppresses it once it
has — so a freshly created case never opens empty.

## Cubits

Two, per [ADR-002](../decisions/ADR-002-cubit-only.md):

- **`CaseListCubit`** (app-wide) — role-scoped inbox (admin: all · manager: branch +
  own · employee: own via the `reporter` collectionGroup) + create + desktop
  selection. Reuses `BranchRepository` and `GetUsersByBranch`.
- **`CaseConversationCubit`** (per case, via
  `AppDependencies.createCaseConversationCubit`) — streams **both** the case doc and
  its `messages` subcollection; owns `SendCaseMessage` / `ChangeCaseStatus`.

## Pure helpers

| File | Owns |
| --- | --- |
| `case_ordering.dart` | Inbox sort — active-urgent first, closed archived |
| `case_participation.dart` | Viewer = reporter vs recipient |
| `case_thread.dart` | Opening-message synthesis |

**`CaseSeenStore`** (`core/services/case_seen_store.dart`) is client-only unread
tracking: per-user, per-case "last opened" timestamps via `path_provider`
(uid-namespaced, in-memory fallback), surfaced as `unreadIds` on
`CaseListState.loaded` and rendered as a dot + bold subject. Deliberately **not**
server state — unread is a per-device convenience, not a fact worth a write.

## UI

- `cases_screen` — **desktop split-pane** (inbox │ conversation); **mobile** list →
  push
- `create_case_screen` — fast flow; manager → admin-locked; urgent toggle
- `case_conversation_screen` — mobile / deep-link
- Shared: `case_conversation_view` · `case_message_list` · `case_status_control` ·
  `case_composer` · `case_list_tile`

**Two behaviours worth preserving:**

- The composer's `onSend` returns `Future<bool>` — the input clears **only on a
  successful send**, so a failed send keeps the text and attachments. No message
  loss.
- `case_message_list` smart-auto-scrolls: it follows new replies only when the
  reader is already at the bottom or it's their own message; otherwise it shows a
  "New messages" jump pill rather than yanking the viewport.

Desktop: Enter sends, Shift+Enter newlines.

**Routes:** `/cases` · `/cases/create` · `/case/:caseId`

## Related

[DATA_MODEL](DATA_MODEL.md) · [REQUESTS](REQUESTS.md) ·
[NOTIFICATIONS](NOTIFICATIONS.md)
