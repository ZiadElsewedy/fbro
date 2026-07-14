import 'package:drop/features/attendance/domain/attendance_config.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';

/// The attendance module's **policy seam** — the single place that answers
/// "*is attendance on for this user, and with what rules?*". Pure + framework-free.
///
/// Today every branch runs the standing [AttendanceConfig.defaults] with the
/// module enabled. This service is deliberately the one point that later reads a
/// per-branch `branches/{id}/attendanceConfig` (grace windows, geofence, photo,
/// unscheduled clock-in) into an [AttendanceConfig] — so turning attendance into
/// branch-configurable data is a change *here*, with no call-site churn.
///
/// It also owns the module **dark switch** ([isEnabledFor]): while a branch hasn't
/// opted in, the clock surface is inert and the (future) task-start guard is a
/// no-op, so shipping the module never regresses an existing branch. The cubit
/// and any cross-feature guard consult this instead of hard-coding the config.
class AttendanceService {
  const AttendanceService();

  /// The resolved attendance rules for [user]'s branch. The single config seam.
  AttendanceConfig configFor(UserEntity user) =>
      const AttendanceConfig(enabled: true);

  /// Whether the attendance module is live for [user] (the dark-switch gate).
  bool isEnabledFor(UserEntity user) => configFor(user).enabled;
}
