import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fbro/core/enums/task_status.dart';
import 'package:fbro/core/extensions/context_extensions.dart';
import 'package:fbro/core/routes/route_names.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_spacing.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/action_card.dart';
import 'package:fbro/core/widgets/admin_section_header.dart';
import 'package:fbro/core/widgets/app_motion.dart';
import 'package:fbro/core/widgets/dashboard_metric_card.dart';
import 'package:fbro/core/widgets/glass_container.dart';
import 'package:fbro/core/widgets/status_badge.dart';
import 'package:fbro/core/widgets/timeline_tile.dart';
import 'package:fbro/core/widgets/user_avatar.dart';
import 'package:fbro/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:fbro/features/auth/domain/entities/user_entity.dart';
import 'package:fbro/features/auth/presentation/widgets/app_button.dart';
import 'package:fbro/features/statistics/domain/entities/statistics_entity.dart';
import 'package:fbro/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fbro/features/task/domain/entities/activity_entry.dart';
import 'package:fbro/features/task/domain/entities/task_entity.dart';
import 'package:fbro/features/task/presentation/activity_format.dart';
import 'package:fbro/features/task/presentation/cubit/task_cubit.dart';

/// Admin Home — an operations **command center**. Pulls from three live sources
/// (statistics · the task stream · pending users) so an admin instantly sees
/// branch health, workforce, pending approvals, active tasks and operational
/// issues, then reaches any critical action in one tap.
///
/// Composition over a monolith: every visual is a shared component
/// (`GlassContainer`, `DashboardMetricCard`, `ActionCard`, `AdminSectionHeader`,
/// `TimelineTile`) — this screen only arranges them and derives the data.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserEntity> _pending = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.currentUser;
    if (user == null) return;
    context.read<StatisticsCubit>().load(user);
    // The all-branches task stream powers the activity feed + overdue count.
    final taskCubit = context.read<TaskCubit>();
    final taskLoaded =
        taskCubit.state.maybeWhen(loaded: (_, _, _) => true, orElse: () => false);
    if (!taskLoaded) taskCubit.load(user);
    final pending = await context.read<AdminUsersCubit>().pendingUsers();
    if (mounted) setState(() => _pending = pending);
  }

  @override
  Widget build(BuildContext context) {
    final stats = context
        .watch<StatisticsCubit>()
        .state
        .maybeWhen(loaded: (s) => s, orElse: () => null);
    final taskState = context.watch<TaskCubit>().state;
    final tasks = taskState.maybeWhen(
        loaded: (t, _, _) => t, orElse: () => const <TaskEntity>[]);
    final directory = taskState.maybeWhen(
        loaded: (_, _, d) => d, orElse: () => const <String, UserEntity>{});

    var i = 0;
    Widget staggered(Widget child) =>
        EntranceFade(delay: staggerDelay(i++), child: child);

    return RefreshIndicator(
      onRefresh: () => _load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.sm,
            AppSpacing.pagePadding, AppSpacing.xxxl),
        children: [
          staggered(_Greeting(stats: stats, name: context.currentUser?.displayName)),
          const SizedBox(height: AppSpacing.xl),
          staggered(_Hero(stats: stats, tasks: tasks)),
          const SizedBox(height: AppSpacing.xxl),
          staggered(const AdminSectionHeader(title: 'Overview')),
          staggered(_metrics(stats)),
          const SizedBox(height: AppSpacing.xxl),
          staggered(const AdminSectionHeader(title: 'Quick actions')),
          staggered(_quickActions()),
          if (_pending.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            staggered(AdminSectionHeader(
              title: 'Pending approvals',
              subtitle: '${_pending.length} awaiting review',
              actionLabel: 'Review all',
              onAction: () => context.push(RouteNames.adminApprovals),
            )),
            staggered(_PendingList(users: _pending)),
          ],
          const SizedBox(height: AppSpacing.xxl),
          staggered(const AdminSectionHeader(
            title: 'Recent activity',
            subtitle: 'Latest operational events',
          )),
          staggered(_RecentActivity(tasks: tasks, directory: directory)),
          const SizedBox(height: AppSpacing.xxl),
          staggered(const AdminSectionHeader(title: 'Manage')),
          staggered(_manage()),
        ],
      ),
    );
  }

  // ── Metrics grid ─────────────────────────────────────────────────
  Widget _metrics(StatisticsEntity? s) {
    String v(int? n) => s == null ? '—' : '${n ?? 0}';
    final unstaffed = s?.branchesWithoutManagers ?? 0;
    final reviews = s?.waitingReviews ?? 0;
    return _grid([
      DashboardMetricCard(
        icon: Icons.store_mall_directory_outlined,
        value: v(s?.totalBranches),
        label: 'Branches',
        trend: s == null
            ? null
            : (unstaffed > 0 ? '$unstaffed without manager' : 'All staffed'),
        trendColor: unstaffed > 0 ? AppColors.warning : AppColors.success,
        onTap: () => context.push(RouteNames.adminBranches),
      ),
      DashboardMetricCard(
        icon: Icons.groups_outlined,
        value: v(s?.totalEmployees),
        label: 'Employees',
        trend: s == null ? null : '${s.totalManagers} managers',
        onTap: () => context.push(RouteNames.adminEmployees),
      ),
      DashboardMetricCard(
        icon: Icons.supervisor_account_outlined,
        value: v(s?.totalManagers),
        label: 'Managers',
        onTap: () => context.push(RouteNames.adminManagers),
      ),
      DashboardMetricCard(
        icon: Icons.fact_check_outlined,
        value: v(s?.activeTasks),
        label: 'Active tasks',
        trend: s == null
            ? null
            : (reviews > 0 ? '$reviews in review' : 'None in review'),
        trendColor: reviews > 0 ? AppColors.warning : AppColors.textSecondary,
        onTap: () => context.push(RouteNames.adminTasks),
      ),
    ]);
  }

  // ── Quick actions ────────────────────────────────────────────────
  Widget _quickActions() {
    return _grid([
      ActionCard(
        icon: Icons.add_business_outlined,
        title: 'Add Branch',
        onTap: () => context.push(RouteNames.adminBranches),
      ),
      ActionCard(
        icon: Icons.person_add_alt_1_outlined,
        title: 'Add Manager',
        onTap: () => context.push(RouteNames.adminManagers),
      ),
      ActionCard(
        icon: Icons.assignment_add,
        title: 'Assign Task',
        onTap: () => context.push(RouteNames.adminTasks),
      ),
      ActionCard(
        icon: Icons.how_to_reg_outlined,
        title: 'Approve Employee',
        onTap: () => context.push(RouteNames.adminApprovals),
      ),
    ]);
  }

  // ── Manage (module directory) ────────────────────────────────────
  Widget _manage() {
    return _grid([
      ActionCard(
        icon: Icons.calendar_view_week_outlined,
        title: 'Schedules',
        subtitle: 'Any branch',
        onTap: () => context.push(RouteNames.adminSchedule),
      ),
      ActionCard(
        icon: Icons.groups_outlined,
        title: 'Employees',
        subtitle: 'Manage staff',
        onTap: () => context.push(RouteNames.adminEmployees),
      ),
      ActionCard(
        icon: Icons.insights_outlined,
        title: 'Analytics',
        subtitle: 'Full metrics',
        onTap: () => context.push(RouteNames.adminAnalytics),
      ),
      ActionCard(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'App & account',
        onTap: () => context.push(RouteNames.settings),
      ),
    ]);
  }

  /// Lay out [cards] two-per-row at equal height.
  Widget _grid(List<Widget> cards) {
    return Column(
      children: [
        for (var i = 0; i < cards.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
                bottom: i + 2 < cards.length ? AppSpacing.md : 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[i]),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child:
                        i + 1 < cards.length ? cards[i + 1] : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Greeting header ────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting({required this.stats, this.name});
  final StatisticsEntity? stats;
  final String? name;

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _salutation {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _date {
    final n = DateTime.now();
    return '${_weekdays[n.weekday - 1]}, ${n.day} ${_months[n.month - 1]}';
  }

  String get _scope {
    final s = stats;
    if (s == null) return 'Operations overview';
    final b = '${s.totalBranches} ${s.totalBranches == 1 ? 'branch' : 'branches'}';
    final e =
        '${s.totalEmployees} ${s.totalEmployees == 1 ? 'employee' : 'employees'}';
    return '$b · $e';
  }

  @override
  Widget build(BuildContext context) {
    final first =
        (name != null && name!.trim().isNotEmpty) ? name!.trim().split(' ').first : 'Admin';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_date.toUpperCase(),
            style: AppTypography.labelSmall
                .copyWith(color: AppColors.textTertiary, letterSpacing: 1.0)),
        const SizedBox(height: AppSpacing.sm),
        Text('$_salutation,', style: AppTypography.h2),
        Text(first, style: AppTypography.display),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(Icons.public_rounded,
                size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(_scope, style: AppTypography.caption),
          ],
        ),
      ],
    );
  }
}

