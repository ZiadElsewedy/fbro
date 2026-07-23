import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/utils/app_date_formatter.dart';
import 'package:drop/features/chat/domain/entities/chat_message.dart';
import 'package:drop/features/chat/presentation/chat_message_preview.dart';
import 'package:drop/features/task/presentation/activity_format.dart'
    show relativeTime;

/// The direct-chat thread — the [CaseMessageList] sibling. Messages arrive
/// ascending by `seq` (oldest first) and render bottom-anchored: left/right
/// bubbles (counterpart vs mine), day changes get a date separator, and the
/// list auto-follows the newest message unless the reader has scrolled up
/// (then a "New messages" pill appears instead — Cases convention).
///
/// Two chat-specific additions over Cases:
/// * **Scroll-back pagination** — nearing the top with older history available
///   fires [onLoadOlder]; a quiet spinner row shows while the page is in
///   flight, and the scroll position is preserved when it prepends.
/// * **Visible-read signal** — [onVisible] fires post-frame whenever messages
///   are actually on screen; the cubit's monotonic mark-read makes repeated
///   calls free.
class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.myUserId,
    this.hasMore = false,
    this.loadingOlder = false,
    this.onLoadOlder,
    this.onVisible,
    this.onMessageLongPress,
    this.onRetry,
    this.onImageTap,
    this.deletingMessageId,
    this.counterpartName,
  });

  /// Ascending by `seq` — oldest first.
  final List<ChatMessage> messages;

  /// The caller's backend-internal user id, when derivable. Null → own-message
  /// alignment isn't resolvable yet (deep link into a never-messaged thread);
  /// everything renders left-aligned until the first send resolves it.
  final String? myUserId;

  /// Whether older history exists beyond the loaded window.
  final bool hasMore;

  /// An older page is in flight (top spinner row).
  final bool loadingOlder;

  /// Fired when the reader nears the top and [hasMore] — load the next older
  /// page. The cubit no-ops re-entrant calls.
  final VoidCallback? onLoadOlder;

  /// Fired post-frame while messages are on screen — the mark-read signal.
  final VoidCallback? onVisible;

  /// Long-press on a bubble — opens the message context menu (the host owns
  /// the sheet + the action). Null → long-press does nothing.
  final void Function(ChatMessage message, bool mine)? onMessageLongPress;

  /// Tap on a failed optimistic bubble — re-sends it.
  final void Function(ChatMessage message)? onRetry;

  /// Tap on an image attachment — opens the full-screen viewer.
  final void Function(ChatMessage message)? onImageTap;

  /// The message with a delete in flight — its bubble dims until it resolves.
  final String? deletingMessageId;

  /// Counterpart's display name — personalizes the empty state.
  final String? counterpartName;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final _controller = ScrollController();

  /// Within this distance of the end counts as "at the bottom" — new messages
  /// auto-scroll only when the reader is already here.
  static const _bottomThreshold = 240.0;

  /// Within this distance of the top triggers the older-page load.
  static const _topThreshold = 120.0;

  bool _atBottom = true;
  bool _showJump = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _scrollToBottom(animated: false);
    _notifyVisible();
  }

  @override
  void didUpdateWidget(covariant ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.isEmpty) return;

    final grew = widget.messages.length > oldWidget.messages.length;
    final prepended =
        grew &&
        oldWidget.messages.isNotEmpty &&
        widget.messages.first.id != oldWidget.messages.first.id;
    final appended =
        grew &&
        (oldWidget.messages.isEmpty ||
            widget.messages.last.id != oldWidget.messages.last.id);

    if (prepended) {
      _preserveOffsetAfterPrepend();
    }
    if (appended) {
      // Don't yank a reader who has scrolled up to read history: follow the
      // newest message only when they're already at the bottom, or it's their
      // own send. Otherwise surface a "New messages" pill.
      final newestMine = _isMine(widget.messages.last);
      if (_atBottom || newestMine) {
        _scrollToBottom();
      } else if (!_showJump) {
        setState(() => _showJump = true);
      }
    }
    if (grew || oldWidget.messages.isEmpty) _notifyVisible();
  }

  /// An older page was prepended above the viewport — the list grew upward, so
  /// keep the message the reader was looking at exactly where it was by
  /// re-applying the pre-layout offset plus the extent the page added.
  void _preserveOffsetAfterPrepend() {
    if (!_controller.hasClients) return;
    final oldMax = _controller.position.maxScrollExtent;
    final oldOffset = _controller.offset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final delta = _controller.position.maxScrollExtent - oldMax;
      if (delta > 0) _controller.jumpTo(oldOffset + delta);
    });
  }

  void _notifyVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.messages.isNotEmpty) widget.onVisible?.call();
    });
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (widget.hasMore &&
        !widget.loadingOlder &&
        position.pixels <= _topThreshold) {
      widget.onLoadOlder?.call();
    }
    final atBottom =
        position.maxScrollExtent - position.pixels <= _bottomThreshold;
    if (atBottom != _atBottom) {
      setState(() {
        _atBottom = atBottom;
        if (atBottom) _showJump = false;
      });
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final target = _controller.position.maxScrollExtent;
      if (animated) {
        _controller.animateTo(
          target,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      } else {
        _controller.jumpTo(target);
      }
      if (_showJump && mounted) setState(() => _showJump = false);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  bool _isMine(ChatMessage m) =>
      widget.myUserId != null && m.senderId == widget.myUserId;

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return _EmptyThread(counterpartName: widget.counterpartName);
    }

    final msgs = widget.messages;
    DateTime? lastDay;
    final children = <Widget>[
      if (widget.loadingOlder) const _OlderPageSpinner(),
    ];
    for (var i = 0; i < msgs.length; i++) {
      final m = msgs[i];
      final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      final newDay = lastDay == null || day != lastDay;
      if (newDay) {
        children.add(_DateSeparator(day: day));
        lastDay = day;
      }
      final mine = _isMine(m);
      // Resolve the quoted message's author for the reply preview label.
      final rp = m.replyTo;
      final replyAuthorLabel = rp == null
          ? null
          : (rp.senderId == widget.myUserId
              ? 'You'
              : (widget.counterpartName ?? 'Them'));
      // Group consecutive same-sender messages within the same day: only the
      // last of a run ("tail") shows the timestamp, and grouped bubbles sit
      // tight together — the iMessage/Telegram rhythm that reads as premium.
      final next = i + 1 < msgs.length ? msgs[i + 1] : null;
      final nextSameDay = next != null &&
          next.createdAt.year == m.createdAt.year &&
          next.createdAt.month == m.createdAt.month &&
          next.createdAt.day == m.createdAt.day;
      final isTail =
          next == null || next.senderId != m.senderId || !nextSameDay;
      children.add(
        _Bubble(
          // Keyed by message id so an element follows its message across
          // prepends/appends — the entrance animation then fires only for a
          // genuinely new bubble, never re-running on an existing one.
          key: ValueKey(m.id),
          message: m,
          mine: mine,
          isTail: isTail,
          replyAuthorLabel: replyAuthorLabel,
          deleting: m.id == widget.deletingMessageId,
          onLongPress: widget.onMessageLongPress == null
              ? null
              : () => widget.onMessageLongPress!(m, mine),
        ),
      );
    }

    return Stack(
      children: [
        ListView(
          controller: _controller,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.lg,
            AppSpacing.pagePadding,
            AppSpacing.lg,
          ),
          children: children,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: AppSpacing.md,
          child: _JumpToLatest(visible: _showJump, onTap: _scrollToBottom),
        ),
      ],
    );
  }
}

