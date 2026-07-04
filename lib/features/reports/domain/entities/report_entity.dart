import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drop/core/enums/report_category.dart';
import 'package:drop/core/enums/report_privacy.dart';
import 'package:drop/core/enums/report_recipient.dart';
import 'package:drop/core/enums/report_severity.dart';
import 'package:drop/core/enums/report_status.dart';
import 'package:drop/features/task/domain/entities/activity_entry.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

part 'report_entity.freezed.dart';

/// A single internal report / escalation in DROP's **Reports Center**. An
/// employee files a categorized, severity-rated report, routes it to their
/// manager and/or admin (optionally confidentially), and the recipient reviews
/// and resolves it as a lightweight **escalation conversation** — a message-first
/// thread, not a task. No ownership / assignment machinery.
///
/// **Privacy split:** this doc (`reports/{id}`) is readable by the branch
/// manager, admin, and the reporter, and it **never carries the creator uid**.
/// The reporter's identity lives in the private `reports/{id}/reporter/identity`
/// subdoc ([ReportIdentity]); only [reporterDisplayName] (present when
/// [privacy] is normal) surfaces the sender here.
///
/// **Conversation:** [activityLog] is the thread — the reporter's opening message
/// (the report itself), recipient/reporter **replies** (an entry with
/// `status == 'comment'` + `note`), and subtle status markers — reusing the task
/// [ActivityEntry].
@freezed
class ReportEntity with _$ReportEntity {
  const ReportEntity._();

  const factory ReportEntity({
    required String id,
    /// Owning branch (the reporter's branch). Scopes every read/query.
    String? branchId,
    required String title,
    String? description,
    @Default(ReportCategory.operations) ReportCategory category,
    @Default(ReportRecipient.manager) ReportRecipient recipient,
    @Default(ReportPrivacy.normal) ReportPrivacy privacy,
    @Default(ReportSeverity.medium) ReportSeverity severity,
    @Default(ReportStatus.newReport) ReportStatus status,
    /// Denormalized sender name — set ONLY when [privacy] is normal; null
    /// otherwise (UI then shows "Confidential Sender"). The raw uid is never
    /// here (see the private `reporter/identity` subdoc).
    String? reporterDisplayName,
    /// Media attached to the report (reuses the task attachment pipeline;
    /// Storage `reports/{id}/attachments/{attId}.<ext>`).
    @Default(<TaskAttachment>[]) List<TaskAttachment> attachments,
    /// The conversation thread (opening message context + replies + markers).
    @Default(<ActivityEntry>[]) List<ActivityEntry> activityLog,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) = _ReportEntity;

  /// Whether a branch manager may see this report — the denormalized flag the
  /// manager list query + Firestore rule key off. Derived from [recipient] so it
  /// can never drift (the model writes this to `visibleToManager`).
  bool get visibleToManager => recipient.includesManager;

  /// Still needs attention (drives urgency + "open reports" counts).
  bool get isActive => status.isActive;

  bool get hasAttachments => attachments.isNotEmpty;

  /// The human comments in the timeline (status == 'comment').
  List<ActivityEntry> get comments =>
      activityLog.where((e) => e.status == commentStatus).toList();

  bool get hasComments => activityLog.any((e) => e.status == commentStatus);

  /// The label to show for the sender, honoring [privacy]. Presentation reuses
  /// this so the mapping lives in one place.
  String get senderLabel {
    if (privacy.isConfidential) return 'Confidential Sender';
    final name = reporterDisplayName?.trim();
    return (name != null && name.isNotEmpty) ? name : 'Reporter';
  }

  /// The activity-log `status` value used for a discussion comment (not a
  /// lifecycle transition). Kept here so the datasource, cubit, and timeline all
  /// agree on the one magic string.
  static const String commentStatus = 'comment';
}