// ─── Hero card ──────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.stats, required this.tasks});
  final StatisticsEntity? stats;
  final List<TaskEntity> tasks;

  int get _overdue {
    final now = DateTime.now();
    return tasks.where((t) {
      final d = t.deadline;
      if (d == null) return false;
      final open = t.status == TaskStatus.pending ||
          t.status == TaskStatus.started ||
          t.status == TaskStatus.rejected;
      return open && d.isBefore(now);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final s = stats;
    final pending = s?.pendingApprovals ?? 0;
    final reviews = s?.waitingReviews ?? 0;
    final overdue = _overdue;
    final active = s?.activeTasks ?? 0;
    final doneToday = s?.completedTasksToday ?? 0;
    final totalToday = doneToday + active;
    final progress = totalToday == 0 ? 0.0 : doneToday / totalToday;

    final String title, value, summary, cta, route;
    final Color accent;
    final bool highlight;
    final IconData icon;

    if (pending > 0) {
      title = 'Pending approvals';
      value = '$pending';
      summary =
          '$pending ${pending == 1 ? 'person is' : 'people are'} waiting for account approval.';
      cta = 'Review approvals';
      route = RouteNames.adminApprovals;
      accent = AppColors.warning;
      highlight = true;
      icon = Icons.how_to_reg_rounded;
    } else if (reviews > 0) {
      title = 'Tasks awaiting review';
      value = '$reviews';
      summary =
          '$reviews ${reviews == 1 ? 'task' : 'tasks'} submitted and waiting for your review.';
      cta = 'Review tasks';
      route = RouteNames.adminTasks;
      accent = AppColors.warning;
      highlight = true;
      icon = Icons.rate_review_rounded;
    } else if (overdue > 0) {
      title = 'Overdue tasks';
      value = '$overdue';
      summary =
          '$overdue ${overdue == 1 ? 'task is' : 'tasks are'} past the deadline and not yet submitted.';
      cta = 'View tasks';
      route = RouteNames.adminTasks;
      accent = AppColors.error;
      highlight = true;
      icon = Icons.warning_amber_rounded;
    } else {
      title = 'All clear';
      value = '$active';
      summary =
          'No approvals or reviews waiting. $active active ${active == 1 ? 'task' : 'tasks'} in progress.';
      cta = 'View tasks';
      route = RouteNames.adminTasks;
      accent = AppColors.success;
      highlight = false;
      icon = Icons.check_circle_rounded;
    }

    return GlassContainer(
      highlight: highlight,
      accent: accent,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withAlpha(28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 21, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                highlight ? 'NEEDS ATTENTION' : 'ALL CLEAR',
                style: AppTypography.caption.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(value, style: AppTypography.display),
          Text(title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(summary,
              style: AppTypography.body.copyWith(height: 1.5)),
          const SizedBox(height: AppSpacing.lg),
          // Today's throughput progress.
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: AppColors.darkSurfaceElevated,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '$doneToday/$totalToday today',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: cta,
            icon: const Icon(Icons.arrow_forward_rounded,
                size: 18, color: AppColors.textDark),
            onPressed: () => context.push(route),
          ),
        ],
      ),
    );
  }
}

