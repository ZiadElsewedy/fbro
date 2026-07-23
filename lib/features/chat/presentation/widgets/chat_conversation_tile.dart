import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/widgets/user_avatar.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/chat/domain/entities/chat_conversation.dart';
import 'package:drop/features/chat/presentation/chat_format.dart';
import 'package:drop/features/task/presentation/activity_format.dart'
    show relativeTime;

/// A premium inbox row for one direct conversation: a real avatar, the
/// teammate's name, a last-message preview, relative time, and an unread pill.
///
/// [counterpart] is the resolved teammate (from the Firebase directory); when
/// present it drives the avatar + name + role, so the UI never shows a backend
/// id. [title]/[preview]/[unreadCount] are optional overrides; a null
/// [unreadCount] (or 0) hides the badge.
class ChatConversationTile extends StatelessWidget {
  const ChatConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.counterpart,
    this.title,
    this.preview,
    this.unreadCount,
    this.selected = false,
  });

  final ChatConversationSummary conversation;
  final VoidCallback onTap;

  /// The resolved teammate — drives avatar, name, and role. Null → a neutral
  /// avatar + the deterministic fallback label.
  final UserEntity? counterpart;

  /// Explicit name override (wins over [counterpart]).
  final String? title;

  /// Last-message body. Null → state line off `lastMessageAt`.
  final String? preview;

  /// Unread messages. Null or 0 → no badge.
  final int? unreadCount;

  /// Desktop split-pane highlight.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final unread = (unreadCount ?? 0) > 0;
    final when = conversation.lastMessageAt ?? conversation.createdAt;
    final name = title ??
        chatDisplayName(counterpart,
            fallbackId: conversation.counterpartUserId);
    final role = counterpart == null ? null : chatRoleLabel(counterpart!.role);

    return Material(
      color: selected ? AppColors.primarySurface : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding, vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(counterpart: counterpart, unread: unread),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.body.copyWith(
                                fontWeight:
                                    unread ? FontWeight.w700 : FontWeight.w600,
                                height: 1.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(relativeTime(when),
                            style: AppTypography.caption.copyWith(
                                color: unread
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                                fontWeight: unread
                                    ? FontWeight.w600
                                    : FontWeight.w400)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview ?? chatPreviewLine(conversation),
                            style: AppTypography.bodySmall.copyWith(
                                color: unread
                                    ? AppColors.textSecondary
                                    : AppColors.textTertiary,
                                height: 1.25),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _UnreadBadge(count: unreadCount!),
                        ] else if (role != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(role,
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textTertiary)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The counterpart avatar — real photo/initials when resolved, a neutral glyph
/// otherwise. An unread conversation gets a subtle accent ring.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.counterpart, required this.unread});
  final UserEntity? counterpart;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final ring = unread ? AppColors.primary : AppColors.darkBorder;
    if (counterpart != null) {
      return UserAvatar.fromUser(counterpart!, size: 50, ringColor: ring);
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 1.5),
      ),
      child: const Icon(Icons.person_outline_rounded,
          size: 22, color: AppColors.textSecondary),
    );
  }
}

/// Monochrome unread count pill.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: AppTypography.caption.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
