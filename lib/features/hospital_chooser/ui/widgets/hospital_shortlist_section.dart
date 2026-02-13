import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/repositories/hospital_shortlist_repository.dart';
import 'hospital_rating_badge.dart';

/// Section showing all shortlisted hospitals.
class HospitalShortlistSection extends StatelessWidget {
  static const double _shortlistCardHeight = 170;

  final List<ShortlistWithUnit> shortlistedUnits;
  final String? selectingShortlistId;
  final String? selectedShortlistId;
  final void Function(ShortlistWithUnit shortlistWithUnit) onSetFinalChoiceTap;
  final void Function(ShortlistWithUnit shortlistWithUnit) onHospitalTap;
  final VoidCallback onExploreHospitalsTap;

  const HospitalShortlistSection({
    super.key,
    required this.shortlistedUnits,
    required this.selectingShortlistId,
    required this.selectedShortlistId,
    required this.onSetFinalChoiceTap,
    required this.onHospitalTap,
    required this.onExploreHospitalsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Shortlist', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.gapMD),
        if (shortlistedUnits.isEmpty)
          _EmptyShortlistCard(onExploreHospitalsTap: onExploreHospitalsTap)
        else
          SizedBox(
            height: _shortlistCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shortlistedUnits.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.gapMD),
              itemBuilder: (context, index) {
                final shortlistWithUnit = shortlistedUnits[index];
                final isSelected =
                    selectedShortlistId == shortlistWithUnit.shortlist.id;
                final isSelecting =
                    selectingShortlistId == shortlistWithUnit.shortlist.id;

                return HospitalShortlistCard(
                  shortlistWithUnit: shortlistWithUnit,
                  isSelected: isSelected,
                  isSelecting: isSelecting,
                  onTap: () => onHospitalTap(shortlistWithUnit),
                  onSetFinalChoiceTap: isSelected
                      ? null
                      : () => onSetFinalChoiceTap(shortlistWithUnit),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyShortlistCard extends StatelessWidget {
  final VoidCallback onExploreHospitalsTap;

  const _EmptyShortlistCard({required this.onExploreHospitalsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppEffects.roundedXL,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No hospitals shortlisted yet',
            style: AppTypography.headlineExtraSmall,
          ),
        ],
      ),
    );
  }
}

/// Individual shortlist card with final-choice action.
class HospitalShortlistCard extends StatelessWidget {
  final ShortlistWithUnit shortlistWithUnit;
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback? onTap;
  final VoidCallback? onSetFinalChoiceTap;

  const HospitalShortlistCard({
    super.key,
    required this.shortlistWithUnit,
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
    required this.onSetFinalChoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final unit = shortlistWithUnit.unit;

    return InkWell(
      onTap: onTap,
      borderRadius: AppEffects.roundedXL,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppEffects.roundedXL,
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: AppSpacing.borderWidthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    unit.name,
                    style: AppTypography.headlineExtraSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.gapSM),
                HospitalRatingBadge(rating: unit.bestAvailableRating),
              ],
            ),
            const SizedBox(height: AppSpacing.gapXS),
            Text(
              unit.townCity ?? unit.postcode ?? 'Location unavailable',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSelecting ? null : onSetFinalChoiceTap,
                style: ElevatedButton.styleFrom(
                  elevation: AppSpacing.elevationNone,
                  backgroundColor: isSelected
                      ? AppColors.secondary
                      : AppColors.secondary.withValues(alpha: 0.9),
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppEffects.radiusCircle,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.paddingSM,
                  ),
                ),
                child: isSelecting
                    ? SizedBox(
                        height: AppSpacing.iconXXS,
                        width: AppSpacing.iconXXS,
                        child: const CircularProgressIndicator(
                          strokeWidth: AppSpacing.borderWidthThin,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        isSelected ? 'Final Choice' : 'Set as Final Choice',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
