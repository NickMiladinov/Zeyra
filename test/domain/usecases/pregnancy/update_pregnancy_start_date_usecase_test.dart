@Tags(['pregnancy'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/pregnancy/pregnancy.dart';
import 'package:zeyra/domain/exceptions/pregnancy_exception.dart';
import 'package:zeyra/domain/usecases/pregnancy/update_pregnancy_start_date_usecase.dart';

import '../../../mocks/fake_data/pregnancy_fakes.dart';

void main() {
  late MockPregnancyRepository mockRepository;
  late UpdatePregnancyStartDateUseCase useCase;

  setUpAll(() {
    // Register fallback value for Pregnancy entity (required by mocktail)
    registerFallbackValue(FakePregnancy.simple());
  });

  setUp(() {
    mockRepository = MockPregnancyRepository();
    useCase = UpdatePregnancyStartDateUseCase(repository: mockRepository);
  });

  group('[Pregnancy] UpdatePregnancyStartDateUseCase', () {
    test('should auto-calculate due date as startDate + 280 days', () async {
      // Arrange
      final original = FakePregnancy.simple(
        id: 'preg-1',
        startDate: DateTime(2024, 1, 1),
        dueDate: DateTime(2024, 10, 8), // original due date
      );
      final newStartDate = DateTime(2024, 2, 1);
      final expectedDueDate = newStartDate.add(const Duration(days: 280)); // 2024-11-07

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      final result = await useCase.execute('preg-1', newStartDate);

      // Assert
      expect(result.startDate, equals(newStartDate));
      expect(result.dueDate, equals(expectedDueDate));
      expect(result.dueDate.difference(result.startDate).inDays, equals(280));

      verify(() => mockRepository.getPregnancyById('preg-1')).called(1);
      verify(() => mockRepository.updatePregnancy(any(
        that: predicate<Pregnancy>((p) =>
            p.startDate == newStartDate &&
            p.dueDate == expectedDueDate),
      ))).called(1);
    });

    test('should preserve other pregnancy fields when updating start date', () async {
      // Arrange
      final original = FakePregnancy.simple(
        id: 'preg-1',
        userId: 'user-123',
        selectedHospitalId: 'hospital-456',
        startDate: DateTime(2024, 1, 1),
        dueDate: DateTime(2024, 10, 8),
      );
      final newStartDate = DateTime(2024, 2, 1);

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      final result = await useCase.execute('preg-1', newStartDate);

      // Assert
      expect(result.id, equals(original.id));
      expect(result.userId, equals(original.userId));
      expect(result.selectedHospitalId, equals(original.selectedHospitalId));

      verify(() => mockRepository.updatePregnancy(any(
        that: predicate<Pregnancy>((p) =>
            p.id == 'preg-1' &&
            p.userId == 'user-123' &&
            p.selectedHospitalId == 'hospital-456'),
      ))).called(1);
    });

    test('should throw PregnancyException when pregnancy not found', () async {
      // Arrange
      final newStartDate = DateTime(2024, 2, 1);

      when(() => mockRepository.getPregnancyById('non-existent'))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.execute('non-existent', newStartDate),
        throwsA(isA<PregnancyException>().having(
          (e) => e.type,
          'type',
          PregnancyErrorType.notFound,
        )),
      );

      verify(() => mockRepository.getPregnancyById('non-existent')).called(1);
      verifyNever(() => mockRepository.updatePregnancy(any()));
    });

    test('should handle start date at different points in pregnancy', () async {
      // Test various start dates
      final testCases = [
        DateTime(2024, 1, 1),
        DateTime(2024, 6, 15),
        DateTime(2024, 12, 31),
      ];

      for (final startDate in testCases) {
        final original = FakePregnancy.simple(id: 'preg-1');
        final expectedDueDate = startDate.add(const Duration(days: 280));

        when(() => mockRepository.getPregnancyById('preg-1'))
            .thenAnswer((_) async => original);
        when(() => mockRepository.updatePregnancy(any()))
            .thenAnswer((invocation) async {
          final preg = invocation.positionalArguments[0] as Pregnancy;
          return preg;
        });

        // Act
        final result = await useCase.execute('preg-1', startDate);

        // Assert
        expect(result.startDate, equals(startDate));
        expect(result.dueDate, equals(expectedDueDate));
        expect(result.dueDate.difference(result.startDate).inDays, equals(280));
      }
    });

    test('should call repository update with correct pregnancy object', () async {
      // Arrange
      final original = FakePregnancy.simple(id: 'preg-1');
      final newStartDate = DateTime(2024, 3, 15);
      final expectedDueDate = newStartDate.add(const Duration(days: 280));

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      await useCase.execute('preg-1', newStartDate);

      // Assert
      final captured = verify(() => mockRepository.updatePregnancy(captureAny()))
          .captured.single as Pregnancy;
      expect(captured.id, equals('preg-1'));
      expect(captured.startDate, equals(newStartDate));
      expect(captured.dueDate, equals(expectedDueDate));
    });

    test('should handle leap year dates correctly', () async {
      // Arrange - start date in leap year
      final original = FakePregnancy.simple(id: 'preg-1');
      final leapYearStart = DateTime(2024, 2, 29); // Leap day
      final expectedDueDate = leapYearStart.add(const Duration(days: 280));

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      final result = await useCase.execute('preg-1', leapYearStart);

      // Assert
      expect(result.startDate, equals(leapYearStart));
      expect(result.dueDate, equals(expectedDueDate));
      expect(result.dueDate.difference(result.startDate).inDays, equals(280));
    });
  });
}
