@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/hospital/hospital_filter_criteria.dart';
import 'package:zeyra/domain/entities/hospital/maternity_unit.dart';
import 'package:zeyra/domain/usecases/hospital/filter_units_usecase.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  late MockMaternityUnitRepository mockRepository;
  late FilterUnitsUseCase useCase;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(HospitalFilterCriteria.defaults);
  });

  setUp(() {
    mockRepository = MockMaternityUnitRepository();
    useCase = FilterUnitsUseCase(repository: mockRepository);
  });

  group('[HospitalChooser] FilterUnitsUseCase', () {
    test('should call repository with filter criteria and coordinates', () async {
      // Arrange
      const criteria = HospitalFilterCriteria(maxDistanceMiles: 10.0);
      const userLat = 51.5074;
      const userLng = -0.1278;
      final units = FakeMaternityUnit.batch(3);

      when(() => mockRepository.getFilteredUnits(criteria, userLat, userLng))
          .thenAnswer((_) async => units);

      // Act
      await useCase.execute(
        criteria: criteria,
        userLat: userLat,
        userLng: userLng,
      );

      // Assert
      verify(() => mockRepository.getFilteredUnits(criteria, userLat, userLng))
          .called(1);
    });

    test('should return filtered units from repository', () async {
      // Arrange
      const criteria = HospitalFilterCriteria.defaults;
      final units = FakeMaternityUnit.batch(5);

      when(() => mockRepository.getFilteredUnits(any(), any(), any()))
          .thenAnswer((_) async => units);

      // Act
      final result = await useCase.execute(
        criteria: criteria,
        userLat: 51.5074,
        userLng: -0.1278,
      );

      // Assert
      expect(result, units);
      expect(result.length, 5);
    });

    test('should return empty list when no units match criteria', () async {
      // Arrange
      const criteria = HospitalFilterCriteria(
        maxDistanceMiles: 1.0, // Very small radius
        allowedRatings: {CqcRating.outstanding},
      );

      when(() => mockRepository.getFilteredUnits(any(), any(), any()))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute(
        criteria: criteria,
        userLat: 51.5074,
        userLng: -0.1278,
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getFilteredUnits(any(), any(), any()))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.execute(
          criteria: HospitalFilterCriteria.defaults,
          userLat: 51.5074,
          userLng: -0.1278,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should work with NHS-only filter', () async {
      // Arrange
      const criteria = HospitalFilterCriteria(
        includeNhs: true,
        includeIndependent: false,
      );
      final nhsUnits = [
        FakeMaternityUnit.nhsHospital(id: 'nhs-1'),
        FakeMaternityUnit.nhsHospital(id: 'nhs-2'),
      ];

      when(() => mockRepository.getFilteredUnits(criteria, any(), any()))
          .thenAnswer((_) async => nhsUnits);

      // Act
      final result = await useCase.execute(
        criteria: criteria,
        userLat: 51.5074,
        userLng: -0.1278,
      );

      // Assert
      expect(result.length, 2);
      expect(result.every((u) => u.isNhs), true);
    });

    test('should work with rating filter', () async {
      // Arrange
      const criteria = HospitalFilterCriteria(
        allowedRatings: {CqcRating.outstanding, CqcRating.good},
      );
      final goodUnits = [
        FakeMaternityUnit.withRating(rating: 'Good', id: 'good-1'),
        FakeMaternityUnit.withRating(rating: 'Outstanding', id: 'outstanding-1'),
      ];

      when(() => mockRepository.getFilteredUnits(criteria, any(), any()))
          .thenAnswer((_) async => goodUnits);

      // Act
      final result = await useCase.execute(
        criteria: criteria,
        userLat: 51.5074,
        userLng: -0.1278,
      );

      // Assert
      expect(result.length, 2);
    });

    test('should handle negative coordinates', () async {
      // Arrange
      const criteria = HospitalFilterCriteria.defaults;
      final units = FakeMaternityUnit.batch(2);

      when(() => mockRepository.getFilteredUnits(criteria, -33.8688, 151.2093))
          .thenAnswer((_) async => units);

      // Act
      final result = await useCase.execute(
        criteria: criteria,
        userLat: -33.8688, // Sydney
        userLng: 151.2093,
      );

      // Assert
      expect(result.length, 2);
      verify(() => mockRepository.getFilteredUnits(criteria, -33.8688, 151.2093))
          .called(1);
    });
  });
}
