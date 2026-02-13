import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Intro card with CTA to open hospital exploration map/list.
class HospitalShortlistExploreCard extends StatelessWidget {
  final VoidCallback onExploreTap;

  const HospitalShortlistExploreCard({super.key, required this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppEffects.roundedXL,
        boxShadow: AppEffects.shadowXS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.hospitalLocation,
                color: AppColors.infoDark,
                size: AppSpacing.iconMD,
              ),
              const SizedBox(width: AppSpacing.gapSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find the right ward for your birth',
                      style: AppTypography.headlineExtraSmall,
                    ),
                    const SizedBox(height: AppSpacing.gapXS),
                    Text(
                      'Explore nearby maternity wards, compare their facilities and NHS ratings.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapLG),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onExploreTap,
              style: ElevatedButton.styleFrom(
                elevation: AppSpacing.elevationNone,
                backgroundColor: AppColors.infoDark,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.paddingMD,
                ),
              ),
              child: Text(
                'Explore Hospitals',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
