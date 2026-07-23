import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drop/core/responsive/breakpoints.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_typography.dart';

/// The message composer pinned at the bottom of a chat thread — text only
/// (attachments are a later phase). A premium, iMessage/Telegram-style bar: a
/// generously-padded rounded input that grows with multiline text, and a
/// circular send button that lights up only when there's something to send.
///
/// [onSend] returns whether the send **succeeded**: the composer only clears
/// the input on success, so a failed send never silently loses what the user
/// typed. Focus returns to the field after a successful send.
///
/// Desktop: the field autofocuses on mount and Enter sends (Shift+Enter →
/// newline). Mobile keeps the keyboard down until the user taps the field.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.sending,
  });

  final Future<bool> Function(String text) onSend;
  final bool sending;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();
  late final FocusNode _node = FocusNode(onKeyEvent: _handleKey);

  bool _enterToSend = false;
  bool _autofocused = false;

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (_enterToSend &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _send();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (widget.sending || text.isEmpty) return;
    // Keep the text until the send resolves — only clear on success, so a
    // network failure lets the user retry, not retype.
    final ok = await widget.onSend(text);
    if (!mounted || !ok) return;
    _controller.clear();
    _node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    _enterToSend = context.isDesktop;
    if (_enterToSend && !_autofocused) {
      _autofocused = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _node.requestFocus();
      });
    }
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + safeBottom),
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        border: Border(top: BorderSide(color: AppColors.darkBorder, width: 0.5)),
        // A soft lift so the bar reads as a distinct surface over the thread.
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.darkBorder),
              ),
              padding: const EdgeInsets.only(left: 18, right: 6),
              child: TextField(
                controller: _controller,
                focusNode: _node,
                minLines: 1,
                maxLines: 6,
                style: AppTypography.body.copyWith(height: 1.35),
                cursorColor: AppColors.primary,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: _enterToSend
                    ? TextInputAction.newline
                    : TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: AppTypography.body
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: _enterToSend ? null : (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // The send button reflects state: muted until there's text, then a
          // filled accent circle that gently scales up. Taps always route
          // through _send (a no-op on empty) so it's never a dead target.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final hasText = value.text.trim().isNotEmpty;
              return _SendButton(
                active: hasText && !widget.sending,
                sending: widget.sending,
                onTap: widget.sending ? null : _send,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.active,
    required this.sending,
    required this.onTap,
  });

  final bool active;
  final bool sending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.darkSurface,
          shape: BoxShape.circle,
          border: active ? null : Border.all(color: AppColors.darkBorder),
        ),
        child: sending
            ? const Padding(
                padding: EdgeInsets.all(13),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.onPrimary),
              )
            : AnimatedScale(
                scale: active ? 1 : 0.86,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: 22,
                  color: active ? AppColors.onPrimary : AppColors.textTertiary,
                ),
              ),
      ),
    );
  }
}
