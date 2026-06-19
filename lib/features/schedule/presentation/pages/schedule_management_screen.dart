import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fbro/core/extensions/context_extensions.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/features/branch/presentation/cubit/branch_cubit.dart';
import 'package:fbro/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fbro/features/schedule/presentation/cubit/shift_swap_cubit.dart';
import 'package:fbro/features/schedule/presentation/cubit/shift_swap_state.dart';
import 'package:fbro/features/schedule/presentation/widgets/manager_schedule_view.dart';
import 'package:fbro/features/schedule/presentation/widgets/swap_view.dart';

/// Admin schedule screen (Phase 7). Two tabs: edit **any** branch's weekly
/// schedule (branch selector enabled), and an **all-branches swap-request queue**
/// the admin can approve/reject — the admin counterpart to the manager's branch
/// queue (admin ⊇ manager, so the same approve/reject actions apply).
class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  String _uid = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    _uid = context.currentUser?.uid ?? '';
    // Branches resolve the swap cards' branch labels; every branch's swaps form
    // the admin's global approval queue.
    context.read<BranchCubit>().load();
    context.read<ShiftSwapCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
              onPressed: () {
                context.read<ScheduleCubit>().refresh();
                context.read<ShiftSwapCubit>().refresh();
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Schedule'),
              Tab(text: 'Swap Requests'),
            ],
          ),
        ),
        // An approved swap rewrites a branch roster — refresh the Schedule tab
        // when a swap action settles (busy → idle), matching the manager screen.
        body: BlocListener<ShiftSwapCubit, ShiftSwapState>(
          listenWhen: (prev, curr) =>
              prev.maybeWhen(loaded: (_, busy) => busy, orElse: () => false) &&
              curr.maybeWhen(loaded: (_, busy) => !busy, orElse: () => false),
          listener: (context, _) => context.read<ScheduleCubit>().refresh(),
          child: TabBarView(
            children: [
              const ManagerScheduleView(isAdmin: true),
              SwapListView(isManager: true, currentUid: _uid, showBranch: true),
            ],
          ),
        ),
      ),
    );
  }
}
