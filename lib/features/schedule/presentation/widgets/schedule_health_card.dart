import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/features/schedule/domain/health/schedule_health_analyzer.dart';

/// The compact **Schedule Health** section — one quiet row stating the week's
/// overall read (Healthy / Fair / Strained + a 0–100 score), expandable into a
/// **clickable per-category breakdown** (Coverage · Workload · Fairness · Rest ·
/// Conflicts). Tapping a category filters the findings to it. Advice for the
/// manager's judgment, never a gate: nothing here blocks an edit or a publish.
/// Strictly monochrome — only the tiny severity dot carries the read (white →
/// grey → amber).
class ScheduleHealthCard extends StatefulWidget {
  const ScheduleHealthCard({super.key, required this.report});

  final ScheduleHealthReport report;

  @override
  State<ScheduleHealthCard> createState() => _ScheduleHealthCardState();
}

class _ScheduleHealthCardState extends State<ScheduleHealthCard> {
  bool _expanded = false;

  /// The category the findings list is filtered to (null = all).
  ScheduleRuleCategory? _filter;

  static Color _dotColor(ScheduleHealthSeverity severity) => switch (severity) {
        ScheduleHealthSeverity.none => AppColors.primary,
        ScheduleHealthSeverity.low => AppColors.textTertiary,
        ScheduleHealthSeverity.medium => AppColors.warning,
        ScheduleHealthSeverity.high => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final canExpand = report.findings.isNotEmpty;
    final visible = _filter == null
        ? report.findings
        : [for (final f in report.findings) if (f.category == _filter) f];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap:
                canExpand ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: AppRadius.cardAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.monitor_heart_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Schedule health',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _dotColor(report.overallSeverity),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _summary(report),
                      style:
                          AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${report.overallScore}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '/100',
                    style:
                        AppTypography.caption.copyWith(color: AppColors.textTertiary),
                  ),
                  if (canExpand)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18, color: AppColors.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_expanded && canExpand) ...[
            const Divider(height: 1, color: AppColors.darkBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _breakdown(report),
                  const SizedBox(height: 6),
                  for (final finding in visible) _finding(finding),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _summary(ScheduleHealthReport report) {
    if (report.isHealthy) {
      return '${report.label} · shifts are grouped and rest looks sustainable';
    }
    final n = report.findings.length;
    return '${report.label} · $n ${n == 1 ? 'thing' : 'things'} to review';
  }

  /// The clickable category breakdown — one chip per lens, tap to filter.
  Widget _breakdown(ScheduleHealthReport report) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final result in report.results)
          _categoryChip(result),
      ],
    );
  }

  Widget _categoryChip(ScheduleRuleResult result) {
    final active = result.findings.isNotEmpty;
    final selected = _filter == result.category;
    return InkWell(
      onTap: active
          ? () => setState(() =>
              _filter = selected ? null : result.category)
          : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.darkSurfaceElevated
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.textTertiary : AppColors.darkBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                // A faint muted dot for a category with nothing to flag.
                color: active
                    ? _dotColor(result.severity)
                    : const Color(0x40FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              result.category.label,
              style: AppTypography.caption.copyWith(
                color:
                    active ? AppColors.textPrimary : AppColors.textTertiary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _finding(RuleFinding finding) {
    final icon = switch (finding.category) {
      ScheduleRuleCategory.coverage => Icons.grid_view_rounded,
      ScheduleRuleCategory.workload => Icons.fitness_center_rounded,
      ScheduleRuleCategory.fairness => Icons.balance_rounded,
      ScheduleRuleCategory.rest => Icons.nights_stay_outlined,
      ScheduleRuleCategory.conflict => Icons.error_outline_rounded,
    };
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: _dotColor(finding.severity)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finding.title,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(finding.suggestion, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
