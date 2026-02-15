import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/repositories/hospital_shortlist_repository.dart';
import 'hospital_rating_badge.dart';

/// Final choice section for the hospital shortlist workspace.
class HospitalShortlistFinalChoiceSection extends StatelessWidget {
  final ShortlistWithUnit? selectedHospital;
  final VoidCallback? onClearSelectionTap;
  final void Function(ShortlistWithUnit shortlistWithUnit)? onFinalChoiceTap;
  final bool compact;
  final bool showClearAction;
  final String title;

  const HospitalShortlistFinalChoiceSection({
    super.key,
    required this.selectedHospital,
    required this.onClearSelectionTap,
    required this.onFinalChoiceTap,
    this.compact = false,
    this.showClearAction = true,
    this.title = 'Your Final Choice',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: compact
              ? AppTypography.headlineExtraSmall
              : AppTypography.headlineSmall,
        ),
        SizedBox(height: compact ? AppSpacing.gapSM : AppSpacing.gapMD),
        if (selectedHospital == null)
          _EmptyFinalChoiceCard(compact: compact)
        else
          HospitalSelectedFinalChoiceCard(
            shortlistWithUnit: selectedHospital!,
            onTap: onFinalChoiceTap != null
                ? () => onFinalChoiceTap!(selectedHospital!)
                : null,
            onClearSelectionTap: onClearSelectionTap,
            compact: compact,
            showClearAction: showClearAction,
          ),
      ],
    );
  }
}

class _EmptyFinalChoiceCard extends StatelessWidget {
  const _EmptyFinalChoiceCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.paddingMD : AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppEffects.roundedXL,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.hospital,
            color: AppColors.infoDark,
            size: compact ? AppSpacing.iconLG : AppSpacing.buttonHeightLG,
          ),
          SizedBox(height: compact ? AppSpacing.gapXS : AppSpacing.gapSM),
          Text(
            'Make your final choice',
            style: compact
                ? AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)
                : AppTypography.headlineExtraSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Card that shows the currently selected final hospital.
class HospitalSelectedFinalChoiceCard extends StatelessWidget {
  final ShortlistWithUnit shortlistWithUnit;
  final VoidCallback? onTap;
  final VoidCallback? onClearSelectionTap;
  final bool compact;
  final bool showClearAction;

  const HospitalSelectedFinalChoiceCard({
    super.key,
    required this.shortlistWithUnit,
    required this.onTap,
    required this.onClearSelectionTap,
    this.compact = false,
    this.showClearAction = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppEffects.roundedXL,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? AppSpacing.paddingMD : AppSpacing.paddingLG),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    shortlistWithUnit.unit.name,
                    style: compact
                        ? AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                        : AppTypography.headlineExtraSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.gapSM),
                HospitalRatingBadge(
                  rating: shortlistWithUnit.unit.bestAvailableRating,
                ),
              ],
            ),
            SizedBox(height: compact ? AppSpacing.gapXS : AppSpacing.gapSM),
            Text(
              shortlistWithUnit.unit.formattedAddress.isEmpty
                  ? 'Address unavailable'
                  : shortlistWithUnit.unit.formattedAddress,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (showClearAction) ...[
              SizedBox(height: compact ? AppSpacing.gapXS : AppSpacing.gapSM),
              TextButton(
                onPressed: onClearSelectionTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  alignment: Alignment.centerLeft,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.delete,
                      size: AppSpacing.iconXS,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.gapXS),
                    Text(
                      'Clear final choice',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
