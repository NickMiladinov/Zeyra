import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/hospital_filter_criteria.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';

/// Bottom sheet for selecting hospital sort order.
class HospitalSortBottomSheet extends StatelessWidget {
  /// Current sort option.
  final HospitalSortBy currentSort;

  /// Callback when sort is selected.
  final void Function(HospitalSortBy sort) onSortSelected;

  const HospitalSortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Sort by',
      showCloseButton: true,
      applyContentPadding: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.paddingXL,
          0,
          AppSpacing.paddingXL,
          AppSpacing.paddingXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sort options
            _SortOption(
              title: 'Distance: Nearest to Farthest',
              isSelected: currentSort == HospitalSortBy.distance,
              onTap: () {
                onSortSelected(HospitalSortBy.distance);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            _SortOption(
              title: 'CQC Rating: Highest to Lowest',
              isSelected: currentSort == HospitalSortBy.rating,
              onTap: () {
                onSortSelected(HospitalSortBy.rating);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            _SortOption(
              title: 'Hospital Name: A-Z',
              isSelected: currentSort == HospitalSortBy.name,
              onTap: () {
                onSortSelected(HospitalSortBy.name);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A single sort option row.
class _SortOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMD),
        child: Row(
          children: [
            // Radio-style indicator
            Container(
              width: AppSpacing.iconSM,
              height: AppSpacing.iconSM,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.backgroundGrey400,
                  width: AppSpacing.borderWidthMedium,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.gapMD),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
