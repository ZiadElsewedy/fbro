# ADR-003 — Clean Architecture, sliced by feature

**Status:** Accepted · **Date:** 2026-06-14

## Context

The app is built by a rotating set of contributors (human and AI) who each touch a
narrow slice. The risk is Firebase types leaking into the UI, making every widget
untestable and pinning the app to the vendor (ADR-001).

## Decision

Slice by **feature**, three layers each, dependency rule pointing **inward**:

```
presentation → domain ← data
```

- `domain/` — pure Dart. **Never imports Flutter or Firebase.** Entities, abstract
  repository contracts, use cases, and pure business functions.
- `data/` — the only place Firebase exists. Datasources throw `*Exception`;
  repositories catch and rethrow as `*Failure`; models own all serialization and
  convert `Model → Entity` before returning.
- `presentation/` — cubits, pages, widgets. Sees entities only.

DI is hand-wired in `core/di/injection.dart` — no DI package.

## Consequences

- Business rules are pure functions, unit-testable with no Firebase and no widget
  tree. This is why ~880 tests run in ~16 seconds.
- The repository boundary is the migration seam for ADR-001.
- **Cost:** a new action touches five files (datasource → repository contract →
  impl → use case → cubit) plus `injection.dart`. Accepted for writes; sidestepped
  for plain reads by ADR-002's repo-direct shape.
- **Cost:** hand-wired DI means `injection.dart` must be edited for every new
  dependency. Accepted — it is explicit and greppable.
