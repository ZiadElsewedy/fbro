# DROP — macOS UI/UX Audit (2026-07-02)

> Full-codebase audit against the "premium, Apple-level, first-time-user-ready
> macOS app" brief. Verified against the actual code on `feature/macos-desktop`
> (not the docs alone). Two standing owner rulings **override** parts of the
> brief and were applied as law:
>
> 1. **Strictly monochrome** — the indigo accent the brief suggests was
>    introduced twice and reverted twice (last: 2026-07-01). Not reintroduced.
> 2. **Lean internal ops tool, not enterprise SaaS** — "should feel like
>    enterprise software" is read as *quality*, not feature sprawl.

---

## 1. Branding sweep — ✅ ALREADY CLEAN (verified, no action)

Every user-visible surface already says **DROP**:

| Surface | Value | File |
| --- | --- | --- |
| macOS window title / app name | `PRODUCT_NAME = DROP` | `macos/Runner/Configs/AppInfo.xcconfig` |
| iOS display name | `DROP` | `ios/Runner/Info.plist` |
| Android label | `DROP` | `android/app/src/main/AndroidManifest.xml` |
| Web title/manifest | `DROP` | `web/index.html`, `web/manifest.json` |
| Flutter app title | `DROP` | `lib/main.dart` |
| `AppConstants.appName` | `DROP` | `lib/core/constants/app_constants.dart` |
| Dart package id | `drop` (all imports `package:drop/…`) | `pubspec.yaml` |
| Sidebar / splash / auth / empty states | `DropWordmark` / `DropLogo` / `DropAuthMark` / `DropEmptyState` | `lib/core/widgets/` |

**Deliberate remnants (must NOT be changed):**
- `com.example.fbro` iOS bundle id (`firebase_options.dart`, pbxproj) — this is
  the **registered Firebase iOS app id**; renaming it detaches the app from
  Firebase and re-breaks push (the 2026-06-26 bundle-id fix). Invisible to users.
- The repo folder name `fbro` and generated `Generated.xcconfig` paths — not a
  product string.

## 2. Design system & desktop chrome — ✅ ALREADY PREMIUM (verified, no action)

- Monochrome token system (`app_colors/typography/spacing/radius`), premium
  component layer (`GlassContainer`, `AppGlassCard`, `PremiumButton`,
  `MetricPill`, `TaskSurface` de-flashed cards), skeletons, entrance motion,
  animated counters, keyed live-list items.
- Desktop shell: persistent role-aware `AppSidebar` (hover states, active
  indicator, unread badge, user footer) via `ShellRoute`; every screen on
  `AdaptiveScaffold`; login has a bespoke desktop split; window opens 1440×900.
  Live-QA'd across all three roles on 2026-07-01.
- Splash: branded 1400 ms staged animation (logo scale/fade + wordmark + bloom),
  session-restore runs inside the dwell so Home paints instantly. Not generic.
- Schedule: premium weekly grid (avatar stacks, dashed empty slots, today ring),
  coverage summary, floating pending-swap alert, assign/edit sheets, realtime
  swap streams. The brief's "insights" (understaffed / pending swaps) exist.

## 3. Gaps found → actioned in this pass

### Critical (functional gaps from the brief)

**C1 — No salary / payment data anywhere in the system.**
The brief's financial block (salary amount/type, payment method, the wallet
number salary is sent to) has no fields, no UI, no rules. → Added
`salaryAmount` / `salaryType` / `paymentMethod` / `paymentNumber` to
`UserEntity`/`UserModel`, a **Compensation** section on Create Account and the
admin Edit Info sheet, salary lines in the employee Details dialog, and rules:
only `paymentNumber` is self-editable; the other three are admin-only (frozen
in the `users` self-update rule — **rules deploy required**).

**C2 — Employees cannot edit their own contact/payment data.**
`EditProfilePage` exposed only name/bio/photos even though the whole
write pipeline (`ProfileCubit.save` → `editMap`) already supported
phone/address/emergency (used once at onboarding, then unreachable). Admins had
to relay every phone change. → `ProfileEntity` now carries
`address`/`emergencyContact`/`paymentNumber`; Edit Profile gains **Contact
details** + **Salary payment number** sections (validated, seeded from the live
doc); Profile page displays them. Writes go to the same `users/{uid}` doc the
admin screens read — no stale copy.

### Medium

**M1 — No keyboard navigation on desktop.** A macOS productivity app is
expected to be drivable from the keyboard. → `⌘1…⌘9` now jump between sidebar
destinations (role-aware order), with the shortcut hinted on the sidebar row on
hover. Kept lean — no command palette (no ruling asked for one; deletion-first).

**M2 — Employee Details dialog didn't show compensation** (once it exists) —
covered under C1.

### Nice-to-have — deliberately NOT done (lean ruling)

- **Nickname / employee ID / notes fields** — username was removed 2026-06-18
  as "no operational value"; uid/email already identify; a notes field has no
  consumer. Not added.
- **Command palette, context menus, drag-drop upload** — deferred backlog
  (documented 2026-06-25). Nothing in daily branch ops needs them yet.
- **Schedule conflict engine / staffing quotas** — quotas are a settled product
  rejection; conflicts can't exist in the current one-shift-per-slot model.
- **Indigo accent** — rejected (standing ruling).

## 4. Verification

`dart run build_runner build` (freezed regen for the two entities),
`flutter analyze` clean, full `flutter test` suite green — see CHANGELOG entry
2026-07-02 for exact counts. Firestore rules change requires
`firebase deploy --only firestore:rules` before the paymentNumber self-write
and salary freeze are live.
