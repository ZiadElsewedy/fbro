# FBRO — Current State

> **Live status snapshot of the project.** Read this after
> [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) to know what's done, what's pending,
> and what needs configuring. This file answers "where are we right now?" —
> architecture/how-it-works lives in PROJECT_CONTEXT.md; history lives in
> [CHANGELOG.md](CHANGELOG.md).
>
> **Keep this current** — update it before finishing any task (see
> [Documentation Maintenance](PROJECT_CONTEXT.md#5-documentation-maintenance)).

**Last updated:** 2026-06-14
**Version:** 1.0.0+1 · **Branch:** `main`

---

## Status at a glance

| Module          | Status        | Notes                                                       |
| --------------- | ------------- | ---------------------------------------------------------- |
| Authentication  | ✅ Complete    | Email, phone OTP, Google, verify, forgot/change pw, delete |
| Profile         | ✅ Complete    | View/edit, avatar+cover upload, username checks            |
| Settings        | ✅ Complete    | Settings page + change password + delete account          |
| Home            | 🟡 Basic      | Presentation only; shows authenticated user, no feed yet   |
| Design system   | ✅ Complete    | Monochrome B&W, **dark-mode only**                         |
| Social features | ⛔ Not started | Counters/presence fields exist in schema but no backend    |

Legend: ✅ done · 🟡 partial · ⛔ not started

---

## Working tree

- **Branch:** `main`.
- **Uncommitted:** ~32 Dart files modified (the redesign + profile/settings
  work) are **staged in the working tree but not yet committed**, plus the new
  docs (`PROJECT_CONTEXT.md`, `CHANGELOG.md`, `CURRENT_STATE.md`) and
  `.claude/settings.json` (documentation-protocol `SessionStart` hook) are
  untracked.
- **Action needed:** commit the redesign + documentation work (including
  `.claude/settings.json` so the protocol hook is team-wide).

---

## Routes (all implemented)

| Name                | Path                         | Page                    |
| ------------------- | ---------------------------- | ----------------------- |
| splash              | `/splash`                    | `SplashPage`            |
| welcome             | `/welcome`                   | `WelcomePage`           |
| home                | `/`                          | `HomePage`              |
| login               | `/login`                     | `LoginPage`             |
| register            | `/register`                  | `RegisterPage`          |
| phone               | `/phone`                     | `PhoneOtpPage`          |
| forgotPassword      | `/forgot-password`           | `ForgotPasswordPage`    |
| emailVerification   | `/email-verification`        | `EmailVerificationPage` |
| profile             | `/profile`                   | `ProfilePage`           |
| editProfile         | `/profile/edit`              | `EditProfilePage`       |
| settings            | `/settings`                  | `SettingsPage`          |
| changePassword      | `/settings/change-password`  | `ChangePasswordPage`    |

Defined in [route_names.dart](lib/core/routes/route_names.dart) /
[app_router.dart](lib/core/routes/app_router.dart). Navigation is auth-guarded.

---

## Backend / Firebase status

- **Firebase Auth** — configured & working: Email/Password, Phone, Google.
- **Cloud Firestore** — in use (`users/{uid}`).
- **Firebase Storage** — code uploads to `users/{uid}/avatar.jpg` &
  `cover.jpg`. ⚠️ **Storage must be enabled** in the Firebase console for
  uploads to work in production.
- **Security rules** — ⚠️ **Not in the repo.** No `firestore.rules` /
  `storage.rules` committed. Production needs rules that let a user read/write
  only their own `users/{uid}` document and storage path.

### Firestore schema — `users/{uid}`

Shared by the auth (`UserModel`) and profile (`ProfileModel`) layers.

| Field                                                   | Type      | Notes                          |
| ------------------------------------------------------ | --------- | ------------------------------ |
| `uid`, `email`, `authProvider`                         | string    | core identity                  |
| `displayName`, `photoUrl`                              | string    | **legacy** auth keys, kept in sync |
| `fullName`, `username`, `profileImage`, `coverImage`   | string    | profile identity               |
| `phoneNumber`, `bio`, `gender`, `country`, `city`, `website` | string?  | personal                       |
| `birthDate`, `createdAt`, `updatedAt`, `lastSeen`      | Timestamp | dates                          |
| `isEmailVerified`, `isVerified`, `isOnline`            | bool      | status/presence                |
| `isProfilePublic`, `allowMessages`, `allowNotifications` | bool    | privacy (default true)         |
| `accountStatus`                                        | string    | default `active`               |
| `followersCount`, `followingCount`, `postsCount`, `likesCount` | int | social — **not backend-driven yet** |

### Storage schema

| Path                      | Content                            |
| ------------------------- | ---------------------------------- |
| `users/{uid}/avatar.jpg`  | profile image (overwrite-in-place) |
| `users/{uid}/cover.jpg`   | cover image (overwrite-in-place)   |

---

## Known gaps & follow-ups

- ⚠️ **Enable Firebase Storage** and **add Firestore + Storage security rules**
  before production.
- **Account deletion** removes the Firebase Auth account but **not** the
  `users/{uid}` Firestore document — that cleanup belongs in a Cloud Function
  (`auth.user().onDelete`); see note in
  [auth_cubit.dart](lib/features/auth/presentation/cubit/auth_cubit.dart).
- **Light theme** exists in `AppTheme.light` but is **not wired up** — app is
  hardcoded to dark mode in [main.dart](lib/main.dart).
- **Social counters / presence** fields are schema-ready but have no backend.
- **Home screen** is a placeholder — no feed/content yet.

---

## Testing

- Only `test/widget_test.dart` exists and is an **empty placeholder**
  (`void main() {}`). No real test coverage yet.

---

## Suggested next steps

1. Commit the redesign + documentation work on `main`.
2. Add `firestore.rules` / `storage.rules` and enable Storage.
3. Add a Cloud Function to clean up the user document on account deletion.
4. Build out the Home feed (first real social feature).
5. Add widget/cubit tests, starting with `AuthCubit` and `ProfileCubit`.
