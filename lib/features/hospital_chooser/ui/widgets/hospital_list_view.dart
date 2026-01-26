import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/location_service.dart';
import '../../../../domain/entities/hospital/hospital_filter_criteria.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';
import 'hospital_list_card.dart';
import 'hospital_sort_bottom_sheet.dart';

/// List view for displaying hospitals.
class HospitalListView extends StatelessWidget {
  /// List of hospitals to display.
  final List<MaternityUnit> units;

  /// User's location for distance calculation.
  final LatLng? userLocation;

  /// Current filter criteria (for sort option).
  final HospitalFilterCriteria filters;

  /// Whether data is loading.
  final bool isLoading;

  /// Callback when a hospital is tapped.
  final void Function(MaternityUnit unit)? onHospitalTap;

  /// Callback when favorite is toggled.
  final void Function(MaternityUnit unit)? onFavoriteTap;

  /// Callback when sort option changes.
  final void Function(HospitalSortBy sort) onSortChanged;

  /// Callback to switch to map view.
  final VoidCallback onMapViewTap;

  /// Set of favorite hospital IDs.
  final Set<String> favoriteIds;

  const HospitalListView({
    super.key,
    required this.units,
    this.userLocation,
    required this.filters,
    this.isLoading = false,
    this.onHospitalTap,
    this.onFavoriteTap,
    required this.onSortChanged,
    required this.onMapViewTap,
    this.favoriteIds = const {},
  });

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HospitalSortBottomSheet(
        currentSort: filters.sortBy,
        onSortSelected: onSortChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Results count and sort bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingMD,
                vertical: AppSpacing.paddingSM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${units.length} hospital${units.length == 1 ? '' : 's'} found',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Sort button
                  GestureDetector(
                    onTap: () => _showSortSheet(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sort by: ${filters.sortBy.displayName}',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.unfold_more,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Hospital list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : units.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.paddingXS,
                            bottom: 100, // Space for the floating button
                          ),
                          itemCount: units.length,
                          itemBuilder: (context, index) {
                            final unit = units[index];
                            final distance = userLocation != null
                                ? unit.distanceFrom(
                                    userLocation!.latitude,
                                    userLocation!.longitude,
                                  )
                                : null;

                            return HospitalListCard(
                              unit: unit,
                              distanceMiles: distance,
                              isFavorite: favoriteIds.contains(unit.id),
                              onTap: () => onHospitalTap?.call(unit),
                              onFavoriteTap: () => onFavoriteTap?.call(unit),
                            );
                          },
                        ),
            ),
          ],
        ),

        // Map View floating button
        Positioned(
          bottom: AppSpacing.paddingXL,
          left: 0,
          right: 0,
          child: Center(
            child: _MapViewButton(onTap: onMapViewTap),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.gapLG),
            Text(
              'No hospitals found',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.gapSM),
            Text(
              'Try adjusting your filters or increasing the search distance.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating button to switch to map view.
class _MapViewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MapViewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLG,
              vertical: AppSpacing.paddingSM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.gapSM),
                Text(
                  'Map View',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
