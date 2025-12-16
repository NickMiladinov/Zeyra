import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';

/// Result type for image source picker
enum ImageSourceType {
  camera,
  gallery,
  files,
}

/// Result returned from image source picker
class ImageSourceResult {
  final ImageSourceType type;
  final String? filePath;

  const ImageSourceResult({
    required this.type,
    this.filePath,
  });
}

/// Bottom sheet overlay for selecting image source (Camera, Photos, or Files)
class ImageSourcePicker extends StatelessWidget {
  final String title;

  const ImageSourcePicker({
    super.key,
    this.title = 'Add to Chat',
  });

  /// Show the image source picker overlay
  static Future<ImageSourceResult?> show({
    required BuildContext context,
    String title = 'Add to Chat',
  }) async {
    return await AppBottomSheet.show<ImageSourceResult>(
      context: context,
      child: ImageSourcePicker(title: title),
      isDismissible: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.gapXL),
        
        // Options row - calculate width dynamically
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate width for each option:
            // Available width minus gaps between items, divided by 3
            const gapBetweenItems = AppSpacing.gapMD;
            final availableWidth = constraints.maxWidth;
            final totalGapWidth = gapBetweenItems * 2; // 2 gaps for 3 items
            final itemWidth = (availableWidth - totalGapWidth) / 3;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SourceOption(
                  icon: AppIcons.camera,
                  label: 'Camera',
                  width: itemWidth,
                  onTap: () {
                    Navigator.of(context).pop(
                      const ImageSourceResult(type: ImageSourceType.camera),
                    );
                  },
                ),
                const SizedBox(width: gapBetweenItems),
                _SourceOption(
                  icon: AppIcons.image,
                  label: 'Photos',
                  width: itemWidth,
                  onTap: () {
                    Navigator.of(context).pop(
                      const ImageSourceResult(type: ImageSourceType.gallery),
                    );
                  },
                ),
                const SizedBox(width: gapBetweenItems),
                _SourceOption(
                  icon: AppIcons.folder,
                  label: 'Files',
                  width: itemWidth,
                  onTap: () {
                    Navigator.of(context).pop(
                      const ImageSourceResult(type: ImageSourceType.files),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.gapLG),
      ],
    );
  }
}

/// Individual source option button
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final double width;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.paddingLG,
          horizontal: AppSpacing.paddingSM,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey50,
          borderRadius: BorderRadius.circular(AppEffects.radiusLG),
          border: Border.all(
            color: AppColors.backgroundGrey400,
            width: AppSpacing.borderWidthThin,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon,
              size: AppSpacing.iconLG,
              color: AppColors.iconDark,
            ),
            const SizedBox(height: AppSpacing.gapSM),
            
            // Label
            Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

