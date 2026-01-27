import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';

/// Card widget for displaying a hospital in the list view.
class HospitalListCard extends StatelessWidget {
  /// The maternity unit to display.
  final MaternityUnit unit;

  /// Distance from user in miles.
  final double? distanceMiles;

  /// Whether this hospital is favorited.
  final bool isFavorite;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the favorite button is tapped.
  final VoidCallback? onFavoriteTap;

  const HospitalListCard({
    super.key,
    required this.unit,
    this.distanceMiles,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingMD,
        vertical: AppSpacing.paddingXS,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.backgroundGrey200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital name and favorite button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      unit.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapSM),
                  // Favorite button
                  GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.primary : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapXS),

              // Distance
              if (distanceMiles != null)
                Text(
                  '${distanceMiles!.toStringAsFixed(1)} miles away',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: AppSpacing.gapSM),

              // Rating badge
              _RatingBadge(rating: unit.bestAvailableRating),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge showing the CQC rating with appropriate color.
class _RatingBadge extends StatelessWidget {
  final CqcRating rating;

  const _RatingBadge({required this.rating});

  Color _getBackgroundColor() {
    switch (rating) {
      case CqcRating.outstanding:
        return AppColors.primary;
      case CqcRating.good:
        return AppColors.primary.withValues(alpha: 0.8);
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
        horizontal: AppSpacing.paddingSM,
        vertical: AppSpacing.paddingXS,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        rating.displayName,
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
