import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';

/// Presentation helpers that map a task [ActivityEntry.status] string onto a
/// human label + dot colour, and format an event time. Shared by the Task
/// Details activity timeline and the admin recent-activity feed so the mapping
/// lives in exactly one place.

/// The soft per-state palette — muted, premium, no neon — shared by the
/// living-border orbit (task cards), the activity timeline and the activity
/// feed dots so a state always wears the same colour everywhere.
const Color kStatePending = Color(0xFF7DD3FC); // baby blue
const Color kStateInProgress = Color(0xFFA78BFA); // purple
const Color kStateInReview = Color(0xFFF59E0B); // amber
const Color kStateRejected = Color(0xFFF87171); // soft red
const Color kStateOverdue = Color(0xFFFB923C); // orange

/// Human-readable title for a task activity entry (its post-transition status).
String activityTitle(String status) => switch (status) {
      'pending' => 'Task created',
      'assigned' => 'Assigned to employee',
      'started' => 'Started',
      'completed' => 'Completed',
      'waitingReview' => 'Submitted for review',
      'approved' => 'Approved',
      'rejected' => 'Rework requested',
      'cancelled' => 'Cancelled',
      'note' => 'Note',
      'noteWarning' => 'Warning',
      'noteIssue' => 'Issue',
      _ => status,
    };

/// Dot / accent colour for a task activity entry — the soft state palette, so
/// the timeline reads in the same hues as the cards' living borders.
Color activityColor(String status) => switch (status) {
      'approved' => AppColors.success,
      'rejected' || 'noteIssue' => kStateRejected,
      'waitingReview' || 'noteWarning' => kStateInReview,
      'started' => kStateInProgress,
      'pending' || 'assigned' => kStatePending,
      'completed' => AppColors.textSecondary,
      _ => AppColors.textTertiary,
    };

/// Glyph for a task activity entry — used by the richer timeline event cards.
IconData activityIcon(String status) => switch (status) {
      'pending' => Icons.add_task_rounded,
      'assigned' => Icons.person_add_alt_1_rounded,
      'started' => Icons.play_arrow_rounded,
      'completed' => Icons.check_rounded,
      'waitingReview' => Icons.hourglass_top_rounded,
      'approved' => Icons.verified_rounded,
      'rejected' => Icons.replay_rounded,
      'cancelled' => Icons.close_rounded,
      'note' => Icons.chat_bubble_outline_rounded,
      'noteWarning' => Icons.warning_amber_rounded,
      'noteIssue' => Icons.report_gmailerrorred_rounded,
      _ => Icons.circle_outlined,
    };

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Compact relative time ("Just now", "5m ago", "3h ago", "2d ago", "19 Jun").
String relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day} ${_months[dt.month - 1]}';
}

/// Wall-clock time ("1:43 AM") — pairs with [relativeTime] on timeline rows so
/// ops can see the exact moment, not just "2m ago".
String clockTime(DateTime dt) {
  final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour < 12 ? 'AM' : 'PM';
  return '$h12:${dt.minute.toString().padLeft(2, '0')} $ampm';
}
