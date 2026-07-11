/// One break within a shift — an interval `[start, end)`; a null [end] means the
/// break is still running. Pure + framework-free (mirrors `ShiftHours`): the
/// Firestore `Timestamp ⇄ DateTime` conversion lives in `AttendanceModel`, so
/// this value object never touches Firebase.
///
/// Breaks are a **small array on the attendance doc**, not a subcollection: they
/// are single-writer (only the employee whose shift it is edits them) and few,
/// so the array read-modify-write that bit the old multi-writer logs is not a
/// risk here.
class AttendanceBreak {
  final DateTime start;

  /// When the break ended, or null while it's still open.
  final DateTime? end;

  const AttendanceBreak({required this.start, this.end});

  /// Still running (no [end] recorded yet).
  bool get isOpen => end == null;

  /// The break length in whole minutes. For a closed break that's `end - start`;
  /// for an open one it's measured to [now] (so the live worked-time timer nets
  /// out an in-progress break). Never negative.
  int minutes(DateTime now) {
    final until = end ?? now;
    final diff = until.difference(start).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  AttendanceBreak copyWith({DateTime? start, DateTime? end}) =>
      AttendanceBreak(start: start ?? this.start, end: end ?? this.end);

  /// Returns a copy closed at [when] (used when the employee ends the break).
  AttendanceBreak closeAt(DateTime when) =>
      AttendanceBreak(start: start, end: when);

  @override
  bool operator ==(Object other) =>
      other is AttendanceBreak && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'AttendanceBreak($start → ${end ?? 'open'})';
}

/// Total break minutes across [breaks], measured to [now] for any open break.
int totalBreakMinutes(List<AttendanceBreak> breaks, DateTime now) {
  var total = 0;
  for (final b in breaks) {
    total += b.minutes(now);
  }
  return total;
}

/// The currently-open break in [breaks], or null when none is running.
AttendanceBreak? openBreak(List<AttendanceBreak> breaks) {
  for (final b in breaks) {
    if (b.isOpen) return b;
  }
  return null;
}
