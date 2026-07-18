# Schedule V2 — Locked Scope & Pillar Plan

**Status:** Scope locked, not yet built. Owner-approved direction: *"lock scope, then build pillar by pillar."*
**Branch:** `feature/schedule-optimization`
**Date:** 2026-07-09
**Supersedes nothing.** This is the contract for the Schedule V2 work. Build only what is IN scope here. Anything in the OUT list needs a fresh owner decision before it is touched.

---

## 0. How to read this

The original V2 brief was ~20 subsystems that add up to a full Workforce-Management platform (Deputy / WhenIWork / Homebase). This document is the **triage of that brief against DROP's own philosophy**, plus the pillar plan for the parts that survive.

Two rules govern every line below:

1. **Premium ≠ enterprise.** The parts that make Schedule *feel* premium are cheap and IN. The parts that make it an *enterprise WMS* are expensive, high-risk, built for a scale DROP doesn't have — OUT until a real need appears.
2. **Extend, don't rebuild.** Schedule is a mature ~13,500-LOC feature. Most of the brief is already partly built. Every pillar names the real files it grows from.

---

## 1. Guardrails (the philosophy this plan is bound by)

Pulled from standing owner rulings — these are non-negotiable framing, not aspirations:

- **Premium lean internal ops tool, NOT enterprise/SaaS.** Not Jira/Slack/Linear/Deputy. Small-user scale. Workflow > architecture. UX > feature-count. Default to deletion. Challenge complexity. No over-engineering.
- **Stability > perfection.** 90% + zero regressions beats 100% + risk. Classify every change (bug/polish/refactor/feature) and label risk (LOW/MED/HIGH).
- **Guard intentional / previously-debated UX.** Never replace a lived-in UI without sign-off. "Work on it more" = enrich, not simplify.
- **Monochrome.** Colour only for destructive / genuine status. No %/progress-bars, no staffing quotas, no purple/indigo (all previously reverted).

### Frozen surfaces this plan must NOT touch
- **Employee mobile "My Week"** (`my_schedule_screen.dart`, premium hero + week cards) — owner-FROZEN. In-language improvements only. **Schedule V2 is the manager/admin desktop+tablet surface.**
- The **advice-never-gate** stance of the insight strip — facts are information for the manager's judgment, never enforcement. (This principle outlived Schedule Health, which was **deleted 2026-07-15** — see Pillar 3.)

---

## 2. What already exists (do NOT rebuild)

| Brief asks for | Already shipped |
|---|---|
| #3 Configurable shift hours | `domain/shift_hours.dart` (`ShiftHours` value object, overnight-aware) + per-week `weekly_schedules/{id}.shiftHours` overrides. Hours are **data**, resolved by `WeeklyScheduleEntity.hoursFor(day, shift)`. |
| ~~#5/#6 Scheduling engine + health score~~ | ❌ **DELETED 2026-07-15 (owner ruling).** `domain/schedule_health.dart` + `domain/health/` are gone. The insight strip (`presentation/schedule_insights.dart`) is the only staffing signal. |
| #10 Final view redesign + #20 image export | `pages/schedule_final_view.dart` — branded read-only roster **with real PNG export** (shipped 2026-07-05). |
| #4 Assignment chip (partial) | `widgets/assignment_chip.dart` — avatar, short name, desktop drag-to-move, chip-onto-chip **swap with live drop preview**, context menu, touch action sheet, conflict/caution dots. |
| #15 Conflict / move / swap validation | `domain/move_validation.dart`, `swap_validation.dart`, `swap_eligibility.dart`, `swap_policy.dart`. |
| #1 Responsive foundation | `core/responsive/breakpoints.dart` — 4 tiers (mobile/tablet/desktop/ultrawide), `sidebarWidth`/`sidebarCollapsedWidth` (collapse already modelled), `ResponsiveBuilder`, `ContentConstraint`, tier-aware `pagePadding`. |
| Desktop shell + ⌘K | `core/widgets/app_shell.dart`, `app_sidebar.dart`, `command_palette.dart`. |

**Current manager/admin surface** = the **Schedule 3.0 weekly grid** (`widgets/schedule_grid.dart` + `shift_cell.dart`): days as columns (Sun→Sat), Morning/Night rows, pinned rail, horizontal scroll on phone, individual draggable chips, insight-driven dimming. (The 2026-06 accordion was superseded by this grid; its anti-quota/monochrome ruling still holds in the code.)

