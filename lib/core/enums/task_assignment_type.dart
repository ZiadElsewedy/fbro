/// How a task's work is assigned. `individual`/`team` both populate
/// [TaskEntity.assigneeIds] (a team is just a multi-person pick — there is no
/// separate named-team entity); `shift` leaves `assigneeIds` empty and instead
/// targets whoever is rostered on [TaskEntity.shift] for the relevant day (see
/// `canUserAccessTask`). Stored lower-case in `tasks/{id}.assignmentType`.
enum TaskAssignmentType {
  individual,
  team,
  shift;

  /// The string persisted in Firestore (the lower-case name).
  String get value => name;

  /// Parses the stored string; missing/unknown → [individual] (every task
  /// written before this field existed keeps working unchanged).
  static TaskAssignmentType fromString(String? raw) => switch (raw) {
        'team' => team,
        'shift' => shift,
        _ => individual,
      };

  String get label => switch (this) {
        TaskAssignmentType.individual => 'Employee',
        TaskAssignmentType.team => 'Team',
        TaskAssignmentType.shift => 'Shift',
      };
}
