import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

/// Displays a grid of photo thumbnails with an add button.
class PhotoGrid extends StatelessWidget {
  final List<String> photoPaths;
  final ValueChanged<String> onPhotoAdded;
  final ValueChanged<int>? onPhotoRemoved;
  final int maxPhotos;

  const PhotoGrid({
    super.key,
    required this.photoPaths,
    required this.onPhotoAdded,
    this.onPhotoRemoved,
    this.maxPhotos = 5,
  });

  Future<void> _pickPhoto(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add photo',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Tappable(
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          color: AppColors.textSecondary(ctx)),
                      const SizedBox(width: 12),
                      Text('Take photo',
                          style: Theme.of(ctx).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              Container(height: 1, color: AppColors.dividerColor(ctx)),
              Tappable(
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.photo_library_outlined,
                          color: AppColors.textSecondary(ctx)),
                      const SizedBox(width: 12),
                      Text('Choose from gallery',
                          style: Theme.of(ctx).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      onPhotoAdded(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = photoPaths.length < maxPhotos;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Existing photos
        ...photoPaths.asMap().entries.map((entry) {
          final index = entry.key;
          final path = entry.value;
          return _PhotoThumb(
            path: path,
            onRemove: onPhotoRemoved != null
                ? () => onPhotoRemoved!(index)
                : null,
          );
        }),

        // Add button
        if (canAdd)
          Tappable(
            onTap: () => _pickPhoto(context),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.borderColor(context),
                  width: 1.5,
                ),
                color: AppColors.surfaceColor(context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      size: 20, color: AppColors.textSecondary(context)),
                  const SizedBox(height: 4),
                  Text(
                    'Add',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String path;
  final VoidCallback? onRemove;

  const _PhotoThumb({required this.path, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(path),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.borderColor(context),
              ),
              child: Icon(Icons.broken_image_outlined,
                  size: 20, color: AppColors.textTertiary(context)),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 2,
            right: 2,
            child: Tappable(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
