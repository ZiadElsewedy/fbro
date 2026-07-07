import 'package:flutter/material.dart';
import 'package:drop/core/enums/request_priority.dart';
import 'package:drop/core/enums/request_status.dart';
import 'package:drop/core/enums/request_type.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/features/requests/domain/entities/request_entity.dart';
import 'package:drop/features/requests/domain/request_field_spec.dart';
import 'package:drop/features/requests/domain/request_schema.dart';

/// Presentation-only formatting for Operations Requests — icons, the single
/// status→colour source, priority styling, relative time, and turning the dynamic
/// `details` map into labelled, human-readable rows. Kept out of the domain so the
/// enums stay Flutter-free (mirrors `activity_format.dart` for tasks).
class RequestFormat {
  const RequestFormat._();

  // ─── Type icon (the request category glyph) ────────────────────
  static IconData icon(RequestType type) => switch (type) {
        RequestType.employeeDiscount => Icons.sell_outlined,
        RequestType.leaveStore => Icons.directions_walk_rounded,
        RequestType.giftApproval => Icons.card_giftcard_rounded,
        RequestType.stockRequest => Icons.inventory_2_outlined,
        RequestType.maintenance => Icons.build_outlined,
        RequestType.customerIssue => Icons.report_gmailerrorred_outlined,
        RequestType.cashRequest => Icons.payments_outlined,
        RequestType.equipmentRequest => Icons.handyman_outlined,
        RequestType.branchSupport => Icons.hub_outlined,
        RequestType.other => Icons.more_horiz_rounded,
      };

  // ─── Status → colour (the ONE source, like taskStatusColor) ────
  static Color statusColor(RequestStatus status) => switch (status) {
        RequestStatus.pending => AppColors.warning, // awaiting a decision
        RequestStatus.approved => AppColors.success, // granted, in progress
        RequestStatus.completed => AppColors.textSecondary, // done, archived
        RequestStatus.rejected => AppColors.error,
        RequestStatus.cancelled => AppColors.textTertiary,
      };

  static IconData statusIcon(RequestStatus status) => switch (status) {
        RequestStatus.pending => Icons.hourglass_top_rounded,
        RequestStatus.approved => Icons.check_circle_outline_rounded,
        RequestStatus.completed => Icons.task_alt_rounded,
        RequestStatus.rejected => Icons.cancel_outlined,
        RequestStatus.cancelled => Icons.block_rounded,
      };

  static Color priorityColor(RequestPriority p) => switch (p) {
        RequestPriority.high => AppColors.warning,
        RequestPriority.normal => AppColors.textSecondary,
        RequestPriority.low => AppColors.textTertiary,
      };

  // ─── Relative time ("2m", "3h", "Yesterday", "6 Jul") ──────────
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String relativeTime(DateTime? time, {DateTime? now}) {
    if (time == null) return '';
    final clock = now ?? DateTime.now();
    final diff = clock.difference(time);
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day} ${_months[time.month - 1]}';
  }

  /// A longer age label for a pending request's "waiting" hint.
  static String waitingLabel(Duration d) {
    if (d.inMinutes < 60) return 'Waiting ${d.inMinutes}m';
    if (d.inHours < 24) return 'Waiting ${d.inHours}h';
    return 'Waiting ${d.inDays}d';
  }

  static String timeOfDay(DateTime d) {
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }

  static String dateLabel(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// A precise "6 Jul · 4:30 PM" stamp for the detail header.
  static String fullStamp(DateTime? d) =>
      d == null ? '' : '${dateLabel(d)} · ${timeOfDay(d)}';

  /// Approval-time metric label ("2h 15m", "3d").
  static String durationLabel(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) {
      final m = d.inMinutes % 60;
      return m == 0 ? '${d.inHours}h' : '${d.inHours}h ${m}m';
    }
    return '${d.inDays}d';
  }

  // ─── Dynamic details → labelled rows ───────────────────────────
  /// Turns a request's `details` map into ordered (label, value) rows for the
  /// detail view, skipping empties and formatting dates/times/numbers per the
  /// schema. Values were normalized to `DateTime`/`num`/`String` at the model
  /// boundary, so there is no string parsing here.
  static List<({String label, String value})> detailRows(RequestEntity r) {
    final rows = <({String label, String value})>[];
    for (final spec in RequestSchema.fieldsFor(r.type)) {
      final raw = r.details[spec.key];
      final value = _formatValue(raw, spec.kind);
      if (value.isEmpty) continue;
      rows.add((label: spec.label, value: value));
    }
    return rows;
  }

  static String _formatValue(dynamic raw, RequestFieldKind kind) {
    if (raw == null) return '';
    switch (kind) {
      case RequestFieldKind.time:
        return raw is DateTime ? timeOfDay(raw) : raw.toString();
      case RequestFieldKind.date:
        return raw is DateTime ? dateLabel(raw) : raw.toString();
      case RequestFieldKind.number:
        if (raw is num) {
          return raw == raw.roundToDouble()
              ? raw.toInt().toString()
              : raw.toString();
        }
        return raw.toString().trim();
      case RequestFieldKind.text:
      case RequestFieldKind.multiline:
        return raw.toString().trim();
    }
  }
}
