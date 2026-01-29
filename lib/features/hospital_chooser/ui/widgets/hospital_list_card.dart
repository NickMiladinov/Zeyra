import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_effects.dart';
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
        horizontal: AppSpacing.paddingLG,
        vertical: AppSpacing.paddingXS,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        side: BorderSide(
          color: AppColors.backgroundGrey200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingLG, 
            vertical: AppSpacing.paddingLG
          ),
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
                      style: AppTypography.headlineExtraSmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapSM),
                  // Favorite button
                  GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      AppIcons.favorite,
                      color: isFavorite ? AppColors.primary : AppColors.iconDefault,
                      size: AppSpacing.iconSM,
                      fill: isFavorite ? 1.0 : 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapSM),

              // Distance and rating badge row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distance
                  if (distanceMiles != null)
                    Text(
                      '${distanceMiles!.toStringAsFixed(1)} miles away',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  // Rating badge
                  _RatingBadge(rating: unit.bestAvailableRating),
                ],
              ),
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
        return AppColors.secondary;
      case CqcRating.good:
        return AppColors.success;
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
        borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
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
