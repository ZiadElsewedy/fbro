import 'package:flutter/material.dart';
import 'package:fbro/core/di/injection.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_spacing.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/app_empty_state.dart';
import 'package:fbro/core/widgets/glass_container.dart';
import 'package:fbro/core/widgets/list_skeleton.dart';
import 'package:fbro/features/communications/domain/entities/comms_analytics_entity.dart';

/// Communications analytics dashboard (Phase 2 Commit 6) — reads the **precomputed**
/// monthly rollup (`analytics/{YYYY-MM}`, maintained by Cloud Functions), never a
/// live collection scan. Broadcast + notification metrics, a daily-volume chart,
/// and engagement bars. Read-once, so it loads the repository directly (no cubit).
class CommunicationsAnalyticsScreen extends StatefulWidget {
  const CommunicationsAnalyticsScreen({super.key});

  @override
  State<CommunicationsAnalyticsScreen> createState() =>
      _CommunicationsAnalyticsScreenState();
}

class _CommunicationsAnalyticsScreenState
    extends State<CommunicationsAnalyticsScreen> {
  late Future<CommsAnalyticsEntity> _future;

  @override
  void initState() {
    super.initState();
    _future = AppDependencies.commsAnalyticsRepository.load();
  }

  void _reload() =>
      setState(() => _future = AppDependencies.commsAnalyticsRepository.load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        titleSpacing: AppSpacing.pagePadding,
        title: Text('Communications analytics', style: AppTypography.h3),
      ),
      body: FutureBuilder<CommsAnalyticsEntity>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const ListSkeleton();
          }
          if (snap.hasError) {
            return AppEmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Could not load analytics',
              message: 'Check your connection and try again.',
              action: TextButton(
                onPressed: _reload,
                child: Text('Retry',
                    style:
                        AppTypography.label.copyWith(color: AppColors.primary)),
              ),
            );
          }
          final a = snap.data ?? CommsAnalyticsEntity.empty;
          if (a.isEmpty) {
            return const AppEmptyState(
              icon: Icons.insights_outlined,
              title: 'No activity yet this month',
              message:
                  'Send broadcasts and notifications to see delivery + '
                  'engagement analytics here.',
            );
          }
          return _content(a);
        },
      ),
    );
  }

  Widget _content(CommsAnalyticsEntity a) {
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.lg,
            AppSpacing.pagePadding, AppSpacing.xxxl),
        children: [
          const _SectionLabel('Broadcasts'),
          Row(children: [
            Expanded(child: _Metric('Sent', '${a.broadcastsSent}', Icons.campaign_outlined)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _Metric('Delivered', '${a.delivered}', Icons.mark_email_read_outlined)),
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
                child: _Metric('Failed', '${a.failed}', Icons.error_outline_rounded,
                    accent: a.failed > 0 ? AppColors.error : null)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _Metric('Open rate', _pct(a.openRate), Icons.drafts_outlined)),
          ]),
          const SizedBox(height: AppSpacing.lg),

          const _SectionLabel('Notifications'),
          Row(children: [
            Expanded(child: _Metric('Sent', '${a.notifSent}', Icons.notifications_none_rounded)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _Metric('Read', '${a.notifRead}', Icons.done_all_rounded)),
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: _Metric('Unread', '${a.unread}', Icons.mark_email_unread_outlined)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _Metric('Read rate', _pct(a.readRate), Icons.insights_outlined)),
          ]),
          const SizedBox(height: AppSpacing.lg),

          const _SectionLabel('Daily volume'),
          GlassContainer(child: _BarChart(points: a.daily)),
          const SizedBox(height: AppSpacing.lg),

          const _SectionLabel('Engagement'),
          GlassContainer(
            child: Column(
              children: [
                _Bar(label: 'Delivery rate', value: a.deliveryRate),
                const SizedBox(height: AppSpacing.md),
                _Bar(label: 'Open rate', value: a.openRate),
                const SizedBox(height: AppSpacing.md),
                _Bar(label: 'Read rate', value: a.readRate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _pct(double v) => '${(v * 100).round()}%';
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 2),
        child: Text(text.toUpperCase(),
            style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary, letterSpacing: 0.6)),
      );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon, {this.accent});
  final String label;
  final String value;
  final IconData icon;
  final Color? accent;
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: accent ?? AppColors.textTertiary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: AppTypography.h2
                  .copyWith(color: accent ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value});
  final String label;
  final double value; // 0..1
  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 1) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.bodySmall),
            const Spacer(),
            Text('$pct%', style: AppTypography.label),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1).toDouble(),
            minHeight: 8,
            backgroundColor: AppColors.darkSurfaceElevated,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// A compact monochrome bar chart of daily broadcast + notification volume.
class _BarChart extends StatelessWidget {
  const _BarChart({required this.points});
  final List<CommsDailyPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
            child: Text('No daily activity yet',
                style: AppTypography.caption)),
      );
    }
    final maxV = points
        .map((p) => p.broadcastsSent + p.notifSent)
        .fold<int>(1, (m, v) => v > m ? v : m);
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final p in points)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 100 *
                          ((p.broadcastsSent + p.notifSent) / maxV)
                              .clamp(0.02, 1.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(160),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${p.day}',
                        style: AppTypography.caption
                            .copyWith(fontSize: 8, color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
