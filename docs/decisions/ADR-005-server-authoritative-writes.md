# ADR-005 — Audit trails and privileged writes are server-authoritative

**Status:** Accepted · **Date:** 2026-07-11 (tasks), extended 2026-07-14 (attendance)

## Context

Early features let the client write its own audit trail. That is unenforceable: a
client that can append "approved by X" can forge it, and two reviewers acting at
once could both write, losing one decision. Attendance made the stakes concrete —
worked minutes feed payroll, so a client-writable record is a client-writable
paycheque.

## Decision

**Anything a client must not be able to forge is written by the Admin SDK.**

| Concern | Authority |
| --- | --- |
| Task status transitions | `TaskRepository.transitionTask` — a transaction that verifies the expected predecessor status, appends the `ActivityEntry` to the **server's** current log, and bumps `TaskEntity.version` |
| Attendance audit (`attendance/{id}/events`) | Cloud Function `onAttendanceWritten` derives events by diffing. Clients cannot write the subcollection at all |
| Attendance corrections | `onAttendanceCorrectionWritten` applies the approved resolution and writes the audit event |
| Shift-swap final exchange | Callable `approveSwap` re-validates and applies atomically. Rules **deny** any client write setting `status == managerApproved` |
| Account provisioning | Callable `createUserAccount`. `users` `create: if false` in rules |
| Broadcast sends | Callable `sendBroadcast`. All client writes to `broadcasts/{id}` denied |
| FCM token ownership | Callable `claimFcmToken` — clients cannot self-heal a drifted token |

Rules freeze the fields a client must not touch (review fields, privileged user
fields, non-decreasing `activityLog`). Self-approval is forbidden server-side, not
just hidden in the UI.

## Consequences

- Concurrent reviewers cannot lose a decision; the transaction rejects the loser.
- The audit trail is trustworthy enough to argue with, which is the entire point of
  having one.
- **Cost:** a Function deploy is now part of shipping several features, and a
  forgotten deploy shows up as a runtime permission error rather than a compile
  error. Deploy state is tracked in [CURRENT_STATE.md](../../CURRENT_STATE.md).
- **Cost:** more moving parts than a client write. Accepted only where forgery
  matters — ordinary content edits stay client-side.
