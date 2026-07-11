import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/attendance_status.dart';

void main() {
  group('AttendanceStatus', () {
    test('is lifecycle-only — carries no approve/reject state', () {
      // Approval/rejection belongs to Attendance Correction Requests, not here.
      final names = AttendanceStatus.values.map((s) => s.name).toSet();
      expect(names.contains('approved'), isFalse);
      expect(names.contains('rejected'), isFalse);
      expect(AttendanceStatus.values.length, 6);
    });

    test('inProgress is the only live session', () {
      expect(AttendanceStatus.inProgress.isInProgress, isTrue);
      for (final s in AttendanceStatus.values) {
        if (s != AttendanceStatus.inProgress) {
          expect(s.isInProgress, isFalse, reason: '$s');
        }
      }
    });

    test('terminal states are completed/absent/onLeave (pendingReview is not)', () {
      const terminal = {
        AttendanceStatus.completed,
        AttendanceStatus.absent,
        AttendanceStatus.onLeave,
      };
      for (final s in AttendanceStatus.values) {
        expect(s.isTerminal, terminal.contains(s), reason: '$s');
      }
      expect(AttendanceStatus.pendingReview.isTerminal, isFalse);
    });

    test('only pendingReview needs review', () {
      expect(AttendanceStatus.pendingReview.needsReview, isTrue);
      expect(AttendanceStatus.completed.needsReview, isFalse);
    });

    test('presence covers everyone who showed up (incl. pending review)', () {
      const present = {
        AttendanceStatus.inProgress,
        AttendanceStatus.completed,
        AttendanceStatus.pendingReview,
      };
      for (final s in AttendanceStatus.values) {
        expect(s.isPresent, present.contains(s), reason: '$s');
      }
    });

    test('absent is the only absence outcome', () {
      expect(AttendanceStatus.absent.isAbsence, isTrue);
      expect(AttendanceStatus.onLeave.isAbsence, isFalse);
      expect(AttendanceStatus.completed.isAbsence, isFalse);
    });

    test('fromString round-trips and defaults to scheduled', () {
      for (final s in AttendanceStatus.values) {
        expect(AttendanceStatus.fromString(s.value), s);
      }
      expect(AttendanceStatus.fromString('nonsense'), AttendanceStatus.scheduled);
      expect(AttendanceStatus.fromString(null), AttendanceStatus.scheduled);
      // Legacy values that no longer exist fall back safely.
      expect(AttendanceStatus.fromString('approved'), AttendanceStatus.scheduled);
    });
  });
}
