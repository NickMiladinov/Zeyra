import 'dart:io';

import 'package:flutter/material.dart';

import '../../logic/bump_photo_state.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';

/// Widget displaying a single week card in the bump diary.
///
/// Shows either the bump photo or a placeholder for empty weeks.
/// The latest week with no photo gets a special highlighted style.
class BumpWeekCard extends StatelessWidget {
  final WeekSlot slot;
  final bool isLatest;
  final VoidCallback onTap;

  const BumpWeekCard({
    super.key,
    required this.slot,
    required this.isLatest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Special style for latest week with no photo
    final bool showHighlightedStyle = isLatest && !slot.hasPhoto;
    
    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.gapXL,
        right: AppSpacing.gapXL,
        bottom: AppSpacing.gapXL,
      ),
      decoration: BoxDecoration(
        color: showHighlightedStyle ? AppColors.primaryLight : AppColors.surface,
        borderRadius: AppEffects.roundedXL,
        boxShadow: AppEffects.shadowSM,
        border: showHighlightedStyle
            ? Border.all(
                color: AppColors.borderPrimary,
                width: AppSpacing.borderWidthThin,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppEffects.roundedXL,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: showHighlightedStyle
                ? _buildHighlightedLatestWeek()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo or placeholder on the left
                      _buildPhotoThumbnail(),
                      const SizedBox(width: AppSpacing.gapLG),
                      // Content on the right
                      Expanded(
                        child: _buildContent(context),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Special layout for latest week with no photo (highlighted style)
  Widget _buildHighlightedLatestWeek() {
    return Row(
      children: [
        // Large + icon on left
        Container(
          width: AppSpacing.buttonHeightLG,
          height: AppSpacing.buttonHeightLG,
          decoration: BoxDecoration(
            color: AppColors.primaryOverlay,
            borderRadius: AppEffects.roundedMD,
          ),
          child: Icon(
            AppIcons.add,
            color: AppColors.primary,
            size: AppSpacing.iconSM,
          ),
        ),
        const SizedBox(width: AppSpacing.gapLG),
        // Text content on right
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Week ${slot.weekNumber}: How are you feeling?',
                style: AppTypography.headlineExtraSmall,
              ),
              const SizedBox(height: AppSpacing.gapXS),
              Text(
                'Tap to add a photo and memory.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail() {
    if (slot.hasPhoto && slot.photo!.filePath != null) {
      final file = File(slot.photo!.filePath!);
      return ClipRRect(
        borderRadius: AppEffects.roundedMD,
        child: SizedBox(
          width: AppSpacing.buttonHeightXXL,
          height: AppSpacing.buttonHeightXXL,
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildEmptyThumbnail();
            },
          ),
        ),
      );
    } else {
      return _buildEmptyThumbnail();
    }
  }

  Widget _buildEmptyThumbnail() {
    return Container(
      width: AppSpacing.buttonHeightLG,
      height: AppSpacing.buttonHeightLG,
      decoration: BoxDecoration(
        color: AppColors.primaryOverlay,
        borderRadius: AppEffects.roundedMD,
      ),
      child: Icon(
        AppIcons.camera,
        color: AppColors.primary,
        size: AppSpacing.iconSM,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week title
        _buildTitle(context),
        const SizedBox(height: AppSpacing.gapXS),
        // Subtitle or note
        _buildSubtitle(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    // Always show week number only for filled weeks
    return Text(
      'Week ${slot.weekNumber}',
      style: AppTypography.headlineExtraSmall,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    if (slot.hasPhoto && slot.photo!.note != null && slot.photo!.note!.isNotEmpty) {
      // Show note if available
      return Text(
        slot.photo!.note!,
        style: AppTypography.bodyMedium.copyWith(
          height: 1.4,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      );
    } else if (slot.hasPhoto) {
      // Show prompt to add note if photo exists but no note
      return Text(
        'How did you feel this week?',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    } else {
      // Show prompt to add photo
      return Text(
        'Tap to add a photo and memory.',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
  }
}
