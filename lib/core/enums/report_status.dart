/// Lifecycle of a report, stored in `reports/{id}.status`. Deliberately short —
/// Reports are escalation conversations, not tasks, so there's no start / submit
/// / approve / reject machinery:
///
/// `New → Under Review → Waiting Reply → Resolved`
///
/// The reporter files a [newReport]; the recipient (manager/admin) moves it
/// through review, optionally parking it on [waitingReply] while they wait for
/// the reporter, and closes it as [resolved]. A resolved report can be reopened.
enum ReportStatus {
  newReport,
  underReview,
  waitingReply,
  resolved;

  String get value => name;

  bool get isNew => this == ReportStatus.newReport;
  bool get isUnderReview => this == ReportStatus.underReview;
  bool get isWaitingReply => this == ReportStatus.waitingReply;
  bool get isResolved => this == ReportStatus.resolved;

  /// Still an open conversation — counts toward "active" + the urgency engine.
  bool get isActive => this != ReportStatus.resolved;

  String get label => switch (this) {
        ReportStatus.newReport => 'New',
        ReportStatus.underReview => 'Under Review',
        ReportStatus.waitingReply => 'Waiting Reply',
        ReportStatus.resolved => 'Resolved',
      };

  /// The statuses a recipient may move this report to next.
  List<ReportStatus> get allowedNext => switch (this) {
        ReportStatus.newReport => const [
            ReportStatus.underReview,
            ReportStatus.resolved,
          ],
        ReportStatus.underReview => const [
            ReportStatus.waitingReply,
            ReportStatus.resolved,
          ],
        ReportStatus.waitingReply => const [
            ReportStatus.underReview,
            ReportStatus.resolved,
          ],
        ReportStatus.resolved => const [ReportStatus.underReview], // reopen
      };

  bool canTransitionTo(ReportStatus to) => allowedNext.contains(to);

  /// Parses the stored string; unknown/missing → [newReport].
  static ReportStatus fromString(String? raw) {
    for (final s in ReportStatus.values) {
      if (s.name == raw) return s;
    }
    return ReportStatus.newReport;
  }
}
