import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';

/// Badge showing the CQC rating with an appropriate status color.
class HospitalRatingBadge extends StatelessWidget {
  final CqcRating rating;

  const HospitalRatingBadge({super.key, required this.rating});

  Color _backgroundColor() {
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
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
      ),
      child: Text(
        rating.displayName,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
