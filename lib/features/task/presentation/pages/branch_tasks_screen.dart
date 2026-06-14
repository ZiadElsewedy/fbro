import 'package:flutter/material.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/role_placeholder.dart';

/// Manager task screen (Phase 3 placeholder). Managers create, assign and review
/// tasks for **their own branch only** (enforced by `firestore.rules`) — assign
/// employees + shifts, then approve / reject completed work. The full branch
/// task UI lands in a later phase.
class BranchTasksScreen extends StatelessWidget {
  const BranchTasksScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          title: Text('Branch Tasks', style: AppTypography.h3),
        ),
        body: const RolePlaceholder(
          icon: Icons.assignment_outlined,
          title: 'Branch Tasks',
          subtitle:
              'Create, assign and review tasks for your branch.\n'
              'The full interface arrives in a later phase.',
        ),
      );
}
