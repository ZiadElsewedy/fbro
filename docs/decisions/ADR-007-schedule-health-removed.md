# ADR-007 — Schedule Health is removed

**Status:** Accepted · **Date:** 2026-07-15
**Supersedes:** Schedule V2 Pillar 3 (the modular `domain/health/` analyzer)

> Direction on this has flipped **twice**. It was built, expanded on request, then
> deleted. Do not re-add it without an explicit, fresh decision from the owner.

## Context

Schedule Health scored a week against five pure rules (coverage · conflict ·
fairness · rest · workload) and rendered a report below the grid. It was expanded
under Schedule V2 into a modular analyzer with a `computeScheduleHealth()` facade.

In practice it never changed a decision. A manager looks at the grid and already
knows the week is thin on Tuesday; a composite score restated that less precisely,
and the fairness/workload rules encoded judgments the manager makes by eye and by
context the app does not have. It was advice that could never gate anything, so it
was 2,769 lines of surface answering a question nobody asked.

## Decision

Schedule Health is **deleted** — the `domain/health/` analyzer, its five rules, the
`schedule_health` facade, the below-grid overview surface, and their tests.

The **only** staffing signal the schedule surfaces is the **insight strip above the
grid** (`presentation/schedule_insights.dart` → `computeScheduleInsights`): *open* ·
*one-person* · *short-rest* · *double-booked* · *leave-clash*, each clickable to
filter the grid, plus a one-line summary caption.

Per-employee stats keep **days worked** and deliberately carry **no morning/night
split and no per-day M/N pattern**: how many days someone works is the operational
fact; which shift types they string together is noise the grid already shows.

## Consequences

- The grid is the hero. Every remaining signal is a *specific, clickable problem*
  rather than a score.
- **Cost:** no at-a-glance "is this week good?" verdict. That is intended — the
  verdict was never trustworthy, and the strip names the actual problems instead.
- If a scoring model is ever wanted again, it needs a new decision that says what
  the score would *gate*. "Advice that never gates" is the failure mode to avoid.
