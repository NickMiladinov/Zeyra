import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';

/// Displays PLACE (Patient-Led Assessments of the Care Environment) ratings.
///
/// Shows percentage scores with visual progress bars for cleanliness,
/// food, privacy/dignity/wellbeing, and condition/appearance.
/// Only renders if the unit has PLACE data available.
class PlaceRatingSection extends StatelessWidget {
  /// The maternity unit containing PLACE ratings.
  final MaternityUnit unit;

  const PlaceRatingSection({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    // Don't render if no PLACE data available
    if (!unit.hasPlaceData) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Patient Environment Ratings (PLACE)',
          style: AppTypography.headlineExtraSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.gapSM),

        // Description
        Text(
          'Based on annual NHS patient-led assessments',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.gapMD),

        // Rating rows
        if (unit.placeCleanliness != null)
          _PlaceRatingRow(
            label: 'Cleanliness',
            percentage: unit.placeCleanliness!,
          ),
        if (unit.placeFood != null) ...[
          const SizedBox(height: AppSpacing.gapSM),
          _PlaceRatingRow(
            label: 'Food',
            percentage: unit.placeFood!,
          ),
        ],
        if (unit.placePrivacyDignityWellbeing != null) ...[
          const SizedBox(height: AppSpacing.gapSM),
          _PlaceRatingRow(
            label: 'Privacy, Dignity & Wellbeing',
            percentage: unit.placePrivacyDignityWellbeing!,
          ),
        ],
        if (unit.placeConditionAppearance != null) ...[
          const SizedBox(height: AppSpacing.gapSM),
          _PlaceRatingRow(
            label: 'Condition & Appearance',
            percentage: unit.placeConditionAppearance!,
          ),
        ],
      ],
    );
  }
}

/// A row displaying a PLACE rating with label, percentage, and progress bar.
class _PlaceRatingRow extends StatelessWidget {
  final String label;
  final double percentage;

  const _PlaceRatingRow({
    required this.label,
    required this.percentage,
  });

  /// Get the color for the progress bar based on percentage.
  Color _getProgressColor() {
    if (percentage >= 90) {
      return AppColors.primary;
    } else if (percentage >= 80) {
      return AppColors.success;
    } else if (percentage >= 70) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and percentage row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getProgressColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapSM),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppEffects.radiusSM),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.backgroundGrey100,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              minHeight: AppSpacing.gapSM,
            ),
          ),
        ],
      ),
    );
  }
}
