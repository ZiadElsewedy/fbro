import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_event.freezed.dart';

/// What produced an entry in an attendance record's audit trail. The trail is
/// **fully event-driven** and append-only — every meaningful action is one
/// immutable document in `attendance/{id}/events`, reusing the Requests
/// precedent that deliberately avoids the whole-array read-modify-write bug.
/// "Nothing silently modifies attendance": each of these leaves a trace.
enum AttendanceEventKind {
  clockedIn,
  clockedOut,
  breakStarted,
  breakEnded,
  autoClosed,
  correctionRequested,
  correctionApproved,
  correctionRejected,
  reviewed,
  managerEdited,
  markedAbsent;

  String get value => name;

  String get label => switch (this) {
        AttendanceEventKind.clockedIn => 'Clocked in',
        AttendanceEventKind.clockedOut => 'Clocked out',
        AttendanceEventKind.breakStarted => 'Break started',
        AttendanceEventKind.breakEnded => 'Break ended',
        AttendanceEventKind.autoClosed => 'Auto-closed',
        AttendanceEventKind.correctionRequested => 'Correction requested',
        AttendanceEventKind.correctionApproved => 'Correction approved',
        AttendanceEventKind.correctionRejected => 'Correction rejected',
        AttendanceEventKind.reviewed => 'Reviewed',
        AttendanceEventKind.managerEdited => 'Manager edit',
        AttendanceEventKind.markedAbsent => 'Marked absent',
      };

  /// A system/manager action (rendered as a centered marker, not a clock event).
  bool get isSystem =>
      this == AttendanceEventKind.autoClosed ||
      this == AttendanceEventKind.correctionApproved ||
      this == AttendanceEventKind.correctionRejected ||
      this == AttendanceEventKind.reviewed ||
      this == AttendanceEventKind.managerEdited ||
      this == AttendanceEventKind.markedAbsent;

  /// A correction lifecycle marker (request → approved/rejected).
  bool get isCorrection =>
      this == AttendanceEventKind.correctionRequested ||
      this == AttendanceEventKind.correctionApproved ||
      this == AttendanceEventKind.correctionRejected;

  static AttendanceEventKind fromString(String? raw) {
    for (final k in AttendanceEventKind.values) {
      if (k.name == raw) return k;
    }
    return AttendanceEventKind.managerEdited;
  }
}

/// One entry in an attendance record's audit trail — a document in
/// `attendance/{id}/events`. Append-only + immutable (a single `add`, never a
/// rewrite).
@freezed
class AttendanceEvent with _$AttendanceEvent {
  const AttendanceEvent._();

  const factory AttendanceEvent({
    required String id,
    required AttendanceEventKind kind,

    /// Who performed it (the employee, a manager, or '' for a system action).
    @Default('') String actorId,
    String? actorName,

    /// Free text — a correction reason or a review comment.
    String? note,

    /// Structured payload for edits/corrections (e.g. the proposed
    /// `clockIn`/`clockOut`, or before/after values). Kept as a small map so the
    /// shape stays flexible without new fields.
    @Default(<String, dynamic>{}) Map<String, dynamic> data,
    required DateTime createdAt,
  }) = _AttendanceEvent;

  bool get isSystem => kind.isSystem;
  bool get isCorrection => kind.isCorrection;
  bool get hasNote => (note ?? '').trim().isNotEmpty;
}
