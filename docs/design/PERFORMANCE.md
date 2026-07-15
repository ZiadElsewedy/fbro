# Performance — baseline, backlog, and guardrails

> Consolidates the four `docs/performance/` audits (baseline · actions · Firestore
> query audit · render audit) from 2026-07-08 on `core/optimization`.
>
> **Status re-verified against the code 2026-07-15** — several items moved. The
> measurements themselves were a point-in-time snapshot and have been dropped; what
> survives is the **backlog**, the **rules**, and the **guardrails**.

Priority = *impact × user-visibility × risk-if-ignored* — **not** effort. Do not
batch these; each is independently shippable and must be re-measured before and
after.

---

## 🔴 Critical

### C1 · Unbounded Firestore reads/streams — add `.limit()` + cursor pagination

**Still open. Still the only scaling-critical item.** Verified 2026-07-15:
**0 `startAfter` cursors** anywhere in `lib/`, and only **7 `.limit(` calls** total.

Task/case/request/broadcast/schedule/template list streams read the **entire
collection** and re-emit the full set on every change. Firestore bills per doc read,
so an admin opening the task overview reads every task ever created — on every
re-emit.

This one item drives H1 (TTI), H2 (eager lists), H4 (main-thread sort), and H5
(resident memory). Fixing it makes several others cheap or moot.

- **Measure first:** Firebase console → Usage → reads per admin task-overview open.
  `flutter run --trace-startup` for TTI.
- **Scope:** datasource → repo interface → cubit → list widget, **feature by
  feature, tasks first**. Lean on the existing task tests. Replicate the
  notifications `.limit` pattern and **add the missing `startAfterDocument`
  cursor**.

---

## 🟠 High

| ID | Item | Status |
| --- | --- | --- |
| **H1** | TTI gated on `Future.wait` of home-critical reads (`main.dart`) — first task emission scales with collection size. Depends on C1; consider rendering the home shell before the stream resolves | Open |
| **H2** | Eager, non-virtualized lists on high-traffic screens (`task_feed_section`, `notifications_screen`, `my_tasks_screen`, `cases_screen`, `requests_screen`, `employee_home_screen`). Compounds with C1 | Open |
| **H3** | Wholesale rebuilds — large trees under one `BlocBuilder` over a freezed union. Targets: `employee_home_screen`, `my_schedule_screen`, `manager_schedule_view`, `task_details_screen`. `admin_dashboard_screen` already models the fix. **Do NOT blanket-convert every `BlocBuilder`** | Open |
| **H4** | Client-side sort/group on unbounded input. Largely **subsumed by C1** — bounded pages make it cheap. Keep the pure functions | Open |
| **H5** | `CACHE_SIZE_UNLIMITED` + unbounded resident lists. **Sequence after C1**, not before | Open |
| **H6** | `task_cubit.dart` god object — **grew from 1,264 → 1,533 LOC**. Candidate: extract `TaskTemplatesCubit` (templates only); leave the live-task lifecycle intact | Open, **worse** |
| **H7** | `task_action_sheets.dart` — was 2,452 LOC / 40 classes | ✅ **Done** — decomposed into `task_action_sheets/` (form · assign · review · pickers · checklist), barrel now 140 LOC |

---

## 🟡 Medium

| ID | Item | Status |
| --- | --- | --- |
| **M1** | Lazy-construct leaf singleton cubits — **17 eager** `static late final …Cubit` in `injection.dart` vs 3 lazy factories. Convert admin/comms/statistics leaves to lazy; keep home-critical eager. **Do not adopt a DI framework** | Open |
| **M2** | Persistent image cache — **13 raw `Image.network`**, no disk cache. Measure repeat-download bytes first | Open |
| **M3** | `count()` aggregation for branch-level statistics. Admin totals already use `count()`; extend to branch counts | Open |
| **M4** | **Monitor only** — unbounded embedded `activityLog`. Migrate to a `tasks/{id}/activity` subcollection (the proven cases/requests pattern) **only on evidence** of growth toward 1 MB. Do not pre-migrate | Monitor |
| **M5** | Consolidate date/time formatting | ✅ **Done** — `core/utils/app_date_formatter.dart` is the single source; 18 duplicated month arrays deleted across 21 files. `intl` still imported in **0** files |
| **M6** | Shared sheet/dialog wrappers + stray colours — **27 raw `showModalBottomSheet`**; adopt-or-delete `AppDialog`; sweep `Color(0x…)` literals into theme tokens | Open |
| **M7** | Decompose screens > 1000 LOC (also helps H3). **Preserve the premium UI exactly** | Open |
| **M8** | `setState` churn in `compose_broadcast_screen` (21 in one form) | Open |

---

## 🟢 Low

| ID | Item | Status |
| --- | --- | --- |
| **L1** | Remove dead `savedAudiences` — declared in `app_constants.dart`, **no reads, no rules**. Delete or implement | Open |
| **L2** | Instrument the home-warmup startup segment — `main.dart` times steps 1 & 5 but not step 6 (the data-dependent one). One `AppLog.time` line | Open |
| **L3** | Sweep raw `ScaffoldMessenger` into `AppSnackbar` — **5 stragglers** (was 3) | Open, drifting |

---

## Firestore query rules

Derived from the query audit; these are **rules, not observations**.

- **A filter + `orderBy` needs a composite index.** Adding one to a filtered
  branch/employee query broke loading and was reverted — those queries stay
  filter-only and are ordered in Dart (`sortTasksNewestFirst`). Don't move ordering
  back into the query without shipping the index.
- **The admin task query** uses `orderBy('createdAt', descending: true)` alone, which
  is index-free.
- **`weekly_schedules`** is addressed by deterministic id — no query at all. Prefer
  this pattern.
- **`notifications`** is the reference implementation: an ordered growing-window
  stream on the `recipientUid`+`createdAt` index. It is also the **only** place with
  a `.limit()` on a list stream — copy it, and add the cursor it lacks.
- **The shift-task stream** needs the `tasks` composite
  (`branchId`+`assignmentType`+`shift`) or it fails `failed-precondition`. Undeployed
  — see [CURRENT_STATE](../../CURRENT_STATE.md).
- **`selfDoc()` in rules** is a `get()` that Firestore caches per request — it bills
  once, not per rule evaluation. Rule helpers are not the cost centre.

## Guardrails — do NOT "optimize" these

These would look like wins and are explicitly out of scope. They protect intentional
or owner-frozen design.

- **The `LiveStatusBorder` orbit.** Motion is load-bearing, not decoration
  ([ADR-004](../decisions/ADR-004-monochrome-design.md)).
- **Employee My Week**, the schedule mobile UI, and **Admin Dashboard V2** — frozen.
  Improve in-language only.
- **Premium surfaces are not "over-drawn".** Calm comes from hierarchy, not
  reduction. Do not flatten `GlassContainer`, glows, or entrance motion in the name
  of frames.
- **Do not blanket-convert `BlocBuilder` → `BlocSelector`.** Only the heavy trees in
  H3.
- **Do not adopt a DI framework** for M1. Hand-wired DI is deliberate
  ([ADR-003](../decisions/ADR-003-clean-architecture.md)).
- **Do not pre-migrate `activityLog`** (M4) without evidence.
- **Pixels must not change** in any decomposition (H7-style work).

## Re-measuring

The 2026-07-08 baseline numbers are gone — they were a snapshot, and a stale number
is worse than none. Before working an item, take the "measure first" reading named
above, then re-take it after. `AppLog.time()` escalates anything over 1000ms to a
WARNING and is the cheapest instrument available.
