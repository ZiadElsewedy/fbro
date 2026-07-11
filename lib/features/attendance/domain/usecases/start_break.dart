import 'package:drop/features/attendance/domain/attendance_break.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';
import 'package:drop/features/attendance/domain/repositories/attendance_repository.dart';

/// Starts a break — appends an open [AttendanceBreak] to the record. No minute
/// snapshot is persisted (worked/break totals are only finalized at clock-out).
class StartBreak {
  final AttendanceRepository _repository;
  const StartBreak(this._repository);

  Future<void> call(AttendanceEntity record, {required DateTime now}) {
    final breaks = [...record.breaks, AttendanceBreak(start: now)];
    return _repository.updateBreaks(record.id, breaks);
  }
}
