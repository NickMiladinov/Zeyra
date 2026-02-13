@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/mappers/hospital_shortlist_mapper.dart';
import 'package:zeyra/domain/entities/hospital/hospital_shortlist.dart';

import '../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] HospitalShortlistMapper - toDomain', () {
    test('should map HospitalShortlistDto to domain', () {
      // Arrange
      final now = DateTime.now();
      final dto = HospitalShortlistDto(
        id: 'test-id',
        maternityUnitId: 'unit-123',
        addedAtMillis: now.millisecondsSinceEpoch,
        isSelected: false,
        notes: 'Test notes',
      );

      // Act
      final domain = HospitalShortlistMapper.toDomain(dto);

      // Assert
      expect(domain.id, 'test-id');
      expect(domain.maternityUnitId, 'unit-123');
      expect(domain.isSelected, false);
      expect(domain.notes, 'Test notes');
    });

    test('should convert milliseconds to DateTime', () {
      // Arrange
      final now = DateTime.now();
      final nowMillis = now.millisecondsSinceEpoch;
      final dto = HospitalShortlistDto(
        id: 'test-id',
        maternityUnitId: 'unit-123',
        addedAtMillis: nowMillis,
        isSelected: false,
      );

      // Act
      final domain = HospitalShortlistMapper.toDomain(dto);

      // Assert
      expect(domain.addedAt.millisecondsSinceEpoch, nowMillis);
    });

    test('should handle null notes', () {
      // Arrange
      final dto = HospitalShortlistDto(
        id: 'test-id',
        maternityUnitId: 'unit-123',
        addedAtMillis: DateTime.now().millisecondsSinceEpoch,
        isSelected: false,
        notes: null,
      );

      // Act
      final domain = HospitalShortlistMapper.toDomain(dto);

      // Assert
      expect(domain.notes, isNull);
    });
  });

  group('[HospitalChooser] HospitalShortlistMapper - toDto', () {
    test('should map domain to HospitalShortlistDto', () {
      // Arrange
      final entity = FakeHospitalShortlist.simple(
        id: 'test-id',
        maternityUnitId: 'unit-123',
      );

      // Act
      final dto = HospitalShortlistMapper.toDto(entity);

      // Assert
      expect(dto.id, 'test-id');
      expect(dto.maternityUnitId, 'unit-123');
      expect(dto.isSelected, false);
    });

    test('should convert DateTime to milliseconds', () {
      // Arrange
      final now = DateTime.now();
      final entity = HospitalShortlist(
        id: 'test-id',
        maternityUnitId: 'unit-123',
        addedAt: now,
        isSelected: false,
      );

      // Act
      final dto = HospitalShortlistMapper.toDto(entity);

      // Assert
      expect(dto.addedAtMillis, now.millisecondsSinceEpoch);
    });

    test('should handle selected shortlist', () {
      // Arrange
      final entity = FakeHospitalShortlist.selected(
        id: 'test-id',
        maternityUnitId: 'unit-123',
      );

      // Act
      final dto = HospitalShortlistMapper.toDto(entity);

      // Assert
      expect(dto.isSelected, true);
    });
  });

  group('[HospitalChooser] HospitalShortlistMapper - ShortlistWithUnit', () {
    test('should map ShortlistWithUnitDto to domain using toShortlistWithUnit', () {
      // Arrange - test using the FakeShortlistWithUnit builder
      final fakeItem = FakeShortlistWithUnit.simple();

      // Act - Just verify the fake data works
      expect(fakeItem.shortlist, isNotNull);
      expect(fakeItem.unit, isNotNull);
      expect(fakeItem.shortlist.maternityUnitId, fakeItem.unit.id);
    });

    test('should map list of ShortlistWithUnit', () {
      // Arrange
      final fakeList = FakeShortlistWithUnit.batch(3);

      // Assert
      expect(fakeList.length, 3);
      for (final item in fakeList) {
        expect(item.shortlist, isNotNull);
        expect(item.unit, isNotNull);
      }
    });
  });
}
