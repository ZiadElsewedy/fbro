/// The operational push-notification events DROP THE SHOP sends (Phase 6).
/// These are the agreed `type` values for the FCM **data** payload — the
/// contract a server-side sender (e.g. a Cloud Function) would use.
///
/// The client side (see `NotificationService`) only **registers the device
/// token** and **handles received messages** — there is no in-app history,
/// inbox, or chat. Actually emitting these on the listed triggers requires a
/// server trigger, which is intentionally out of scope (no Node.js / Cloud
/// Functions in this phase).
enum NotificationType {
  // ── Employee ──
  taskAssigned,
  taskApproved,
  taskRejected,
  shiftChanged,
  managerNote,
  // ── Employee · weekly schedule + swaps (Phase 7) ──
  tomorrowShiftReminder,
  swapApproved,
  swapRejected,
  // ── Manager ──
  taskWaitingReview,
  employeeCompletedTask,
  newEmployeePendingApproval,
  shiftWithoutEmployees,
  // ── Manager · shift swaps (Phase 7) ──
  newSwapRequest,
  swapPendingApproval,
  // ── Admin ──
  newEmployeeRegistration,
  branchWithoutManager,
  manyRejectedTasks,
  branchWithoutActiveEmployees,
  // ── Admin · weekly schedule (Phase 7) ──
  branchWithoutSchedule;

  String get value => name;

  static NotificationType? fromString(String? raw) {
    for (final t in NotificationType.values) {
      if (t.name == raw) return t;
    }
    return null;
  }
}
