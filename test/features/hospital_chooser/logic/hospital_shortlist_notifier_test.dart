@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/features/hospital_chooser/logic/hospital_shortlist_state.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] HospitalShortlistState', () {
    test('should have correct initial values', () {
      const state = HospitalShortlistState();

      expect(state.shortlistedUnits, isEmpty);
      expect(state.selectedHospital, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should compute count correctly', () {
      final units = FakeShortlistWithUnit.batch(3);
      final state = HospitalShortlistState(shortlistedUnits: units);

      expect(state.count, 3);
    });

    test('should compute isEmpty correctly', () {
      const emptyState = HospitalShortlistState();
      final nonEmptyState = HospitalShortlistState(
        shortlistedUnits: FakeShortlistWithUnit.batch(1),
      );

      expect(emptyState.isEmpty, true);
      expect(nonEmptyState.isEmpty, false);
    });

    test('should compute hasSelection correctly', () {
      const noSelectionState = HospitalShortlistState();
      final withSelectionState = HospitalShortlistState(
        selectedHospital: FakeShortlistWithUnit.selected(),
      );

      expect(noSelectionState.hasSelection, false);
      expect(withSelectionState.hasSelection, true);
    });

    test('should copyWith update fields correctly', () {
      const original = HospitalShortlistState();
      final updated = original.copyWith(
        isLoading: true,
        error: 'Test error',
      );

      expect(updated.isLoading, true);
      expect(updated.error, 'Test error');
    });

    test('should copyWith preserve unchanged fields', () {
      final units = FakeShortlistWithUnit.batch(2);
      final original = HospitalShortlistState(
        shortlistedUnits: units,
        isLoading: true,
      );
      final updated = original.copyWith(error: 'New error');

      expect(updated.shortlistedUnits.length, 2);
      expect(updated.isLoading, true);
      expect(updated.error, 'New error');
    });

    test('should clearSelection remove selectedHospital', () {
      final state = HospitalShortlistState(
        selectedHospital: FakeShortlistWithUnit.selected(),
        shortlistedUnits: FakeShortlistWithUnit.batch(2),
      );
      final cleared = state.clearSelection();

      expect(cleared.selectedHospital, isNull);
      expect(cleared.shortlistedUnits.length, 2); // Preserved
    });

    test('should have different count for different sizes', () {
      final empty = const HospitalShortlistState();
      final one = HospitalShortlistState(
        shortlistedUnits: FakeShortlistWithUnit.batch(1),
      );
      final five = HospitalShortlistState(
        shortlistedUnits: FakeShortlistWithUnit.batch(5),
      );

      expect(empty.count, 0);
      expect(one.count, 1);
      expect(five.count, 5);
    });

    test('should update error and clear on subsequent copyWith', () {
      const state = HospitalShortlistState();
      
      // Set error
      final withError = state.copyWith(error: 'Test error');
      expect(withError.error, 'Test error');
      
      // Clear error with null in copyWith
      final cleared = withError.copyWith(error: null);
      expect(cleared.error, isNull);
    });
  });

  group('[HospitalChooser] HospitalShortlistState - edge cases', () {
    test('should handle empty shortlist with selection', () {
      // Edge case: selected but empty shortlist (shouldn't happen in practice)
      final state = HospitalShortlistState(
        shortlistedUnits: [],
        selectedHospital: FakeShortlistWithUnit.selected(),
      );

      expect(state.isEmpty, true);
      expect(state.hasSelection, true);
    });

    test('should handle loading state with existing data', () {
      final state = HospitalShortlistState(
        shortlistedUnits: FakeShortlistWithUnit.batch(3),
        isLoading: true,
      );

      expect(state.isLoading, true);
      expect(state.count, 3);
    });

    test('should handle error state with existing data', () {
      final state = HospitalShortlistState(
        shortlistedUnits: FakeShortlistWithUnit.batch(2),
        error: 'Some error',
      );

      expect(state.error, isNotNull);
      expect(state.count, 2);
    });
  });
}
