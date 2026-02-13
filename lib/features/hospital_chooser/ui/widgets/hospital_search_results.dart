import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/hospital_search_result.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';
import '../../logic/hospital_search_state.dart';

/// Overlay widget displaying grouped search results.
///
/// Shows results in two sections:
/// - "Nearby" for in-memory fuzzy matches (Tier 1)
/// - "Other Locations" for database matches (Tier 2)
class HospitalSearchResults extends StatelessWidget {
  /// Current search state.
  final HospitalSearchState searchState;

  /// Callback when a hospital is selected from results.
  final void Function(MaternityUnit unit)? onResultTap;

  /// Callback to close the search overlay.
  final VoidCallback? onClose;

  const HospitalSearchResults({
    super.key,
    required this.searchState,
    this.onResultTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    // If query is empty, show nothing (overlay shouldn't even be visible)
    if (searchState.query.isEmpty) {
      return const SizedBox.shrink();
    }

    // Loading state
    if (searchState.isSearching && !searchState.hasResults) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // No results state
    if (searchState.hasNoResults) {
      return _buildEmptyState();
    }

    // Results list
    if (searchState.hasResults) {
      return _buildResultsList();
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      child: Row(
        children: [
          Icon(
            AppIcons.searchOff,
            size: AppSpacing.iconSM,
            color: AppColors.iconDefault,
          ),
          const SizedBox(width: AppSpacing.gapMD),
          Text(
            'No hospitals found',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView(
      padding: const EdgeInsets.only(
        top: AppSpacing.paddingSM,
        bottom: AppSpacing.paddingLG,
      ),
      children: [
        // Nearby section (Tier 1)
        if (searchState.nearbyResults.isNotEmpty) ...[
          _SectionHeader(
            title: SearchTier.nearby.displayName,
            count: searchState.nearbyResults.length,
          ),
          ...searchState.nearbyResults.map(
            (result) => _SearchResultItem(
              result: result,
              onTap: () => onResultTap?.call(result.unit),
            ),
          ),
        ],

        // Global section (Tier 2)
        if (searchState.globalResults.isNotEmpty) ...[
          if (searchState.nearbyResults.isNotEmpty)
            const SizedBox(height: AppSpacing.gapMD),
          _SectionHeader(
            title: SearchTier.allUk.displayName,
            count: searchState.globalResults.length,
          ),
          ...searchState.globalResults.map(
            (result) => _SearchResultItem(
              result: result,
              onTap: () => onResultTap?.call(result.unit),
            ),
          ),
        ],

        // Loading indicator for ongoing search
        if (searchState.isSearching)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.paddingMD),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Section header for result groups.
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingMD,
        vertical: AppSpacing.paddingSM,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.labelLarge,
          ),
          const SizedBox(width: AppSpacing.gapXS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingSM,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey100,
              borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual search result item.
class _SearchResultItem extends StatelessWidget {
  final HospitalSearchResult result;
  final VoidCallback? onTap;

  const _SearchResultItem({
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unit = result.unit;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingMD,
          vertical: AppSpacing.paddingSM,
        ),
        child: Row(
          children: [
            // Hospital icon
            Container(
              width: AppSpacing.iconXXL,
              height: AppSpacing.iconXXL,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppEffects.radiusMD),
              ),
              child: Icon(
                AppIcons.hospital,
                color: AppColors.primary,
                size: AppSpacing.iconXS,
              ),
            ),
            const SizedBox(width: AppSpacing.gapMD),

            // Hospital details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Location
                      if (unit.townCity != null) ...[
                        Flexible(
                          child: Text(
                            unit.townCity!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      // Distance
                      if (result.distanceMiles != null) ...[
                        if (unit.townCity != null)
                          Text(
                            ' · ',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          _formatDistance(result.distanceMiles!),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              AppIcons.arrowForward,
              color: AppColors.iconDefault,
              size: AppSpacing.iconXS,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double miles) {
    if (miles < 1) {
      return '${(miles * 10).round() / 10} mi';
    }
    if (miles < 10) {
      return '${miles.toStringAsFixed(1)} mi';
    }
    return '${miles.round()} mi';
  }
}
