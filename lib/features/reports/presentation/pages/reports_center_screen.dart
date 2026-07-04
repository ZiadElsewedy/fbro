import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:drop/core/extensions/context_extensions.dart';
import 'package:drop/core/routes/route_names.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/widgets/adaptive_scaffold.dart';
import 'package:drop/core/widgets/app_search_field.dart';
import 'package:drop/core/widgets/drop_empty_state.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/presentation/cubit/report_cubit.dart';
import 'package:drop/features/reports/presentation/cubit/report_state.dart';
import 'package:drop/features/reports/presentation/widgets/report_card.dart';

/// The Reports Center list — role-scoped (admin: all · manager: branch · employee:
/// own), with status filter chips, search, urgency-ordered cards, and a "New
/// Report" action. Strictly monochrome.
class ReportsCenterScreen extends StatefulWidget {
  const ReportsCenterScreen({super.key});

  @override
  State<ReportsCenterScreen> createState() => _ReportsCenterScreenState();
}

enum _ReportFilter { all, active, resolved, critical }

extension _FilterX on _ReportFilter {
  String get label => switch (this) {
        _ReportFilter.all => 'All',
        _ReportFilter.active => 'Active',
        _ReportFilter.resolved => 'Resolved',
        _ReportFilter.critical => 'Critical',
      };

  bool matches(ReportEntity r) => switch (this) {
        _ReportFilter.all => true,
        _ReportFilter.active => r.status.isActive,
        _ReportFilter.resolved => r.status.isResolved,
        _ReportFilter.critical => r.severity.isCritical,
      };
}

class _ReportsCenterScreenState extends State<ReportsCenterScreen> {
  _ReportFilter _filter = _ReportFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final user = context.currentUser;
    if (user != null) {
      // Idempotent — a revisit no-ops (the cubit keeps its scope live).
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ReportCubit>().load(user),
      );
    }
  }

  List<ReportEntity> _visible(List<ReportEntity> reports) {
    final q = _query.trim().toLowerCase();
    return reports.where((r) {
      if (!_filter.matches(r)) return false;
      if (q.isEmpty) return true;
      return r.title.toLowerCase().contains(q) ||
          (r.description ?? '').toLowerCase().contains(q) ||
          r.category.label.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isGlobal = context.currentRole?.isAdmin ?? false;
    // Admins RECEIVE reports; they don't file them (the top of the escalation
    // chain has no-one to escalate to). Only managers + employees file.
    final canFile = !isGlobal;
    return AdaptiveScaffold(
      title: 'Reports',
      subtitle: isGlobal
          ? 'Incoming reports & escalations'
          : 'Report an issue or track an escalation',
      floatingActionButton: canFile
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.reportsCreate),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Report'),
            )
          : null,
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          return state.when(
            initial: () => const _Loading(),
            loading: () => const _Loading(),
            error: (message) => _ErrorView(
              message: message,
              onRetry: () {
                final u = context.currentUser;
                if (u != null) context.read<ReportCubit>().load(u, forceRefresh: true);
              },
              // A failed LIST must never block FILING — filing doesn't need the
              // list query (or its index). Only non-admins may file.
              onCreate: (context.currentRole?.isAdmin ?? false)
                  ? null
                  : () => context.push(RouteNames.reportsCreate),
            ),
            loaded: (reports, busy, directory) {
              final branchNames = context.read<ReportCubit>().branchNames;
              final visible = _visible(reports);
              return RefreshIndicator(
                onRefresh: () => context.read<ReportCubit>().refresh(),
                color: AppColors.primary,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding,
                          AppSpacing.md, AppSpacing.pagePadding, AppSpacing.sm),
                      child: AppSearchField(
                        hint: 'Search reports',
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    _FilterBar(
                      selected: _filter,
                      onSelect: (f) => setState(() => _filter = f),
                    ),
                    Expanded(
                      child: visible.isEmpty
                          ? DropEmptyState(
                              title: reports.isEmpty
                                  ? 'No reports yet'
                                  : 'Nothing here',
                              message: reports.isEmpty
                                  ? (canFile
                                      ? 'File a report to raise an issue, request, or escalation.'
                                      : 'No reports have been filed yet.')
                                  : 'No reports match this filter.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.pagePadding,
                                  AppSpacing.sm,
                                  AppSpacing.pagePadding,
                                  AppSpacing.huge),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, i) {
                                final r = visible[i];
                                return ReportCard(
                                  report: r,
                                  branchName: isGlobal
                                      ? branchNames[r.branchId]
                                      : null,
                                  onTap: () => context
                                      .push(RouteNames.reportDetail(r.id)),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});
  final _ReportFilter selected;
  final ValueChanged<_ReportFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        children: [
          for (final f in _ReportFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(f.label),
                selected: selected == f,
                onSelected: (_) => onSelect(f),
                showCheckmark: false,
                backgroundColor: AppColors.darkSurfaceElevated,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected == f
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: selected == f
                      ? AppColors.primary
                      : AppColors.darkBorder,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.primary));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry, this.onCreate});
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.textTertiary, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: onRetry, child: const Text('Retry')),
                if (onCreate != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: onCreate,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New Report'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
