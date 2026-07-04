import 'package:flutter/material.dart';
import 'package:drop/core/enums/report_category.dart';
import 'package:drop/core/enums/report_severity.dart';
import 'package:drop/core/enums/report_status.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/features/reports/domain/report_urgency.dart';

/// Shared, pure presentation helpers for the Reports Center — the single source
/// for a category glyph, a severity/status colour, and the thread markers.
/// Strictly monochrome: colour appears only for high/critical severity, the
/// resolved status, and an SLA-breached urgency badge.

// ─── Category ───────────────────────────────────────────────────────
IconData reportCategoryIcon(ReportCategory c) => switch (c) {
      ReportCategory.sales => Icons.point_of_sale_outlined,
      ReportCategory.inventory => Icons.inventory_2_outlined,
      ReportCategory.staff => Icons.groups_2_outlined,
      ReportCategory.security => Icons.shield_outlined,
      ReportCategory.operations => Icons.storefront_outlined,
    };

// ─── Severity ───────────────────────────────────────────────────────
/// Monochrome for low/medium, amber for high, red for critical (colour reserved
/// for what's actually urgent).
Color reportSeverityColor(ReportSeverity s) => switch (s) {
      ReportSeverity.low => AppColors.textTertiary,
      ReportSeverity.medium => AppColors.textSecondary,
      ReportSeverity.high => AppColors.warning,
      ReportSeverity.critical => AppColors.error,
    };

// ─── Status ─────────────────────────────────────────────────────────
Color reportStatusColor(ReportStatus s) => switch (s) {
      ReportStatus.newReport => AppColors.primary,
      ReportStatus.underReview => AppColors.warning,
      ReportStatus.waitingReply => AppColors.textSecondary,
      ReportStatus.resolved => AppColors.success,
    };

// ─── Urgency (SLA) ──────────────────────────────────────────────────
Color reportUrgencyColor(ReportUrgencyLevel level) => switch (level) {
      ReportUrgencyLevel.calm => AppColors.textTertiary,
      ReportUrgencyLevel.watch => AppColors.warning,
      ReportUrgencyLevel.breached => AppColors.error,
    };

String reportUrgencyLabel(ReportUrgencyLevel level) => switch (level) {
      ReportUrgencyLevel.calm => '',
      ReportUrgencyLevel.watch => 'Due soon',
      ReportUrgencyLevel.breached => 'SLA breached',
    };

// ─── Thread markers (status changes shown inline in the conversation) ─
String reportMarkerTitle(String status) => switch (status) {
      'created' => 'Report filed',
      'newReport' => 'Reopened',
      'underReview' => 'Marked under review',
      'waitingReply' => 'Waiting for a reply',
      'resolved' => 'Marked resolved',
      _ => status,
    };

Color reportMarkerColor(String status) => switch (status) {
      'resolved' => AppColors.success,
      'underReview' => AppColors.warning,
      'created' => AppColors.textPrimary,
      _ => AppColors.textTertiary,
    };

IconData reportMarkerIcon(String status) => switch (status) {
      'created' => Icons.flag_outlined,
      'newReport' => Icons.refresh_rounded,
      'underReview' => Icons.visibility_outlined,
      'waitingReply' => Icons.hourglass_bottom_rounded,
      'resolved' => Icons.check_circle_outline_rounded,
      _ => Icons.circle_outlined,
    };
