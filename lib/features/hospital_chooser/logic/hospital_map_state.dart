import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/main_providers.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/hospital/hospital_filter_criteria.dart';
import '../../../domain/entities/hospital/maternity_unit.dart';
import '../../../domain/usecases/hospital/filter_units_usecase.dart';

// ----------------------------------------------------------------------------
// State Classes
// ----------------------------------------------------------------------------

/// State for the hospital map/list view.
class HospitalMapState {
  /// List of nearby maternity units.
  final List<MaternityUnit> nearbyUnits;

  /// Currently selected unit (for marker tap or list selection).
  final MaternityUnit? selectedUnit;

  /// Active filter criteria.
  final HospitalFilterCriteria filters;

  /// Map center coordinates.
  final LatLng? mapCenter;

  /// Whether data is loading.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  const HospitalMapState({
    this.nearbyUnits = const [],
    this.selectedUnit,
    this.filters = HospitalFilterCriteria.defaults,
    this.mapCenter,
    this.isLoading = false,
    this.error,
  });

  /// Number of units after filtering.
  int get unitCount => nearbyUnits.length;

  /// Whether there are any units to display.
  bool get hasUnits => nearbyUnits.isNotEmpty;

  HospitalMapState copyWith({
    List<MaternityUnit>? nearbyUnits,
    MaternityUnit? selectedUnit,
    HospitalFilterCriteria? filters,
    LatLng? mapCenter,
    bool? isLoading,
    String? error,
  }) {
    return HospitalMapState(
      nearbyUnits: nearbyUnits ?? this.nearbyUnits,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      filters: filters ?? this.filters,
      mapCenter: mapCenter ?? this.mapCenter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Copy with cleared selection.
  HospitalMapState clearSelection() {
    return HospitalMapState(
      nearbyUnits: nearbyUnits,
      selectedUnit: null,
      filters: filters,
      mapCenter: mapCenter,
      isLoading: isLoading,
      error: error,
    );
  }
}

// ----------------------------------------------------------------------------
// Notifier
// ----------------------------------------------------------------------------

/// Notifier for managing hospital map state.
class HospitalMapNotifier extends StateNotifier<HospitalMapState> {
  final FilterUnitsUseCase? _filterUnits;
  final bool _isLoading;

  HospitalMapNotifier({
    required FilterUnitsUseCase filterUnits,
  })  : _filterUnits = filterUnits,
        _isLoading = false,
        super(const HospitalMapState());

  /// Creates a loading-only notifier used while dependencies are initializing.
  HospitalMapNotifier._loading()
      : _filterUnits = null,
        _isLoading = true,
        super(const HospitalMapState(isLoading: true));

  /// Load nearby units for the given location.
  Future<void> loadNearbyUnits(LatLng location) async {
    final filterUnits = _filterUnits;
    if (_isLoading || filterUnits == null) return;
    
    state = state.copyWith(
      isLoading: true,
      error: null,
      mapCenter: location,
    );

    try {
      // Use filter criteria for the search
      final units = await filterUnits.execute(
        criteria: state.filters,
        userLat: location.latitude,
        userLng: location.longitude,
      );

      state = state.copyWith(
        nearbyUnits: units,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load nearby units with a specific radius.
  ///
  /// Used for auto-expanding radius when not enough units are found.
  Future<void> loadNearbyUnitsWithRadius(
    LatLng location, {
    required double radiusMiles,
  }) async {
    final filterUnits = _filterUnits;
    if (_isLoading || filterUnits == null) return;
    
    state = state.copyWith(
      isLoading: true,
      error: null,
      mapCenter: location,
    );

    try {
      // Create filter criteria with the specified radius
      final criteria = state.filters.copyWith(maxDistanceMiles: radiusMiles);
      
      final units = await filterUnits.execute(
        criteria: criteria,
        userLat: location.latitude,
        userLng: location.longitude,
      );

      state = state.copyWith(
        nearbyUnits: units,
        filters: criteria, // Update filters to reflect current radius
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Apply new filter criteria.
  /// 
  /// [sortLocation] - Optional location to use for distance sorting.
  /// If not provided, uses the current map center.
  Future<void> applyFilters(
    HospitalFilterCriteria newFilters, {
    LatLng? sortLocation,
  }) async {
    final filterUnits = _filterUnits;
    if (_isLoading || filterUnits == null) return;
    if (state.mapCenter == null) return;

    // Use provided location for sorting, or fall back to map center
    final locationForSort = sortLocation ?? state.mapCenter!;

    state = state.copyWith(
      filters: newFilters,
      isLoading: true,
      error: null,
    );

    try {
      final units = await filterUnits.execute(
        criteria: newFilters,
        userLat: locationForSort.latitude,
        userLng: locationForSort.longitude,
      );

      state = state.copyWith(
        nearbyUnits: units,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Select a unit (when marker is tapped or list item selected).
  void selectUnit(MaternityUnit unit) {
    if (_isLoading) return;
    state = state.copyWith(selectedUnit: unit);
  }

  /// Clear the current selection.
  void clearSelection() {
    if (_isLoading) return;
    state = state.clearSelection();
  }

  /// Refresh the current data.
  Future<void> refresh() async {
    if (_isLoading) return;
    if (state.mapCenter != null) {
      await loadNearbyUnits(state.mapCenter!);
    }
  }
  
  /// Auto-expand distance filter to find at least [minResults] units.
  /// 
  /// Uses distance progression: 1mi → 2mi → 3mi → 5mi → 10mi → 15mi
  /// Returns the final distance used.
  Future<double> autoExpandDistance({
    required LatLng location,
    int minResults = 10,
  }) async {
    final filterUnits = _filterUnits;
    if (_isLoading || filterUnits == null) return state.filters.maxDistanceMiles;
    
    const distanceProgression = [1.0, 2.0, 3.0, 5.0, 10.0, 15.0];
    
    state = state.copyWith(
      isLoading: true,
      error: null,
      mapCenter: location,
    );
    
    try {
      List<MaternityUnit> units = [];
      double finalDistance = distanceProgression.first;
      
      for (final distance in distanceProgression) {
        final criteria = state.filters.copyWith(maxDistanceMiles: distance);
        
        units = await filterUnits.execute(
          criteria: criteria,
          userLat: location.latitude,
          userLng: location.longitude,
        );
        
        finalDistance = distance;
        
        if (units.length >= minResults) {
          break;
        }
      }
      
      state = state.copyWith(
        nearbyUnits: units,
        filters: state.filters.copyWith(maxDistanceMiles: finalDistance),
        isLoading: false,
      );
      
      return finalDistance;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return state.filters.maxDistanceMiles;
    }
  }
}

// ----------------------------------------------------------------------------
// Provider
// ----------------------------------------------------------------------------

/// Provider that indicates whether hospital map dependencies are ready.
final hospitalMapReadyProvider = Provider<bool>((ref) {
  final filterUnitsAsync = ref.watch(filterUnitsUseCaseProvider);
  return filterUnitsAsync.hasValue;
});

/// Provider for hospital map state.
///
/// IMPORTANT: Only access this provider when [hospitalMapReadyProvider] is true.
final hospitalMapProvider =
    StateNotifierProvider<HospitalMapNotifier, HospitalMapState>((ref) {
  final filterUnitsAsync = ref.watch(filterUnitsUseCaseProvider);

  // If dependencies aren't ready, return a notifier with loading state
  if (!filterUnitsAsync.hasValue) {
    return HospitalMapNotifier._loading();
  }

  return HospitalMapNotifier(
    filterUnits: filterUnitsAsync.requireValue,
  );
});
