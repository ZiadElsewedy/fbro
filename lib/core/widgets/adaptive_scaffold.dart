import 'package:flutter/material.dart';
import 'package:drop/core/responsive/breakpoints.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_typography.dart';

/// A scaffold that adapts its chrome to the platform width.
///
/// * **Mobile / tablet** → the familiar [AppBar] (title + actions + automatic
///   back button), exactly like the screens used before.
/// * **Desktop / macOS** → no mobile app bar. Instead a calm, generously-spaced
///   in-body **page header** (large title, optional subtitle, right-aligned
///   actions, hairline divider) sits beside the persistent [AppShell] sidebar,
///   and the body is centred in a comfortable max-width column.
///
/// This is the drop-in used to migrate a screen off the "stretched mobile"
/// look: replace `Scaffold(appBar: AppBar(title: …, actions: …), body: …)` with
/// `AdaptiveScaffold(title: …, actions: …, body: …)`.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.floatingActionButton,
    this.bottom,
    this.constrainContent = true,
    this.scrollableHeaderActions = false,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;

  /// Optional custom leading control (e.g. a sub-view back toggle). When null,
  /// the desktop header auto-shows a back button if the route can pop, and the
  /// mobile app bar uses its automatic back button.
  final Widget? leading;
  final Widget? floatingActionButton;

  /// Optional widget pinned under the header on desktop / under the app bar on
  /// mobile (e.g. a [TabBar] or a filter row).
  final PreferredSizeWidget? bottom;

  /// Centre the body in a comfortable max-width column on wide windows.
  final bool constrainContent;

  /// When true the header actions sit in a scrollable row (avoids overflow when
  /// a screen has many actions on a narrow desktop window).
  final bool scrollableHeaderActions;

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          title: Text(title, style: AppTypography.h3),
          leading: leading,
          actions: actions,
          bottom: bottom,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      );
    }

    final canPop = Navigator.of(context).canPop();
    final content = constrainContent ? ContentConstraint(child: body) : body;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      floatingActionButton: floatingActionButton,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DesktopPageHeader(
            title: title,
            subtitle: subtitle,
            actions: actions,
            leading: leading,
            scrollableActions: scrollableHeaderActions,
            onBack: canPop ? () => Navigator.of(context).maybePop() : null,
          ),
          const Divider(height: 1, color: AppColors.darkBorder),
          if (bottom != null) ...[
            bottom!,
            const Divider(height: 1, color: AppColors.darkBorder),
          ],
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _DesktopPageHeader extends StatelessWidget {
  const _DesktopPageHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.leading,
    required this.scrollableActions,
    required this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final bool scrollableActions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final actionRow = actions.isEmpty
        ? const SizedBox.shrink()
        : Row(mainAxisSize: MainAxisSize.min, children: actions);

    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      color: AppColors.darkBg,
      padding: const EdgeInsets.fromLTRB(40, 22, 40, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 14),
          ] else if (onBack != null) ...[
            _HeaderBackButton(onTap: onBack!),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.h1),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTypography.body),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (scrollableActions)
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: actionRow,
              ),
            )
          else
            actionRow,
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatefulWidget {
  const _HeaderBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_HeaderBackButton> createState() => _HeaderBackButtonState();
}

class _HeaderBackButtonState extends State<_HeaderBackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.darkSurfaceElevated : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: const Icon(Icons.arrow_back_rounded,
              size: 19, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
