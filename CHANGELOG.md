# Changelog

All notable changes to **FBRO** are recorded here. After every completed
feature, append a short summary of what was **added / removed / fixed /
refactored**. See [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) for architecture.

The project adheres loosely to [Keep a Changelog](https://keepachangelog.com)
and [Semantic Versioning](https://semver.org).

---

## [Unreleased]

### Added
- `PROJECT_CONTEXT.md` — architecture, dependency maps, modification map, and
  conventions as the single source of truth for the codebase.
- `CURRENT_STATE.md` — live project status: module status, working tree, routes,
  Firebase/Firestore/Storage status & schema, known gaps, and next steps.
- `CHANGELOG.md` — this file.
- Documentation protocol: PROJECT_CONTEXT.md, CURRENT_STATE.md, and CHANGELOG.md
  are treated as production source and must be verified/synchronized before any
  task completes (verification rules + self-check in PROJECT_CONTEXT §5). Docs
  are updated automatically — never ask whether to update.
- `.claude/settings.json` — committed `SessionStart` hook that injects the
  documentation protocol into every new session (read all three docs first,
  verify against the codebase, auto-update docs + any stale project memory
  before finishing).

---

## 2026-06-14 — Redesign & production profile system

### Added
- **Profile module** (`features/profile`): full view + edit, Firestore-backed
  `ProfileEntity` (identity, personal, account, social counters, presence,
  privacy settings), avatar/cover upload to Firebase Storage with live progress,
  and case-insensitive username availability checks.
- `ProfileCubit` with optimistic, flicker-free save flow (keeps last-known
  profile visible across `saving`/`error`).
- Settings module (`features/settings`): settings page + change password; delete
  account flow.
- Design system: monochrome black & white theme with white accent
  (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppTheme`).
- FBRO branding (`FbroLogo` wordmark), shared `AppSnackbar` and `Skeleton`
  widgets, custom page transitions (fade/slide).
- Enhanced Google authentication configuration (Info.plist / settings).

### Fixed
- Per-action loading: `AuthState.loading` now carries an `AuthAction` so only
  the triggering button shows a spinner (fixes "every button spins on Google
  sign-in").

### Notes / follow-ups
- Requires Firebase **Storage enabled** and **Firestore security rules** to be
  configured for production.
- Social counters and presence fields are schema-ready but not yet
  backend-driven.

---

## 2026-06-13 — Authentication feature set

### Added
- Email/password sign-in & registration, phone OTP sign-in, Google sign-in.
- Forgot password, email verification (send + poll), change password,
  delete account.
- Session restore on cold start (`AuthCubit.restoreSession`) and auth-aware
  routing via `go_router` redirects (`_AuthStateNotifier`).
- Firestore user document: saved on registration (`users/{uid}`), loaded to
  restore session, surfaced on the Home screen.
- Clean Architecture scaffold: `core/` (di, errors, routes, theme, widgets,
  constants) and `features/auth` across data/domain/presentation layers.
- Auth UI + design system foundations (Phase 2).

### Refactored
- Completed Firebase authentication integration end-to-end (datasources →
  repository → use cases → cubit → pages).

---

## Earlier

- **Phase 1** — initial Flutter project bootstrap and Firebase setup.
