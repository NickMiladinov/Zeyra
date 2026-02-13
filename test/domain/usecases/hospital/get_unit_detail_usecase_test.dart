@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/usecases/hospital/get_unit_detail_usecase.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  late MockMaternityUnitRepository mockRepository;
  late GetUnitDetailUseCase useCase;

  setUp(() {
    mockRepository = MockMaternityUnitRepository();
    useCase = GetUnitDetailUseCase(repository: mockRepository);
  });

  group('[HospitalChooser] GetUnitDetailUseCase', () {
    test('should call repository with unit ID', () async {
      // Arrange
      const unitId = 'unit-123';
      final unit = FakeMaternityUnit.simple(id: unitId);

      when(() => mockRepository.getUnitById(unitId))
          .thenAnswer((_) async => unit);

      // Act
      await useCase.execute(unitId);

      // Assert
      verify(() => mockRepository.getUnitById(unitId)).called(1);
    });

    test('should return unit when found', () async {
      // Arrange
      const unitId = 'unit-123';
      final unit = FakeMaternityUnit.simple(
        id: unitId,
        name: 'Test Hospital',
      );

      when(() => mockRepository.getUnitById(unitId))
          .thenAnswer((_) async => unit);

      // Act
      final result = await useCase.execute(unitId);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, unitId);
      expect(result.name, 'Test Hospital');
    });

    test('should return null when unit not found', () async {
      // Arrange
      when(() => mockRepository.getUnitById('non-existent'))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.execute('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getUnitById(any()))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.execute('unit-123'),
        throwsA(isA<Exception>()),
      );
    });

    test('should return unit with all details', () async {
      // Arrange
      final unit = FakeMaternityUnit.simple(
        id: 'detailed-unit',
        name: 'Royal Hospital',
        overallRating: 'Outstanding',
        latitude: 51.5074,
        longitude: -0.1278,
        postcode: 'SW1A 1AA',
      );

      when(() => mockRepository.getUnitById('detailed-unit'))
          .thenAnswer((_) async => unit);

      // Act
      final result = await useCase.execute('detailed-unit');

      // Assert
      expect(result, isNotNull);
      expect(result!.name, 'Royal Hospital');
      expect(result.overallRating, 'Outstanding');
      expect(result.latitude, 51.5074);
      expect(result.postcode, 'SW1A 1AA');
    });
  });
}
