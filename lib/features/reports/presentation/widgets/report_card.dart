import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/widgets/status_badge.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/report_urgency.dart';
import 'package:drop/features/reports/presentation/report_format.dart';
import 'package:drop/features/task/presentation/activity_format.dart' show relativeTime;

/// A dense, scannable, strictly-monochrome row for one report in the Reports
/// Center list. Leads with the category glyph; shows the title, a compact meta
/// line (category · severity · time · comments · privacy), a status chip, and an
/// SLA/urgency badge when the report is due-soon / breached.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.branchName,
    this.now,
  });

  final ReportEntity report;
  final VoidCallback onTap;

  /// Shown for the admin/global list (which spans branches). Null → hidden.
  final String? branchName;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final clock = now ?? DateTime.now();
    final urgency = reportUrgencyLevel(report, clock);
    final severityColor = reportSeverityColor(report.severity);

    return Material(
      color: AppColors.darkSurfaceElevated,
      borderRadius: AppRadius.cardAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardAll,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryTile(icon: reportCategoryIcon(report.category)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report.title,
                            style: AppTypography.body
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatusBadge(
                          label: report.status.label,
                          color: reportStatusColor(report.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _MetaLine(
                      report: report,
                      severityColor: severityColor,
                      branchName: branchName,
                      time: report.createdAt == null
                          ? ''
                          : relativeTime(report.createdAt!),
                    ),
                    if (urgency != ReportUrgencyLevel.calm) ...[
                      const SizedBox(height: 8),
                      _UrgencyPill(level: urgency),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(icon, size: 20, color: AppColors.textSecondary),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.report,
    required this.severityColor,
    required this.time,
    this.branchName,
  });

  final ReportEntity report;
  final Color severityColor;
  final String time;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    final commentCount = report.comments.length;
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Severity dot + label.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(color: severityColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(report.severity.label,
                style: AppTypography.caption.copyWith(color: severityColor)),
          ],
        ),
        _dot(context),
        Text(report.category.label, style: AppTypography.caption),
        if (branchName != null && branchName!.isNotEmpty) ...[
          _dot(context),
          Text(branchName!, style: AppTypography.caption),
        ],
        if (time.isNotEmpty) ...[
          _dot(context),
          Text(time, style: AppTypography.caption),
        ],
        if (commentCount > 0) ...[
          _dot(context),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 3),
              Text('$commentCount', style: AppTypography.caption),
            ],
          ),
        ],
        if (!report.privacy.isNormal) ...[
          _dot(context),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 3),
              Text(report.privacy.label, style: AppTypography.caption),
            ],
          ),
        ],
      ],
    );
  }

  Widget _dot(BuildContext context) => Text('·',
      style: AppTypography.caption.copyWith(color: AppColors.textTertiary));
}

class _UrgencyPill extends StatelessWidget {
  const _UrgencyPill({required this.level});
  final ReportUrgencyLevel level;

  @override
  Widget build(BuildContext context) {
    final color = reportUrgencyColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: color.withAlpha(110)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: color),
          const SizedBox(width: 5),
          Text(reportUrgencyLabel(level),
              style: AppTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
