import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/repositories/hospital_shortlist_repository.dart';
import 'hospital_list_card.dart';

/// Section showing all shortlisted hospitals.
class HospitalShortlistSection extends StatelessWidget {
  final List<ShortlistWithUnit> shortlistedUnits;
  final void Function(ShortlistWithUnit shortlistWithUnit) onHospitalTap;
  final void Function(ShortlistWithUnit shortlistWithUnit) onShortlistTap;
  final VoidCallback onExploreHospitalsTap;

  const HospitalShortlistSection({
    super.key,
    required this.shortlistedUnits,
    required this.onHospitalTap,
    required this.onShortlistTap,
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shortlistedUnits.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gapSM),
            itemBuilder: (context, index) {
              final shortlistWithUnit = shortlistedUnits[index];
              return HospitalListCard(
                unit: shortlistWithUnit.unit,
                onTap: () => onHospitalTap(shortlistWithUnit),
                isFavorite: true,
                onFavoriteTap: () => onShortlistTap(shortlistWithUnit),
                showAddress: true,
                // Keep shortlist cards flush with workspace padding.
                margin: EdgeInsets.zero,
              );
            },
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
