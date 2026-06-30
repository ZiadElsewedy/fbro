import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:drop/core/enums/user_role.dart';
import 'package:drop/core/extensions/context_extensions.dart';
import 'package:drop/core/responsive/breakpoints.dart';
import 'package:drop/core/routes/route_names.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/widgets/app_sidebar.dart';
import 'package:drop/core/widgets/user_avatar.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:drop/features/notifications/presentation/cubit/notification_state.dart';

/// The desktop application shell — the single source of persistent navigation
/// chrome for the whole signed-in app.
///
/// Wired into the router as a [ShellRoute] so the [AppSidebar] is mounted **once**
/// and survives every route change (no re-animation, no flicker) — the structural
/// difference between a real macOS productivity app and a stack of pushed mobile
/// screens. On mobile/tablet the shell is a no-op pass-through: those widths keep
/// the original per-screen app bars + bottom navigation untouched.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  /// Current router location (from `GoRouterState.matchedLocation`).
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Mobile / tablet: unchanged. Also bail out if we somehow render without a
    // session (the router's redirect guards normally prevent this).
    final user = context.currentUser;
    if (!context.isDesktop || user == null) return child;

    final role = user.role;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            sections: _sectionsForRole(role),
            location: location,
            onSelect: (route) {
              if (route != location) context.go(route);
            },
            footer: _SidebarUserFooter(
              user: user,
              role: role,
              onTap: () => context.go(RouteNames.profile),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  List<SidebarSection> _sectionsForRole(UserRole role) {
    const notifications = SidebarItem(
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_rounded,
      label: 'Notifications',
      route: RouteNames.notifications,
    );
    const communications = SidebarItem(
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign_rounded,
      label: 'Communications',
      route: RouteNames.communications,
    );

    switch (role) {
      case UserRole.admin:
        return [
          SidebarSection(items: [
            const SidebarItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: 'Dashboard',
              route: RouteNames.adminDashboard,
            ),
            const SidebarItem(
              icon: Icons.fact_check_outlined,
              activeIcon: Icons.fact_check_rounded,
              label: 'Tasks',
              route: RouteNames.adminTasks,
            ),
            const SidebarItem(
              icon: Icons.calendar_view_week_outlined,
              activeIcon: Icons.calendar_view_week_rounded,
              label: 'Schedule',
              route: RouteNames.adminSchedule,
            ),
            communications,
            notifications,
          ]),
          SidebarSection(title: 'Administration', items: [
            const SidebarItem(
              icon: Icons.analytics_outlined,
              activeIcon: Icons.analytics_rounded,
              label: 'Analytics',
              route: RouteNames.adminAnalytics,
            ),
            const SidebarItem(
              icon: Icons.store_outlined,
              activeIcon: Icons.store_rounded,
              label: 'Branches',
              route: RouteNames.adminBranches,
            ),
            const SidebarItem(
              icon: Icons.badge_outlined,
              activeIcon: Icons.badge_rounded,
              label: 'Managers',
              route: RouteNames.adminManagers,
            ),
            const SidebarItem(
              icon: Icons.people_outline_rounded,
              activeIcon: Icons.people_rounded,
              label: 'Employees',
              route: RouteNames.adminEmployees,
            ),
          ]),
        ];
      case UserRole.manager:
        return [
          SidebarSection(items: [
            const SidebarItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: 'Dashboard',
              route: RouteNames.managerHome,
            ),
            const SidebarItem(
              icon: Icons.fact_check_outlined,
              activeIcon: Icons.fact_check_rounded,
              label: 'Operations',
              route: RouteNames.managerTasks,
            ),
            const SidebarItem(
              icon: Icons.calendar_view_week_outlined,
              activeIcon: Icons.calendar_view_week_rounded,
              label: 'Schedule',
              route: RouteNames.managerSchedule,
            ),
            communications,
            notifications,
          ]),
        ];
      case UserRole.employee:
        return [
          SidebarSection(items: [
            const SidebarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              route: RouteNames.home,
            ),
            const SidebarItem(
              icon: Icons.fact_check_outlined,
              activeIcon: Icons.fact_check_rounded,
              label: 'My Tasks',
              route: RouteNames.myTasks,
            ),
            const SidebarItem(
              icon: Icons.calendar_view_week_outlined,
              activeIcon: Icons.calendar_view_week_rounded,
              label: 'My Schedule',
              route: RouteNames.mySchedule,
            ),
            notifications,
          ]),
        ];
    }
  }
}

/// Pinned sidebar footer: unread-aware avatar + name + role, tappable → profile.
class _SidebarUserFooter extends StatefulWidget {
  const _SidebarUserFooter({
    required this.user,
    required this.role,
    required this.onTap,
  });

  final UserEntity user;
  final UserRole role;
  final VoidCallback onTap;

  @override
  State<_SidebarUserFooter> createState() => _SidebarUserFooterState();
}

class _SidebarUserFooterState extends State<_SidebarUserFooter> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final name = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName!
        : 'Profile';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0x12FFFFFF) : AppColors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              UserAvatar.fromUser(user, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label,
                    ),
                    Text(
                      widget.role.name.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        letterSpacing: 1,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const _FooterBell(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small unread-count indicator in the footer so notifications are glanceable
/// even when the inbox isn't the active destination.
class _FooterBell extends StatelessWidget {
  const _FooterBell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, _) {
        final unread = context.read<NotificationCubit>().unreadCount;
        if (unread <= 0) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            unread > 9 ? '9+' : '$unread',
            style: AppTypography.caption.copyWith(
              color: AppColors.onAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
