@Tags(['pregnancy'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/mappers/pregnancy_mapper.dart';

import '../../mocks/fake_data/pregnancy_fakes.dart';

void main() {
  group('[Pregnancy] PregnancyMapper', () {
    test('should map PregnancyDto to Pregnancy domain entity', () {
      // Arrange
      final dto = PregnancyDto(
        id: 'pregnancy-1',
        userId: 'user-123',
        startDateMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        dueDateMillis: DateTime(2024, 10, 8).millisecondsSinceEpoch,
        selectedHospitalId: 'hospital-456',
        createdAtMillis: DateTime(2024, 1, 1, 12, 0).millisecondsSinceEpoch,
        updatedAtMillis: DateTime(2024, 1, 2, 14, 30).millisecondsSinceEpoch,
      );

      // Act
      final domain = PregnancyMapper.toDomain(dto);

      // Assert
      expect(domain.id, equals('pregnancy-1'));
      expect(domain.userId, equals('user-123'));
      expect(domain.startDate, equals(DateTime(2024, 1, 1)));
      expect(domain.dueDate, equals(DateTime(2024, 10, 8)));
      expect(domain.selectedHospitalId, equals('hospital-456'));
      expect(domain.createdAt, equals(DateTime(2024, 1, 1, 12, 0)));
      expect(domain.updatedAt, equals(DateTime(2024, 1, 2, 14, 30)));
    });

    test('should map Pregnancy domain entity to PregnancyDto', () {
      // Arrange
      final domain = FakePregnancy.simple(
        id: 'preg-123',
        userId: 'user-456',
        selectedHospitalId: 'hospital-789',
      );

      // Act
      final dto = PregnancyMapper.toDto(domain);

      // Assert
      expect(dto.id, equals(domain.id));
      expect(dto.userId, equals(domain.userId));
      expect(
        dto.startDateMillis,
        equals(domain.startDate.millisecondsSinceEpoch),
      );
      expect(
        dto.dueDateMillis,
        equals(domain.dueDate.millisecondsSinceEpoch),
      );
      expect(dto.selectedHospitalId, equals(domain.selectedHospitalId));
      expect(
        dto.createdAtMillis,
        equals(domain.createdAt.millisecondsSinceEpoch),
      );
      expect(
        dto.updatedAtMillis,
        equals(domain.updatedAt.millisecondsSinceEpoch),
      );
    });

    test('should handle null selectedHospitalId correctly', () {
      // Arrange - DTO with null hospital
      final dto = PregnancyDto(
        id: 'pregnancy-1',
        userId: 'user-123',
        startDateMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        dueDateMillis: DateTime(2024, 10, 8).millisecondsSinceEpoch,
        selectedHospitalId: null,
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );

      // Act
      final domain = PregnancyMapper.toDomain(dto);

      // Assert
      expect(domain.selectedHospitalId, isNull);

      // Arrange - Domain with null hospital
      final domainWithNull = FakePregnancy.simple(selectedHospitalId: null);

      // Act
      final dtoWithNull = PregnancyMapper.toDto(domainWithNull);

      // Assert
      expect(dtoWithNull.selectedHospitalId, isNull);
    });

    test('should handle DateTime to milliseconds conversion correctly', () {
      // Arrange - specific timestamps with time components
      final startDate = DateTime(2024, 1, 15, 10, 30, 45, 123);
      final dueDate = DateTime(2024, 10, 12, 14, 15, 30, 456);
      final created = DateTime(2024, 1, 15, 11, 0, 0);
      final updated = DateTime(2024, 2, 1, 16, 30, 0);

      final domain = FakePregnancy.simple(
        startDate: startDate,
        dueDate: dueDate,
        createdAt: created,
        updatedAt: updated,
      );

      // Act
      final dto = PregnancyMapper.toDto(domain);

      // Assert - exact millisecond precision
      expect(dto.startDateMillis, equals(startDate.millisecondsSinceEpoch));
      expect(dto.dueDateMillis, equals(dueDate.millisecondsSinceEpoch));
      expect(dto.createdAtMillis, equals(created.millisecondsSinceEpoch));
      expect(dto.updatedAtMillis, equals(updated.millisecondsSinceEpoch));
    });

    test('should handle milliseconds to DateTime conversion correctly', () {
      // Arrange - specific millisecond timestamps
      final startMillis = DateTime(2024, 1, 15, 10, 30, 45, 123).millisecondsSinceEpoch;
      final dueMillis = DateTime(2024, 10, 12, 14, 15, 30, 456).millisecondsSinceEpoch;
      final createdMillis = DateTime(2024, 1, 15, 11, 0, 0).millisecondsSinceEpoch;
      final updatedMillis = DateTime(2024, 2, 1, 16, 30, 0).millisecondsSinceEpoch;

      final dto = PregnancyDto(
        id: 'id',
        userId: 'user',
        startDateMillis: startMillis,
        dueDateMillis: dueMillis,
        selectedHospitalId: null,
        createdAtMillis: createdMillis,
        updatedAtMillis: updatedMillis,
      );

      // Act
      final domain = PregnancyMapper.toDomain(dto);

      // Assert - exact millisecond precision
      expect(domain.startDate.millisecondsSinceEpoch, equals(startMillis));
      expect(domain.dueDate.millisecondsSinceEpoch, equals(dueMillis));
      expect(domain.createdAt.millisecondsSinceEpoch, equals(createdMillis));
      expect(domain.updatedAt.millisecondsSinceEpoch, equals(updatedMillis));
    });

    test('should preserve all data in round-trip conversion (domain -> dto -> domain)', () {
      // Arrange
      final original = FakePregnancy.simple(
        id: 'test-pregnancy',
        userId: 'test-user',
        selectedHospitalId: 'test-hospital',
      );

      // Act - convert to DTO and back to domain
      final dto = PregnancyMapper.toDto(original);
      final roundTrip = PregnancyMapper.toDomain(dto);

      // Assert - all fields match
      expect(roundTrip.id, equals(original.id));
      expect(roundTrip.userId, equals(original.userId));
      expect(
        roundTrip.startDate.millisecondsSinceEpoch,
        equals(original.startDate.millisecondsSinceEpoch),
      );
      expect(
        roundTrip.dueDate.millisecondsSinceEpoch,
        equals(original.dueDate.millisecondsSinceEpoch),
      );
      expect(roundTrip.selectedHospitalId, equals(original.selectedHospitalId));
      expect(
        roundTrip.createdAt.millisecondsSinceEpoch,
        equals(original.createdAt.millisecondsSinceEpoch),
      );
      expect(
        roundTrip.updatedAt.millisecondsSinceEpoch,
        equals(original.updatedAt.millisecondsSinceEpoch),
      );
    });

    test('should handle round-trip with null selectedHospitalId', () {
      // Arrange
      final original = FakePregnancy.simple(selectedHospitalId: null);

      // Act
      final dto = PregnancyMapper.toDto(original);
      final roundTrip = PregnancyMapper.toDomain(dto);

      // Assert
      expect(roundTrip.selectedHospitalId, isNull);
    });

    test('should map pregnancy at different stages correctly', () {
      // First trimester
      final firstTri = FakePregnancy.firstTrimester();
      final firstTriDto = PregnancyMapper.toDto(firstTri);
      final firstTriBack = PregnancyMapper.toDomain(firstTriDto);
      expect(firstTriBack.gestationalWeek, lessThan(14));

      // Second trimester
      final secondTri = FakePregnancy.secondTrimester();
      final secondTriDto = PregnancyMapper.toDto(secondTri);
      final secondTriBack = PregnancyMapper.toDomain(secondTriDto);
      expect(secondTriBack.gestationalWeek, greaterThanOrEqualTo(14));
      expect(secondTriBack.gestationalWeek, lessThan(28));

      // Third trimester
      final thirdTri = FakePregnancy.thirdTrimester();
      final thirdTriDto = PregnancyMapper.toDto(thirdTri);
      final thirdTriBack = PregnancyMapper.toDomain(thirdTriDto);
      expect(thirdTriBack.gestationalWeek, greaterThanOrEqualTo(28));
    });

    test('should handle overdue pregnancy correctly', () {
      // Arrange
      final overdue = FakePregnancy.overdue(daysOverdue: 5);

      // Act
      final dto = PregnancyMapper.toDto(overdue);
      final roundTrip = PregnancyMapper.toDomain(dto);

      // Assert
      expect(roundTrip.isOverdue, isTrue);
      expect(roundTrip.daysRemaining, lessThan(0));
    });

    test('should handle pregnancy with min and max durations', () {
      // Min duration (266 days / 38 weeks)
      final minDuration = FakePregnancy.minDuration();
      final minDto = PregnancyMapper.toDto(minDuration);
      final minBack = PregnancyMapper.toDomain(minDto);
      final minDurationDays = minBack.dueDate.difference(minBack.startDate).inDays;
      expect(minDurationDays, equals(266));

      // Max duration (294 days / 42 weeks)
      final maxDuration = FakePregnancy.maxDuration();
      final maxDto = PregnancyMapper.toDto(maxDuration);
      final maxBack = PregnancyMapper.toDomain(maxDto);
      final maxDurationDays = maxBack.dueDate.difference(maxBack.startDate).inDays;
      expect(maxDurationDays, equals(294));
    });

    test('should preserve computed properties after round-trip', () {
      // Arrange - pregnancy at exactly 20 weeks 3 days
      final domain = FakePregnancy.atWeek(20, days: 3);

      // Act
      final dto = PregnancyMapper.toDto(domain);
      final roundTrip = PregnancyMapper.toDomain(dto);

      // Assert - computed properties work correctly
      expect(roundTrip.gestationalWeek, equals(domain.gestationalWeek));
      expect(roundTrip.gestationalDaysInWeek, equals(domain.gestationalDaysInWeek));
      expect(roundTrip.gestationalAgeFormatted, equals(domain.gestationalAgeFormatted));
      expect(roundTrip.isOverdue, equals(domain.isOverdue));
      // Note: daysRemaining might differ by 1 due to time passing during test
      expect(
        (roundTrip.daysRemaining - domain.daysRemaining).abs(),
        lessThanOrEqualTo(1),
      );
    });

    test('should handle standard 280-day pregnancy duration', () {
      // Arrange - create pregnancy with exactly 280 days duration
      final startDate = DateTime(2024, 1, 1);
      final dueDate = startDate.add(const Duration(days: 280));
      final domain = FakePregnancy.simple(
        startDate: startDate,
        dueDate: dueDate,
      );

      // Act
      final dto = PregnancyMapper.toDto(domain);
      final roundTrip = PregnancyMapper.toDomain(dto);

      // Assert
      final duration = roundTrip.dueDate.difference(roundTrip.startDate).inDays;
      expect(duration, equals(280));
    });
  });
}
