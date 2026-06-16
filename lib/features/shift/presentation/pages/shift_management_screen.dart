import 'package:flutter/material.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/role_placeholder.dart';

/// Admin shift screen (Phase 2 placeholder). Admins manage shifts across **all
/// branches** — create / edit / delete / assign employees. The full management
/// UI (backed by `ShiftRepository`) lands in a later phase.
class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          title: Text('Shift Management', style: AppTypography.h3),
        ),
        body: const RolePlaceholder(
          icon: Icons.calendar_month_outlined,
          title: 'Shift Management',
          subtitle:
              'Create, edit, assign and delete shifts across all branches.\n'
              'The full interface arrives in a later phase.',
        ),
      );
}
