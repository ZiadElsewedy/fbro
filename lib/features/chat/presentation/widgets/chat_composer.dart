import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drop/core/extensions/context_extensions.dart';
import 'package:drop/core/responsive/breakpoints.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/features/chat/domain/entities/chat_outgoing_attachment.dart';
import 'package:drop/features/chat/presentation/chat_attachment_picker.dart';
import 'package:drop/features/chat/presentation/chat_message_preview.dart';
import 'package:drop/features/chat/presentation/widgets/chat_attachment_sheet.dart';

/// The message composer pinned at the bottom of a chat thread — a premium,
/// iMessage/Telegram-style bar: a paperclip attachment button, a generously
/// padded rounded input that grows with multiline text (1–6 lines), and a
/// circular send button that animates in only when there is something to send
/// (text or a staged attachment).
///
/// [onSend] returns whether the send was accepted; the composer clears the
/// input and any staged attachment only then, so a rejected send never loses
/// what the user prepared. With optimistic sending this returns almost
/// immediately (the network resolves on the bubble), so the bar never blocks.
///
/// Desktop: the field autofocuses on mount and Enter sends (Shift+Enter →
/// newline). Mobile keeps the keyboard down until the user taps the field.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.sending,
    this.header,
    this.attachmentSource,
  });

  /// Sends the composed message. Returns whether it was accepted.
  final Future<bool> Function(String text, ChatOutgoingAttachment? attachment)
      onSend;

  final bool sending;

  /// Optional banner rendered above the input row, inside the composer surface
  /// (e.g. the "Replying to …" preview). Null → just the input row.
  final Widget? header;

  /// Source for the paperclip button. Null → attachments are unavailable and
  /// the paperclip is hidden (e.g. in tests, or an unsupported platform).
  final ChatAttachmentSource? attachmentSource;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();
  late final FocusNode _node = FocusNode(onKeyEvent: _handleKey);

  bool _enterToSend = false;
  bool _autofocused = false;
  bool _picking = false;

  /// Whether the input holds focus — drives the pill's focus animation.
  bool _focused = false;

  /// The staged attachment awaiting send (preview shown above the input).
  ChatOutgoingAttachment? _pending;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted && _node.hasFocus != _focused) {
      setState(() => _focused = _node.hasFocus);
    }
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
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

  bool get _canSend =>
      !widget.sending &&
      (_controller.text.trim().isNotEmpty || _pending != null);

  Future<void> _send() async {
    final text = _controller.text.trim();
    final attachment = _pending;
    if (widget.sending || (text.isEmpty && attachment == null)) return;
    final ok = await widget.onSend(text, attachment);
    if (!mounted || !ok) return;
    _controller.clear();
    setState(() => _pending = null);
    _node.requestFocus();
  }

  Future<void> _pickAttachment() async {
    final source = widget.attachmentSource;
    if (source == null || _picking) return;
    final choice = await showChatAttachmentSheet(context);
    if (choice == null || !mounted) return;
    setState(() => _picking = true);
    try {
      final picked = switch (choice) {
        ChatAttachmentChoice.camera => await source.pickCameraImage(),
        ChatAttachmentChoice.gallery => await source.pickGalleryImage(),
        ChatAttachmentChoice.document => await source.pickDocument(),
      };
      if (picked != null && mounted) setState(() => _pending = picked);
    } on UnsupportedAttachmentException catch (e) {
      if (mounted) context.showError(e.message);
    } catch (_) {
      if (mounted) context.showError('Could not attach that file.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
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
    final showAttach = widget.attachmentSource != null;
    return Container(
      padding: EdgeInsets.fromLTRB(10, 6, 10, 6 + safeBottom),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        border: Border(
          top: BorderSide(
            color: AppColors.darkBorder.withValues(alpha: 0.7),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply banner + staged-attachment preview animate in above the pill.
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.header ?? const SizedBox(width: double.infinity),
                if (_pending != null)
                  _PendingAttachmentPreview(
                    attachment: _pending!,
                    onRemove: () => setState(() => _pending = null),
                  ),
              ],
            ),
          ),
          // ONE cohesive pill — the attachment (+) and send controls live
          // INSIDE the field, not as detached satellites. The whole surface
          // lifts on focus (brighter, heavier border). This is the composer
          // redesign: a single iMessage/Telegram-grade input, not a TextField
          // flanked by loose buttons.
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color:
                    _focused ? AppColors.textSecondary : AppColors.darkBorder,
                width: _focused ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showAttach)
                  _InlineIconButton(
                    icon: Icons.add_rounded,
                    onTap: _picking ? null : _pickAttachment,
                  ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: showAttach ? 0 : 18, right: 4),
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
                        hintStyle: AppTypography.body.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w400,
                        ),
                        // The pill IS the AnimatedContainer above; the field
                        // must draw no border of its own. Null out EVERY state
                        // explicitly — setting only `border` still lets the
                        // global inputDecorationTheme's focusedBorder leak
                        // through on focus (a second bright outline around the
                        // text, breaking the single-pill look).
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        isCollapsed: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onSubmitted: _enterToSend ? null : (_) => _send(),
                    ),
                  ),
                ),
                // Send appears only with something to send, scaling in from the
                // trailing edge inside the pill.
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    final canSend = _canSend;
                    final show = canSend || widget.sending;
                    return AnimatedSize(
                      duration: const Duration(milliseconds: 170),
                      curve: Curves.easeOut,
                      alignment: Alignment.centerRight,
                      child: show
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(2, 6, 6, 6),
                              child: _SendButton(
                                active: canSend,
                                sending: widget.sending,
                                onTap: widget.sending ? null : _send,
                              ),
                            )
                          : const SizedBox(width: 8, height: 50),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A staged attachment shown above the input before sending — an image
/// thumbnail or a compact file row, with a remove affordance.
class _PendingAttachmentPreview extends StatelessWidget {
  const _PendingAttachmentPreview({
    required this.attachment,
    required this.onRemove,
  });

  final ChatOutgoingAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.kind.isImage;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  attachment.bytes,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_rounded,
                    size: 20, color: AppColors.textSecondary),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.originalFilename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${attachment.format.value} · '
                    '${chatHumanBytes(attachment.bytes.length)}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.textTertiary,
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove attachment',
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a tappable control with a quick press-scale — the tactile "give" that
/// makes iMessage/Telegram controls feel physical. No-op when [onTap] is null.
class _TapScale extends StatefulWidget {
  const _TapScale({required this.onTap, required this.child});
  final VoidCallback? onTap;
  final Widget child;
  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _down = false;
  void _set(bool v) {
    if (mounted && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? 0.88 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// The attachment control that lives INSIDE the pill's leading edge — a
/// borderless, bottom-aligned icon (no floating satellite disc), so the pill
/// reads as one unit. Bottom-aligned via the row so it tracks the last text
/// line as the field grows.
class _InlineIconButton extends StatelessWidget {
  const _InlineIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 50,
        alignment: Alignment.center,
        child: Icon(icon, size: 25, color: AppColors.textSecondary),
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
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.darkSurface,
          shape: BoxShape.circle,
          border: active ? null : Border.all(color: AppColors.darkBorder),
        ),
        child: sending
            ? const Padding(
                padding: EdgeInsets.all(11),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.onPrimary),
              )
            : Icon(
                Icons.arrow_upward_rounded,
                size: 19,
                color: active ? AppColors.onPrimary : AppColors.textTertiary,
              ),
      ),
    );
  }
}
