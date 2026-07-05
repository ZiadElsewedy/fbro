import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/core/responsive/breakpoints.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/widgets/branch_avatar.dart';
import 'package:drop/core/widgets/drop_logo.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/branch/domain/entities/branch_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/domain/schedule_week.dart';
import 'package:drop/features/schedule/presentation/schedule_insights.dart';
import 'package:drop/features/schedule/presentation/widgets/schedule_grid.dart';
import 'package:drop/features/schedule/presentation/widgets/schedule_helpers.dart';

/// Opens an opaque route on the root navigator so the final roster is shown
/// above the authenticated [AppShell] (including its persistent sidebar).
Future<void> showScheduleFinalView({
  required BuildContext context,
  required WeeklyScheduleEntity schedule,
  required List<UserEntity> members,
  required BranchEntity? branch,
  ScheduleShift? filter,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: true,
      barrierColor: AppColors.darkBg,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: ScheduleFinalView(
          schedule: schedule,
          members: members,
          branch: branch,
          filter: filter,
        ),
      ),
    ),
  );
}

/// Read-only, screenshot-ready rendering of one weekly branch roster.
///
/// The floating controls can be hidden for a completely clean capture. Escape
/// restores them first, then closes the preview on the next press.
class ScheduleFinalView extends StatefulWidget {
  const ScheduleFinalView({
    super.key,
    required this.schedule,
    required this.members,
    required this.branch,
    this.filter,
  });

  final WeeklyScheduleEntity schedule;
  final List<UserEntity> members;
  final BranchEntity? branch;
  final ScheduleShift? filter;

  @override
  State<ScheduleFinalView> createState() => _ScheduleFinalViewState();
}

class _ScheduleFinalViewState extends State<ScheduleFinalView> {
  bool _clean = false;

  void _handleEscape() {
    if (_clean) {
      setState(() => _clean = false);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _handleEscape,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.darkBg,
          body: Stack(
            children: [
              Positioned.fill(child: _ScheduleCanvas(widget: widget)),
              if (!_clean)
                Positioned(
                  top: context.isDesktop ? 20 : 12,
                  right: context.isDesktop ? 24 : 12,
                  child: _PreviewControls(
                    onClean: () => setState(() => _clean = true),
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleCanvas extends StatelessWidget {
  const _ScheduleCanvas({required this.widget});

  final ScheduleFinalView widget;

  @override
  Widget build(BuildContext context) {
    final schedule = widget.schedule;
    final members = widget.members;
    final branchName = widget.branch?.name ?? 'Branch';
    final insights = computeScheduleInsights(
      schedule,
      members,
      filter: widget.filter,
    );
    final assignedUids = <String>{};
    var assignmentCount = 0;
    for (final day in ScheduleDay.values) {
      for (final shift in ScheduleShift.values) {
        if (widget.filter != null && shift != widget.filter) continue;
        final valid = validAssignments(
          schedule.employeesFor(day, shift),
          members,
        );
        assignedUids.addAll(valid);
        assignmentCount += valid.length;
      }
    }

    final grid = ScheduleGrid(
      schedule: schedule,
      members: members,
      filter: widget.filter,
      insights: insights,
      canEdit: false,
      onCellTap: (_, _) {},
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.isDesktop ? 52 : 18,
          context.isDesktop ? 44 : 24,
          context.isDesktop ? 52 : 18,
          context.isDesktop ? 30 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FinalHeader(
              branch: widget.branch,
              branchName: branchName,
              weekLabel: ScheduleWeek.rangeLabel(schedule.weekStart),
              shiftLabel: widget.filter?.label,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: AppColors.darkBorder),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _FactPill(
                  icon: Icons.people_outline_rounded,
                  value: '${assignedUids.length}',
                  label: assignedUids.length == 1 ? 'employee' : 'employees',
                ),
                _FactPill(
                  icon: Icons.calendar_month_outlined,
                  value: '$assignmentCount',
                  label: assignmentCount == 1 ? 'assignment' : 'assignments',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: Align(
                alignment: const Alignment(0, -0.15),
                child: SizedBox(height: grid.height, child: grid),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const DropLogo(height: 15, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Text(
                  'OPERATIONS  /  WEEKLY STAFF SCHEDULE',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalHeader extends StatelessWidget {
  const _FinalHeader({
    required this.branch,
    required this.branchName,
    required this.weekLabel,
    required this.shiftLabel,
  });

  final BranchEntity? branch;
  final String branchName;
  final String weekLabel;
  final String? shiftLabel;

  @override
  Widget build(BuildContext context) {
    final identity = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BranchAvatar(
          logoUrl: branch?.logoUrl,
          name: branchName,
          size: context.isDesktop ? 48 : 42,
          radius: 13,
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(branchName, style: AppTypography.h2),
            const SizedBox(height: 3),
            Text(
              shiftLabel == null
                  ? 'Weekly staff schedule'
                  : '$shiftLabel shift schedule',
              style: AppTypography.body,
            ),
          ],
        ),
      ],
    );

    final week = Column(
      crossAxisAlignment: context.isDesktop
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          'WEEK OF',
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(weekLabel, style: AppTypography.h3),
      ],
    );

    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          identity,
          const SizedBox(height: AppSpacing.lg),
          week,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [identity, week],
    );
  }
}

class _FactPill extends StatelessWidget {
  const _FactPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Text(
            '$value ',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _PreviewControls extends StatelessWidget {
  const _PreviewControls({required this.onClean, required this.onClose});

  final VoidCallback onClean;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurfaceElevated,
      borderRadius: AppRadius.fullAll,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: AppRadius.fullAll,
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(120),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: onClean,
              icon: const Icon(Icons.photo_camera_outlined, size: 17),
              label: const Text('Clean screenshot'),
            ),
            IconButton(
              onPressed: onClose,
              tooltip: 'Close preview (Esc)',
              icon: const Icon(Icons.close_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}
