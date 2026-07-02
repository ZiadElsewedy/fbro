/// How often a [RecurringTaskTemplateEntity] generates a task instance.
/// Distinct from [RecurrenceFrequency] (which drives the existing per-task
/// spawn-on-approve recurrence for individually/team-assigned tasks) — this one
/// drives the date-based `generateShiftTaskInstances` Cloud Function instead.
/// Stored lower-case in `recurringTaskTemplates/{id}.repeat`.
enum TemplateRepeatMode {
  once,
  daily,
  weekly;

  /// The string persisted in Firestore (the lower-case name).
  String get value => name;

  /// Parses the stored string; missing/unknown → [once].
  static TemplateRepeatMode fromString(String? raw) => switch (raw) {
        'daily' => daily,
        'weekly' => weekly,
        _ => once,
      };

  String get label => switch (this) {
        TemplateRepeatMode.once => 'Once',
        TemplateRepeatMode.daily => 'Daily',
        TemplateRepeatMode.weekly => 'Weekly',
      };
}
