@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/usecases/hospital/get_nearby_units_usecase.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  late MockMaternityUnitRepository mockRepository;
  late GetNearbyUnitsUseCase useCase;

  setUp(() {
    mockRepository = MockMaternityUnitRepository();
    useCase = GetNearbyUnitsUseCase(repository: mockRepository);
  });

  group('[HospitalChooser] GetNearbyUnitsUseCase', () {
    test('should call repository with coordinates and default radius', () async {
      // Arrange
      final units = FakeMaternityUnit.batch(5);
      when(() => mockRepository.getNearbyUnits(51.5, -0.1, radiusMiles: 15.0))
          .thenAnswer((_) async => units);

      // Act
      final result = await useCase.execute(lat: 51.5, lng: -0.1);

      // Assert
      expect(result, equals(units));
      verify(() => mockRepository.getNearbyUnits(51.5, -0.1, radiusMiles: 15.0)).called(1);
    });

    test('should call repository with custom radius', () async {
      // Arrange
      when(() => mockRepository.getNearbyUnits(51.5, -0.1, radiusMiles: 25.0))
          .thenAnswer((_) async => []);

      // Act
      await useCase.execute(lat: 51.5, lng: -0.1, radiusMiles: 25.0);

      // Assert
      verify(() => mockRepository.getNearbyUnits(51.5, -0.1, radiusMiles: 25.0)).called(1);
    });

    test('should return units from repository', () async {
      // Arrange
      final units = FakeMaternityUnit.batch(3);
      when(() => mockRepository.getNearbyUnits(any(), any(), radiusMiles: any(named: 'radiusMiles')))
          .thenAnswer((_) async => units);

      // Act
      final result = await useCase.execute(lat: 51.5, lng: -0.1);

      // Assert
      expect(result.length, 3);
    });

    test('should return empty list when no units found', () async {
      // Arrange
      when(() => mockRepository.getNearbyUnits(any(), any(), radiusMiles: any(named: 'radiusMiles')))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute(lat: 51.5, lng: -0.1);

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getNearbyUnits(any(), any(), radiusMiles: any(named: 'radiusMiles')))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.execute(lat: 51.5, lng: -0.1),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle negative coordinates', () async {
      // Arrange - Southern hemisphere
      when(() => mockRepository.getNearbyUnits(-33.8, 151.2, radiusMiles: 15.0))
          .thenAnswer((_) async => []);

      // Act
      await useCase.execute(lat: -33.8, lng: 151.2);

      // Assert
      verify(() => mockRepository.getNearbyUnits(-33.8, 151.2, radiusMiles: 15.0)).called(1);
    });
  });
}
