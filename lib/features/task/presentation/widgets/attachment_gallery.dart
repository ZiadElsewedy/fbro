import 'package:flutter/material.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_radius.dart';
import 'package:fbro/core/theme/app_spacing.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/features/task/domain/entities/task_attachment.dart';
import 'package:fbro/features/task/presentation/attachment_format.dart';
import 'package:fbro/features/task/presentation/widgets/attachment_viewer.dart';

/// A premium thumbnail grid of task media — images show a poster, videos a dark
/// tile with a play overlay. Tapping any tile opens the fullscreen viewer
/// (swipeable, zoomable images, inline video). A caption line names the uploader
/// and time. Reused by the timeline event cards and the "Submitted work" view.
class AttachmentGallery extends StatelessWidget {
  const AttachmentGallery({
    super.key,
    required this.attachments,
    this.tileSize = 76,
    this.showCaption = true,
  });

  final List<TaskAttachment> attachments;
  final double tileSize;
  final bool showCaption;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    final first = attachments.first;
    final uploader = first.uploadedByName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < attachments.length; i++)
              _Tile(
                attachment: attachments[i],
                size: tileSize,
                onTap: () => showAttachmentViewer(
                  context,
                  attachments: attachments,
                  initialIndex: i,
                ),
              ),
          ],
        ),
        if (showCaption) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                attachments.any((a) => a.type.isVideo)
                    ? Icons.perm_media_outlined
                    : Icons.photo_library_outlined,
                size: 13,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  _caption(uploader, first.uploadedAt),
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _caption(String? uploader, DateTime at) {
    final summary = attachmentSummary(attachments);
    final who = (uploader != null && uploader.isNotEmpty)
        ? 'Uploaded by $uploader'
        : summary;
    return '$who · ${attachmentTimestamp(at)}';
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.attachment, required this.size, required this.onTap});
  final TaskAttachment attachment;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (attachment.type.isImage)
                _imageThumb()
              else
                _videoThumb(),
              if (attachment.type.isVideo)
                Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(130),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageThumb() {
    return Image.network(
      attachment.url,
      fit: BoxFit.cover,
      cacheWidth: 320,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: AppColors.darkBg,
              alignment: Alignment.center,
              child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
      errorBuilder: (_, _, _) => Container(
        color: AppColors.darkBg,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined,
            size: 18, color: AppColors.textTertiary),
      ),
    );
  }

  // No frame extraction (keeps the dependency footprint small) — a clean dark
  // tile with a film glyph; the play overlay sits on top.
  Widget _videoThumb() {
    return Container(
      color: AppColors.darkSurfaceElevated,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(6),
      child: const Icon(Icons.movie_outlined,
          size: 16, color: AppColors.textTertiary),
    );
  }
}
