import 'package:flutter/material.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/role_placeholder.dart';

/// Employee shift screen (Phase 2 placeholder). Employees can **view their own
/// assigned shift only** — no editing (enforced by `firestore.rules`). The shift
/// details view (backed by `ShiftRepository.getEmployeeShift`) lands in a later
/// phase.
class MyShiftScreen extends StatelessWidget {
  const MyShiftScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          title: Text('My Shift', style: AppTypography.h3),
        ),
        body: const RolePlaceholder(
          icon: Icons.schedule_outlined,
          title: 'My Shift',
          subtitle:
              'Your assigned shift will appear here once a manager assigns one.\n'
              'The shift details view arrives in a later phase.',
        ),
      );
}
