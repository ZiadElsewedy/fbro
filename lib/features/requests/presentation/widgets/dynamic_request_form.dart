import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drop/core/theme/app_colors.dart';
import 'package:drop/core/theme/app_radius.dart';
import 'package:drop/core/theme/app_spacing.dart';
import 'package:drop/core/theme/app_typography.dart';
import 'package:drop/core/enums/request_type.dart';
import 'package:drop/features/requests/domain/request_field_spec.dart';
import 'package:drop/features/requests/domain/request_schema.dart';
import 'package:drop/features/requests/presentation/request_format.dart';

/// Renders **only** the fields relevant to [type] (from `RequestSchema`), typed
/// per [RequestFieldKind], and reports the collected `details` map + validity via
/// [onChanged]. Give it a `Key(type)` from the parent so switching type rebuilds
/// a fresh form. Never a giant generic form — the whole point of the schema.
class DynamicRequestForm extends StatefulWidget {
  const DynamicRequestForm({
    super.key,
    required this.type,
    required this.onChanged,
  });

  final RequestType type;

  /// Called on every edit with the current values and whether all `required`
  /// fields are satisfied.
  final void Function(Map<String, dynamic> values, bool isValid) onChanged;

  @override
  State<DynamicRequestForm> createState() => _DynamicRequestFormState();
}

class _DynamicRequestFormState extends State<DynamicRequestForm> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, DateTime> _dateTimes = {};

  List<RequestFieldSpec> get _fields => RequestSchema.fieldsFor(widget.type);

  @override
  void initState() {
    super.initState();
    for (final spec in _fields) {
      if (spec.kind == RequestFieldKind.time ||
          spec.kind == RequestFieldKind.date) {
        continue;
      }
      _controllers[spec.key] = TextEditingController()
        ..addListener(_emit);
    }
    // Report initial (all-empty) validity after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  ({Map<String, dynamic> values, bool valid}) _collect() {
    final values = <String, dynamic>{};
    var valid = true;
    for (final spec in _fields) {
      dynamic value;
      switch (spec.kind) {
        case RequestFieldKind.time:
        case RequestFieldKind.date:
          value = _dateTimes[spec.key];
        case RequestFieldKind.number:
          final text = _controllers[spec.key]?.text.trim() ?? '';
          value = text.isEmpty ? null : num.tryParse(text);
        case RequestFieldKind.text:
        case RequestFieldKind.multiline:
          final text = _controllers[spec.key]?.text.trim() ?? '';
          value = text.isEmpty ? null : text;
      }
      if (value != null) values[spec.key] = value;
      if (spec.required && value == null) valid = false;
    }
    return (values: values, valid: valid);
  }

  void _emit() {
    final r = _collect();
    widget.onChanged(r.values, r.valid);
  }

  Future<void> _pickTime(RequestFieldSpec spec) async {
    final existing = _dateTimes[spec.key];
    final picked = await showTimePicker(
      context: context,
      initialTime: existing != null
          ? TimeOfDay(hour: existing.hour, minute: existing.minute)
          : TimeOfDay.now(),
    );
    if (picked == null) return;
    final now = DateTime.now();
    setState(() {
      _dateTimes[spec.key] =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    });
    _emit();
  }

  Future<void> _pickDate(RequestFieldSpec spec) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTimes[spec.key] ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _dateTimes[spec.key] = picked);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final spec in _fields) ...[
          _FieldLabel(spec: spec),
          const SizedBox(height: AppSpacing.sm),
          _fieldFor(spec),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }

  Widget _fieldFor(RequestFieldSpec spec) {
    switch (spec.kind) {
      case RequestFieldKind.time:
        return _PickerField(
          icon: Icons.schedule_rounded,
          value: _dateTimes[spec.key] == null
              ? null
              : RequestFormat.timeOfDay(_dateTimes[spec.key]!),
          placeholder: spec.hint ?? 'Select a time',
          onTap: () => _pickTime(spec),
        );
      case RequestFieldKind.date:
        return _PickerField(
          icon: Icons.calendar_today_rounded,
          value: _dateTimes[spec.key] == null
              ? null
              : RequestFormat.dateLabel(_dateTimes[spec.key]!),
          placeholder: spec.hint ?? 'Select a date',
          onTap: () => _pickDate(spec),
        );
      case RequestFieldKind.number:
        return _TextField(
          controller: _controllers[spec.key]!,
          hint: spec.hint ?? spec.label,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
        );
      case RequestFieldKind.multiline:
        return _TextField(
          controller: _controllers[spec.key]!,
          hint: spec.hint ?? spec.label,
          maxLines: 4,
          minLines: 3,
        );
      case RequestFieldKind.text:
        return _TextField(
          controller: _controllers[spec.key]!,
          hint: spec.hint ?? spec.label,
          textCapitalization: TextCapitalization.sentences,
        );
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.spec});
  final RequestFieldSpec spec;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(spec.label,
            style: AppTypography.label
                .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        if (!spec.required) ...[
          const SizedBox(width: AppSpacing.sm),
          Text('Optional',
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textTertiary)),
        ],
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AppTypography.body.copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.primary.withAlpha(120)),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final IconData icon;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.darkBorder),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  hasValue ? value! : placeholder,
                  style: AppTypography.body.copyWith(
                    color: hasValue
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
