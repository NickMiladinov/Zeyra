@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/hospital/hospital_search_result.dart';
import 'package:zeyra/features/hospital_chooser/logic/hospital_search_state.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] HospitalSearchState', () {
    test('should have correct initial values', () {
      const state = HospitalSearchState();

      expect(state.query, isEmpty);
      expect(state.nearbyResults, isEmpty);
      expect(state.globalResults, isEmpty);
      expect(state.isSearching, false);
      expect(state.isActive, false);
      expect(state.error, isNull);
    });

    test('should compute hasResults correctly', () {
      const emptyState = HospitalSearchState();
      final stateWithNearby = HospitalSearchState(
        nearbyResults: [
          HospitalSearchResult(
            unit: FakeMaternityUnit.simple(),
            score: 0.9,
            tier: SearchTier.nearby,
          ),
        ],
      );
      final stateWithGlobal = HospitalSearchState(
        globalResults: [
          HospitalSearchResult(
            unit: FakeMaternityUnit.simple(),
            score: 0.8,
            tier: SearchTier.allUk,
          ),
        ],
      );

      expect(emptyState.hasResults, false);
      expect(stateWithNearby.hasResults, true);
      expect(stateWithGlobal.hasResults, true);
    });

    test('should compute hasNoResults correctly', () {
      const emptyState = HospitalSearchState();
      const searchingState = HospitalSearchState(
        query: 'test',
        isSearching: true,
      );
      const noResultsState = HospitalSearchState(
        query: 'test',
        isSearching: false,
      );
      final hasResultsState = HospitalSearchState(
        query: 'test',
        isSearching: false,
        nearbyResults: [
          HospitalSearchResult(
            unit: FakeMaternityUnit.simple(),
            score: 0.9,
            tier: SearchTier.nearby,
          ),
        ],
      );

      expect(emptyState.hasNoResults, false); // No query
      expect(searchingState.hasNoResults, false); // Still searching
      expect(noResultsState.hasNoResults, true); // Query but no results
      expect(hasResultsState.hasNoResults, false); // Has results
    });

    test('should compute totalResultCount correctly', () {
      const emptyState = HospitalSearchState();
      final stateWithResults = HospitalSearchState(
        nearbyResults: [
          HospitalSearchResult(
            unit: FakeMaternityUnit.simple(),
            score: 0.9,
            tier: SearchTier.nearby,
          ),
          HospitalSearchResult(
            unit: FakeMaternityUnit.simple(),
            score: 0.8,
            tier: SearchTier.nearby,
          ),
        ],
        globalResults: [
          HospitalSearchResult(
            unit: FakeMaternityUnit.simple(),
            score: 0.7,
            tier: SearchTier.allUk,
          ),
        ],
      );

      expect(emptyState.totalResultCount, 0);
      expect(stateWithResults.totalResultCount, 3);
    });

    test('should copyWith update fields correctly', () {
      const original = HospitalSearchState();
      final results = [
        HospitalSearchResult(
          unit: FakeMaternityUnit.simple(),
          score: 0.9,
          tier: SearchTier.nearby,
        ),
      ];

      final updated = original.copyWith(
        query: 'test query',
        nearbyResults: results,
        isSearching: true,
        isActive: true,
      );

      expect(updated.query, 'test query');
      expect(updated.nearbyResults.length, 1);
      expect(updated.isSearching, true);
      expect(updated.isActive, true);
    });

    test('should copyWith preserve unchanged fields', () {
      final results = [
        HospitalSearchResult(
          unit: FakeMaternityUnit.simple(),
          score: 0.9,
          tier: SearchTier.nearby,
        ),
      ];
      final original = HospitalSearchState(
        query: 'original',
        nearbyResults: results,
        isActive: true,
      );

      final updated = original.copyWith(isSearching: true);

      expect(updated.query, 'original');
      expect(updated.nearbyResults.length, 1);
      expect(updated.isActive, true);
      expect(updated.isSearching, true);
    });

    test('should copyWith clear error with null', () {
      const withError = HospitalSearchState(error: 'Test error');
      final cleared = withError.copyWith(error: null);

      expect(cleared.error, isNull);
    });

    test('should clear reset state but preserve isActive', () {
      final fullState = HospitalSearchState(
        query: 'test',
        nearbyResults: [
          HospitalSearchResult(
            unit: FakeMaternityUnit.simple(),
            score: 0.9,
            tier: SearchTier.nearby,
          ),
        ],
        isSearching: true,
        isActive: true,
        error: 'some error',
      );

      final cleared = fullState.clear();

      expect(cleared.query, isEmpty);
      expect(cleared.nearbyResults, isEmpty);
      expect(cleared.globalResults, isEmpty);
      expect(cleared.isSearching, false);
      expect(cleared.isActive, true); // Preserved
      expect(cleared.error, isNull);
    });
  });

  group('[HospitalChooser] SearchTier', () {
    test('nearby should have correct displayName', () {
      expect(SearchTier.nearby.displayName, 'Nearby');
    });

    test('allUk should have correct displayName', () {
      expect(SearchTier.allUk.displayName, 'Other Locations');
    });
  });

  group('[HospitalChooser] HospitalSearchResult', () {
    test('should create with required fields', () {
      final unit = FakeMaternityUnit.simple();
      final result = HospitalSearchResult(
        unit: unit,
        score: 0.95,
        tier: SearchTier.nearby,
        distanceMiles: 1.5,
      );

      expect(result.unit, unit);
      expect(result.score, 0.95);
      expect(result.tier, SearchTier.nearby);
      expect(result.distanceMiles, 1.5);
    });

    test('should copyWith correctly', () {
      final result = HospitalSearchResult(
        unit: FakeMaternityUnit.simple(),
        score: 0.9,
        tier: SearchTier.nearby,
      );

      final updated = result.copyWith(
        score: 0.8,
        tier: SearchTier.allUk,
        distanceMiles: 5.0,
      );

      expect(updated.score, 0.8);
      expect(updated.tier, SearchTier.allUk);
      expect(updated.distanceMiles, 5.0);
      expect(updated.unit, result.unit); // Preserved
    });

    test('should have correct equality based on unit id and tier', () {
      final unit = FakeMaternityUnit.simple();
      final result1 = HospitalSearchResult(
        unit: unit,
        score: 0.9,
        tier: SearchTier.nearby,
      );
      final result2 = HospitalSearchResult(
        unit: unit,
        score: 0.8, // Different score
        tier: SearchTier.nearby,
      );
      final result3 = HospitalSearchResult(
        unit: unit,
        score: 0.9,
        tier: SearchTier.allUk, // Different tier
      );

      expect(result1, equals(result2)); // Same unit and tier
      expect(result1, isNot(equals(result3))); // Different tier
    });
  });
}
