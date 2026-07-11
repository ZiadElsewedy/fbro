import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drop/core/enums/leave_type.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/attendance/domain/attendance_config.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';

part 'attendance_state.freezed.dart';

@freezed
class AttendanceState with _$AttendanceState {
  const factory AttendanceState.initial() = _Initial;

  /// First load (full-screen skeleton).
  const factory AttendanceState.loading() = _Loading;

  /// Loaded. [today] is the record the clock UI acts on — the live open session
  /// if one exists (including an overnight session from yesterday), else today's
  /// record for the resolved [shift], else null (not clocked in yet). [shift] /
  /// [scheduledStart] / [scheduledEnd] describe today's rostered slot (null when
  /// nothing is rostered); [leave] is set when the employee is on leave today.
  /// [tick] is bumped by the live timer so the worked-time display recomputes.
  const factory AttendanceState.loaded({
    AttendanceEntity? today,
    @Default(<AttendanceEntity>[]) List<AttendanceEntity> history,
    ScheduleShift? shift,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    LeaveType? leave,
    required AttendanceConfig config,
    required DateTime tick,
    @Default(false) bool busy,
  }) = _Loaded;

  /// Transient — surfaced as a snackbar; the cubit immediately re-emits the last
  /// [loaded] snapshot so the UI never loses its data.
  const factory AttendanceState.error(String message) = _Error;
}
