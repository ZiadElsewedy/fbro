# FBRO — Project Context

> **Source of truth for the FBRO codebase.** Read this first, before opening any
> source file. It documents the architecture, dependency chains, where to make
> changes, and the conventions every contributor (human or AI) must follow.
>
> **Documentation set (treat as production source code, keep in sync):**
> - **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** (this file) — architecture, dependency maps, conventions.
> - **[CURRENT_STATE.md](CURRENT_STATE.md)** — live project status: what's done, pending, and what needs configuring.
> - **[CHANGELOG.md](CHANGELOG.md)** — chronological history of completed work.
>
> Keep all three current — see [Documentation Maintenance](#documentation-maintenance).

---

## 1. Overview

**FBRO** is a Flutter app built on Firebase for **role-based branch / shift
operations** (admin · manager · employee) — it is **not a social network**. It
currently ships a complete authentication system with an **account-approval
gate** (new sign-ups start *pending* and can't use the app until a
manager/admin approves them), a role system with role-based navigation + route
guards (Phase 1), a production-ready user profile module, account settings, a
**shift** foundation (Phase 2), a **task management workflow** (Phase 3–4):
managers/admins create + assign tasks, employees execute them (start → complete
→ submit, with notes + proof image), and managers/admins review (approve /
reject); an **admin management module** (Phase 5): branch CRUD, manager /
employee management, **admin-only** pending-user approval, and branch assignment;
and **operational dashboards + a Firebase Cloud Messaging foundation** (Phase 6):
live role-scoped statistics (admin / manager / employee) and device-token
registration for push; and a **weekly schedule + shift-swap system** (Phase 7):
managers build their branch's weekly roster (Day → Morning / Night → Employees),
employees view their week / today's team / manager and request shift swaps
(coworker approves → manager approves → schedule updates automatically), and
admins override any branch. All dressed in a custom monochrome (black & white)
design system.

> **DROP THE SHOP operations system** — focused on daily store operations
> (branches · shifts · tasks · employee activity · approvals). It is **not** a
> social app, ERP, or analytics engine.

> There is **no marketing / Welcome page** — FBRO is an internal tool, so the
> unauthenticated landing screen is **Login** (with Register one tap away).

> ⚠️ Some legacy social fields (follower / post counters) linger in the profile
> schema from an earlier iteration. They are **unused** and slated for removal —
> do not build on them.

### Tech stack

| Concern            | Choice                                                        |
| ------------------ | ------------------------------------------------------------ |
| State management   | `flutter_bloc` (Cubits only, no Blocs)                       |
| Navigation         | `go_router` (declarative, auth-aware redirects)             |
| Backend            | Firebase: Auth, Cloud Firestore, Storage, Google Sign-In    |
| Immutable models   | `freezed` + `freezed_annotation` (entities & states)        |
| Media              | `image_picker`                                              |
| Secure storage     | `flutter_secure_storage`                                    |
| Codegen            | `build_runner`, `freezed`, `json_serializable`             |
| Dart SDK           | `^3.12.1`                                                   |

### Architecture

The project follows **Clean Architecture** sliced by **feature**. Each feature
has three layers:

```
feature/
├── data/            # Firebase-facing implementation
│   ├── datasources/ # Talk to FirebaseAuth / Firestore / Storage; throw *Exception
│   ├── models/      # Serialization (toMap/fromMap, toEntity/fromEntity)
│   └── repositories/# Implement domain contracts; convert Exception → Failure
├── domain/          # Pure Dart, no Flutter/Firebase imports
│   ├── entities/    # freezed immutable business objects
│   ├── repositories/# Abstract contracts
│   └── usecases/    # One class per action, callable via .call()
└── presentation/    # UI
    ├── cubit/       # Cubit + freezed state
    ├── pages/       # Full screens (routed)
    ├── widgets/     # Feature-local widgets
    └── animations/  # Feature-local transitions
```

The dependency rule points **inward**: `presentation → domain ← data`. The
`domain` layer depends on nothing; `data` and `presentation` depend on `domain`.

### Directory map (`lib/`)

```
lib/
├── main.dart                 # Bootstraps Firebase, DI, router, MaterialApp.router
├── firebase_options.dart     # FlutterFire generated config
├── core/
│   ├── constants/            # app_constants.dart (appName, collection names)
│   ├── di/                   # injection.dart — AppDependencies service locator
│   ├── enums/                # user_role · approval_status · task_* · notification_type · schedule_day · schedule_shift · swap_status
│   ├── services/             # notification_service.dart (FCM foundation, Phase 6)
│   ├── errors/               # exceptions.dart (data layer) / failures.dart (domain)
│   ├── routes/               # app_router.dart (role dispatch + guards), route_names.dart
│   ├── theme/                # app_colors / typography / spacing / radius / app_theme
│   └── widgets/              # app_snackbar, drop_logo, skeleton, role_scaffold, role_placeholder
└── features/
    ├── auth/                 # Sign-in/up, phone OTP, Google, email verify, password, role, approval
    ├── profile/              # View + edit profile, image uploads, username checks
    ├── shift/                # Shift data/domain (entity·model·repository·datasource) + role shift screens (Phase 2)
    ├── task/                 # Task feature — data/domain + use cases + TaskCubit + functional role screens (Phase 3–4)
    ├── branch/               # Branch feature — data/domain + BranchCubit + branch management (Phase 5)
    ├── admin/                # Admin module — user-admin data/domain + AdminUsersCubit + dashboard/managers/employees/approvals (Phase 5)
    ├── statistics/           # Statistics feature — entity/model/repo/datasource + StatisticsCubit; powers all 3 dashboards (Phase 6, +Phase 7 schedule figures)
    ├── schedule/             # Weekly schedule + shift swaps (Phase 7) — full slice + ScheduleCubit & ShiftSwapCubit; weekly_schedules + shift_swaps
    ├── manager/              # ManagerShell + ManagerHomeScreen (live branch dashboard, Phase 6)
    ├── employee/             # EmployeeShell + EmployeeHomeScreen (live own dashboard, Phase 6)
    └── settings/             # Settings + change password (presentation only)
```

> `settings` is presentation-only (reuses `auth`/`profile` cubits). Each user is
> dispatched to exactly one role shell after login; **all three role home
> dashboards are now live** (Phase 6) — they read role-scoped counts from the
> shared `StatisticsCubit` (admin: global · manager: own branch · employee: own).
>
> The `task` (Phase 3–4), `branch` + `admin` (Phase 5), `statistics` (Phase 6)
> and `schedule` (Phase 7) features are full vertical slices. The `shift` feature
> (Phase 2) owns only data + domain with **placeholder screens** (no `ShiftCubit`)
> and is **superseded** by `schedule` for production scheduling.
>
> **Cubit→repository convention varies by feature:** `auth`/`profile`/`task`
> cubits go through **use cases**; `branch`/`admin`/`statistics`/`schedule` cubits
> call their **repositories directly** (no use-case layer) — a deliberate scope
> choice (the `schedule` cubits reuse the auth `GetUsersByBranch` use case for the
> member/assignee list). All app-wide cubits are provided in `main.dart`
> (`auth`/`profile`/`task`/`branch`/`adminUsers`/`statistics`/`schedule`/`shiftSwap`).

---

## 2. File Dependency Map

The composition root is `main.dart` → `AppDependencies.init()`
([core/di/injection.dart](lib/core/di/injection.dart)), which wires every
datasource, repository, use case, and cubit by hand (no DI package). The two
app-wide cubits (`AuthCubit`, `ProfileCubit`) are provided at the root via
`MultiBlocProvider` in [main.dart](lib/main.dart).

### Authentication chain

```
LoginPage / RegisterPage / PhoneOtpPage                  (presentation/pages)
EmailVerificationPage / PendingApprovalPage
        ↓  context.read<AuthCubit>()
AuthCubit                                                (presentation/cubit)
        ↓  calls one use case per action
SignInWithEmail · RegisterWithEmail · SignInWithGoogle
VerifyPhoneNumber · SignInWithOtp · ForgotPassword
SendEmailVerification · CheckEmailVerified · ChangePassword
DeleteAccount · SaveUser · GetUser · SignOut             (domain/usecases)
        ↓  every use case wraps one AuthRepository method
AuthRepository (abstract)                                (domain/repositories)
        ↓
AuthRepositoryImpl                                       (data/repositories)
        ↓                          ↓
AuthRemoteDataSource          UserRemoteDataSource        (data/datasources)
  (FirebaseAuth, Google)        (Firestore users/{uid})
        ↓                          ↓
   FirebaseAuth               Cloud Firestore
```

- `AuthRepositoryImpl` holds **two** datasources: `AuthRemoteDataSource`
  (Firebase Auth + Google) and `UserRemoteDataSource` (the `users/{uid}`
  Firestore document). It maps `UserModel ⇄ UserEntity` at the boundary.
- Datasources throw `AuthException`; the repository catches and rethrows as
  `AuthFailure`; the cubit catches `AuthFailure` and emits `AuthState.error`.

### Routing & session chain

```
AuthCubit.stream
        ↓
_AuthStateNotifier (ChangeNotifier)   ← refreshListenable
        ↓
GoRouter.redirect                     ← auth guard + APPROVAL gate + ROLE guard
        ↓
splash → login/register/... → pending-approval → role shell  (/ employee · /admin · /manager)
```

`createRouter(AuthCubit)` ([core/routes/app_router.dart](lib/core/routes/app_router.dart))
re-evaluates its `redirect` whenever `AuthCubit` emits, routing unauthenticated
users to the auth flow (landing = **Login**), `awaitingEmailVerification` users
to the verification page, and authenticated users onward. Before role dispatch,
the redirect applies the **approval gate**: an authenticated user whose account
is not approved/active (`user.hasAppAccess == false`) is confined to the
**Pending Approval** screen (`/pending-approval`) — sign-out is the only way off
it. Approved users go to **their role shell** (`RouteNames.homeForRole(user.role)`
→ `/` employee, `/admin`, `/manager`). The redirect also **role-guards** every
navigation: admin areas are admin-only, manager areas admit manager + admin
(**admin ⊇ manager**), the employee home (`/`) is employee-only; anyone entering
an area that isn't theirs is bounced to their own home. `/profile` & `/settings`
are shared across roles. `SplashPage` calls `AuthCubit.restoreSession()` once on
cold start and dispatches by approval + role. Because Firebase sign-ins don't
know the role/approval, `AuthCubit` re-reads the Firestore user after
email/Google/OTP sign-in (and on `refreshUser()`, which the Pending Approval
screen polls) so the emitted `authenticated` state carries the authoritative
role/branch/approval.

### Profile chain

```
ProfilePage / EditProfilePage         (presentation/pages)
        ↓  context.read<ProfileCubit>()
ProfileCubit                          (presentation/cubit)
        ↓
GetProfile · UpdateProfile · UploadProfileImage
UploadCoverImage · CheckUsername      (domain/usecases)
        ↓
ProfileRepository (abstract)          (domain/repositories)
        ↓
ProfileRepositoryImpl                 (data/repositories)
        ↓                          ↓
ProfileRemoteDataSource         AuthRemoteDataSource (re-used)
  (Firestore + Storage)           (keeps Auth displayName/photoURL in sync)
        ↓                          ↓
Firestore users/{uid}          FirebaseAuth
+ Storage users/{uid}/avatar.jpg, cover.jpg
```

- `ProfileRepositoryImpl` also depends on `AuthRemoteDataSource` to mirror
  `fullName`/`profileImage` into the Firebase Auth profile (best-effort, never
  fatal) so Home/session stay current without re-login.
- The Firestore document at `users/{uid}` is **shared** between `auth`
  (`UserModel`) and `profile` (`ProfileModel`). `ProfileModel` is back-compat:
  it falls back to the legacy `displayName`/`photoUrl` keys, and `editMap`
  keeps those legacy keys in sync on write.

### Shift chain (Phase 2 — foundation only)

```
ShiftManagementScreen / BranchShiftScreen / MyShiftScreen   (presentation/pages)
  (functional placeholders — NO ShiftCubit/use cases yet)
                              ⋮  (next phase wires a ShiftCubit + use cases here)
ShiftRepository (abstract)                                   (domain/repositories)
        ↓   AppDependencies.shiftRepository  (composed in injection.dart)
ShiftRepositoryImpl                                          (data/repositories)
        ↓
ShiftRemoteDataSource                                        (data/datasources)
        ↓
Cloud Firestore  shifts/{shiftId}
```

- The shift **data + domain** layers are complete (`ShiftEntity`, `ShiftModel`,
  `ShiftRepository(+Impl)`, `ShiftRemoteDataSource(+Impl)`) and exposed via
  `AppDependencies.shiftRepository`. Datasources throw `ServerException`; the
  repository converts to `ServerFailure` and maps `ShiftModel → ShiftEntity`.
- **No presentation logic yet** — the three role screens are placeholders. The
  branch/role access model is enforced server-side in `firestore.rules`
  (`shifts/{shiftId}`): admin = all branches, manager = own branch, employee =
  their own assigned shift (read-only). The user's `assignedShift` (Phase 1)
  references the assigned `shiftId`; the shift's `employeeId` references back.

### Task chain (Phase 3–4 — full vertical slice)

```
MyTasksScreen (employee)                ManagerTasksView          (presentation/pages + widgets)
+ _CompleteSheet (notes+proof)          ← BranchTasksScreen (manager) / TaskManagementScreen (admin)
+ TaskCard / task_action_sheets (create·assign·review)
        ↓  context.read<TaskCubit>()      (provided app-wide in main.dart)
TaskCubit  + TaskState                                        (presentation/cubit)
        ↓  one use case per action
GetAllTasks · GetTasksByBranch · GetEmployeeTasks · CreateTask
UpdateTask · DeleteTask · AssignTask · ChangeTaskStatus
ReviewTask · UploadTaskProof            (domain/usecases)
GetUsersByBranch (auth use case — assignee picker)
        ↓
TaskRepository (abstract)                                    (domain/repositories)
        ↓   AppDependencies.taskRepository  (composed in injection.dart)
TaskRepositoryImpl                                           (data/repositories)
        ↓
TaskRemoteDataSource                                         (data/datasources)
        ↓                          ↓
Cloud Firestore  tasks/{taskId}    Firebase Storage  tasks/{taskId}/proof.jpg
```

- Full vertical slice: `TaskCubit` (app-wide, provided in `main.dart`) injects
  **one use case per action**; each wraps a `TaskRepository` method. Datasource
  throws `ServerException`; repo → `ServerFailure`; maps `TaskModel → TaskEntity`.
- **Core workflow:** a manager/admin creates + assigns a task (assignee picked
  from branch employees via the auth `GetUsersByBranch`); the employee drives it
  `pending → started → completed (+notes/proof) → waitingReview`; a manager/admin
  reviews → `approved` | `rejected` (writing the audit fields). `TaskType`
  (daily/special), `TaskStatus` and `TaskPriority` are enums in `core/enums`.
- **Status transitions are validated in `TaskCubit._canTransition`** (invalid
  moves are blocked client-side and surfaced as an error snackbar); WHO may write
  is enforced in `firestore.rules` (`tasks/{taskId}`): admin all branches,
  manager own branch, employee own assigned tasks with **limited writes** (may
  advance status / add notes / proof but may not reassign, change branch, or
  approve/reject). Proof images upload to Storage `tasks/{taskId}/proof.jpg`.
- The `TaskCubit` loads the list **by role** (admin: all · manager: own branch ·
  employee: own) and keeps it visible during mutations (`loaded(tasks, busy)`),
  re-emitting the previous list on error so the UI never flickers/loses data.

### Admin module chain (Phase 5)

```
AdminShell ▸ AdminDashboardScreen (reports + nav)            (admin/presentation/pages)
  ├─ BranchManagementScreen ────────────┐
  ├─ ManagerManagementScreen            │  (push /admin/* routes)
  ├─ EmployeeManagementScreen           │
  └─ PendingApprovalsScreen             │
        ↓ context.read<…Cubit>()  (all provided app-wide in main.dart)
BranchCubit          AdminUsersCubit          StatisticsCubit (shared, Phase 6)
        ↓                  ↓                         ↓
BranchRepository     UserAdminRepository      StatisticsRepository
        ↓                  ↓                         ↓
BranchRepositoryImpl UserAdminRepositoryImpl  StatisticsRepositoryImpl
        ↓                  ↓                         ↓
BranchRemoteDataSource  UserAdminRemoteDataSource  StatisticsRemoteDataSource
        ↓                  ↓                         ↓
Firestore branches/{id}   Firestore users/{uid}     aggregates users/tasks/shifts/branches
```

- **Branch** is a full vertical slice (`BranchEntity`/`BranchModel`/
  `BranchRepository(+Impl)`/`BranchRemoteDataSource`). "Delete" is a **soft
  delete** (`deletedAt` set; excluded from the default list). Admin-only writes
  per `firestore.rules` (`branches/{branchId}`); any signed-in user may read.
- **`admin`** owns user administration over `users/{uid}` via its own
  `UserAdminRemoteDataSource` (reusing the auth `UserModel`/`UserEntity`) — a
  third datasource on `users` alongside `auth` and `profile`. `AdminUsersCubit`
  loads a slice by `AdminUserFilter` (pending / managers / employees) and
  performs approve/reject, (de)activate, change-branch, change-role, and
  **promote-to-manager**. **Account approval is admin-only** (Phase 6) — managers
  no longer write user docs.
- **Manager creation:** with no Cloud Functions/Admin SDK (client can't create
  Auth accounts without signing the admin out), a "manager" is an existing
  approved user **promoted** to `role: manager` (then assigned a branch) — there
  is no admin-creates-account flow.

### Statistics + notifications (Phase 6)

- **`statistics`** is a full vertical slice (`StatisticsEntity`/`StatisticsModel`/
  `StatisticsRepository(+Impl)`/`StatisticsRemoteDataSource`) + `StatisticsCubit`.
  `StatisticsCubit.load(user)` dispatches by role to `adminStats()` (global) /
  `managerStats(branchId)` / `employeeStats(uid)`. The datasource fetches the
  **branch-scoped** collections once (single-field `where` queries — automatic
  indexes) and **counts client-side** (status/type/today breakdowns), avoiding
  composite indexes; `count()` aggregate queries are a future optimization.
  All three role dashboards (`AdminDashboardScreen`, `ManagerHomeScreen`,
  `EmployeeHomeScreen`) read it via the shared `StatGrid` widget.
- **Notifications** (`core/services/notification_service.dart`, FCM): requests
  permission, persists the device `fcmToken` on `users/{uid}` (best-effort), and
  surfaces foreground pushes as in-app snackbars (wired in `main.dart` via a
  `scaffoldMessengerKey` + an `AuthCubit` listener that registers/forgets the
  token on auth changes). `core/enums/notification_type.dart` is the event
  contract. **Sending** the events needs a server trigger (out of scope — no
  Cloud Functions / Node.js); this is the client foundation only. No history /
  inbox / chat.

### Schedule chain (Phase 7 — full vertical slice)

```
BranchScheduleScreen (manager, tabs)   ScheduleManagementScreen (admin)   MyScheduleScreen (employee, tabs)
  └─ ManagerScheduleView (shared editor) ─┘   + SwapListView / showSwapRequestSheet      (presentation/pages + widgets)
        ↓  context.read<ScheduleCubit>() / context.read<ShiftSwapCubit>()  (both app-wide in main.dart)
ScheduleCubit (+ ScheduleState)        ShiftSwapCubit (+ ShiftSwapState)              (presentation/cubit)
  load/create/assign/remove,             loadMine/loadBranch, requestSwap,
  week + branch navigation               coworkerApprove/reject/managerApprove
        ↓  (repo-direct; ScheduleCubit also uses auth GetUsersByBranch for members)
ScheduleRepository (abstract)                                                          (domain/repositories)
        ↓   AppDependencies.scheduleCubit / shiftSwapCubit  (composed in injection.dart)
ScheduleRepositoryImpl                                                                 (data/repositories)
        ↓                          (managerApproveSwap writes the swap AND the schedule)
ScheduleRemoteDataSource                                                              (data/datasources)
        ↓                          ↓
Cloud Firestore  weekly_schedules/{branchId_yyyy-MM-dd}    Cloud Firestore  shift_swaps/{id}
```

- **Weekly schedule** = one doc per (branch, week) at a deterministic id
  (`ScheduleWeek.docId` = `<branchId>_<yyyy-MM-dd>` of the week's Sunday), so a
  week is read directly without a query. The roster is a nested map
  `assignments.<day>.<shift> = [uid…]`; assign/remove use Firestore nested
  `arrayUnion`/`arrayRemove` (no read-modify-write). `ScheduleDay` (Sun→Sat),
  `ScheduleShift` (morning/night) and `SwapStatus` are enums in `core/enums`.
- **Shift swap** = a single-slot handover: the requester gives up one (week, day,
  shift) cell to a target coworker. `pending → employeeApproved → managerApproved`
  (or `rejected`); on `managerApproveSwap` the repo flips the status **and**
  rewrites the schedule slot (requester removed, target added). The flow order is
  validated in `ShiftSwapCubit`; `firestore.rules` enforce who may write.
- **Dashboards reuse this data:** the `statistics` datasource reads
  `weekly_schedules` for the current week to compute the employee current/upcoming
  shift, the manager scheduled/morning/night-today counts, and the admin schedule
  coverage (`ScheduleWeek` + `ScheduleDay` imported into statistics).

### Shared (core) dependencies

Every layer may import `core/errors` (failures/exceptions). Presentation
imports `core/theme`, `core/widgets`, `core/routes`. Data imports
`core/errors` and `core/constants`. `domain` imports only `core/errors`.

---

## 3. Modification Map

> **"When changing X, edit these files."** Use this to act without scanning.

| You want to change…                       | Edit here                                                                 |
| ----------------------------------------- | ------------------------------------------------------------------------ |
| **Auth screens / UI**                     | `lib/features/auth/presentation/pages/` + `.../widgets/`                  |
| **Auth logic / flow / state**             | `lib/features/auth/presentation/cubit/auth_cubit.dart` + `auth_state.dart` |
| **A new auth action**                     | add `domain/usecases/`, a method on `AuthRepository(+Impl)`, a datasource method, wire in `auth_cubit.dart` **and** `core/di/injection.dart` |
| **Firebase Auth / Google calls**          | `lib/features/auth/data/datasources/auth_remote_datasource.dart`         |
| **User Firestore document (auth side)**   | `lib/features/auth/data/datasources/user_remote_datasource.dart` + `data/models/user_model.dart` |
| **Profile screens / UI**                  | `lib/features/profile/presentation/pages/` + `.../widgets/`              |
| **Profile logic / state**                 | `lib/features/profile/presentation/cubit/profile_cubit.dart` + `profile_state.dart` |
| **Profile reads/writes / image uploads**  | `lib/features/profile/data/datasources/profile_remote_datasource.dart`   |
| **Profile schema / serialization**        | `lib/features/profile/domain/entities/profile_entity.dart` + `data/models/profile_model.dart` (then run codegen) |
| **Auth ⇄ Profile sync (name/avatar)**     | `lib/features/profile/data/repositories/profile_repository_impl.dart`    |
| **Shift schema / serialization**          | `lib/features/shift/domain/entities/shift_entity.dart` + `data/models/shift_model.dart` (then run codegen) |
| **Shift reads/writes (Firestore)**        | `lib/features/shift/data/datasources/shift_remote_datasource.dart`       |
| **Shift repository contract / impl**      | `lib/features/shift/domain/repositories/shift_repository.dart` + `data/repositories/shift_repository_impl.dart` (wired in `core/di/injection.dart`) |
| **Shift screens (admin/manager/employee)**| `lib/features/shift/presentation/pages/` (`shift_management_screen` · `branch_shift_screen` · `my_shift_screen`) |
| **Shift routes / role entry point**       | `lib/core/routes/route_names.dart` (`adminShifts`/`managerShifts`/`myShift` + `shiftsForRole`) + `app_router.dart` + `role_scaffold.dart` (Shifts icon) |
| **Task type/status/priority values**      | `lib/core/enums/task_type.dart` · `task_status.dart` · `task_priority.dart` |
| **Task schema / serialization (incl. audit fields)** | `lib/features/task/domain/entities/task_entity.dart` + `data/models/task_model.dart` (then run codegen) |
| **Task reads/writes / review / proof upload** | `lib/features/task/data/datasources/task_remote_datasource.dart` (Firestore + Storage `tasks/{id}/proof.jpg`) |
| **Task repository contract / impl**       | `lib/features/task/domain/repositories/task_repository.dart` + `data/repositories/task_repository_impl.dart` (wired in `core/di/injection.dart`) |
| **Task workflow logic / status transitions / state** | `lib/features/task/presentation/cubit/task_cubit.dart` (`_canTransition`) + `task_state.dart` |
| **A new task action**                     | add `domain/usecases/`, a `TaskRepository(+Impl)` method, a datasource method, wire in `task_cubit.dart` **and** `core/di/injection.dart` |
| **Task screens (admin/manager/employee)** | `lib/features/task/presentation/pages/` (`my_tasks_screen` employee · `branch_tasks_screen`/`task_management_screen` → shared `widgets/manager_tasks_view.dart`) |
| **Task UI actions (create/assign/review/complete) + card** | `lib/features/task/presentation/widgets/` (`task_action_sheets.dart`, `task_card.dart`, `task_empty_state.dart`) |
| **Assignee picker (branch employees)**    | `AuthRepository.getUsersByBranch` + `auth/domain/usecases/get_users_by_branch.dart` → `TaskCubit.branchEmployees` |
| **Task routes / role entry point**        | `lib/core/routes/route_names.dart` (`adminTasks`/`managerTasks`/`myTasks` + `tasksForRole`) + `app_router.dart` + `role_scaffold.dart` (Tasks icon) |
| **Branch schema / data**                  | `lib/features/branch/domain/entities/branch_entity.dart` + `data/models/branch_model.dart` + `data/datasources/branch_remote_datasource.dart` (then run codegen) |
| **Branch logic / repo / UI**              | `lib/features/branch/domain/repositories/branch_repository.dart` (+impl) · `presentation/cubit/branch_cubit.dart` · `presentation/pages/branch_management_screen.dart` · `widgets/branch_form_sheet.dart` |
| **Admin user administration (data)**      | `lib/features/admin/data/datasources/user_admin_remote_datasource.dart` + `domain/repositories/user_admin_repository.dart` (+impl) — operates on `users/{uid}`, reuses auth `UserModel` |
| **Admin user lists / actions (pending·managers·employees)** | `lib/features/admin/presentation/cubit/admin_users_cubit.dart` (`AdminUserFilter`) + `presentation/pages/{manager,employee}_management_screen.dart` · `pending_approvals_screen.dart` · `widgets/admin_user_card.dart` · `admin_user_sheets.dart` · `admin_users_list_view.dart` |
| **Operational stats / dashboard data**    | `lib/features/statistics/` (entity·model·repository·datasource + `StatisticsCubit`) — branch-scoped counts for all 3 dashboards; **schedule figures (Phase 7)** read `weekly_schedules` in the statistics datasource |
| **Weekly schedule schema / serialization**| `lib/features/schedule/domain/entities/weekly_schedule_entity.dart` + `data/models/weekly_schedule_model.dart` (then run codegen); week math in `domain/schedule_week.dart`; day/shift/swap enums in `lib/core/enums/schedule_day.dart` · `schedule_shift.dart` · `swap_status.dart` |
| **Schedule/swap reads/writes (Firestore)**| `lib/features/schedule/data/datasources/schedule_remote_datasource.dart` (`weekly_schedules` + `shift_swaps`) + `data/repositories/schedule_repository_impl.dart` (+ `domain/repositories/schedule_repository.dart`) |
| **Schedule logic / week+branch nav / assign-remove** | `lib/features/schedule/presentation/cubit/schedule_cubit.dart` + `schedule_state.dart` |
| **Shift-swap workflow / status transitions** | `lib/features/schedule/presentation/cubit/shift_swap_cubit.dart` + `shift_swap_state.dart` |
| **Schedule screens (admin/manager/employee)** | `lib/features/schedule/presentation/pages/` (`schedule_management_screen` admin · `branch_schedule_screen` manager · `my_schedule_screen` employee) → shared `widgets/manager_schedule_view.dart` · `swap_view.dart` · `schedule_helpers.dart` |
| **Schedule routes / role entry point**    | `lib/core/routes/route_names.dart` (`adminSchedule`/`managerSchedule`/`mySchedule` + `scheduleForRole`) + `app_router.dart` + `role_scaffold.dart` (calendar icon → Schedule) |
| **Schedule/swap DI wiring**               | `lib/core/di/injection.dart` (`scheduleCubit`/`shiftSwapCubit`) + `main.dart` providers |
| **Dashboard screens (live stats)**        | `lib/features/admin/presentation/pages/admin_dashboard_screen.dart` · `manager/.../manager_home_screen.dart` · `employee/.../employee_home_screen.dart` (+ shared `statistics/presentation/widgets/stat_grid.dart`) |
| **Push notifications (FCM)**              | `lib/core/services/notification_service.dart` + `core/enums/notification_type.dart`; wired in `main.dart` (background handler, init, token register on auth, foreground snackbar) |
| **Admin routes**                          | `lib/core/routes/route_names.dart` (`adminBranches`/`adminManagers`/`adminEmployees`/`adminApprovals`) + `app_router.dart` (under `_isAdminArea`) |
| **Admin/branch DI wiring**                | `lib/core/di/injection.dart` (`branchCubit`/`adminUsersCubit`/`adminStatsCubit`) + `main.dart` providers |
| **A role's home/dashboard screen**        | `lib/features/{employee,manager,admin}/presentation/pages/`              |
| **Shared role chrome / placeholder**      | `lib/core/widgets/role_scaffold.dart` · `role_placeholder.dart`         |
| **Roles enum / role values**              | `lib/core/enums/user_role.dart`                                         |
| **Approval status enum / values**         | `lib/core/enums/approval_status.dart` (pending/approved/rejected)        |
| **Role + approval on the user model / seeding** | `lib/features/auth/data/models/user_model.dart` + `data/datasources/user_remote_datasource.dart` (seed-once block: pending + inactive employee) |
| **Approval gate (pending → dashboard)**   | `lib/core/routes/app_router.dart` (redirect `hasAppAccess` check) + `UserEntity.hasAppAccess`/`isApproved` + `pending_approval_page.dart` + `AuthCubit.refreshUser` |
| **Role-based redirect / route guards**    | `lib/core/routes/app_router.dart` (redirect + `_isAdminArea`/`_isManagerArea`) + `RouteNames.homeForRole` |
| **Settings / change password UI**         | `lib/features/settings/presentation/pages/`                              |
| **Routes / navigation guards**            | `lib/core/routes/app_router.dart` + `route_names.dart`                    |
| **Firestore / Storage security rules**    | `firestore.rules` · `storage.rules` (registered in `firebase.json`)     |
| **Dependency injection / wiring**         | `lib/core/di/injection.dart`                                             |
| **Colors / typography / spacing / radius**| `lib/core/theme/app_colors.dart` · `app_typography.dart` · `app_spacing.dart` · `app_radius.dart` |
| **Global ThemeData (inputs, buttons…)**   | `lib/core/theme/app_theme.dart`                                          |
| **Cross-feature widgets (snackbar, logo, skeleton)** | `lib/core/widgets/`                                            |
| **App brand / logo (the DROP wordmark)**  | artwork `assets/drop_logo.png` (registered in `pubspec.yaml`) rendered by `lib/core/widgets/drop_logo.dart` (`DropLogo`, white-tinted via `srcIn`, sized by `height`) — used on splash, login, register, pending-approval; app name in `main.dart` (`title`) + `AppConstants.appName` |
| **Error / failure types**                 | `lib/core/errors/exceptions.dart` (data) · `failures.dart` (domain)      |
| **Constants (collection names, app name)**| `lib/core/constants/app_constants.dart`                                  |
| **App bootstrap / providers**             | `lib/main.dart`                                                          |
| **Firebase platform config**              | `lib/firebase_options.dart`, `firebase.json`, platform folders           |

---

## 4. Project Conventions

Patterns below are established across the codebase and **must be reused**.

### Folder & file conventions
- Feature-first: `features/<feature>/{data,domain,presentation}`.
- Three layers per feature; never let `domain` import Flutter or Firebase.
- Presentation-only features (`home`, `settings`) reuse other features' cubits.
- File names are `snake_case.dart`; one primary class per file.
- Generated files are `*.freezed.dart` / `*.g.dart` and live beside their source.

### Naming conventions
- Classes `PascalCase`; members/vars `camelCase`; constants `camelCase`.
- Datasources: `XRemoteDataSource` (abstract) + `XRemoteDataSourceImpl`.
- Repositories: `XRepository` (abstract) + `XRepositoryImpl`.
- Use cases: a **verb phrase** class (`SignInWithEmail`, `UploadCoverImage`).
- Cubits: `XCubit`; states: `XState`; pages: `XPage`; entities: `XEntity`.
- Private dependency fields are underscore-prefixed (`_repository`).

### Use case conventions
- One class = one action. Stateless, holds only its repository.
- `const` constructor taking the repository positionally.
- Exposes a single `call(...)` method (invoked as `useCase(...)`), delegating
  straight to the repository. Use named params when there's more than one.
  See [sign_in_with_email.dart](lib/features/auth/domain/usecases/sign_in_with_email.dart).

### Repository conventions
- Abstract contract in `domain/repositories`; impl in `data/repositories`.
- Impl depends on datasource(s) only — never on Firebase directly.
- Wrap every datasource call in `try/catch`, converting `*Exception` →
  `*Failure` (`AuthException` → `AuthFailure`).
- Convert `Model → Entity` (`model.toEntity()`) before returning; the rest of
  the app sees entities only.

### Datasource conventions
- Abstract + `Impl`; the `Impl` receives the Firebase SDK instance via
  constructor (injected in `injection.dart`).
- Catch `FirebaseException` and throw a domain-agnostic `*Exception` with a
  user-readable message.
- Firestore collection: `users/{uid}`. Storage paths: fixed
  `users/{uid}/avatar.jpg` and `users/{uid}/cover.jpg` (overwrite-in-place).

### Cubit conventions
- Extend `Cubit<XState>`; inject use cases (and the repository when stream
  access / non-action calls are needed) via a named-param constructor.
- Start in `XState.initial()`.
- Guard against concurrent/double submits with a `_busy` getter that inspects
  the current state (`if (_busy) return;`) — see `AuthCubit`.
- Emit a **loading** state, `await` the use case, then emit success or error.
- Carry an action discriminator on loading (`AuthState.loading(AuthAction.x)`)
  so the UI spins **only** the button that triggered the request.
- Catch `AuthFailure` → emit `XState.error(e.message)`; catch-all → emit a
  generic friendly message.
- For optimistic flows, keep the last-known entity visible across transient
  states (e.g. `ProfileState.saving(profile)`), and on error re-emit
  `loaded(previous)` so the UI never flickers or loses data.
- Cancel stream subscriptions in `close()`.

### State conventions
- States are `freezed` unions (`@freezed class XState with _$XState`).
- One factory per distinct UI state; success/transient states carry their data.
- Read state in the UI/router with `maybeWhen` / `mapOrNull` / `maybeMap`.
- After editing a state or entity, **run codegen** (see below).

### Entity / model conventions
- Entities are `freezed`, in `domain/entities`, with `@Default(...)` for
  non-null optionals. Add computed getters via a private `const X._()`
  constructor (see `ProfileEntity.displayName`).
- Models live in `data/models` and own all (de)serialization:
  `fromMap`/`toMap`, `fromEntity`/`toEntity`, `fromFirebaseUser`.
- Models bridge Firestore types (`Timestamp ⇄ DateTime`) and tolerate missing
  keys with defaults. Keep legacy keys in sync on write when schemas overlap.

### Widget conventions
- Cross-feature reusable widgets → `core/widgets`. Feature-local →
  `features/<f>/presentation/widgets`.
- Buttons use `AppButton` (variants: `primary` / `secondary` / `ghost`) with a
  built-in `isLoading` spinner — don't hand-roll buttons.
- User feedback uses `AppSnackbar.success/error`, never raw `ScaffoldMessenger`.
- Loading placeholders use `Skeleton`.
- Pull spacing/radius from `AppSpacing` / `AppRadius`; never hardcode.

### Theme conventions
- The app is **dark-mode only** today (`themeMode: ThemeMode.dark`); a `light`
  theme exists in `AppTheme` but is not wired up.
- **Strictly monochrome**: `AppColors.primary` is white; the only chromatic
  colors are the semantic `success` / `error` / `warning`, used for status only.
- Never use raw `Color(...)` or `TextStyle(...)` in features — reference
  `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`.
- Global component styling (inputs, buttons, app bar) lives in `AppTheme`; tune
  it there rather than per-widget.

### Roles & access model
- The access role is the `UserRole` enum (`core/enums/user_role.dart`), stored
  as a string in `users/{uid}.role`. Parse stored strings with
  `UserRole.fromString`, which **defaults unknown/missing to `employee`** so a
  bad document can never escalate privileges. Use the `isAdmin`/`isManager`/
  `isEmployee`/`isGlobal` getters rather than re-comparing enum values.
- **Access model (single source of truth, mirrored in `firestore.rules`):**
  - **admin** — *global*. Not restricted by `branchId`; can do everything a
    manager can, across every branch (**admin ⊇ manager**).
  - **manager** — belongs to exactly one branch; limited to data where
    `resource.branchId == manager.branchId`.
  - **employee** — limited to their own assigned data and profile.
- **Account approval (activation gate).** A new sign-up is **not** usable: it is
  seeded as a `pending` + `isActive: false` employee with no branch and is
  confined to the **Pending Approval** screen. A manager/admin approves it
  (`approvalStatus → approved`, `isActive → true`, assigns role + branch); only
  then does it reach a role shell. Gate logic = `UserEntity.hasAppAccess`
  (`isApproved && isActive`), checked in the router redirect **before** role
  dispatch. `ApprovalStatus.fromString` defaults missing → `approved` so legacy
  docs aren't locked out; **new** accounts are explicitly seeded `pending`.
  **Approval is ADMIN-ONLY (Phase 6)** — managers manage branch operations
  (shifts/tasks), not user accounts; only an admin approves/rejects, assigns
  role/branch, and (de)activates (mirrored in `firestore.rules`). The **first
  admin** must be bootstrapped out of band (Firebase console).
- **Privileged fields** (`role`, `branchId`, `isActive`, `assignedShift`,
  `approvalStatus`) are seeded **once** in the `saveUser` first-creation block
  and are kept **out of `UserModel.toMap()`**, because `saveUser` merges on every
  login — including them would reset an admin's role / re-pend an approved
  account on the next sign-in. Self cannot change these (enforced by
  `firestore.rules`); only an **admin** may. (Self may still write
  non-privileged fields like `fcmToken`.)
- **Enforcement** lives in `firestore.rules`: reusable `isAdmin()`/`isManager()`/
  `selfBranch()`/`canReachBranch(branch)` helpers read the requester's own user
  doc. **`shifts/{shiftId}` (Phase 2)** and **`tasks/{taskId}` (Phase 3)** are
  the branch-scoped collections wired to `canReachBranch()` (admin all · manager
  own-branch · employee own assigned data). Shifts are employee read-only; tasks
  additionally allow the **assigned employee a limited self-update** (advance
  status / add notes / proof, but not reassign, move branch, or approve/reject).
  **`branches/{branchId}` (Phase 5)** is admin-write / any-signed-in-read (a
  branch isn't branch-scoped *data* — it defines the branches), with "delete" as
  a soft delete (admin update). Admin user-administration writes go through the
  existing `users` admin-update rule (`isAdmin()`). **`weekly_schedules/{id}` and
  `shift_swaps/{id}` (Phase 7)** are branch-scoped via `canReachBranch()`: a
  schedule is **admin / own-branch-manager write** and **readable by any employee
  of the branch** (`branchId == selfBranch()`, so they see their roster + today's
  team); a swap is read/written by the two involved employees and the branch
  manager/admin, with **create** restricted to the requester in their own branch
  (the status order is validated client-side in `ShiftSwapCubit`).
- Routes are role-guarded in the GoRouter `redirect`: admin areas are
  admin-only, manager areas admit **manager + admin** (the hierarchy), the
  employee home (`/`) is employee-only. Add a new role area as a path prefix
  with an `_isXArea` helper + a guard line, and extend `RouteNames.homeForRole`.
  Never gate role access in the UI only.
- New role-facing screens are presentation-only features
  (`features/<role>/presentation/pages/`) wrapped in a `RoleScaffold`; reuse
  `RolePlaceholder` for not-yet-built screens.

### Codegen
After editing any `freezed` file (`*_entity.dart`, `*_state.dart`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 5. Documentation Maintenance

**The three docs are part of the codebase and must never fall behind the code.**
Treat `PROJECT_CONTEXT.md`, `CURRENT_STATE.md`, and `CHANGELOG.md` as production
source, not notes. **Before finishing ANY task**, verify each is synchronized
and update any that is outdated — automatically, in the same task.

### Verification (run before marking a task complete)

1. **PROJECT_CONTEXT.md** matches the current architecture.
2. **CHANGELOG.md** contains the latest completed work.
3. **CURRENT_STATE.md** reflects the current project status.
4. If any document is outdated → update it. **Never leave docs behind the code.**

### Self-check — confirm each is documented

- [ ] Architecture documentation is correct.
- [ ] New **files** added to the [directory map](#directory-map-lib) and chains.
- [ ] New **routes** documented (here, `route_names.dart`, and `CURRENT_STATE.md`).
- [ ] New **cubits / states** documented in [File Dependency Map](#2-file-dependency-map).
- [ ] New **repositories** documented.
- [ ] New **use cases** documented.
- [ ] New **models / entities** documented (incl. Firestore/Storage schema in `CURRENT_STATE.md`).
- [ ] **Dependency injection** changes documented (`injection.dart` chain).
- [ ] **Firebase / Storage / Firestore schema** changes documented in `CURRENT_STATE.md`.
- [ ] [Architecture diagrams](#architecture) / [dependency maps](#2-file-dependency-map) updated if layers/flow/wiring changed.
- [ ] New/changed **conventions** noted in [Project Conventions](#4-project-conventions).
- [ ] **CHANGELOG.md** entry appended (added / removed / fixed / refactored).
- [ ] **CURRENT_STATE.md** updated (status, working tree, gaps, next steps).

### Documentation integrity

If the code and the docs disagree: **verify the code, then update the docs.**
Never ignore the mismatch — the documentation must always represent the latest
state of the project. The goal: a future task can be completed with **minimal
codebase scanning**.

---

## 6. AI Workflow

Future AI sessions should:

1. **Read all three docs first**, in order, and treat them as the source of
   truth: [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) →
   [CURRENT_STATE.md](CURRENT_STATE.md) → [CHANGELOG.md](CHANGELOG.md).
2. Use the [Modification Map](#3-modification-map) to find the exact files to
   touch — do **not** re-scan the whole project.
3. Read only the files related to the requested task.
4. Avoid re-analyzing the entire codebase unless absolutely necessary; trust the
   dependency chains here.
5. When adding a feature, follow it through **all** layers in order:
   datasource → repository (contract + impl) → use case → cubit/state → page,
   then wire it in [`injection.dart`](lib/core/di/injection.dart) and (if
   routed) [`app_router.dart`](lib/core/routes/app_router.dart) +
   `route_names.dart`.
6. Run codegen after touching any `freezed` file.
7. **Before finishing**, run the
   [Documentation Maintenance](#5-documentation-maintenance) verification +
   self-check and update all three docs as needed. Never leave docs behind the
   code.
