# ADR-009 — No analytics pipeline

**Status:** Accepted · **Date:** 2026-06-23

## Context

The Communications Center shipped an analytics pipeline: `onNotificationRead` /
`onBroadcastOpened` Functions, a `bumpAnalytics` aggregator, `analytics/{YYYY-MM}`
rollups, a `broadcastOpens` collection, an `openedCount` field, and a charts screen.

Reviewed against a single question — *what decision does this change?* — the answer
was none. An open rate on a broadcast to twelve people you see every day is a number
you look at once. It was vanity metrics with a Cloud Function bill.

## Decision

The analytics pipeline is **deleted**. No open tracking, no rollups, no charts
screen.

**Kept:** minimal delivery diagnostics on `broadcast_detail_screen` — recipients ·
delivered · failed. Those answer a real question ("did it actually send?").

Also kept from that era, because they earn their place: broadcast history,
templates, custom audiences, and the scheduler.

## Consequences

- Less to maintain, no per-read write amplification, no rollup consistency to worry
  about.
- **Cost:** no historical engagement data, and none is recoverable retroactively.
  Accepted.
- The precedent generalizes: **before building a metric, name the decision it
  changes.** If you cannot, do not build it. `automationRuns` telemetry currently
  has no reader and is the next candidate for this test.
