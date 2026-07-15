# Attendance — GPS clock in/out · corrections · admin board

> **Status:** code complete (P1–P3), **not deployed, not QA'd on device**. See
> [CURRENT_STATE](../../CURRENT_STATE.md).
>
> **Attendance minutes feed payroll.** That single fact drives every design choice
> below: the record is forgery-resistant, the audit trail is server-only, and the
> minute math has exactly one implementation.

## The shape

A record is one person, one shift, one day:

```
attendance/{uid}_{yyyyMMdd}_{shift}
  └── events/{eventId}     ← audit trail, Admin SDK ONLY
attendance_corrections/{id} ← Pending → Approved/Rejected
```

The **deterministic id** ([`domain/attendance_id.dart`](../../lib/features/attendance/domain/attendance_id.dart))
is the core trick: clock-in is idempotent and offline-safe by construction. A retry,
a double-tap, or a queued offline write all address the same document — there is no
path that creates two records for one shift, so no de-duplication logic exists
anywhere.

## Domain (pure, no Flutter/Firebase)

| File | Owns |
| --- | --- |
| `attendance_calculator.dart` | **The single source of worked / late / early / overtime minutes.** Nothing else computes them |
| `attendance_validation.dart` | `checkClockIn` (eligibility) · `checkClockOut` · `checkCorrection` |
| `attendance_gps.dart` | `gpsDistanceMeters` (Haversine) + `AttendanceVerification` |
| `attendance_board.dart` | `computeAttendanceBoard(roster, records, now, config)` — the admin board |
| `attendance_config.dart` | Grace / geofence / photo policy + the **module dark-switch** |
| `attendance_feed.dart` | `AttendanceFeed` — records + offline/pending-write metadata |
| `attendance_id.dart` | The deterministic id |
| `attendance_resolution.dart` · `attendance_location.dart` · `attendance_break.dart` | Value objects |
| `attendance_analytics.dart` | Derived stats |
| `attendance_service.dart` · `attendance_location_service.dart` | Config + location seams |

**`AttendanceCalculator` is the whole point.** Worked minutes are computed in one
place and persisted as a **snapshot only at clock-out or correction-approve** —
never recomputed on read, so a config change cannot retroactively alter a closed
shift's pay. If you need minute math, call the calculator. Do not inline it.

## Verification

Clock-in and clock-out carry **separate** verifications
(`clockInVerification` / `clockOutVerification`) — a single field could not express
"arrived on site, left early from elsewhere", which is exactly what matters.

`AttendanceVerification` snapshots the branch's radius and accuracy floor **at the
time of the punch**, so later editing a geofence never rewrites history — the same
principle as [ADR-006](../decisions/ADR-006-schedule-shift-plan-snapshots.md).

- `BranchGeofence` (lat · lng · radius · `minGpsAccuracy`) lives on the branch —
  [`branch/domain/branch_geofence.dart`](../../lib/features/branch/domain/branch_geofence.dart),
  edited via `BranchRepository.setGeofence`.
- Clock **times are server timestamps**. `effectiveClockIn` covers the live timer
  until the server value syncs back, so the UI never shows a client clock.
- `checkGpsFix` is the gate: it rejects no-shift · service-off · permission-denied ·
  low-accuracy · outside-radius.

> **Clock-out is never GPS-blocked.** It records verification and lets you leave.
> Trapping someone at work because their GPS drifted is not a feature.

## Corrections

A correction is an approval object, deliberately the same shape as a Request —
see [ADR-008](../decisions/ADR-008-requests-are-approvals.md). It reuses
`RequestStatus`.

```
employee files          → RequestCorrection
reviewer decides        → DecideCorrection   (computes the corrected snapshot
                                              via AttendanceCalculator)
server applies + audits → onAttendanceCorrectionWritten
```

**Self-approval is forbidden server-side**, not hidden in the UI.

## Server authority

The client writes **only the record**. The audit trail is derived by diffing, in a
Function — see [ADR-005](../decisions/ADR-005-server-authoritative-writes.md).

| Function | Does |
| --- | --- |
| `onAttendanceWritten` | Derives audit events by diffing the record |
| `onAttendanceCorrectionWritten` | Correction lifecycle → apply → audit → notify |
| `autoCloseAttendance` | Scheduled: never-clocked-out sessions → `pendingReview` |

Clients **cannot write `attendance/{id}/events` at all.** That is what makes
"nothing silently modifies attendance" an enforceable claim rather than a hope.

## Presentation

**Employee** — `attendance_screen.dart` (`/attendance`). `AttendanceCubit` drives the
entire surface from **one** realtime history stream, resolving today's shift through
the existing `ScheduleRepository` seam rather than re-deriving the roster. The feed
exposes today · session · loading · **syncing** · **offline** · clock-availability ·
validation errors.

Flow: Today's Shift → GPS-gated Clock In → live `HH:MM:SS` Working → Today's Summary.
A state-driven GPS card reads a live `previewLocation()`: Checking · At-branch ·
Outside · Permission · Off.

**Admin** — `admin_attendance_screen.dart` (`/admin/attendance`). The **schedule ×
attendance board**: `AttendanceAdminCubit` fuses the roster (`getSchedule` +
`employeesFor` + `ShiftWindow` + `GetUsersByBranch`) with live `watchBranchDay` +
`watchBranchPendingCorrections`. `computeAttendanceBoard` derives Not-started → Late
→ Absent by time, plus Working / Completed / On-leave / Needs-review. Branch picker ·
filterable KPIs · details sheet · corrections approve/reject · GPS-area shortcut.

**Geofence editor** — `branch/presentation/pages/branch_geofence_editor_screen.dart`.

> The admin cubit and screen are **branch-scoped**, so a future manager view is the
> same code pinned to one branch. Descoped for V1 — don't rebuild it.

## Removed — dormant extension points

**Breaks** were cut for the MVP. `AttendanceBreak`, the `breaks` field, and the
calculator's netting remain as extension points. `attendance_break_test.dart` still
covers them. Re-enabling is additive; do not delete these to "clean up".

## Tests

13 files: `attendance_calculator` · `attendance_gps` · `attendance_board` ·
`attendance_validation` · `attendance_id` · `attendance_entity` · `attendance_model` ·
`attendance_correction_model` · `attendance_correction_validation` ·
`attendance_status` · `attendance_analytics` · `attendance_break` ·
`attendance_cubit`.

## Before shipping

1. **Deploy** — `functions,firestore:rules,firestore:indexes`. Until then the audit
   trail is not written and corrections do not apply.
2. **QA on real hardware, both platforms.** A simulator cannot validate a geofence.
