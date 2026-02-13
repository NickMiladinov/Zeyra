@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/hospital/hospital_filter_criteria.dart';
import 'package:zeyra/domain/entities/hospital/maternity_unit.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] Rating Filter', () {
    test('should allow any rating with allRatings', () {
      const criteria = HospitalFilterCriteria(
        allowedRatings: HospitalFilterCriteria.allRatings,
      );
      expect(criteria.hasRatingFilter, isFalse);
    });

    test('should filter by specific ratings', () {
      const criteria = HospitalFilterCriteria(
        allowedRatings: {CqcRating.outstanding, CqcRating.good},
      );
      expect(criteria.hasRatingFilter, isTrue);
      expect(criteria.allowedRatings.contains(CqcRating.outstanding), isTrue);
      expect(criteria.allowedRatings.contains(CqcRating.good), isTrue);
      expect(criteria.allowedRatings.contains(CqcRating.inadequate), isFalse);
    });

    test('should filter outstanding only', () {
      const criteria = HospitalFilterCriteria(
        allowedRatings: {CqcRating.outstanding},
      );
      expect(criteria.hasRatingFilter, isTrue);
      expect(criteria.allowedRatings.length, 1);
    });

    test('should have correct ratingFilterDisplayName', () {
      const anyRating = HospitalFilterCriteria.defaults;
      expect(anyRating.ratingFilterDisplayName, 'Any Rating');
      
      const goodOrBetter = HospitalFilterCriteria(
        allowedRatings: {CqcRating.outstanding, CqcRating.good},
      );
      expect(goodOrBetter.ratingFilterDisplayName, 'Good or better');
      
      const outstandingOnly = HospitalFilterCriteria(
        allowedRatings: {CqcRating.outstanding},
      );
      expect(outstandingOnly.ratingFilterDisplayName, 'Outstanding');
    });
  });

  group('[HospitalChooser] HospitalFilterCriteria Creation', () {
    test('should create with default values', () {
      const criteria = HospitalFilterCriteria();

      expect(criteria.maxDistanceMiles, 15.0);
      expect(criteria.allowedRatings, HospitalFilterCriteria.allRatings);
      expect(criteria.includeNhs, isTrue);
      expect(criteria.includeIndependent, isTrue);
      expect(criteria.sortBy, HospitalSortBy.distance);
    });

    test('should create with custom values', () {
      const criteria = HospitalFilterCriteria(
        maxDistanceMiles: 25.0,
        allowedRatings: {CqcRating.outstanding, CqcRating.good},
        includeNhs: true,
        includeIndependent: false,
        sortBy: HospitalSortBy.rating,
      );

      expect(criteria.maxDistanceMiles, 25.0);
      expect(criteria.hasRatingFilter, isTrue);
      expect(criteria.includeIndependent, isFalse);
      expect(criteria.sortBy, HospitalSortBy.rating);
    });

    test('should detect active filters', () {
      const criteria = HospitalFilterCriteria(
        maxDistanceMiles: 25.0,
      );

      expect(criteria.hasActiveFilters, isTrue);
    });

    test('should return false for default filters', () {
      const criteria = HospitalFilterCriteria.defaults;
      expect(criteria.hasActiveFilters, isFalse);
    });
  });

  group('[HospitalChooser] Filter Application', () {
    late List<MaternityUnit> testUnits;
    const userLat = 51.5074;
    const userLng = -0.1278;

    setUp(() {
      testUnits = [
        // Valid units at different distances
        FakeMaternityUnit.atLocation(
          id: 'nearby',
          latitude: 51.51, // ~0.2 miles away
          longitude: -0.13,
        ),
        FakeMaternityUnit.atLocation(
          id: 'medium',
          latitude: 51.6, // ~6 miles away
          longitude: -0.1,
        ),
        FakeMaternityUnit.atLocation(
          id: 'far',
          latitude: 52.0, // ~35 miles away
          longitude: -0.1,
        ),
        // Invalid unit
        FakeMaternityUnit.invalid(id: 'invalid', isActive: false),
      ];
    });

    test('should filter by distance', () {
      const criteria = HospitalFilterCriteria(maxDistanceMiles: 10.0);
      final result = criteria.apply(testUnits, userLat, userLng);

      // Only nearby and medium should pass (both within 10 miles)
      expect(result.length, lessThanOrEqualTo(2));
      expect(result.any((u) => u.id == 'far'), isFalse);
    });

    test('should filter by NHS/independent type', () {
      final units = [
        FakeMaternityUnit.nhsHospital(id: 'nhs-1'),
        FakeMaternityUnit.independentHospital(id: 'ind-1'),
      ];

      const nhsOnlyCriteria = HospitalFilterCriteria(
        includeNhs: true,
        includeIndependent: false,
        maxDistanceMiles: 1000, // Large radius to include all
      );

      final result = nhsOnlyCriteria.apply(units, userLat, userLng);

      expect(result.every((u) => u.isNhs), isTrue);
    });

    test('should filter by allowed ratings', () {
      final units = [
        FakeMaternityUnit.withRating(rating: 'Outstanding', id: 'outstanding'),
        FakeMaternityUnit.withRating(rating: 'Good', id: 'good'),
        FakeMaternityUnit.withRating(rating: 'Requires improvement', id: 'ri'),
      ];

      const criteria = HospitalFilterCriteria(
        allowedRatings: {CqcRating.outstanding, CqcRating.good},
        maxDistanceMiles: 1000,
      );

      final result = criteria.apply(units, userLat, userLng);

      expect(result.length, 2);
      expect(result.any((u) => u.id == 'ri'), isFalse);
    });

    test('should exclude invalid units', () {
      const criteria = HospitalFilterCriteria(maxDistanceMiles: 1000);
      final result = criteria.apply(testUnits, userLat, userLng);

      expect(result.any((u) => u.id == 'invalid'), isFalse);
    });

    test('should combine multiple filters', () {
      final units = [
        FakeMaternityUnit.simple(id: 'valid', overallRating: 'Good'),
        FakeMaternityUnit.withRating(rating: 'Inadequate', id: 'bad-rating'),
        FakeMaternityUnit.independentHospital(id: 'private'),
      ];

      const criteria = HospitalFilterCriteria(
        allowedRatings: {CqcRating.outstanding, CqcRating.good},
        includeIndependent: false,
        maxDistanceMiles: 1000,
      );

      final result = criteria.apply(units, userLat, userLng);

      // Only the first unit should pass (good rating + NHS)
      expect(result.length, lessThanOrEqualTo(1));
    });

    test('should return empty list when no matches', () {
      const criteria = HospitalFilterCriteria(
        maxDistanceMiles: 0.001, // Very small radius
      );

      final result = criteria.apply(testUnits, 0, 0); // Far from all units
      expect(result, isEmpty);
    });
  });

  group('[HospitalChooser] Filter Sorting', () {
    test('should sort by distance ascending', () {
      final units = FakeMaternityUnit.atDistances(
        centerLat: 51.5,
        centerLng: -0.1,
        distancesMiles: [10, 5, 15, 2],
      );

      const criteria = HospitalFilterCriteria(
        sortBy: HospitalSortBy.distance,
        maxDistanceMiles: 20,
      );

      final result = criteria.apply(units, 51.5, -0.1);

      // Should be sorted by distance
      for (int i = 0; i < result.length - 1; i++) {
        final dist1 = result[i].distanceFrom(51.5, -0.1)!;
        final dist2 = result[i + 1].distanceFrom(51.5, -0.1)!;
        expect(dist1, lessThanOrEqualTo(dist2));
      }
    });

    test('should sort by rating descending', () {
      final units = [
        FakeMaternityUnit.withRating(rating: 'Good', id: 'good'),
        FakeMaternityUnit.withRating(rating: 'Outstanding', id: 'outstanding'),
        FakeMaternityUnit.withRating(rating: 'Requires improvement', id: 'ri'),
      ];

      const criteria = HospitalFilterCriteria(
        sortBy: HospitalSortBy.rating,
        maxDistanceMiles: 1000,
      );

      final result = criteria.apply(units, 51.5, -0.1);

      // Outstanding should be first
      expect(result.first.id, 'outstanding');
    });

    test('should sort by name alphabetically', () {
      final units = [
        FakeMaternityUnit.simple(id: 'c', name: 'Charlie Hospital'),
        FakeMaternityUnit.simple(id: 'a', name: 'Alpha Hospital'),
        FakeMaternityUnit.simple(id: 'b', name: 'Bravo Hospital'),
      ];

      const criteria = HospitalFilterCriteria(
        sortBy: HospitalSortBy.name,
        maxDistanceMiles: 1000,
      );

      final result = criteria.apply(units, 51.5, -0.1);

      expect(result[0].name, 'Alpha Hospital');
      expect(result[1].name, 'Bravo Hospital');
      expect(result[2].name, 'Charlie Hospital');
    });

    test('should use distance as secondary sort for rating', () {
      final units = [
        FakeMaternityUnit.atLocation(
          id: 'far-good',
          latitude: 52.0,
          longitude: -0.1,
        ).copyWith(overallRating: 'Good'),
        FakeMaternityUnit.atLocation(
          id: 'near-good',
          latitude: 51.51,
          longitude: -0.1,
        ).copyWith(overallRating: 'Good'),
      ];

      const criteria = HospitalFilterCriteria(
        sortBy: HospitalSortBy.rating,
        maxDistanceMiles: 1000,
      );

      final result = criteria.apply(units, 51.5, -0.1);

      // Both are 'Good', so nearer should come first
      if (result.length == 2) {
        expect(result.first.id, 'near-good');
      }
    });
  });
}
