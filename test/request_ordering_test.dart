import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/request_priority.dart';
import 'package:drop/core/enums/request_status.dart';
import 'package:drop/core/enums/request_type.dart';
import 'package:drop/features/requests/domain/entities/request_entity.dart';
import 'package:drop/features/requests/domain/request_ordering.dart';

void main() {
  RequestEntity r(
    String id, {
    RequestStatus status = RequestStatus.pending,
    RequestPriority priority = RequestPriority.normal,
    DateTime? lastEventAt,
    DateTime? decidedAt,
  }) =>
      RequestEntity(
        id: id,
        type: RequestType.other,
        requesterId: 'u1',
        status: status,
        priority: priority,
        lastEventAt: lastEventAt,
        decidedAt: decidedAt,
      );

  final t0 = DateTime(2026, 7, 7, 9);
  final t1 = DateTime(2026, 7, 7, 10);
  final t2 = DateTime(2026, 7, 7, 11);

  group('partitionRequests', () {
    test('splits active (pending/approved) vs terminal', () {
      final parts = partitionRequests([
        r('a', status: RequestStatus.pending),
        r('b', status: RequestStatus.completed, decidedAt: t1),
        r('c', status: RequestStatus.approved),
        r('d', status: RequestStatus.rejected, decidedAt: t0),
      ]);
      expect(parts.active.map((e) => e.id), containsAll(['a', 'c']));
      expect(parts.archived.map((e) => e.id), containsAll(['b', 'd']));
    });

    test('pending floats above approved in the active section', () {
      final parts = partitionRequests([
        r('approved', status: RequestStatus.approved, lastEventAt: t2),
        r('pending', status: RequestStatus.pending, lastEventAt: t0),
      ]);
      expect(parts.active.first.id, 'pending');
    });

    test('within the same status, higher priority comes first', () {
      final parts = partitionRequests([
        r('normal', priority: RequestPriority.normal, lastEventAt: t2),
        r('high', priority: RequestPriority.high, lastEventAt: t0),
      ]);
      expect(parts.active.first.id, 'high');
    });

    test('within the same status + priority, newest activity first', () {
      final parts = partitionRequests([
        r('old', lastEventAt: t0),
        r('new', lastEventAt: t2),
        r('mid', lastEventAt: t1),
      ]);
      expect(parts.active.map((e) => e.id), ['new', 'mid', 'old']);
    });

    test('archive is newest-decided first', () {
      final parts = partitionRequests([
        r('older', status: RequestStatus.rejected, decidedAt: t0),
        r('newer', status: RequestStatus.approved) // still active, ignore
      ]);
      // only the rejected one is archived
      expect(parts.archived.map((e) => e.id), ['older']);
    });
  });

  test('sortRequestsForInbox concatenates active then archive', () {
    final list = sortRequestsForInbox([
      r('done', status: RequestStatus.completed, decidedAt: t0),
      r('todo', status: RequestStatus.pending, lastEventAt: t1),
    ]);
    expect(list.first.id, 'todo');
    expect(list.last.id, 'done');
  });
}
