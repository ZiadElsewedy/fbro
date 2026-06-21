import 'package:fbro/core/enums/attachment_type.dart';
import 'package:fbro/features/task/domain/entities/activity_entry.dart';
import 'package:fbro/features/task/domain/entities/task_attachment.dart';
import 'package:fbro/features/task/domain/entities/task_entity.dart';

/// Presentation helpers for task media (Phase 10). Resolve which attachments a
/// timeline event should show — including a back-compat path that surfaces a
/// **legacy** single `proofImageUrl` as one synthesized image attachment for
/// tasks submitted before media moved onto events.

/// True when any event on the task carries real (Phase 10) media — used to avoid
/// double-rendering the legacy proof alongside new event attachments.
bool _hasEventAttachments(TaskEntity task) =>
    task.activityLog.any((e) => e.attachments.isNotEmpty);

/// Attachments to render for [entry]. Returns the event's own media when present;
/// otherwise, for a truly legacy task, synthesizes the single `proofImageUrl` on
/// the "submitted for review" event so old submissions still show their proof.
List<TaskAttachment> attachmentsForEvent(ActivityEntry entry, TaskEntity task) {
  if (entry.attachments.isNotEmpty) return entry.attachments;
  final proof = task.proofImageUrl ?? '';
  if (proof.isNotEmpty &&
      entry.status == 'waitingReview' &&
      !_hasEventAttachments(task)) {
    return [_legacy(proof, entry.at, entry.actorId, entry.actorName)];
  }
  return const [];
}

/// The most recent submission's media — for the "Submitted work" quick view and
/// the review sheet. Falls back to the legacy proof image.
List<TaskAttachment> latestAttachments(TaskEntity task) {
  for (final e in task.activityLog.reversed) {
    if (e.attachments.isNotEmpty) return e.attachments;
  }
  final proof = task.proofImageUrl ?? '';
  if (proof.isNotEmpty) {
    return [_legacy(proof, task.submittedAt ?? DateTime.now(), '', null)];
  }
  return const [];
}

TaskAttachment _legacy(String url, DateTime at, String by, String? byName) =>
    TaskAttachment(
      id: 'legacy',
      url: url,
      type: AttachmentType.image,
      uploadedAt: at,
      uploadedBy: by,
      uploadedByName: byName,
    );

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Full upload timestamp, e.g. `20 Jun 2026 • 4:32 PM`.
String attachmentTimestamp(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ampm = d.hour < 12 ? 'AM' : 'PM';
  final min = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_months[d.month - 1]} ${d.year} • $h12:$min $ampm';
}

/// Compact summary like `4 photos`, `1 video`, `3 photos · 1 video`.
String attachmentSummary(List<TaskAttachment> items) {
  final images = items.where((a) => a.type.isImage).length;
  final videos = items.where((a) => a.type.isVideo).length;
  final parts = <String>[];
  if (images > 0) parts.add('$images photo${images == 1 ? '' : 's'}');
  if (videos > 0) parts.add('$videos video${videos == 1 ? '' : 's'}');
  return parts.join(' · ');
}
