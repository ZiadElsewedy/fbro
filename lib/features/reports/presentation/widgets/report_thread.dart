import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/presentation/report_format.dart';
import 'package:drop/features/task/domain/entities/activity_entry.dart';
import 'package:drop/features/task/presentation/activity_format.dart' show relativeTime;
import 'package:drop/features/task/presentation/widgets/attachment_gallery.dart';

/// The report **conversation** — a premium chat/support thread. Replies render
/// as left/right bubbles (mine vs the other party); status changes render as
/// quiet centered markers. The opening report is shown by the detail screen as
/// the first message, so the `created` entry is skipped here.
class ReportThread extends StatelessWidget {
  const ReportThread({
    super.key,
    required this.entries,
    required this.currentUid,
    required this.iAmReporter,
  });

  final List<ActivityEntry> entries;
  final String currentUid;

  /// True when the viewer is the report's author (an employee on their own
  /// report) — so their de-identified confidential replies (empty actorId) still
  /// align to the right.
  final bool iAmReporter;

  bool _isMine(ActivityEntry e) =>
      e.actorId == currentUid || (iAmReporter && e.actorId.isEmpty);

  @override
  Widget build(BuildContext context) {
    final thread = entries.where((e) => e.status != 'created').toList();
    if (thread.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text('No replies yet — start the conversation.',
              style: AppTypography.bodySmall),
        ),
      );
    }
    return Column(
      children: [
        for (final e in thread)
          e.status == ReportEntity.commentStatus
              ? _Bubble(entry: e, mine: _isMine(e))
              : _Marker(entry: e),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.entry, required this.mine});
  final ActivityEntry entry;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final who = (entry.actorName ?? '').trim();
    const tail = 4.0; // the flattened "tail" corner nearest the sender
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.lg),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(mine ? AppRadius.lg : tail),
      bottomRight: Radius.circular(mine ? tail : AppRadius.lg),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!mine && who.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(who,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: mine
                    ? AppColors.primary
                    : AppColors.darkSurfaceElevated,
                borderRadius: radius,
                border: mine
                    ? null
                    : Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((entry.note ?? '').trim().isNotEmpty)
                    Text(
                      entry.note!.trim(),
                      style: AppTypography.body.copyWith(
                          color: mine ? AppColors.onPrimary : null),
                    ),
                  if (entry.attachments.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AttachmentGallery(attachments: entry.attachments),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Text(relativeTime(entry.at),
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.entry});
  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = reportMarkerColor(entry.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppRadius.fullAll,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(reportMarkerIcon(entry.status), size: 13, color: color),
              const SizedBox(width: 6),
              Text(reportMarkerTitle(entry.status),
                  style: AppTypography.caption.copyWith(color: color)),
              Text('  ·  ${relativeTime(entry.at)}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}
