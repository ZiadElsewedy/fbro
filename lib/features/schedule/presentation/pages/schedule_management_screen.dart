import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fbro/features/schedule/presentation/widgets/manager_schedule_view.dart';

/// Admin schedule screen (Phase 7). View and edit **any** branch's weekly
/// schedule: pick a branch, navigate weeks, and override assignments. Reuses the
/// shared [ManagerScheduleView] with the admin branch selector enabled.
class ScheduleManagementScreen extends StatelessWidget {
  const ScheduleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        title: Text('Branch Schedules', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: () => context.read<ScheduleCubit>().refresh(),
          ),
        ],
      ),
      body: const ManagerScheduleView(isAdmin: true),
    );
  }
}
