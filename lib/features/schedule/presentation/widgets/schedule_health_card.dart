import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/features/schedule/domain/schedule_health.dart';

/// The compact **Schedule Health** section (Schedule 5.0) — one quiet row
/// stating the week's wellbeing read (Healthy / Fair / Strained), expandable
/// into per-person recommendations. Advice for the manager's judgment, never
/// a gate: nothing here blocks an edit or a publish. Strictly monochrome —
/// only the tiny status dot carries the read (white → grey → amber).
class ScheduleHealthCard extends StatefulWidget {
  const ScheduleHealthCard({super.key, required this.health});

  final ScheduleHealth health;

  @override
  State<ScheduleHealthCard> createState() => _ScheduleHealthCardState();
}

class _ScheduleHealthCardState extends State<ScheduleHealthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final health = widget.health;
    final canExpand = health.findings.isNotEmpty;
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
            onTap: canExpand
                ? () => setState(() => _expanded = !_expanded)
                : null,
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
                      color: switch (health.label) {
                        'Healthy' => AppColors.primary,
                        'Fair' => AppColors.textTertiary,
                        _ => AppColors.warning,
                      },
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      health.isHealthy
                          ? '${health.label} · shifts are grouped and rest '
                              'looks sustainable'
                          : '${health.label} · ${health.findings.length} '
                              '${health.findings.length == 1 ? 'suggestion' : 'suggestions'}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (canExpand)
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: AppColors.textTertiary),
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
                  for (final finding in health.findings) _finding(finding),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _finding(HealthFinding finding) {
    final icon = switch (finding.kind) {
      HealthFindingKind.shortRest => Icons.nights_stay_outlined,
      HealthFindingKind.alternation => Icons.swap_vert_rounded,
      HealthFindingKind.longStreak => Icons.date_range_outlined,
      HealthFindingKind.unevenLoad => Icons.balance,
    };
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textTertiary),
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
                Text(finding.recommendation, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
