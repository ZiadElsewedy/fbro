import 'package:drop/core/enums/leave_type.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/attendance/domain/attendance_config.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';

/// Why a clock action can't proceed. [none] means "allowed". Each carries a
/// user-facing [message]; the enum value gives the UI a stable code to key on.
enum AttendanceBlock {
  none,
  notEnabled,
  userDisabled,
  noActiveShift,
  onLeave,
  outsideWindow,
  alreadyClockedIn,
  alreadyClockedOut,
  notClockedIn,
  openBreak,
  noOpenBreak;

  bool get isBlocked => this != AttendanceBlock.none;
}

/// The outcome of a validation check — [allowed] plus a human [message] when
/// blocked. Mirrors the "return a reason" shape of `MoveValidation`, but typed so
/// callers (cubit + UI + tests) can branch on the [reason] code, not a string.
class AttendanceCheck {
  final AttendanceBlock reason;
  final String message;

  const AttendanceCheck(this.reason, [this.message = '']);

  static const AttendanceCheck ok = AttendanceCheck(AttendanceBlock.none);

  bool get allowed => reason == AttendanceBlock.none;
  bool get blocked => !allowed;
}

/// The pure, reusable **validation engine** for attendance clock actions. No
/// Flutter, no Firestore — every input is passed in (the caller resolves the
/// roster / user / existing record), so each rule is independently unit-testable.
/// This is the single place clock rules live; the cubit and the UI both consult
/// it rather than re-deriving.
class AttendanceValidation {
  AttendanceValidation._();

  /// Can [existing == null ? "this user" : "this record"] clock **in** now?
  ///
  /// Rules, in order of precedence:
  ///   module enabled → user active → not on leave → has a shift (unless the
  ///   config allows unscheduled) → not already in/out for this shift → inside
  ///   the clock-in window `[start − lead, scheduledEnd]`.
  static AttendanceCheck checkClockIn({
    required bool userActive,
    required ScheduleShift? todaysShift,
    required LeaveType? leave,
    required DateTime? scheduledStart,
    required DateTime? scheduledEnd,
    required AttendanceEntity? existing,
    required DateTime now,
    AttendanceConfig config = AttendanceConfig.defaults,
  }) {
    if (!config.enabled) {
      return const AttendanceCheck(
          AttendanceBlock.notEnabled, 'Attendance isn\'t enabled here.');
    }
    if (!userActive) {
      return const AttendanceCheck(
          AttendanceBlock.userDisabled, 'Your account is inactive.');
    }
    if (leave != null) {
      return AttendanceCheck(
          AttendanceBlock.onLeave, 'You\'re on ${leave.label.toLowerCase()} today.');
    }
    if (todaysShift == null && !config.allowUnscheduledClockIn) {
      return const AttendanceCheck(
          AttendanceBlock.noActiveShift, 'You have no shift scheduled today.');
    }
    if (existing != null && existing.isOpen) {
      return const AttendanceCheck(
          AttendanceBlock.alreadyClockedIn, 'You\'re already clocked in.');
    }
    if (existing != null && existing.hasClockedOut) {
      return const AttendanceCheck(AttendanceBlock.alreadyClockedOut,
          'You\'ve already completed this shift.');
    }
    // Window check only applies when we know the scheduled bounds.
    if (scheduledStart != null) {
      final opensAt =
          scheduledStart.subtract(Duration(minutes: config.clockInLeadMinutes));
      if (now.isBefore(opensAt)) {
        return AttendanceCheck(AttendanceBlock.outsideWindow,
            'Too early — you can clock in from ${_hhmm(opensAt)}.');
      }
      if (scheduledEnd != null && now.isAfter(scheduledEnd)) {
        return const AttendanceCheck(AttendanceBlock.outsideWindow,
            'This shift has ended — file a correction instead.');
      }
    }
    return AttendanceCheck.ok;
  }

  /// Can [existing] clock **out** now? Needs an open session with no running
  /// break.
  static AttendanceCheck checkClockOut({
    required AttendanceEntity? existing,
    required DateTime now,
    AttendanceConfig config = AttendanceConfig.defaults,
  }) {
    if (!config.enabled) {
      return const AttendanceCheck(
          AttendanceBlock.notEnabled, 'Attendance isn\'t enabled here.');
    }
    if (existing == null || !existing.hasClockedIn) {
      return const AttendanceCheck(
          AttendanceBlock.notClockedIn, 'You haven\'t clocked in.');
    }
    if (existing.hasClockedOut) {
      return const AttendanceCheck(
          AttendanceBlock.alreadyClockedOut, 'You\'ve already clocked out.');
    }
    if (existing.isOnBreak) {
      return const AttendanceCheck(
          AttendanceBlock.openBreak, 'End your break before clocking out.');
    }
    return AttendanceCheck.ok;
  }

  /// Can [existing] start a break now? Needs an open session and no break already
  /// running.
  static AttendanceCheck checkStartBreak({required AttendanceEntity? existing}) {
    if (existing == null || !existing.isOpen) {
      return const AttendanceCheck(
          AttendanceBlock.notClockedIn, 'Clock in before taking a break.');
    }
    if (existing.isOnBreak) {
      return const AttendanceCheck(
          AttendanceBlock.openBreak, 'You\'re already on a break.');
    }
    return AttendanceCheck.ok;
  }

  /// Can [existing] end a break now? Needs a break currently running.
  static AttendanceCheck checkEndBreak({required AttendanceEntity? existing}) {
    if (existing == null || !existing.isOnBreak) {
      return const AttendanceCheck(
          AttendanceBlock.noOpenBreak, 'No break is running.');
    }
    return AttendanceCheck.ok;
  }

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
