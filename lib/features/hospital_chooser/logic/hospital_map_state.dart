import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/main_providers.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/hospital/hospital_filter_criteria.dart';
import '../../../domain/entities/hospital/maternity_unit.dart';
import '../../../domain/usecases/hospital/filter_units_usecase.dart';
import '../../../domain/usecases/hospital/get_nearby_units_usecase.dart';
import 'hospital_location_state.dart';

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
  final GetNearbyUnitsUseCase _getNearbyUnits;
  final FilterUnitsUseCase _filterUnits;

  HospitalMapNotifier({
    required GetNearbyUnitsUseCase getNearbyUnits,
    required FilterUnitsUseCase filterUnits,
  })  : _getNearbyUnits = getNearbyUnits,
        _filterUnits = filterUnits,
        super(const HospitalMapState());

  /// Load nearby units for the given location.
  Future<void> loadNearbyUnits(LatLng location) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      mapCenter: location,
    );

    try {
      // Use filter criteria for the search
      final units = await _filterUnits.execute(
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

  /// Apply new filter criteria.
  Future<void> applyFilters(HospitalFilterCriteria newFilters) async {
    if (state.mapCenter == null) return;

    state = state.copyWith(
      filters: newFilters,
      isLoading: true,
      error: null,
    );

    try {
      final units = await _filterUnits.execute(
        criteria: newFilters,
        userLat: state.mapCenter!.latitude,
        userLng: state.mapCenter!.longitude,
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
    state = state.copyWith(selectedUnit: unit);
  }

  /// Clear the current selection.
  void clearSelection() {
    state = state.clearSelection();
  }

  /// Refresh the current data.
  Future<void> refresh() async {
    if (state.mapCenter != null) {
      await loadNearbyUnits(state.mapCenter!);
    }
  }
}

// ----------------------------------------------------------------------------
// Provider
// ----------------------------------------------------------------------------

/// Provider for hospital map state.
final hospitalMapProvider =
    StateNotifierProvider<HospitalMapNotifier, HospitalMapState>((ref) {
  final getNearbyUnitsAsync = ref.watch(getNearbyUnitsUseCaseProvider);
  final filterUnitsAsync = ref.watch(filterUnitsUseCaseProvider);

  if (!getNearbyUnitsAsync.hasValue || !filterUnitsAsync.hasValue) {
    throw StateError(
      'hospitalMapProvider accessed before dependencies are ready.',
    );
  }

  return HospitalMapNotifier(
    getNearbyUnits: getNearbyUnitsAsync.requireValue,
    filterUnits: filterUnitsAsync.requireValue,
  );
});
