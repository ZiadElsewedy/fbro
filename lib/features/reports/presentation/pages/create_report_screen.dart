import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:drop/core/enums/report_category.dart';
import 'package:drop/core/enums/report_privacy.dart';
import 'package:drop/core/enums/report_recipient.dart';
import 'package:drop/core/enums/report_severity.dart';
import 'package:drop/core/extensions/context_extensions.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/widgets/adaptive_scaffold.dart';
import 'package:drop/features/auth/presentation/widgets/app_button.dart';
import 'package:drop/features/auth/presentation/widgets/app_text_field.dart';
import 'package:drop/features/reports/presentation/cubit/report_cubit.dart';
import 'package:drop/features/reports/presentation/report_format.dart';
import 'package:drop/features/task/presentation/cubit/task_cubit.dart' show PickedAttachment;
import 'package:drop/features/task/presentation/widgets/attachment_picker.dart';

/// The ≤30-second report-filing flow: Category → Title → Description → Severity →
/// Recipient (smart-routed default, editable) → Privacy → Attachments → Submit.
/// Strictly monochrome; minimal friction for non-technical retail staff.
class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController();

  ReportCategory _category = ReportCategory.operations;
  ReportSeverity _severity = ReportSeverity.medium;
  ReportRecipient _recipient = ReportCategory.operations.defaultRecipient;
  ReportPrivacy _privacy = ReportPrivacy.normal;
  List<PickedAttachment> _attachments = const [];
  bool _recipientTouched = false;
  bool _recipientLocked = false; // manager: escalation always goes to admin
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.currentUser;
    final role = user?.role;
    // A manager who files a report is escalating UP — it always goes to the
    // admin (about staff below them, or a branch-level issue). Locked, not
    // chosen. Employees keep the full manager / admin / both choice.
    if (role != null && role.isManager) {
      _recipient = ReportRecipient.admin;
      _recipientLocked = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Admins receive reports; they don't file them — bounce them back.
      if (role != null && role.isAdmin) {
        context.showError("Admins receive reports — they don't file them.");
        context.pop();
        return;
      }
      // Ensure the cubit knows the signed-in user (its `submitReport` reads it),
      // even on a direct deep-link to /reports/create.
      if (user != null) context.read<ReportCubit>().load(user);
    });
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    super.dispose();
  }

  void _onCategory(ReportCategory c) {
    setState(() {
      _category = c;
      // Smart routing: adopt the category's default recipient until the user
      // manually overrides it. A manager's recipient is locked to admin.
      if (!_recipientTouched && !_recipientLocked) {
        _recipient = c.defaultRecipient;
      }
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final title = _titleC.text.trim();
    if (title.isEmpty) {
      context.showError('Add a short title so the report is easy to scan.');
      return;
    }
    setState(() => _submitting = true);
    final ok = await context.read<ReportCubit>().submitReport(
          title: title,
          description: _descC.text.trim().isEmpty ? null : _descC.text.trim(),
          category: _category,
          recipient: _recipient,
          privacy: _privacy,
          severity: _severity,
          attachments: _attachments,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      context.showSuccess('Report submitted');
      context.pop();
    } else {
      context.showError('Could not submit the report. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'New Report',
      subtitle: 'Raise an issue, request, or escalation',
      contentMaxWidth: 620,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.md,
            AppSpacing.pagePadding, AppSpacing.huge),
        children: [
          const _SectionLabel('Category'),
          _CategoryPicker(selected: _category, onSelect: _onCategory),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: _titleC,
            label: 'Title',
            hint: 'A short summary',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _descC,
            label: 'Description',
            hint: 'What happened? Add any detail that helps.',
            maxLines: 5,
            minLines: 3,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('Severity'),
          _EnumChips<ReportSeverity>(
            values: ReportSeverity.values,
            selected: _severity,
            labelOf: (s) => s.label,
            colorOf: reportSeverityColor,
            onSelect: (s) => setState(() => _severity = s),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('Send to'),
          if (_recipientLocked)
            const _EscalationNote()
          else
            _EnumChips<ReportRecipient>(
              values: ReportRecipient.values,
              selected: _recipient,
              labelOf: (r) => r.label,
              onSelect: (r) => setState(() {
                _recipient = r;
                _recipientTouched = true;
              }),
            ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('Privacy'),
          _EnumChips<ReportPrivacy>(
            values: ReportPrivacy.values,
            selected: _privacy,
            labelOf: (p) => p.label,
            onSelect: (p) => setState(() => _privacy = p),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(_privacy.hint, style: AppTypography.caption),
          ),
          const SizedBox(height: AppSpacing.xl),
          AttachmentPickerField(
            attachments: _attachments,
            onChanged: (v) => setState(() => _attachments = v),
            title: 'Attachments',
            hint: 'Add photos or a short video (optional)',
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Submit Report',
            onPressed: _submitting ? null : _submit,
            isLoading: _submitting,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(text,
            style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
      );
}

/// Shown instead of the recipient chips when a **manager** files a report — the
/// recipient is fixed (a manager escalates UP to the admin).
class _EscalationNote extends StatelessWidget {
  const _EscalationNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_upward_rounded,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Escalated to the Admin',
              style: AppTypography.label
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.selected, required this.onSelect});
  final ReportCategory selected;
  final ValueChanged<ReportCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final c in ReportCategory.values)
          _CategoryChip(
            category: c,
            selected: c == selected,
            onTap: () => onSelect(c),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });
  final ReportCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.darkSurfaceElevated,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.fullAll,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.darkBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(reportCategoryIcon(category),
                  size: 15,
                  color:
                      selected ? AppColors.onPrimary : AppColors.textSecondary),
              const SizedBox(width: 7),
              Text(
                category.label,
                style: AppTypography.label.copyWith(
                  color:
                      selected ? AppColors.onPrimary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A generic single-select chip row for a small enum (severity / recipient /
/// privacy). [colorOf] tints the selected fill semantically (used for severity).
class _EnumChips<T> extends StatelessWidget {
  const _EnumChips({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
    this.colorOf,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;
  final Color Function(T)? colorOf;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final v in values)
          _pill(context, v),
      ],
    );
  }

  Widget _pill(BuildContext context, T v) {
    final isSel = v == selected;
    final accent = colorOf?.call(v) ?? AppColors.primary;
    final fg = isSel
        ? (colorOf != null ? accent : AppColors.onPrimary)
        : AppColors.textSecondary;
    return Material(
      color: isSel
          ? (colorOf != null ? accent.withAlpha(30) : AppColors.primary)
          : AppColors.darkSurfaceElevated,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        onTap: () => onSelect(v),
        borderRadius: AppRadius.fullAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: isSel
                  ? (colorOf != null ? accent.withAlpha(140) : AppColors.primary)
                  : AppColors.darkBorder,
            ),
          ),
          child: Text(
            labelOf(v),
            style: AppTypography.label
                .copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
