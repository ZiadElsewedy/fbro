import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/request_status.dart';

void main() {
  group('RequestStatus lifecycle', () {
    test('has exactly five states with the expected labels', () {
      expect(RequestStatus.values.length, 5);
      expect(RequestStatus.pending.label, 'Pending');
      expect(RequestStatus.approved.label, 'Approved');
      expect(RequestStatus.completed.label, 'Completed');
      expect(RequestStatus.rejected.label, 'Rejected');
      expect(RequestStatus.cancelled.label, 'Cancelled');
    });

    test('pending is active and can advance to approved or rejected', () {
      expect(RequestStatus.pending.isActive, isTrue);
      expect(RequestStatus.pending.approverNext,
          [RequestStatus.approved, RequestStatus.rejected]);
    });

    test('approved is active and can advance only to completed', () {
      expect(RequestStatus.approved.isActive, isTrue);
      expect(RequestStatus.approved.approverNext, [RequestStatus.completed]);
    });

    test('terminal states are inactive with no next transitions', () {
      for (final s in [
        RequestStatus.completed,
        RequestStatus.rejected,
        RequestStatus.cancelled,
      ]) {
        expect(s.isActive, isFalse, reason: '$s should be inactive');
        expect(s.isTerminal, isTrue);
        expect(s.approverNext, isEmpty);
      }
    });

    test('only pending lets the requester cancel', () {
      expect(RequestStatus.pending.requesterCanCancel, isTrue);
      expect(RequestStatus.approved.requesterCanCancel, isFalse);
      expect(RequestStatus.completed.requesterCanCancel, isFalse);
    });

    test('approve/reject are decisions; complete/cancel are not', () {
      expect(RequestStatus.approved.isDecision, isTrue);
      expect(RequestStatus.rejected.isDecision, isTrue);
      expect(RequestStatus.completed.isDecision, isFalse);
      expect(RequestStatus.cancelled.isDecision, isFalse);
    });

    test('rejected and cancelled are negative outcomes', () {
      expect(RequestStatus.rejected.isNegative, isTrue);
      expect(RequestStatus.cancelled.isNegative, isTrue);
      expect(RequestStatus.approved.isNegative, isFalse);
      expect(RequestStatus.completed.isNegative, isFalse);
    });

    test('fromString is lenient and defaults to pending', () {
      expect(RequestStatus.fromString('approved'), RequestStatus.approved);
      expect(RequestStatus.fromString('nonsense'), RequestStatus.pending);
      expect(RequestStatus.fromString(null), RequestStatus.pending);
    });
  });
}
