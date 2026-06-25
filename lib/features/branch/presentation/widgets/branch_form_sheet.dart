import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_radius.dart';
import 'package:fbro/core/theme/app_spacing.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/branch_avatar.dart';
import 'package:fbro/core/widgets/premium_button.dart';
import 'package:fbro/features/auth/presentation/widgets/app_button.dart';
import 'package:fbro/features/auth/presentation/widgets/app_text_field.dart';
import 'package:fbro/features/branch/domain/entities/branch_entity.dart';
import 'package:fbro/features/branch/presentation/cubit/branch_cubit.dart';

/// Create or edit a branch (admin). Editing also offers **branch media** —
/// logo + cover upload to Storage (§8).
Future<void> showBranchFormSheet({
  required BuildContext context,
  required BranchCubit cubit,
  BranchEntity? existing,
}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BranchFormSheet(cubit: cubit, existing: existing),
    );

class _BranchFormSheet extends StatefulWidget {
  const _BranchFormSheet({required this.cubit, required this.existing});
  final BranchCubit cubit;
  final BranchEntity? existing;

  @override
  State<_BranchFormSheet> createState() => _BranchFormSheetState();
}

class _BranchFormSheetState extends State<_BranchFormSheet> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _location =
      TextEditingController(text: widget.existing?.location ?? '');
  String? _error;

  // Live media preview (seeded from the branch; updated after each upload).
  late String? _logoUrl = widget.existing?.logoUrl;
  late String? _coverUrl = widget.existing?.coverUrl;
  bool _busyLogo = false;
  bool _busyCover = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Branch name is required.');
      return;
    }
    final location = _location.text.trim().isEmpty ? null : _location.text.trim();
    final existing = widget.existing;
    if (existing == null) {
      widget.cubit.createBranch(name: name, location: location);
    } else {
      widget.cubit.editBranch(existing.copyWith(name: name, location: location));
    }
    Navigator.of(context).pop();
  }

  Future<void> _pick({required bool isLogo}) async {
    final existing = widget.existing;
    if (existing == null) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: isLogo ? 600 : 1600,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;
    setState(() => isLogo ? _busyLogo = true : _busyCover = true);
    final url = await widget.cubit
        .uploadBranchImage(existing.id, File(picked.path), isLogo: isLogo);
    if (!mounted) return;
    setState(() {
      if (isLogo) {
        _busyLogo = false;
        if (url != null) _logoUrl = url;
      } else {
        _busyCover = false;
        if (url != null) _coverUrl = url;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(existing == null ? 'New Branch' : 'Edit Branch',
                style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _name,
              label: 'Branch name',
              hint: 'e.g. Cairo Festival City',
              prefixIcon: Icons.store_mall_directory_outlined,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _location,
              label: 'Location (optional)',
              prefixIcon: Icons.place_outlined,
            ),

            // ── Branch media (editing only — needs an existing branch id) ──
            const SizedBox(height: AppSpacing.xl),
            Text('BRANCH MEDIA',
                style: AppTypography.caption.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                )),
            const SizedBox(height: AppSpacing.md),
            if (existing == null)
              Text('Save the branch first, then reopen it to add a logo & cover.',
                  style: AppTypography.caption)
            else ...[
              _LogoRow(
                logoUrl: _logoUrl,
                name: _name.text,
                busy: _busyLogo,
                onPick: () => _pick(isLogo: true),
              ),
              const SizedBox(height: AppSpacing.md),
              _CoverField(
                coverUrl: _coverUrl,
                busy: _busyCover,
                onPick: () => _pick(isLogo: false),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!,
                  style: AppTypography.caption.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: existing == null ? 'Create Branch' : 'Save Changes',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoRow extends StatelessWidget {
  const _LogoRow({
    required this.logoUrl,
    required this.name,
    required this.busy,
    required this.onPick,
  });

  final String? logoUrl;
  final String name;
  final bool busy;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BranchAvatar(logoUrl: logoUrl, name: name, size: 56),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Logo', style: AppTypography.label),
              const SizedBox(height: 2),
              Text('Square mark shown across the app',
                  style: AppTypography.caption),
            ],
          ),
        ),
        busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2))
            : PremiumButton(
                label: (logoUrl ?? '').isEmpty ? 'Add' : 'Change',
                icon: Icons.image_outlined,
                onPressed: onPick,
              ),
      ],
    );
  }
}

class _CoverField extends StatelessWidget {
  const _CoverField({
    required this.coverUrl,
    required this.busy,
    required this.onPick,
  });

  final String? coverUrl;
  final bool busy;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final hasCover = (coverUrl ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppRadius.cardAll,
          child: Container(
            height: 120,
            width: double.infinity,
            color: AppColors.darkSurfaceElevated,
            child: busy
                ? const Center(
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.2)))
                : hasCover
                    ? Image.network(coverUrl!,
                        fit: BoxFit.cover,
                        cacheWidth: 1200,
                        errorBuilder: (_, _, _) => _placeholder())
                    : _placeholder(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        PremiumButton(
          label: hasCover ? 'Change cover' : 'Add cover',
          icon: Icons.photo_size_select_actual_outlined,
          onPressed: busy ? null : onPick,
        ),
      ],
    );
  }

  Widget _placeholder() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.textTertiary, size: 24),
            const SizedBox(height: 4),
            Text('No cover yet', style: AppTypography.caption),
          ],
        ),
      );
}