---

## 3. Scope decision

### ✅ IN — genuine DROP-premium, high leverage

| # | Item | Lands in |
|---|---|---|
| 1 | Adaptive Mac vs iPad layout | Pillar 1 |
| 2 | Focus mode (collapse sidebar) | Pillar 1 |
| 4 | Assignment chip craft (bigger, position, initials, cross-day drag, keyboard move) | Pillar 2 |
| ~~6~~ | ~~Health score **breakdown made clickable**~~ | ❌ Pillar 3 **deleted 2026-07-15** |
| 10 | Final view / export polish (mostly done) | Pillar 5 |
| 16 | Premium motion | Pillar 6 |
| 18 | Accessibility | Pillar 6 |

### 🟡 IN but bounded — the one worthwhile idea from the "enterprise" set

| # | Item | Why it survives | Lands in |
|---|---|---|---|
| 3 | **Named, reusable shift templates** with an explicit *"only this week / future / update template"* choice | Naturally bounded; builds directly on `shift_hours`; history-safe by construction. The single highest-value structural idea in the brief. | Pillar 4 |

### ❌ OUT — enterprise WMS bloat (contradicts standing rulings). Revisit only on the stated trigger.

| # | Item | Why out | Revisit trigger |
|---|---|---|---|
| 5/7 | 9-class **isolated** Rule-Engine + **configurable policy** engine | ❌ **Fully back to NO (2026-07-15).** The 2026-07-09 partial lift (the bounded 5-rule analyzer in `domain/health/`) was **deleted** — the owner ruled the whole quality-scoring layer unnecessary. | An explicit, fresh owner ask. The direction here has now flipped twice; do not infer it from the brief. |
| 8 | Full metadata audit trail (createdBy/updatedBy/reason/previousEmployee/source) | Jira-grade traceability the owner explicitly rejected on Requests. | A real dispute/accountability need appears. |
| 9 | Schedule history / snapshots / rollback / compare revisions | Versioning system for a handful of managers. | Managers actually ask to undo a *published* week. |
| — | Versioning (v1/v2/v3), draft-vs-published, shift locking | Enterprise workflow engine. | Employees see wrong in-progress edits AND that causes real confusion. |
| 11 | Excel keyboard interaction (arrow/tab/copy/paste/range/fill/undo/redo) | Huge surface, tiny payoff at this scale. | Managers build schedules for >50 people regularly. |
| 13/14 | Workload heatmaps + AI assignment suggestions | WMS analytics. Doubly settled — the lighter-weight version of this (Pillar 3 findings) was itself deleted 2026-07-15 as unwanted. | Explicit owner ask. |
| 17 | Background isolates / "hundreds of employees" | Premature — not DROP's scale. | Profiler shows real jank on a real branch. |
| 19 | Offline edit + pending-ops + conflict-resolution/merge | Distributed-systems complexity. Firestore offline persistence already covers reads. | Managers routinely edit on flaky connections AND lose edits. |
| 20 | PDF / Print / CSV / Excel export | PNG already ships. Format sprawl. | A concrete "I need CSV for payroll" request. |

**All ❌ items live in Pillar 7 (Reserve). They are parked, not planned.**

---

## 4. The 7 pillars

Each pillar states **Goal · Architecture · UX · Logic · Risk · Out-of-scope · Done-when**. Ordering = build order.

### Pillar 1 — Adaptive Shell (Mac vs iPad) + Focus Mode
- **Goal:** the manager/admin schedule stops feeling like a stretched phone. Mac = roomy, hover, floating inspector. iPad = touch, bottom sheets, Apple-Calendar feel.
- **Architecture:** extend `core/responsive/breakpoints.dart` (tiers + `sidebarCollapsedWidth` already exist). Inside `manager_schedule_view.dart`, branch layout on `context.deviceType`: desktop/ultrawide → `Row(grid | floating inspector panel)`; tablet → grid + bottom-sheet inspector. Focus Mode = a shell-level toggle that collapses `app_sidebar.dart`, bound to a keyboard shortcut via existing shortcut infra. Toolbar stays visible when collapsed.
- **UX:** wider gutters + larger grid + resizable/hover on Mac; larger tap targets + bottom sheets on iPad; shared design language; sidebar collapse toggle; ⌘-based toggle.
- **Logic:** none new. Pure layout + `focusMode` / `inspectorOpen` UI state. Use `BlocSelector` so toggling chrome never rebuilds the grid.
- **Risk:** **MED** (touches the shared shell). Guard: mobile employee My Week untouched.
- **Out-of-scope:** split-view multitasking beyond what the OS gives for free.
- **Done-when:** Mac shows inspector + collapsible sidebar; iPad shows bottom-sheet inspector; grid never rebuilds on chrome toggle; My Week unchanged.