// ─── Pending approvals list ─────────────────────────────────────────

class _PendingList extends StatelessWidget {
  const _PendingList({required this.users});
  final List<UserEntity> users;

  @override
  Widget build(BuildContext context) {
    final shown = users.take(3).toList();
    return GlassContainer(
      onTap: () => context.push(RouteNames.adminApprovals),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0)
              const Divider(color: AppColors.darkBorder, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  UserAvatar.fromUser(shown[i], size: 38),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (shown[i].displayName?.isNotEmpty ?? false)
                              ? shown[i].displayName!
                              : shown[i].email,
                          style: AppTypography.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(shown[i].email,
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(label: 'Pending', color: AppColors.warning),
                ],
              ),
            ),
          ],
          if (users.length > shown.length)
            Padding(
              padding: const EdgeInsets.only(
                  top: AppSpacing.xs, bottom: AppSpacing.sm),
              child: Text(
                '+${users.length - shown.length} more awaiting approval',
                style: AppTypography.caption,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Recent activity feed ───────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.tasks, required this.directory});
  final List<TaskEntity> tasks;
  final Map<String, UserEntity> directory;

  @override
  Widget build(BuildContext context) {
    final events = <({String task, ActivityEntry e})>[];
    for (final t in tasks) {
      for (final e in t.activityLog) {
        events.add((task: t.title, e: e));
      }
    }
    events.sort((a, b) => b.e.at.compareTo(a.e.at));
    final top = events.take(6).toList();

    if (top.isEmpty) {
      return GlassContainer(
        child: Row(
          children: [
            const Icon(Icons.timeline_rounded,
                size: 18, color: AppColors.textTertiary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text('No recent activity yet.',
                  style: AppTypography.body),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      child: Column(
        children: [
          for (var i = 0; i < top.length; i++)
            TimelineTile(
              title: activityTitle(top[i].e.status),
              titleColor: activityColor(top[i].e.status),
              dotColor: activityColor(top[i].e.status),
              time: relativeTime(top[i].e.at),
              subtitle: '${_actor(top[i].e)} · ${top[i].task}',
              note: top[i].e.note,
              isLast: i == top.length - 1,
            ),
        ],
      ),
    );
  }

  String _actor(ActivityEntry e) {
    final u = directory[e.actorId];
    return e.actorName ??
        (u != null ? (u.displayName ?? u.email) : 'Someone');
  }
}
