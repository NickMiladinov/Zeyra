import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/hospital_filter_criteria.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.gapLG),

          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort by',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapMD),

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

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
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
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.backgroundGrey400,
                  width: 2,
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
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
