import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../domain/entities/hospital/hospital_filter_criteria.dart';

/// Displays active filter chips that can be removed.
///
/// Shows chips for:
/// - Distance filter (only in list view)
/// - CQC rating filter
/// - NHS/Independent filter
class HospitalFilterChips extends StatelessWidget {
  /// Current filter criteria.
  final HospitalFilterCriteria filters;

  /// Callback when a filter is removed, with updated criteria.
  final void Function(HospitalFilterCriteria) onRemoveFilter;

  /// Whether to show distance filter (only for list view).
  final bool showDistanceFilter;

  const HospitalFilterChips({
    super.key,
    required this.filters,
    required this.onRemoveFilter,
    this.showDistanceFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    // Add distance filter chip if non-default (only in list view)
    if (showDistanceFilter && filters.maxDistanceMiles != 15.0) {
      final distanceLabel = filters.maxDistanceMiles < 5
          ? 'Within ${filters.maxDistanceMiles.toStringAsFixed(1)}mi'
          : 'Within ${filters.maxDistanceMiles.toInt()}mi';
      chips.add(_FilterChip(
        label: distanceLabel,
        onRemove: () {
          onRemoveFilter(filters.copyWith(maxDistanceMiles: 15.0));
        },
      ));
    }

    // Add rating filter chip if filtering by specific ratings
    if (filters.hasRatingFilter) {
      chips.add(_FilterChip(
        label: 'CQC: ${filters.ratingFilterDisplayName}',
        onRemove: () {
          onRemoveFilter(filters.copyWith(
            allowedRatings: HospitalFilterCriteria.allRatings,
          ));
        },
      ));
    }

    // Add NHS/Independent filter chips if not both selected
    if (!filters.includeNhs) {
      chips.add(_FilterChip(
        label: 'Independent only',
        onRemove: () {
          onRemoveFilter(filters.copyWith(includeNhs: true));
        },
      ));
    }
    if (!filters.includeIndependent) {
      chips.add(_FilterChip(
        label: 'NHS only',
        onRemove: () {
          onRemoveFilter(filters.copyWith(includeIndependent: true));
        },
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }
}

/// Individual removable filter chip.
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.gapSM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingSM,
        vertical: AppSpacing.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
        border: Border.all(color: AppColors.backgroundGrey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.gapXS),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              AppIcons.close,
              size: AppSpacing.iconXXS,
              color: AppColors.iconDefault,
            ),
          ),
        ],
      ),
    );
  }
}
