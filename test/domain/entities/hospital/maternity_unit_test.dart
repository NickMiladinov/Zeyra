@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/hospital/maternity_unit.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] CqcRating Enum', () {
    test('should parse rating from string correctly', () {
      expect(CqcRating.fromString('Outstanding'), CqcRating.outstanding);
      expect(CqcRating.fromString('Good'), CqcRating.good);
      expect(CqcRating.fromString('Requires improvement'), CqcRating.requiresImprovement);
      expect(CqcRating.fromString('Inadequate'), CqcRating.inadequate);
    });

    test('should return notRated for null or unknown string', () {
      expect(CqcRating.fromString(null), CqcRating.notRated);
      expect(CqcRating.fromString('Unknown'), CqcRating.notRated);
      expect(CqcRating.fromString(''), CqcRating.notRated);
    });

    test('should have correct displayName for each rating', () {
      expect(CqcRating.outstanding.displayName, 'Outstanding');
      expect(CqcRating.good.displayName, 'Good');
      expect(CqcRating.requiresImprovement.displayName, 'Requires Improvement');
      expect(CqcRating.inadequate.displayName, 'Inadequate');
      expect(CqcRating.notRated.displayName, 'Not Rated');
    });

    test('should have correct sortValue for rating comparison', () {
      expect(CqcRating.outstanding.sortValue, 4);
      expect(CqcRating.good.sortValue, 3);
      expect(CqcRating.requiresImprovement.sortValue, 2);
      expect(CqcRating.inadequate.sortValue, 1);
      expect(CqcRating.notRated.sortValue, 0);
    });

    test('should handle case-insensitive parsing', () {
      expect(CqcRating.fromString('GOOD'), CqcRating.good);
      expect(CqcRating.fromString('good'), CqcRating.good);
      expect(CqcRating.fromString('GoOd'), CqcRating.good);
    });

    test('should handle "Requires Improvement" with space', () {
      expect(CqcRating.fromString('Requires improvement'), CqcRating.requiresImprovement);
      expect(CqcRating.fromString('requires improvement'), CqcRating.requiresImprovement);
    });
  });

  group('[HospitalChooser] MaternityUnit Creation', () {
    test('should create unit with all required fields', () {
      final unit = FakeMaternityUnit.simple(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
      );

      expect(unit.id, 'test-id');
      expect(unit.cqcLocationId, 'cqc-123');
      expect(unit.name, 'Test Hospital');
      expect(unit.isNhs, true);
      expect(unit.isActive, true);
    });

    test('should handle nullable fields correctly', () {
      final unit = MaternityUnit(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
        unitType: 'nhs_hospital',
        isNhs: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(unit.providerName, isNull);
      expect(unit.odsCode, isNull);
      expect(unit.website, isNull);
      expect(unit.phone, isNull);
      expect(unit.notes, isNull);
    });

    test('should have equality based on id and cqcLocationId', () {
      final unit1 = FakeMaternityUnit.simple(id: 'id-1', cqcLocationId: 'cqc-1');
      final unit2 = FakeMaternityUnit.simple(id: 'id-1', cqcLocationId: 'cqc-1');
      final unit3 = FakeMaternityUnit.simple(id: 'id-2', cqcLocationId: 'cqc-1');

      expect(unit1, equals(unit2));
      expect(unit1, isNot(equals(unit3)));
    });

    test('should generate correct hashCode', () {
      final unit1 = FakeMaternityUnit.simple(id: 'id-1', cqcLocationId: 'cqc-1');
      final unit2 = FakeMaternityUnit.simple(id: 'id-1', cqcLocationId: 'cqc-1');

      expect(unit1.hashCode, equals(unit2.hashCode));
    });
  });

  group('[HospitalChooser] MaternityUnit Computed Properties', () {
    test('should return isValid true when active, registered, and has coordinates', () {
      final unit = FakeMaternityUnit.simple(
        isActive: true,
        registrationStatus: 'Registered',
        latitude: 51.5074,
        longitude: -0.1278,
      );

      expect(unit.isValid, isTrue);
    });

    test('should return isValid false when inactive', () {
      final unit = FakeMaternityUnit.simple(isActive: false);
      expect(unit.isValid, isFalse);
    });

    test('should return isValid false when not registered', () {
      final unit = FakeMaternityUnit.simple(registrationStatus: 'Deregistered');
      expect(unit.isValid, isFalse);
    });

    test('should return isValid false when missing coordinates', () {
      final unit = FakeMaternityUnit.invalid(
        isActive: true,
        registrationStatus: 'Registered',
        latitude: null,
        longitude: null,
      );
      expect(unit.isValid, isFalse);
    });

    test('should return hasAddress true with postcode', () {
      final unit = FakeMaternityUnit.simple(postcode: 'SW1A 1AA');
      expect(unit.hasAddress, isTrue);
    });

    test('should format address correctly', () {
      final unit = FakeMaternityUnit.simple(postcode: 'SW1A 1AA');
      expect(unit.formattedAddress, isNotEmpty);
      expect(unit.formattedAddress, contains('SW1A 1AA'));
    });
  });

  group('[HospitalChooser] MaternityUnit Distance Calculation', () {
    test('should calculate distance using Haversine formula', () {
      // London coordinates
      final unit = FakeMaternityUnit.atLocation(
        latitude: 51.5074,
        longitude: -0.1278,
      );

      // Distance from same location should be 0
      final distance = unit.distanceFrom(51.5074, -0.1278);
      expect(distance, closeTo(0, 0.01));
    });

    test('should return 0 for same coordinates', () {
      final unit = FakeMaternityUnit.atLocation(
        latitude: 51.5,
        longitude: -0.1,
      );

      final distance = unit.distanceFrom(51.5, -0.1);
      expect(distance, closeTo(0, 0.001));
    });

    test('should return null when unit has no coordinates', () {
      final unit = FakeMaternityUnit.invalid(
        latitude: null,
        longitude: null,
      );

      expect(unit.distanceFrom(51.5, -0.1), isNull);
    });

    test('should calculate correct distance London to Leeds', () {
      // London
      final unit = FakeMaternityUnit.atLocation(
        latitude: 51.5074,
        longitude: -0.1278,
      );

      // Leeds coordinates
      final distance = unit.distanceFrom(53.8008, -1.5491);

      // London to Leeds is approximately 170 miles
      expect(distance, greaterThan(150));
      expect(distance, lessThan(190));
    });

    test('should handle negative coordinates', () {
      // Southern hemisphere
      final unit = FakeMaternityUnit.atLocation(
        latitude: -33.8688,
        longitude: 151.2093,
      );

      final distance = unit.distanceFrom(-33.8688, 151.2093);
      expect(distance, closeTo(0, 0.01));
    });

    test('should handle coordinates at 0,0', () {
      final unit = FakeMaternityUnit.atLocation(
        latitude: 0,
        longitude: 0,
      );

      final distance = unit.distanceFrom(0, 0);
      expect(distance, closeTo(0, 0.01));
    });
  });

  group('[HospitalChooser] MaternityUnit Best Available Rating', () {
    test('should use maternity rating when available', () {
      final unit = MaternityUnit(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
        unitType: 'nhs_hospital',
        isNhs: true,
        isActive: true,
        overallRating: 'Good',
        maternityRating: 'Outstanding',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(unit.bestAvailableRating, CqcRating.outstanding);
    });

    test('should fall back to overall rating when no maternity rating', () {
      final unit = FakeMaternityUnit.withRating(rating: 'Good');
      expect(unit.bestAvailableRating, CqcRating.good);
    });
  });
}
