class AppConstants {
  AppConstants._();

  static const String appName = 'DROP';
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String taskTemplatesCollection = 'task_templates';
  static const String recurringTaskTemplatesCollection = 'recurringTaskTemplates';
  static const String branchesCollection = 'branches';
  static const String weeklySchedulesCollection = 'weekly_schedules';
  static const String shiftSwapsCollection = 'shift_swaps';
  static const String broadcastsCollection = 'broadcasts';
  static const String notificationsCollection = 'notifications';

  /// Reports Center (Reports / Escalation System). The reporter's identity lives
  /// in the private subcollection `reports/{id}/reporter/identity`.
  static const String reportsCollection = 'reports';

  // ─── Communications Center — Phase 2 ──────────────────────────
  static const String broadcastTemplatesCollection = 'broadcastTemplates';
  static const String broadcastSchedulesCollection = 'broadcastSchedules';
  static const String reminderConfigCollection = 'reminderConfig';
  static const String savedAudiencesCollection = 'savedAudiences';
  static const String taskRemindersCollection = 'taskReminders';
}
