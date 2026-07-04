import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/features/cases/domain/entities/case_message.dart';
import 'package:drop/features/cases/presentation/case_format.dart';
import 'package:drop/features/task/presentation/activity_format.dart'
    show relativeTime;
import 'package:drop/features/task/presentation/widgets/attachment_gallery.dart';

/// The case **conversation** — a premium chat/support thread. Real messages
/// render as left/right bubbles (mine vs the other party); status changes render
/// as quiet centered system chips; day changes get a date separator. Auto-scrolls
/// to the newest message as replies stream in.
class CaseMessageList extends StatefulWidget {
  const CaseMessageList({
    super.key,
    required this.messages,
    required this.currentUid,
    required this.iAmReporter,
  });

  final List<CaseMessage> messages;

  /// The signed-in user's uid — a message they authored aligns right.
  final String currentUid;

  /// True when the viewer is the case's reporter — so their de-identified
  /// confidential replies (empty authorId) still align to the right.
  final bool iAmReporter;

  @override
  State<CaseMessageList> createState() => _CaseMessageListState();
}

class _CaseMessageListState extends State<CaseMessageList> {
  final _controller = ScrollController();

  @override
  void didUpdateWidget(covariant CaseMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isMine(CaseMessage m) =>
      m.authorId == widget.currentUid ||
      (widget.iAmReporter && m.authorRole == CaseAuthorRole.reporter);

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    if (messages.isEmpty) {
      return Center(
        child: Text('No messages yet.', style: AppTypography.bodySmall),
      );
    }
    DateTime? lastDay;
    final children = <Widget>[];
    for (final m in messages) {
      final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      if (lastDay == null || day != lastDay) {
        children.add(_DateSeparator(day: day));
        lastDay = day;
      }
      if (m.isSystem) {
        children.add(_SystemChip(message: m));
      } else {
        children.add(_Bubble(message: m, mine: _isMine(m)));
      }
    }
    return ListView(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.lg,
          AppSpacing.pagePadding, AppSpacing.lg),
      children: children,
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});
  final CaseMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final who = (message.authorName ?? '').trim();
    const tail = 4.0; // the flattened "tail" corner nearest the sender
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.lg),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(mine ? AppRadius.lg : tail),
      bottomRight: Radius.circular(mine ? tail : AppRadius.lg),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!mine && who.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(who,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.72),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: mine ? AppColors.primary : AppColors.darkSurfaceElevated,
                borderRadius: radius,
                border: mine ? null : Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.hasText)
                    Text(
                      message.text!.trim(),
                      style: AppTypography.body
                          .copyWith(color: mine ? AppColors.onPrimary : null),
                    ),
                  if (message.hasAttachments) ...[
                    if (message.hasText) const SizedBox(height: AppSpacing.sm),
                    AttachmentGallery(attachments: message.attachments),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Text(relativeTime(message.createdAt),
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }
}

class _SystemChip extends StatelessWidget {
  const _SystemChip({required this.message});
  final CaseMessage message;

  @override
  Widget build(BuildContext context) {
    final event = message.systemEvent ?? '';
    final color = caseSystemColor(event);
    final label = message.hasText ? message.text!.trim() : caseSystemLabel(event);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppRadius.fullAll,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(caseSystemIcon(event), size: 13, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTypography.caption.copyWith(color: color)),
              Text('  ·  ${relativeTime(message.createdAt)}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.day});
  final DateTime day;

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[day.month - 1]} ${day.day}, ${day.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Text(_label(),
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
      ),
    );
  }
}
