import 'package:flutter/material.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/role_placeholder.dart';

/// Employee task screen (Phase 3 placeholder). Employees see **their own
/// assigned tasks only** — start, complete, add notes and upload a proof image;
/// they cannot edit others' tasks or approve (enforced by `firestore.rules`).
/// The full task list + execution UI (backed by `TaskRepository`) lands in a
/// later phase.
class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          title: Text('My Tasks', style: AppTypography.h3),
        ),
        body: const RolePlaceholder(
          icon: Icons.checklist_rounded,
          title: 'My Tasks',
          subtitle:
              'Your assigned tasks will appear here to start, complete and submit.\n'
              'The full interface arrives in a later phase.',
        ),
      );
}
