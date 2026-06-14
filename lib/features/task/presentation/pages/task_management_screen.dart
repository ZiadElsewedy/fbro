import 'package:flutter/material.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/role_placeholder.dart';

/// Admin task screen (Phase 3 placeholder). Admins manage tasks across **all
/// branches** — create / assign / edit / delete / review (approve · reject). The
/// full management UI (backed by `TaskRepository`) lands in a later phase.
class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          title: Text('Task Management', style: AppTypography.h3),
        ),
        body: const RolePlaceholder(
          icon: Icons.fact_check_outlined,
          title: 'Task Management',
          subtitle:
              'Create, assign, edit, delete and review tasks across all branches.\n'
              'The full interface arrives in a later phase.',
        ),
      );
}
