@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/core/services/location_service.dart';
import 'package:zeyra/domain/entities/hospital/hospital_filter_criteria.dart';
import 'package:zeyra/features/hospital_chooser/logic/hospital_map_state.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] HospitalMapState', () {
    test('should have correct initial values', () {
      const state = HospitalMapState();

      expect(state.nearbyUnits, isEmpty);
      expect(state.selectedUnit, isNull);
      expect(state.filters, HospitalFilterCriteria.defaults);
      expect(state.mapCenter, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should compute unitCount correctly', () {
      final units = FakeMaternityUnit.batch(5);
      final state = HospitalMapState(nearbyUnits: units);

      expect(state.unitCount, 5);
    });

    test('should compute hasUnits correctly', () {
      const emptyState = HospitalMapState();
      final nonEmptyState = HospitalMapState(
        nearbyUnits: FakeMaternityUnit.batch(3),
      );

      expect(emptyState.hasUnits, false);
      expect(nonEmptyState.hasUnits, true);
    });

    test('should copyWith update fields correctly', () {
      const original = HospitalMapState();
      final units = FakeMaternityUnit.batch(2);
      const filters = HospitalFilterCriteria(
        maxDistanceMiles: 10.0,
        includeNhs: true,
        includeIndependent: false,
      );
      final center = LatLng(51.5074, -0.1278);

      final updated = original.copyWith(
        nearbyUnits: units,
        filters: filters,
        mapCenter: center,
        isLoading: true,
      );

      expect(updated.nearbyUnits.length, 2);
      expect(updated.filters.maxDistanceMiles, 10.0);
      expect(updated.mapCenter, isNotNull);
      expect(updated.isLoading, true);
    });

    test('should copyWith preserve unchanged fields', () {
      final units = FakeMaternityUnit.batch(3);
      final original = HospitalMapState(
        nearbyUnits: units,
        mapCenter: LatLng(51.5074, -0.1278),
      );
      final updated = original.copyWith(isLoading: true);

      expect(updated.nearbyUnits.length, 3);
      expect(updated.mapCenter, isNotNull);
      expect(updated.isLoading, true);
    });

    test('should copyWith clear error with null', () {
      const withError = HospitalMapState(error: 'Test error');
      final cleared = withError.copyWith(error: null);

      expect(cleared.error, isNull);
    });

    test('should copyWith set selectedUnit', () {
      final unit = FakeMaternityUnit.simple();
      const original = HospitalMapState();
      final updated = original.copyWith(selectedUnit: unit);

      expect(updated.selectedUnit, isNotNull);
      expect(updated.selectedUnit!.id, unit.id);
    });

    test('should clearSelection remove selectedUnit', () {
      final unit = FakeMaternityUnit.simple();
      final withSelection = HospitalMapState(selectedUnit: unit);
      final cleared = withSelection.clearSelection();

      expect(cleared.selectedUnit, isNull);
    });

    test('should clearSelection preserve other fields', () {
      final units = FakeMaternityUnit.batch(2);
      final center = LatLng(51.5074, -0.1278);
      final withSelection = HospitalMapState(
        nearbyUnits: units,
        selectedUnit: units.first,
        mapCenter: center,
      );
      final cleared = withSelection.clearSelection();

      expect(cleared.nearbyUnits.length, 2);
      expect(cleared.mapCenter, isNotNull);
      expect(cleared.selectedUnit, isNull);
    });
  });

  group('[HospitalChooser] HospitalMapState - filter scenarios', () {
    test('should use default filters', () {
      const state = HospitalMapState();

      expect(state.filters.maxDistanceMiles, 15.0);
      expect(state.filters.includeNhs, true);
      expect(state.filters.includeIndependent, true);
      expect(state.filters.minRating, MinRatingFilter.any);
    });

    test('should update filters with copyWith', () {
      const original = HospitalMapState();
      const newFilters = HospitalFilterCriteria(
        maxDistanceMiles: 5.0,
        includeNhs: true,
        includeIndependent: false,
        minRating: MinRatingFilter.good,
      );
      final updated = original.copyWith(filters: newFilters);

      expect(updated.filters.maxDistanceMiles, 5.0);
      expect(updated.filters.includeNhs, true);
      expect(updated.filters.includeIndependent, false);
      expect(updated.filters.minRating, MinRatingFilter.good);
    });
  });

  group('[HospitalChooser] HospitalMapState - edge cases', () {
    test('should handle empty units list', () {
      const state = HospitalMapState(nearbyUnits: []);

      expect(state.unitCount, 0);
      expect(state.hasUnits, false);
    });

    test('should handle loading state with existing units', () {
      final units = FakeMaternityUnit.batch(3);
      final state = HospitalMapState(
        nearbyUnits: units,
        isLoading: true,
      );

      expect(state.isLoading, true);
      expect(state.hasUnits, true);
      expect(state.unitCount, 3);
    });

    test('should handle error state with existing units', () {
      final units = FakeMaternityUnit.batch(2);
      final state = HospitalMapState(
        nearbyUnits: units,
        error: 'Failed to refresh',
      );

      expect(state.error, isNotNull);
      expect(state.hasUnits, true);
    });

    test('should handle selectedUnit not in nearbyUnits', () {
      // Edge case: selection might persist while units refresh
      final selectedUnit = FakeMaternityUnit.simple(id: 'selected-unit');
      final nearbyUnits = FakeMaternityUnit.batch(3); // Different units

      final state = HospitalMapState(
        nearbyUnits: nearbyUnits,
        selectedUnit: selectedUnit,
      );

      expect(state.selectedUnit, isNotNull);
      expect(state.nearbyUnits.contains(selectedUnit), false);
    });
  });
}
