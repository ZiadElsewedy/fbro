import 'package:flutter/material.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/role_placeholder.dart';

/// Manager shift screen (Phase 2 placeholder). Managers view, edit and assign
/// shifts for **their own branch only** (enforced by `firestore.rules`). The
/// full branch scheduling UI lands in a later phase.
class BranchShiftScreen extends StatelessWidget {
  const BranchShiftScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          title: Text('Branch Shifts', style: AppTypography.h3),
        ),
        body: const RolePlaceholder(
          icon: Icons.store_mall_directory_outlined,
          title: 'Branch Shifts',
          subtitle:
              'View, edit and assign shifts for your branch.\n'
              'The full interface arrives in a later phase.',
        ),
      );
}
