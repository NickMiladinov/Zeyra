import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';

/// Displays all CQC ratings for a maternity unit.
///
/// Shows ratings as label badges (Outstanding, Good, Requires Improvement, etc.)
/// with appropriate color coding. Only displays ratings that are available.
class CqcRatingSection extends StatelessWidget {
  /// The maternity unit containing CQC ratings.
  final MaternityUnit unit;

  const CqcRatingSection({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Official CQC Ratings',
          style: AppTypography.headlineExtraSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.gapMD),

        // Rating rows - only show if rating is available
        _buildRatingsList(),

        // Last inspection date
        if (unit.lastInspectionDate != null &&
            unit.lastInspectionDate!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.gapMD),
          _buildInspectionDate(),
        ],
      ],
    );
  }

  /// Build the list of rating rows.
  Widget _buildRatingsList() {
    final ratings = <Widget>[];

    // Overall rating (always show if available)
    ratings.add(
      _CqcRatingRow(
        label: 'Overall',
        rating: unit.overallRatingEnum,
      ),
    );

    // Maternity-specific rating (show if different from overall)
    if (unit.maternityRating != null &&
        unit.maternityRating != unit.overallRating) {
      ratings.add(const SizedBox(height: AppSpacing.gapSM));
      ratings.add(
        _CqcRatingRow(
          label: 'Maternity',
          rating: unit.maternityRatingEnum,
        ),
      );
    }

    // Safe rating
    if (unit.ratingSafe != null) {
      ratings.add(const SizedBox(height: AppSpacing.gapSM));
      ratings.add(
        _CqcRatingRow(
          label: 'Safe',
          rating: CqcRating.fromString(unit.ratingSafe),
        ),
      );
    }

    // Effective rating
    if (unit.ratingEffective != null) {
      ratings.add(const SizedBox(height: AppSpacing.gapSM));
      ratings.add(
        _CqcRatingRow(
          label: 'Effective',
          rating: CqcRating.fromString(unit.ratingEffective),
        ),
      );
    }

    // Caring rating
    if (unit.ratingCaring != null) {
      ratings.add(const SizedBox(height: AppSpacing.gapSM));
      ratings.add(
        _CqcRatingRow(
          label: 'Caring',
          rating: CqcRating.fromString(unit.ratingCaring),
        ),
      );
    }

    // Responsive rating
    if (unit.ratingResponsive != null) {
      ratings.add(const SizedBox(height: AppSpacing.gapSM));
      ratings.add(
        _CqcRatingRow(
          label: 'Responsive',
          rating: CqcRating.fromString(unit.ratingResponsive),
        ),
      );
    }

    // Well-Led rating
    if (unit.ratingWellLed != null) {
      ratings.add(const SizedBox(height: AppSpacing.gapSM));
      ratings.add(
        _CqcRatingRow(
          label: 'Well-Led',
          rating: CqcRating.fromString(unit.ratingWellLed),
        ),
      );
    }

    return Column(children: ratings);
  }

  /// Build the last inspection date row.
  Widget _buildInspectionDate() {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: AppSpacing.iconXXS,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.gapSM),
        Text(
          'Last inspected: ${unit.lastInspectionDate}',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// A row displaying a CQC rating category and its value as a badge.
class _CqcRatingRow extends StatelessWidget {
  final String label;
  final CqcRating rating;

  const _CqcRatingRow({
    required this.label,
    required this.rating,
  });

  /// Get the color for the rating badge.
  Color _getBadgeColor() {
    switch (rating) {
      case CqcRating.outstanding:
        return AppColors.primary;
      case CqcRating.good:
        return AppColors.primary;
      case CqcRating.requiresImprovement:
        return AppColors.warning;
      case CqcRating.inadequate:
        return AppColors.error;
      case CqcRating.notRated:
        return AppColors.backgroundGrey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingMD,
        vertical: AppSpacing.paddingSM + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingSM,
              vertical: AppSpacing.paddingXS,
            ),
            decoration: BoxDecoration(
              color: _getBadgeColor(),
              borderRadius: BorderRadius.circular(AppEffects.radiusSM),
            ),
            child: Text(
              rating.displayName,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
