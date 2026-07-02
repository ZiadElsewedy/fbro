import 'package:flutter/material.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/core/responsive/breakpoints.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/widgets/app_context_menu.dart';
import 'package:drop/core/widgets/user_avatar.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/presentation/widgets/schedule_helpers.dart';

/// Payload carried while dragging an [AssignmentChip] between grid cells:
/// who is being moved and which slot they came from.
class ChipDragData {
  const ChipDragData({
    required this.uid,
    required this.day,
    required this.shift,
  });

  final String uid;
  final ScheduleDay day;
  final ScheduleShift shift;
}

/// One person on a shift — the atomic unit of the schedule grid. Each chip is
/// a click target (cell details), a drag handle (desktop: move between slots),
/// and a context-menu anchor (right-click on desktop, long-press on touch).
/// A double-booked person carries a red hairline + dot; strictly monochrome
/// otherwise.
class AssignmentChip extends StatefulWidget {
  const AssignmentChip({
    super.key,
    required this.user,
    required this.day,
    required this.shift,
    this.conflicted = false,
    this.canEdit = false,
    this.canMoveToOpposite = true,
    this.onRemove,
    this.onMoveToOpposite,
  });

  final UserEntity user;
  final ScheduleDay day;
  final ScheduleShift shift;

  /// This person is on both shifts of this day (double-booked).
  final bool conflicted;

  final bool canEdit;

  /// False when the opposite shift already contains this person — the move
  /// action shows disabled instead of silently double-booking them.
  final bool canMoveToOpposite;

  final VoidCallback? onRemove;
  final VoidCallback? onMoveToOpposite;

  @override
  State<AssignmentChip> createState() => _AssignmentChipState();
}

class _AssignmentChipState extends State<AssignmentChip> {
  bool _hovered = false;

  void _showMenu(Offset globalPosition) {
    final opposite = widget.shift.opposite;
    showAppContextMenu(
      context: context,
      position: globalPosition,
      items: [
        AppContextMenuItem(
          icon: opposite == ScheduleShift.morning
              ? Icons.wb_sunny_rounded
              : Icons.nightlight_round,
          label: 'Move to ${opposite.label.toLowerCase()}',
          enabled: widget.canMoveToOpposite,
          onSelected: widget.onMoveToOpposite,
        ),
        AppContextMenuItem(
          icon: Icons.person_remove_outlined,
          label: 'Remove from shift',
          destructive: true,
          onSelected: widget.onRemove,
        ),
      ],
    );
  }

  Widget _visual({required bool hovered, bool dragging = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(3, 3, 8, 3),
      decoration: BoxDecoration(
        color: hovered || dragging
            ? const Color(0xFF232327)
            : AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: widget.conflicted
              ? AppColors.error.withAlpha(190)
              : hovered
                  ? AppColors.accentBorder
                  : AppColors.darkBorder,
        ),
        boxShadow: dragging
            ? [
                BoxShadow(
                  color: AppColors.black.withAlpha(120),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar.fromUser(widget.user, size: 17),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              shortName(widget.user),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
          if (widget.conflicted) ...[
            const SizedBox(width: 5),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    Widget chip = MouseRegion(
      cursor: widget.canEdit && isDesktop
          ? SystemMouseCursors.grab
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onSecondaryTapDown:
            widget.canEdit ? (d) => _showMenu(d.globalPosition) : null,
        // Touch fallback for the same actions (no right-click on mobile).
        onLongPressStart: widget.canEdit && !isDesktop
            ? (d) => _showMenu(d.globalPosition)
            : null,
        child: _visual(hovered: _hovered),
      ),
    );

    // Drag-to-move is a desktop affordance; on touch the cell sheet handles
    // assignment, so chips stay plain tappable content there.
    if (widget.canEdit && isDesktop) {
      chip = Draggable<ChipDragData>(
        data: ChipDragData(
            uid: widget.user.uid, day: widget.day, shift: widget.shift),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.06,
            child: _visual(hovered: false, dragging: true),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: chip),
        child: chip,
      );
    }
    return chip;
  }
}
