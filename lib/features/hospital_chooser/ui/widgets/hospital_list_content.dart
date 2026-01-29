import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';
import '../../logic/hospital_location_state.dart';
import '../../logic/hospital_map_state.dart';
import '../../logic/hospital_search_state.dart';
import 'hospital_filter_chips.dart';
import 'hospital_list_view.dart';
import 'hospital_search_bar.dart';
import 'hospital_search_results.dart';

/// List content wrapper for the hospital chooser.
///
/// Wraps [HospitalListView] with search bar, filter chips,
/// search overlay, and preview sheet.
class HospitalListContent extends ConsumerWidget {
  /// Current location state.
  final HospitalLocationState locationState;

  /// Current map state with nearby units.
  final HospitalMapState mapState;

  /// Whether currently loading units.
  final bool isLoadingUnits;

  /// Set of favorite hospital IDs.
  final Set<String> favoriteIds;

  /// Search text controller.
  final TextEditingController searchController;

  /// Search focus node.
  final FocusNode searchFocusNode;

  /// Callback when filter button is tapped.
  final VoidCallback onFilterTap;

  /// Callback to clear search.
  final VoidCallback onClearSearch;

  /// Callback to dismiss search overlay.
  final VoidCallback onDismissSearch;

  /// Callback when a search result is selected.
  final void Function(MaternityUnit unit) onSearchResultSelected;

  /// Callback when a hospital is tapped.
  final void Function(MaternityUnit unit) onHospitalTap;

  /// Callback when favorite is toggled.
  final void Function(MaternityUnit unit) onFavoriteTap;

  /// Callback to switch to map view.
  final VoidCallback onMapViewTap;

  const HospitalListContent({
    super.key,
    required this.locationState,
    required this.mapState,
    required this.isLoadingUnits,
    required this.favoriteIds,
    required this.searchController,
    required this.searchFocusNode,
    required this.onFilterTap,
    required this.onClearSearch,
    required this.onDismissSearch,
    required this.onSearchResultSelected,
    required this.onHospitalTap,
    required this.onFavoriteTap,
    required this.onMapViewTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(hospitalSearchProvider);

    return Stack(
      children: [
        // Main list content (always visible)
        Column(
          children: [
            // Search bar and filter button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingLG,
                vertical: AppSpacing.paddingSM,
              ),
              child: HospitalSearchBar(
                controller: searchController,
                focusNode: searchFocusNode,
                filters: mapState.filters,
                onFilterTap: onFilterTap,
                onClear: onClearSearch,
              ),
            ),

            // Active filter chips (show distance filter in list view)
            if (mapState.filters.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.paddingLG,
                ),
                child: HospitalFilterChips(
                  filters: mapState.filters,
                  showDistanceFilter: true,
                  onRemoveFilter: (newFilters) {
                    ref.read(hospitalMapProvider.notifier).applyFilters(
                      newFilters,
                      sortLocation: locationState.userLocation,
                    );
                  },
                ),
              ),

            // Hospital list (always visible behind overlay)
            Expanded(
              child: HospitalListView(
                units: mapState.nearbyUnits,
                userLocation: locationState.userLocation,
                filters: mapState.filters,
                isLoading: isLoadingUnits || mapState.isLoading,
                favoriteIds: favoriteIds,
                onHospitalTap: onHospitalTap,
                onFavoriteTap: onFavoriteTap,
                onSortChanged: (sort) {
                  final newFilters = mapState.filters.copyWith(sortBy: sort);
                  ref.read(hospitalMapProvider.notifier).applyFilters(
                    newFilters,
                    sortLocation: locationState.userLocation,
                  );
                },
                onMapViewTap: onMapViewTap,
              ),
            ),
          ],
        ),

        // Dismiss layer (below search bar)
        if (searchState.isActive && searchState.query.isNotEmpty)
          Positioned(
            top: AppSpacing.searchBarHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onDismissSearch,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),

        // Search results overlay (positioned below search bar)
        if (searchState.isActive && searchState.query.isNotEmpty)
          Positioned(
            top: AppSpacing.searchBarHeight + AppSpacing.paddingSM,
            left: AppSpacing.paddingLG,
            right: AppSpacing.paddingLG,
            child: GestureDetector(
              onTap: () {}, // Prevent tap propagation
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppEffects.radiusLG),
                  boxShadow: AppEffects.shadowMD,
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppEffects.radiusLG),
                  child: HospitalSearchResults(
                    searchState: searchState,
                    onResultTap: onSearchResultSelected,
                    onClose: onClearSearch,
                  ),
                ),
              ),
            ),
          ),

      ],
    );
  }
}