**Increment status**
- **✅ 1a — Focus Mode (shipped 2026-07-09):** `app_shell.dart` now stateful; ⌘\ + a sidebar collapse control + a floating restore handle. Only the sidebar *width* animates (clip + `OverflowBox`), so the `Expanded(child)` shell Navigator is never remounted — guarded by `test/focus_mode_test.dart`. It is **app-wide** (collapsing the shell sidebar is global by nature; route-gating it to the schedule would be *more* code for less value). **Persistence is in-session only** — the app has no local-prefs store yet; cross-restart memory needs one small dependency (`shared_preferences`) and an owner OK. Reduced-motion + Semantics done here already.
- **✅ 1b — Adaptive layout (shipped 2026-07-09):** `manager_schedule_view.dart` splits on `context.isDesktop`. Desktop / iPad-landscape (≥1024) → `Row(grid hero | inspector rail)`; the rail docks the week totals + (at the time) the health card that used to sit *below* the grid. Touch widths keep the byte-identical stacked `ListView` + bottom-sheet detail. Presentation-only recomposition of existing widgets — every edit/validation/save path unchanged. *(The health card is gone as of 2026-07-15; the rail now carries week totals + the team roster only.)*
- **✅ Inspector drawer (shipped 2026-07-09, owner-directed):** the rail's empty lower area became a real drawer — extracted to `widgets/schedule_inspector_drawer.dart` (stateless, selection lifted → tests in isolation with no cubits). Overview + **team roster** → tap a person → **week detail** (hours from resolved `ShiftHours`, morning/night/weekend split, consecutive-day streak, days off, Sun→Sat glance, wellbeing flags from `health.findings`). Backed by pure `domain/employee_week_stats.dart`. This is the lean read-only slice of brief #12 (metadata panel) — no per-employee analytics engine, no persistence. Tests: `schedule_inspector_drawer_test.dart` (4) + `employee_week_stats_test.dart` (3).

**Pillar 1 is complete.** Next: Pillar 2 (Assignment Craft).

> **TODO (deferred, owner decision):** Focus Mode persistence across a cold launch. Needs a local-prefs store the app lacks (`shared_preferences`, one std dep). Left as in-session-only until we decide to add it — do not implement without an explicit GO.

### Pillar 2 — Assignment Craft ✅ (shipped 2026-07-09)
- **Goal:** the chip is the atom of the schedule — make it richer and easier to move.
- **Architecture:** enriched `widgets/assignment_chip.dart` (already avatar + drag + swap-drop + preview) — no scheduling-architecture change. Threaded a keyboard-move callback `assignment_chip → shift_cell → schedule_grid`, where it maps straight onto the existing `onMoveChip`.
- **What shipped:**
  - **Premium chip:** avatar 17→18, initials fallback via `UserAvatar` (already existed), `user.position` trails the name (single-line, ellipsizes first so it never outgrows the 140px cell). Desktop hover tooltip = full name + position; touch tooltip unchanged.
  - **Bigger target + lift:** roomier padding; soft shadow on hover / focus.
  - **Cross-day drag:** was *already* routed through `MoveValidation` (the `ShiftCell` DragTarget was never same-day-restricted) — now test-locked.
  - **Keyboard move (desktop):** `Focus` + arrow keys (←/→ days same shift, ↑/↓ Morning↔Night) → same `onMoveChip` → `MoveValidation` → same Firestore write. Edges are a consumed no-op. Focus ring on the chip.
  - **Motion:** one-shot scale-in on placement; chips keyed by uid so a person who stays put never re-animates; scale-only (stays hit-testable); reduce-motion aware.
  - **Touch unchanged:** drag/keyboard/focus desktop-gated; long-press → action sheet (test-locked).
- **Logic:** all legality via `move_validation.dart` — **no new persistence, no new write path** (verified).
- **Risk:** LOW–MED, realised LOW (isolated widget + validation reuse).
- **Tests:** `test/assignment_chip_interactions_test.dart` (6). Regression: 60 pass, analyze clean.
- **Explicitly NOT built (per constraints):** bulk/range selection, Excel keys, AI, quotas, audit — none touched.

