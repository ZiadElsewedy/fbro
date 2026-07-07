import 'package:drop/features/requests/domain/entities/request_entity.dart';

/// Inbox ordering for the requests list (the left split-pane) — an approval inbox,
/// not a task board. Pure Dart, deterministic given the same inputs.
///
/// Rules:
///   1. Active requests (Pending / Approved) come first; terminal ones archive.
///   2. Among active, **Pending** (needs a decision) floats above Approved.
///   3. Then by **priority** (High → Normal → Low).
///   4. Then by latest activity, newest first.
///   5. The archive section is newest-decided first.

int _cmpDateDesc(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1; // nulls last
  if (b == null) return -1;
  return b.compareTo(a); // newest first
}

int _cmpActive(RequestEntity a, RequestEntity b) {
  // Pending before Approved.
  if (a.status.isPending != b.status.isPending) {
    return a.status.isPending ? -1 : 1;
  }
  // Higher priority first.
  if (a.priority.weight != b.priority.weight) {
    return b.priority.weight.compareTo(a.priority.weight);
  }
  return _cmpDateDesc(a.lastActivityAt, b.lastActivityAt);
}

int _cmpArchived(RequestEntity a, RequestEntity b) => _cmpDateDesc(
      a.decidedAt ?? a.completedAt ?? a.lastActivityAt,
      b.decidedAt ?? b.completedAt ?? b.lastActivityAt,
    );

/// Splits requests into the two inbox sections, each already sorted.
({List<RequestEntity> active, List<RequestEntity> archived}) partitionRequests(
  List<RequestEntity> requests,
) {
  final active = <RequestEntity>[];
  final archived = <RequestEntity>[];
  for (final r in requests) {
    (r.isActive ? active : archived).add(r);
  }
  active.sort(_cmpActive);
  archived.sort(_cmpArchived);
  return (active: active, archived: archived);
}

/// The full inbox order (active section then archive), for a single flat list.
List<RequestEntity> sortRequestsForInbox(List<RequestEntity> requests) {
  final parts = partitionRequests(requests);
  return [...parts.active, ...parts.archived];
}
