import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';
import 'package:drop/features/attendance/domain/repositories/attendance_repository.dart';

/// Ends the currently-open break — closes it at [now]. A no-op (no write) when
/// no break is running, so a double-tap can't corrupt the array.
class EndBreak {
  final AttendanceRepository _repository;
  const EndBreak(this._repository);

  Future<void> call(AttendanceEntity record, {required DateTime now}) async {
    if (!record.isOnBreak) return;
    final breaks = [
      for (final b in record.breaks) b.isOpen ? b.closeAt(now) : b,
    ];
    await _repository.updateBreaks(record.id, breaks);
  }
}
