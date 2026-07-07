import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drop/core/enums/request_priority.dart';
import 'package:drop/core/enums/request_type.dart';
import 'package:drop/core/extensions/context_extensions.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/widgets/adaptive_scaffold.dart';
import 'package:drop/core/widgets/premium_button.dart';
import 'package:drop/features/requests/presentation/cubit/requests_list_cubit.dart';
import 'package:drop/features/requests/presentation/request_format.dart';
import 'package:drop/features/requests/presentation/widgets/dynamic_request_form.dart';
import 'package:drop/features/task/presentation/cubit/task_cubit.dart'
    show PickedAttachment;
import 'package:drop/features/task/presentation/widgets/attachment_picker.dart';

/// The fast, premium request-filing flow — pick a type, fill only the fields
/// that type needs, optionally raise priority / attach a photo, submit. Two clean
/// steps so it takes well under 20 seconds. Reachable from `/requests/create`.
class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key, this.initialType});

  /// A pre-chosen type (from a quick action) skips the picker straight to the form.
  final RequestType? initialType;

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  RequestType? _type;
  Map<String, dynamic> _values = const {};
  bool _valid = false;
  bool _high = false;
  List<PickedAttachment> _attachments = const [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    // Ensure the app-wide cubit knows the user (idempotent) so submit works even
    // when the create screen is the first requests surface visited.
    final user = context.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<RequestsListCubit>().load(user),
      );
    }
  }

  void _onFormChanged(Map<String, dynamic> values, bool valid) {
    setState(() {
      _values = values;
      _valid = valid;
    });
  }

  Future<void> _submit() async {
    final type = _type;
    if (type == null || !_valid || _submitting) return;
    setState(() => _submitting = true);
    final created = await context.read<RequestsListCubit>().submitRequest(
          type: type,
          details: _values,
          priority: _high ? RequestPriority.high : RequestPriority.normal,
          attachments: _attachments,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (created != null) {
      context.showSuccess('Request submitted');
      Navigator.of(context).pop();
    } else {
      context.showError('Could not submit your request. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;
    return AdaptiveScaffold(
      title: type == null ? 'New Request' : type.label,
      subtitle: type == null
          ? 'What do you need approved?'
          : 'Fill in the details',
      leading: type != null && widget.initialType == null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() {
                _type = null;
                _valid = false;
                _values = const {};
              }),
            )
          : null,
      body: type == null ? _TypePicker(onPick: _pick) : _form(type),
    );
  }

  void _pick(RequestType type) => setState(() {
        _type = type;
        _valid = false;
        _values = const {};
        _high = false;
        _attachments = const [];
      });

  Widget _form(RequestType type) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
      children: [
        _TypeSummary(type: type),
        const SizedBox(height: AppSpacing.xl),
        DynamicRequestForm(
          key: ValueKey(type),
          type: type,
          onChanged: _onFormChanged,
        ),
        _PriorityToggle(
          high: _high,
          onChanged: (v) => setState(() => _high = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        AttachmentPickerField(
          attachments: _attachments,
          onChanged: (a) => setState(() => _attachments = a),
          title: 'Attachments',
          hint: 'Add a photo or short video (optional)',
        ),
        const SizedBox(height: AppSpacing.xxl),
        PremiumButton(
          label: _submitting ? 'Submitting…' : 'Submit request',
          icon: Icons.send_rounded,
          style: PremiumButtonStyle.filled,
          onPressed: (_valid && !_submitting) ? _submit : null,
        ),
      ],
    );
  }
}

class _TypeSummary extends StatelessWidget {
  const _TypeSummary({required this.type});
  final RequestType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(RequestFormat.icon(type),
                color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label,
                    style: AppTypography.label.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(type.blurb,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityToggle extends StatelessWidget {
  const _PriorityToggle({required this.high, required this.onChanged});
  final bool high;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = RequestFormat.priorityColor(RequestPriority.high);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
            color: high ? color.withAlpha(90) : AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.priority_high_rounded,
              size: 18, color: high ? color : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mark as high priority',
                    style: AppTypography.label
                        .copyWith(color: AppColors.textPrimary)),
                Text('Floats to the top of the approver’s queue',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Switch(
            value: high,
            onChanged: onChanged,
            activeThumbColor: AppColors.onPrimary,
            activeTrackColor: color,
          ),
        ],
      ),
    );
  }
}

class _TypePicker extends StatelessWidget {
  const _TypePicker({required this.onPick});
  final ValueChanged<RequestType> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(AppSpacing.lg),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.05,
      children: [
        for (final type in RequestType.values)
          _TypeTileCard(type: type, onTap: () => onPick(type)),
      ],
    );
  }
}

class _TypeTileCard extends StatelessWidget {
  const _TypeTileCard({required this.type, required this.onTap});
  final RequestType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.darkBorder),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(RequestFormat.icon(type),
                    color: AppColors.textPrimary, size: 20),
              ),
              const Spacer(),
              Text(type.label,
                  style: AppTypography.label.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(type.blurb,
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.textTertiary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
