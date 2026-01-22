@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/mappers/maternity_unit_mapper.dart';
import 'package:zeyra/domain/entities/hospital/maternity_unit.dart';

import '../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] MaternityUnitMapper - toDomain', () {
    test('should map all fields correctly', () {
      // Arrange
      final now = DateTime.now();
      final dto = MaternityUnitDto(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        cqcProviderId: 'prov-123',
        odsCode: 'ODS123',
        name: 'Test Hospital',
        providerName: 'NHS Trust',
        unitType: 'nhs_hospital',
        isNhs: true,
        addressLine1: '123 Main St',
        addressLine2: 'Building A',
        townCity: 'London',
        county: 'Greater London',
        postcode: 'SW1A 1AA',
        region: 'South East',
        localAuthority: 'Westminster',
        latitude: 51.5074,
        longitude: -0.1278,
        phone: '020 1234 5678',
        website: 'https://example.com',
        overallRating: 'Good',
        ratingSafe: 'Good',
        ratingEffective: 'Good',
        ratingCaring: 'Outstanding',
        ratingResponsive: 'Good',
        ratingWellLed: 'Good',
        maternityRating: 'Outstanding',
        maternityRatingDate: '2025-01-01',
        lastInspectionDate: '2025-06-01',
        cqcReportUrl: 'https://cqc.org.uk/report/123',
        registrationStatus: 'Registered',
        birthingOptions: null,
        facilities: null,
        birthStatistics: null,
        notes: 'Test note',
        isActive: true,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
        cqcSyncedAtMillis: now.millisecondsSinceEpoch,
      );

      // Act
      final domain = MaternityUnitMapper.toDomain(dto);

      // Assert
      expect(domain.id, 'test-id');
      expect(domain.cqcLocationId, 'cqc-123');
      expect(domain.cqcProviderId, 'prov-123');
      expect(domain.name, 'Test Hospital');
      expect(domain.unitType, 'nhs_hospital');
      expect(domain.isNhs, true);
      expect(domain.latitude, 51.5074);
      expect(domain.longitude, -0.1278);
      expect(domain.overallRating, 'Good');
      expect(domain.maternityRating, 'Outstanding');
      expect(domain.isActive, true);
    });

    test('should convert milliseconds to DateTime', () {
      // Arrange
      final now = DateTime.now();
      final nowMillis = now.millisecondsSinceEpoch;
      final dto = MaternityUnitDto(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
        unitType: 'nhs_hospital',
        isNhs: true,
        isActive: true,
        createdAtMillis: nowMillis,
        updatedAtMillis: nowMillis,
        cqcSyncedAtMillis: nowMillis,
      );

      // Act
      final domain = MaternityUnitMapper.toDomain(dto);

      // Assert
      expect(domain.createdAt.millisecondsSinceEpoch, nowMillis);
      expect(domain.updatedAt.millisecondsSinceEpoch, nowMillis);
      expect(domain.cqcSyncedAt?.millisecondsSinceEpoch, nowMillis);
    });

    test('should handle null optional fields', () {
      // Arrange
      final now = DateTime.now();
      final dto = MaternityUnitDto(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
        unitType: 'nhs_hospital',
        isNhs: true,
        isActive: true,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
        // All nullable fields are null
        cqcProviderId: null,
        odsCode: null,
        providerName: null,
        latitude: null,
        longitude: null,
        phone: null,
        website: null,
        cqcSyncedAtMillis: null,
      );

      // Act
      final domain = MaternityUnitMapper.toDomain(dto);

      // Assert
      expect(domain.cqcProviderId, isNull);
      expect(domain.odsCode, isNull);
      expect(domain.latitude, isNull);
      expect(domain.longitude, isNull);
      expect(domain.cqcSyncedAt, isNull);
    });

    test('should parse JSON array for birthingOptions', () {
      // Arrange
      final now = DateTime.now();
      final dto = MaternityUnitDto(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
        unitType: 'nhs_hospital',
        isNhs: true,
        isActive: true,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
        birthingOptions: '["water_birth","home_birth"]',
      );

      // Act
      final domain = MaternityUnitMapper.toDomain(dto);

      // Assert
      expect(domain.birthingOptions, isNotNull);
      expect(domain.birthingOptions, contains('water_birth'));
      expect(domain.birthingOptions, contains('home_birth'));
    });

    test('should parse JSON object for facilities', () {
      // Arrange
      final now = DateTime.now();
      final dto = MaternityUnitDto(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
        unitType: 'nhs_hospital',
        isNhs: true,
        isActive: true,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
        facilities: '{"pool":true,"parking":true}',
      );

      // Act
      final domain = MaternityUnitMapper.toDomain(dto);

      // Assert
      expect(domain.facilities, isNotNull);
      expect(domain.facilities!['pool'], true);
      expect(domain.facilities!['parking'], true);
    });

    test('should handle empty/invalid JSON gracefully', () {
      // Arrange
      final now = DateTime.now();
      final dto = MaternityUnitDto(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
        unitType: 'nhs_hospital',
        isNhs: true,
        isActive: true,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
        birthingOptions: 'invalid json',
        facilities: '{}', // Empty object
      );

      // Act
      final domain = MaternityUnitMapper.toDomain(dto);

      // Assert - should not throw, should return null for invalid
      expect(domain.birthingOptions, isNull);
      expect(domain.facilities, isNull); // Empty object returns null
    });
  });

  group('[HospitalChooser] MaternityUnitMapper - toDto', () {
    test('should map all fields correctly', () {
      // Arrange
      final entity = FakeMaternityUnit.simple(
        id: 'test-id',
        cqcLocationId: 'cqc-123',
        name: 'Test Hospital',
      );

      // Act
      final dto = MaternityUnitMapper.toDto(entity);

      // Assert
      expect(dto.id, 'test-id');
      expect(dto.cqcLocationId, 'cqc-123');
      expect(dto.name, 'Test Hospital');
      expect(dto.isNhs, true);
      expect(dto.isActive, true);
    });

    test('should convert DateTime to milliseconds', () {
      // Arrange
      final entity = FakeMaternityUnit.simple();

      // Act
      final dto = MaternityUnitMapper.toDto(entity);

      // Assert
      expect(dto.createdAtMillis, entity.createdAt.millisecondsSinceEpoch);
      expect(dto.updatedAtMillis, entity.updatedAt.millisecondsSinceEpoch);
    });

    test('should handle null optional fields', () {
      // Arrange
      final entity = FakeMaternityUnit.invalid(
        latitude: null,
        longitude: null,
      );

      // Act
      final dto = MaternityUnitMapper.toDto(entity);

      // Assert
      expect(dto.latitude, isNull);
      expect(dto.longitude, isNull);
      expect(dto.cqcSyncedAtMillis, isNull);
    });

    test('should batch convert list of entities', () {
      // Arrange
      final entities = FakeMaternityUnit.batch(5);

      // Act
      final dtos = MaternityUnitMapper.toDtoList(entities);

      // Assert
      expect(dtos.length, 5);
      for (int i = 0; i < 5; i++) {
        expect(dtos[i].id, entities[i].id);
      }
    });

    test('should batch convert list of DTOs', () {
      // Arrange
      final now = DateTime.now();
      final dtos = List.generate(3, (i) => MaternityUnitDto(
        id: 'id-$i',
        cqcLocationId: 'cqc-$i',
        name: 'Hospital $i',
        unitType: 'nhs_hospital',
        isNhs: true,
        isActive: true,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      ));

      // Act
      final entities = MaternityUnitMapper.toDomainList(dtos);

      // Assert
      expect(entities.length, 3);
      for (int i = 0; i < 3; i++) {
        expect(entities[i].id, 'id-$i');
      }
    });
  });
}
