import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/theme/app_spacing.dart';

/// An Apple-style **segmented control** — a pill-shaped toggle with a single
/// filled selector that slides between segments (like the iOS Files tab bar).
///
/// Strictly monochrome: the track is a dark surface, the selected segment is the
/// white [AppColors.accent] fill with dark text; unselected labels are grey. It
/// drives a [TabController], so the caller pairs it with a `TabBarView` for the
/// swipe-able page switch. Fits the [AdaptiveScaffold.bottom] slot at a 44px
/// preferred height by default.
class SegmentedTabBar extends StatelessWidget implements PreferredSizeWidget {
  const SegmentedTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.pagePadding,
      0,
      AppSpacing.pagePadding,
      AppSpacing.md,
    ),
    this.height = 44,
  });

  /// The controller shared with the paired `TabBarView`.
  final TabController controller;

  /// Segment labels, in order (typically 2–3).
  final List<String> tabs;

  /// Outer spacing around the pill.
  final EdgeInsets margin;

  /// Preferred height reported to the app bar.
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(9),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelColor: AppColors.onAccent,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTypography.caption,
        tabs: [for (final t in tabs) Tab(text: t)],
      ),
    );
  }
}