class _OlderPageSpinner extends StatelessWidget {
  const _OlderPageSpinner();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(bottom: AppSpacing.md),
    child: Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.message,
    required this.mine,
    this.isTail = true,
    this.replyAuthorLabel,
    this.deleting = false,
    this.onLongPress,
  });
  final ChatMessage message;
  final bool mine;

  /// Display label for the author of the quoted (replied-to) message, when
  /// this message is a reply — "You" or the counterpart's name.
  final String? replyAuthorLabel;

  /// Last message of a consecutive same-sender run — shows the timestamp and
  /// the flattened "tail" corner; grouped (non-tail) bubbles are fully rounded
  /// and sit tight against the next.
  final bool isTail;

  /// A delete for this message is in flight — dimmed until it resolves.
  final bool deleting;

  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    const tailR = 5.0; // the flattened "tail" corner nearest the sender
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.lg),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(mine || !isTail ? AppRadius.lg : tailR),
      bottomRight: Radius.circular(!mine || !isTail ? AppRadius.lg : tailR),
    );
    final body = (message.body ?? '').trim();
    final tombstone = message.deletedForEveryone;
    final attachment = message.attachment;
    // Cap bubble width so a short line doesn't stretch edge-to-edge on tablets
    // and large phones while still tracking the viewport on small ones.
    final maxBubbleWidth =
        math.min(MediaQuery.sizeOf(context).width * 0.72, 560.0);

    // Subtle entrance: fade + a small upward drift, ~220ms. Keyed by message
    // id at the list level, so this runs once per new bubble, never on rebuild.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
      ),
      child: Padding(
      // Tight gap within a group, roomier gap between senders/groups.
      padding: EdgeInsets.only(bottom: isTail ? AppSpacing.md : 2),
      child: Column(
        crossAxisAlignment: mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          AnimatedOpacity(
            opacity: deleting ? 0.4 : 1,
            duration: const Duration(milliseconds: 160),
            child: GestureDetector(
              onLongPress: deleting ? null : onLongPress,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: mine
                        ? AppColors.primary
                        : AppColors.darkSurfaceElevated,
                    borderRadius: radius,
                    border: mine
                        ? null
                        : Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quoted reply preview, above the body it replies to.
                      if (message.replyTo != null && !tombstone) ...[
                        _QuotedPreview(
                          mine: mine,
                          authorLabel: replyAuthorLabel ?? 'Them',
                          snippet: chatReplySnippet(
                            body: message.replyTo!.body,
                            attachment: message.replyTo!.attachment,
                          ),
                        ),
                        if (body.isNotEmpty || attachment != null)
                          const SizedBox(height: 6),
                      ],
                      if (body.isNotEmpty)
                        Text(
                          body,
                          style: AppTypography.body.copyWith(
                            color: tombstone
                                ? (mine
                                      ? AppColors.onPrimary.withValues(
                                          alpha: 0.7,
                                        )
                                      : AppColors.textTertiary)
                                : (mine ? AppColors.onPrimary : null),
                            fontStyle: tombstone ? FontStyle.italic : null,
                          ),
                        ),
                      // Attachments have no download UI yet (a later phase) — an
                      // attachment received in history still shows honestly as a
                      // named chip instead of silently vanishing.
                      if (attachment != null && !tombstone) ...[
                        if (body.isNotEmpty) const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: 13,
                              color: mine
                                  ? AppColors.onPrimary.withValues(alpha: 0.7)
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                attachment.originalFilename,
                                style: AppTypography.caption.copyWith(
                                  color: mine
                                      ? AppColors.onPrimary.withValues(
                                          alpha: 0.7,
                                        )
                                      : AppColors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isTail)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    relativeTime(message.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  // Delivery status on my own messages only — a monochrome
                  // single/double check (no chromatic accent exists in the
                  // system). Hidden on a tombstone (nothing to acknowledge).
                  if (mine && !tombstone) ...[
                    const SizedBox(width: 4),
                    _StatusTicks(status: message.status),
                  ],
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }
}

/// Monochrome delivery ticks for an own message: a single check until the
/// counterpart has read it, then a brighter double check. Delivered (if the
/// server ever reports it) reads as a muted double check. Color-free by design
/// — the system has no chromatic accent, so state is carried by shape + weight.
class _StatusTicks extends StatelessWidget {
  const _StatusTicks({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final read = status == 'READ';
    final delivered = read || status == 'DELIVERED';
    return Icon(
      delivered ? Icons.done_all_rounded : Icons.done_rounded,
      size: 14,
      color: read ? AppColors.textSecondary : AppColors.textTertiary,
      semanticLabel: read
          ? 'Read'
          : delivered
              ? 'Delivered'
              : 'Sent',
    );
  }
}

/// The quoted-message block shown at the top of a reply bubble: an accent bar,
/// the quoted author, and a one-line snippet. Tinted to sit legibly on either
/// bubble surface — a dark tint on my white bubble, a light tint on the
/// counterpart's dark bubble.
class _QuotedPreview extends StatelessWidget {
  const _QuotedPreview({
    required this.mine,
    required this.authorLabel,
    required this.snippet,
  });

  final bool mine;
  final String authorLabel;
  final String snippet;

  @override
  Widget build(BuildContext context) {
    final bg = mine
        ? AppColors.onPrimary.withValues(alpha: 0.06)
        : const Color(0x14FFFFFF);
    final bar = mine
        ? AppColors.onPrimary.withValues(alpha: 0.45)
        : AppColors.textSecondary;
    final author = mine ? AppColors.onPrimary : AppColors.textSecondary;
    final snippetColor = mine
        ? AppColors.onPrimary.withValues(alpha: 0.65)
        : AppColors.textTertiary;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: bar,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorLabel,
                    style: AppTypography.caption.copyWith(
                      color: author,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTypography.caption.copyWith(color: snippetColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The empty-thread state — a quiet, premium invitation to start the chat,
/// personalized with the counterpart's name when known.
class _EmptyThread extends StatelessWidget {
  const _EmptyThread({this.counterpartName});
  final String? counterpartName;

  @override
  Widget build(BuildContext context) {
    final name = (counterpartName ?? '').trim();
    final title = name.isEmpty ? 'Say hello' : 'Say hello to ${name.split(' ').first}';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.waving_hand_rounded,
                  size: 30, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              'This is the beginning of your conversation.',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A floating "New messages" pill shown when a message lands while the reader
/// is scrolled up in the history. Tapping it animates back to the newest.
class _JumpToLatest extends StatelessWidget {
  const _JumpToLatest({required this.visible, required this.onTap});
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 160),
          child: Center(
            child: Material(
              color: AppColors.darkSurfaceElevated,
              elevation: 3,
              shadowColor: Colors.black54,
              shape: const StadiumBorder(
                side: BorderSide(color: AppColors.darkBorder),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_downward_rounded,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'New messages',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    return AppDateFormatter.monthDayYear(day);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Text(
          _label(),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