**Pillar 2 is complete.**

### Pillar 3 — Health Analyzer ❌ **REVERTED / DELETED 2026-07-15 (owner ruling)**

> **This pillar no longer exists in the codebase. Do not re-add it.**
>
> **The ruling (2026-07-15):** the schedule was crowded and nobody needed the
> crowding. The same staffing facts rendered **twice** — the insight strip above
> the grid, and again below it in `ScheduleOverviewSurface` (health score +
> category breakdown + findings + legend). The owner's brief: *keep the things at
> the top — open shifts, one-person shifts, short rest — and drop Schedule Health
> and the rest.*
>
> **Deleted:** the entire `domain/health/` package (analysis · rule · report ·
> analyzer + the 5 rules), the `domain/schedule_health.dart` facade
> (`computeScheduleHealth`), `widgets/schedule_overview_surface.dart`, and the
> tests `schedule_health_test` · `schedule_health_analyzer_test` ·
> `schedule_overview_surface_test`. The inspector rail also lost its health-derived
> **Wellbeing** block.
>
> **What survives as the only staffing signal:** `presentation/schedule_insights.dart`
> (`computeScheduleInsights` → open · one-person · short-rest · double-booked ·
> leave-clash, click-to-filter) + a one-line `_weekSummary`.
>
> **Note the arc:** Pillar 3 was itself an owner-directed *expansion* on 2026-07-09
> (overriding the original "don't build rule classes" scope). It has now been
> reversed in full. Twice-changed direction — treat any future "schedule quality
> score" proposal as needing an explicit, fresh owner ask.
>
> The original record follows for history.

<details>
<summary>Historical record — Pillar 3 as shipped 2026-07-09 (now deleted)</summary>

- **Goal:** make Schedule Health the **single source of truth for schedule quality** — a pure, modular domain engine that computes the read and exposes a structured report, with the card as a thin presentation layer over it.
- **⚠️ Owner-directed scope change:** this pillar was originally scoped *"do **not** rebuild into rule classes — add derived subscores over the existing `computeScheduleHealth`."* The owner **overrode that** on 2026-07-09 with an explicit, prescriptive brief: build a **modular rule-based analyzer** (independent Coverage / Workload / Fairness / Rest / Conflict rules → aggregated report). So the ❌ #5/7 line below is **partially lifted** — the *bounded 5-rule analyzer is now IN*; what stays ❌ is the **enterprise** part (background isolates, a configurable per-branch *policy* engine, 9+ classes). This is a deliberate, recorded reversal.
- **Architecture (as built):** new `domain/health/` package —
  - `schedule_analysis.dart` — `ScheduleAnalysis.of(...)` reduces the roster to shared per-member + per-slot signals in **one pass** (`MemberWeek`); every rule reads these, none re-walks the roster.
  - `schedule_rule.dart` — `ScheduleRule` (abstract, pure `evaluate(analysis)`), `ScheduleRuleResult`, `RuleFinding`, `ScheduleHealthSeverity` (none/low/medium/high), `ScheduleRuleCategory`.
  - `rules/` — `CoverageRule`, `WorkloadRule`, `FairnessRule`, `RestRule`, `ConflictRule`, each ~one screen, fully independent (no switch/if-else chains, no rule-to-rule coupling).
  - `schedule_health_report.dart` — `ScheduleHealthReport` (`overallScore`/`overallSeverity`, the five `ScheduleRuleResult`s, flattened `findings`/`suggestions`, `findingsFor(uid)`, the shared `analysis`).
  - `schedule_health_analyzer.dart` — `ScheduleHealthAnalyzer` folds the rules over the analysis → report. Synchronous, **no async/isolates**. Adding a lens = one rule file + one line in `defaultRules` (OCP).
