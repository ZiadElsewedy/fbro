import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drop/core/enums/report_status.dart';
import 'package:drop/core/extensions/context_extensions.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/widgets/adaptive_scaffold.dart';
import 'package:drop/core/widgets/status_badge.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/presentation/cubit/report_cubit.dart';
import 'package:drop/features/reports/presentation/cubit/report_state.dart';
import 'package:drop/features/reports/presentation/report_format.dart';
import 'package:drop/features/reports/presentation/widgets/report_thread.dart';
import 'package:drop/features/task/presentation/activity_format.dart' show relativeTime;
import 'package:drop/features/task/presentation/widgets/attachment_gallery.dart';

/// A report reads like a **premium support conversation**, not a task: the
/// opening message (the report), the reply thread, a compact status control for
/// the recipient, and a reply composer pinned at the bottom.
class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({super.key, required this.reportId});
  final String reportId;

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  ReportEntity? _fetched; // deep-link fallback (report not in the scoped list)
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    final user = context.currentUser;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cubit = context.read<ReportCubit>();
      if (user != null) cubit.load(user);
      if (cubit.reportById(widget.reportId) == null) {
        final fetched = await cubit.fetchReport(widget.reportId);
        if (mounted) setState(() => _fetched = fetched);
      }
      if (mounted) setState(() => _resolving = false);
    });
  }

  Future<void> _revealSender(ReportEntity r) async {
    final identity = await context.read<ReportCubit>().revealReporter(r.id);
    if (!mounted) return;
    final name = (identity?.createdByName ?? '').trim();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurfaceElevated,
        title: const Text('Reporter identity'),
        content: Text(
          identity == null
              ? 'The reporter identity could not be read.'
              : 'Filed by ${name.isNotEmpty ? name : identity.createdByUserId}.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        final report = context.read<ReportCubit>().reportById(widget.reportId) ??
            _fetched;
        final canReveal = report != null &&
            (context.currentRole?.isAdmin ?? false) &&
            report.privacy.isConfidential;
        return AdaptiveScaffold(
          title: 'Report',
          contentMaxWidth: 720,
          actions: [
            if (canReveal)
              IconButton(
                tooltip: 'Reveal sender',
                icon: const Icon(Icons.visibility_outlined),
                onPressed: () => _revealSender(report),
              ),
          ],
          body: report == null
              ? _resolving
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : const Center(child: Text('This report is unavailable.'))
              : _Conversation(report: report),
        );
      },
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({required this.report});
  final ReportEntity report;

  @override
  Widget build(BuildContext context) {
    final role = context.currentRole;
    final isAdmin = role?.isAdmin ?? false;
    final canAct =
        isAdmin || ((role?.isManager ?? false) && report.visibleToManager);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding,
                AppSpacing.lg, AppSpacing.pagePadding, AppSpacing.lg),
            children: [
              _OpeningMessage(report: report),
              const SizedBox(height: AppSpacing.xl),
              ReportThread(
                entries: report.activityLog,
                currentUid: context.currentUser?.uid ?? '',
                iAmReporter: role?.isEmployee ?? false,
              ),
            ],
          ),
        ),
        if (canAct) _StatusBar(report: report),
        _Composer(report: report),
      ],
    );
  }
}

/// The report itself, shown as the opening message — the "message-first" surface.
class _OpeningMessage extends StatelessWidget {
  const _OpeningMessage({required this.report});
  final ReportEntity report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(reportCategoryIcon(report.category),
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(report.title, style: AppTypography.h3)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusBadge(
                  label: report.status.label,
                  color: reportStatusColor(report.status)),
              StatusBadge(
                  label: report.severity.label,
                  color: reportSeverityColor(report.severity)),
              StatusBadge(
                  label: report.category.label,
                  color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                  report.privacy.isNormal
                      ? Icons.person_outline
                      : Icons.lock_outline,
                  size: 14,
                  color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(report.senderLabel, style: AppTypography.caption),
              if (report.createdAt != null) ...[
                Text('  ·  ', style: AppTypography.caption),
                Text(relativeTime(report.createdAt!),
                    style: AppTypography.caption),
              ],
            ],
          ),
          if ((report.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(report.description!.trim(), style: AppTypography.body),
          ],
          if (report.hasAttachments) ...[
            const SizedBox(height: AppSpacing.md),
            AttachmentGallery(attachments: report.attachments),
          ],
        ],
      ),
    );
  }
}

/// Compact recipient status control — one tap moves the conversation forward.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.report});
  final ReportEntity report;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportCubit>();
    final options = report.status.allowedNext;
    if (options.isEmpty) return const SizedBox.shrink();

    (String, VoidCallback, bool) mapping(ReportStatus next) {
      switch (next) {
        case ReportStatus.underReview:
          return report.status.isResolved
              ? ('Reopen', () => cubit.reopen(report), false)
              : ('Under Review', () => cubit.markUnderReview(report), false);
        case ReportStatus.waitingReply:
          return ('Waiting Reply', () => cubit.markWaitingReply(report), false);
        case ReportStatus.resolved:
          return ('Resolve', () => cubit.resolve(report), true);
        case ReportStatus.newReport:
          return ('Reopen', () => cubit.reopen(report), false);
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding, AppSpacing.sm, AppSpacing.pagePadding, 0),
      child: Row(
        children: [
          for (final next in options) ...[
            Builder(builder: (context) {
              final (label, onTap, strong) = mapping(next);
              return _StatusChip(label: label, onTap: onTap, strong: strong);
            }),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(
      {required this.label, required this.onTap, this.strong = false});
  final String label;
  final VoidCallback onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final bg = strong ? AppColors.success.withAlpha(28) : AppColors.darkSurfaceElevated;
    final border = strong ? AppColors.success.withAlpha(130) : AppColors.darkBorder;
    final fg = strong ? AppColors.success : AppColors.textSecondary;
    return Material(
      color: bg,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.fullAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            border: Border.all(color: border),
          ),
          child: Text(label,
              style: AppTypography.label
                  .copyWith(color: fg, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({required this.report});
  final ReportEntity report;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    await context.read<ReportCubit>().addComment(widget.report, text);
    if (!mounted) return;
    _controller.clear();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        AppSpacing.sm + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                borderRadius: AppRadius.xlAll,
                border: Border.all(color: AppColors.darkBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                style: AppTypography.body,
                decoration: const InputDecoration(
                  hintText: 'Write a reply…',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _sending ? null : _send,
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.onPrimary))
                    : const Icon(Icons.arrow_upward_rounded,
                        color: AppColors.onPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
