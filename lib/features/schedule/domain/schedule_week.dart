/// Week-math helpers for the weekly schedule (Phase 7). A "week" is identified by
/// its **start date** — the Sunday at 00:00 — so a branch has exactly one
/// schedule document per week, addressed by a deterministic id
/// (`<branchId>_<yyyy-MM-dd>`). This avoids duplicate weekly docs and lets the
/// app read a week directly without a query.
class ScheduleWeek {
  ScheduleWeek._();

  /// The Sunday (00:00) that starts the week containing [date]. `DateTime.weekday`
  /// is Mon=1…Sun=7, so `weekday % 7` is the number of days since Sunday.
  static DateTime startOf(DateTime date) {
    final midnight = DateTime(date.year, date.month, date.day);
    return midnight.subtract(Duration(days: date.weekday % 7));
  }

  /// The start (Sunday) of the current week.
  static DateTime currentWeekStart() => startOf(DateTime.now());

  /// Deterministic document id for a branch's schedule in a given week.
  static String docId(String branchId, DateTime weekStart) {
    final w = startOf(weekStart);
    return '${branchId}_${_iso(w)}';
  }

  /// `Sun dd/MM – Sat dd/MM` label for the week selector.
  static String rangeLabel(DateTime weekStart) {
    final start = startOf(weekStart);
    final end = start.add(const Duration(days: 6));
    return '${_two(start.day)}/${_two(start.month)} – '
        '${_two(end.day)}/${_two(end.month)}';
  }

  static bool isSameWeek(DateTime a, DateTime b) =>
      startOf(a) == startOf(b);

  static String _iso(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String _two(int n) => n.toString().padLeft(2, '0');
}