- **Backward compatibility:** `domain/schedule_health.dart` is now the **facade** — `ScheduleHealth`/`HealthFinding`/`HealthFindingKind` preserved, and `computeScheduleHealth()` **delegates to the analyzer** then projects the report's shared analysis back through the original scoring formula, **byte-for-byte identical** (the pre-existing `schedule_health_test.dart` passes unchanged).
- **UX (card only, no redesign):** `schedule_health_card.dart` now consumes the `ScheduleHealthReport` — overall score `/100`, severity dot, and a **clickable category breakdown** (tap a lens → filter its findings), with the richer rule wording. Monochrome kept (white → grey → amber dot). Inspector drawer threads the report through unchanged; grid cell-drill deferred (kept out of scope — "no layout work").
- **Logic:** rules are pure/derived; the analysis is computed **once per build** (same cost as the old single call). Advice-never-gate stays — even a `high` finding never blocks an edit or publish.
- **Risk:** **LOW–MED** (new domain package; presentation swap). Realised LOW — analyze clean, backward-compat proven, zero regressions.
- **Out-of-scope (still ❌):** grid cell-highlight drilling, heatmaps, AI fixes, one-click auto-fix (#13/#14), isolates (#17), configurable policy engine (#5/7).
- **Tests:** `schedule_health_analyzer_test.dart` (24 — each rule in isolation, aggregation, OCP custom-rule set, backward compat incl. the silent double-book penalty) + the frozen `schedule_health_test.dart` (6). Full suite **649 pass / 3 pre-existing fail**.

</details>

**Pillar 3 was deleted on 2026-07-15.** Pillar 4 (Shift Templates) shipped and is unaffected.

### Pillar 4 — Shift Templates (the bounded 🟡) ✅ (shipped 2026-07-09)
> **Sequencing note:** the owner shipped Final View first and called this "Pillar 5" in the roadmap; it is the doc's Pillar 4. **Design-reviewed + owner-approved ("as proposed") before any code**, per the gate below.
- **Goal (delivered):** reusable, **per-branch** shift-hour templates with an explicit change scope. **Never silently overwrites historical schedules.**
- **Architecture (as built):** a dedicated **`shift_templates/{id}`** collection (per-branch, keyed `{branch}__{role}`) — a template = `{ name, role, ShiftHours }` reusing the overnight-aware `shift_hours.dart`. Three standing roles (Morning · Weekday night · Weekend night) + a reserved `custom`; seeded lazily to match `ShiftHours.standard` (behaviour-neutral). **History-safety is a per-week snapshot:** the week doc carries an additive `shiftPlan` (morning/weekday-night/weekend-night `ShiftHours`) captured **at creation**, so `WeeklyScheduleEntity.hoursFor` resolves **per-slot override → the week's own snapshot → standard**. `hoursFor` stays **entity-only** — no live templates threaded into the grid / employee views / Final View (those frozen surfaces are untouched); a legacy week (no snapshot) resolves standard, unchanged.
- **The 3-way scope** (`ScheduleCubit.applyShiftHours`): **① This week only** (the existing per-slot `setShiftHours` override), **② Future schedules** (updates the template — only weeks created afterward snapshot it), **③ Update globally** (updates the template **+** `ScheduleRepository.restampShiftPlan` onto this week + every future existing week; past weeks stay frozen).
- **UX:** a simple template-manager sheet (`shift_templates_sheet.dart`) + the "Apply changes to…" scope dialog (`shift_hours_scope_dialog.dart`), reached from the day sheet's *Shift hours* section; the day-sheet hours editor routes through the scope dialog. No enterprise config screens.
- **Layers (modular):** enums `shift_template_role` + `shift_hours_scope`; domain `shift_plan.dart`, `shift_template.dart` (+ `ShiftTemplateSet` + validation), `repositories/shift_template_repository.dart`; data model/datasource/repo; `ShiftTemplateCubit`; extended `ScheduleCubit`/`ScheduleRepository`; DI. Rules: additive `shift_templates` block mirroring `weekly_schedules` (**deploy pending; confirmed absent from the active production ruleset on 2026-07-18, which blocks Create Schedule at its template pre-read for every role**).
- **Risk:** MED–HIGH (data model + resolution) — realised LOW via additive/opt-in + snapshot history-safety + no frozen-surface changes.
- **Out-of-scope (still ❌):** template versioning / audit trail; custom named per-slot templates ship **data-model-ready but UI-light** (future).
- **Done:** templates reusable + configurable; the 3-way scope works; a template edit provably never mutates a historical week — **test-guarded** (`shift_template_*_test.dart`, 24 tests). Suite **681 pass / 3 pre-existing fail**.

### Pillar 5 — Final View Redesign ✅ (shipped 2026-07-09)
> **Sequencing note:** the owner pulled this **ahead of Pillar 4 (Shift Templates)** and called it "Pillar 4 — Final View Redesign." Shift Templates + Metadata/History remain deferred behind it.

- **Goal (delivered):** the Final View was **redesigned from scratch** into a premium, read-only, print/export-ready schedule — a modern spreadsheet (Apple Numbers / Notion tables) in DROP's monochrome language. Not a polish pass; a rebuild.
- **Architecture (as built):** a **dedicated presentation surface** `widgets/final_schedule_sheet.dart` (`FinalScheduleSheet`) — *not* the editor with another mode. `pages/schedule_final_view.dart` keeps only the route/chrome (`showScheduleFinalView` launch signature, the preview toolbar, and the `RepaintBoundary`→`toImage`→Downloads **PNG export**) and hosts the sheet. The old grid-reuse `_ExportCanvas` + fact-pills were deleted.
- **Layout:** one **employee per row** × **day per column** (Sun→Sat + dates), a single scannable **token per cell** (`M`·`N`·`M/N`·`OFF`·`LEAVE`·`VAC`), a document header (DROP · branch · Week of · Generated · Manager), a **day-notes row** (only when notes exist), and a legend. Fixed-width **1600 landscape document**, natural height (≈ A4-landscape for a typical roster), `FittedBox`-scaled to any screen; subtle zebra + hairline rules, no chips/avatars/heavy shadows.
- **UX:** pure presentation — no drag/inspector/health/analytics/suggestions/builder controls. Employee names lead; shift tokens are the scan target; whitespace carries the rest.
- **Logic:** none new — reads `WeeklyScheduleEntity` / `UserEntity` / `ShiftHours` / `LeaveType` / `ScheduleWeek` / `AppDateFormatter` only.
- **Risk:** LOW (presentation-only; frozen surfaces untouched).
- **Out-of-scope (still ❌):** PDF/CSV/Excel + any export-engine work (#20) — **PNG only**, unchanged.
- **Tests:** `schedule_final_view_test.dart` rewritten (7 — rendering, large roster, empty notes, export layout/landscape, page + responsiveness, filename). Suite **657 pass / 3 pre-existing fail**.
- **Done:** roster reads as an export-quality sheet; PNG intact; read-only; responsive; tests green; docs updated.

### Pillar 6 — Motion & Accessibility
- **Goal:** subtle Apple-philosophy motion + a11y pass across the new surfaces.
- **Architecture:** apply the Design-System-V2 core standards (Semantics, ≥44px targets, reduced-motion) to Pillars 1–5. Subtle fade/slide/scale on chip insert, inspector open, health drill.
- **UX:** subtle only — no flashy effects.
- **Logic:** none.
- **Risk:** **LOW.**
- **Done-when:** reduced-motion respected; screen-reader labels on chips/inspector/health; targets ≥44px.

### Pillar 7 — Reserve (explicitly deferred)
Everything in §3 ❌. **Not built.** Each carries a revisit trigger in the table above. Do not start any of these without a fresh owner decision.

---

## 5. Sequencing & dependencies

```
1 Adaptive Shell ──► 2 Assignment Craft ──► 3 Health Legible ──► 5 Final View ──► 6 Motion/A11y
                                                                   ▲
                          4 Shift Templates (own mini-design + GO) ┘  (gated, parallel-able after 1)
```

- **1 → 2 → 3** is the core sequence; each is independently shippable and low/med risk.
- **4** is gated behind its own design + owner GO because it alone touches the data model.
- **5, 6** are polish; run last (6 sweeps everything built before it).
- **7** stays parked.

---

## 6. Change classification (per working rules)

| Pillar | Class | Risk |
|---|---|---|
| 1 Adaptive Shell + Focus | feature + refactor | MED |
| 2 Assignment Craft | polish + feature | LOW–MED |
| 3 Health Legible | feature (presentation over existing logic) | LOW |
| 4 Shift Templates | feature (data model) | MED–HIGH |
| 5 Final View polish | polish | LOW |
| 6 Motion / A11y | polish | LOW |

---

## 7. Open questions to resolve at each pillar's kickoff
- **P1:** Is Focus Mode global (all screens) or schedule-only? Recommend schedule-first, generalise if it lands well.
- **P4:** Where do templates live — a dedicated `shift_templates` collection, or a field on branch settings? (Decide at P4 design.) Are templates global or per-branch?
- **P5:** Is PDF actually wanted, or is PNG enough? (Default: PNG only unless asked.)
