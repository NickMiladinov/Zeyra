@Tags(['pregnancy'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/pregnancy/pregnancy.dart';
import 'package:zeyra/domain/exceptions/pregnancy_exception.dart';
import 'package:zeyra/domain/usecases/pregnancy/update_pregnancy_due_date_usecase.dart';

import '../../../mocks/fake_data/pregnancy_fakes.dart';

void main() {
  late MockPregnancyRepository mockRepository;
  late UpdatePregnancyDueDateUseCase useCase;

  setUpAll(() {
    // Register fallback value for Pregnancy entity (required by mocktail)
    registerFallbackValue(FakePregnancy.simple());
  });

  setUp(() {
    mockRepository = MockPregnancyRepository();
    useCase = UpdatePregnancyDueDateUseCase(repository: mockRepository);
  });

  group('[Pregnancy] UpdatePregnancyDueDateUseCase', () {
    test('should auto-calculate start date as dueDate - 280 days', () async {
      // Arrange
      final original = FakePregnancy.simple(
        id: 'preg-1',
        startDate: DateTime(2024, 1, 1),
        dueDate: DateTime(2024, 10, 8),
      );
      final newDueDate = DateTime(2024, 11, 7);
      final expectedStartDate = newDueDate.subtract(const Duration(days: 280)); // 2024-02-01

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      final result = await useCase.execute('preg-1', newDueDate);

      // Assert
      expect(result.dueDate, equals(newDueDate));
      expect(result.startDate, equals(expectedStartDate));
      expect(result.dueDate.difference(result.startDate).inDays, equals(280));

      verify(() => mockRepository.getPregnancyById('preg-1')).called(1);
      verify(() => mockRepository.updatePregnancy(any(
        that: predicate<Pregnancy>((p) =>
            p.dueDate == newDueDate &&
            p.startDate == expectedStartDate),
      ))).called(1);
    });

    test('should preserve other pregnancy fields when updating due date', () async {
      // Arrange
      final original = FakePregnancy.simple(
        id: 'preg-1',
        userId: 'user-123',
        selectedHospitalId: 'hospital-456',
        startDate: DateTime(2024, 1, 1),
        dueDate: DateTime(2024, 10, 8),
      );
      final newDueDate = DateTime(2024, 11, 7);

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      final result = await useCase.execute('preg-1', newDueDate);

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
      final newDueDate = DateTime(2024, 11, 7);

      when(() => mockRepository.getPregnancyById('non-existent'))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.execute('non-existent', newDueDate),
        throwsA(isA<PregnancyException>().having(
          (e) => e.type,
          'type',
          PregnancyErrorType.notFound,
        )),
      );

      verify(() => mockRepository.getPregnancyById('non-existent')).called(1);
      verifyNever(() => mockRepository.updatePregnancy(any()));
    });

    test('should handle due date at different points', () async {
      // Test various due dates
      final testCases = [
        DateTime(2024, 6, 1),
        DateTime(2024, 10, 15),
        DateTime(2025, 1, 31),
      ];

      for (final dueDate in testCases) {
        final original = FakePregnancy.simple(id: 'preg-1');
        final expectedStartDate = dueDate.subtract(const Duration(days: 280));

        when(() => mockRepository.getPregnancyById('preg-1'))
            .thenAnswer((_) async => original);
        when(() => mockRepository.updatePregnancy(any()))
            .thenAnswer((invocation) async {
          final preg = invocation.positionalArguments[0] as Pregnancy;
          return preg;
        });

        // Act
        final result = await useCase.execute('preg-1', dueDate);

        // Assert
        expect(result.dueDate, equals(dueDate));
        expect(result.startDate, equals(expectedStartDate));
        expect(result.dueDate.difference(result.startDate).inDays, equals(280));
      }
    });

    test('should call repository update with correct pregnancy object', () async {
      // Arrange
      final original = FakePregnancy.simple(id: 'preg-1');
      final newDueDate = DateTime(2024, 12, 20);
      final expectedStartDate = newDueDate.subtract(const Duration(days: 280));

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      await useCase.execute('preg-1', newDueDate);

      // Assert
      final captured = verify(() => mockRepository.updatePregnancy(captureAny()))
          .captured.single as Pregnancy;
      expect(captured.id, equals('preg-1'));
      expect(captured.dueDate, equals(newDueDate));
      expect(captured.startDate, equals(expectedStartDate));
    });

    test('should handle leap year dates correctly', () async {
      // Arrange - due date that results in leap day start
      final original = FakePregnancy.simple(id: 'preg-1');
      final dueDate = DateTime(2024, 12, 5); // Results in leap day (Feb 29, 2024) as start
      final expectedStartDate = dueDate.subtract(const Duration(days: 280));

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      final result = await useCase.execute('preg-1', dueDate);

      // Assert
      expect(result.dueDate, equals(dueDate));
      expect(result.startDate, equals(expectedStartDate));
      expect(result.dueDate.difference(result.startDate).inDays, equals(280));
      // Verify leap day handling
      expect(expectedStartDate.month, equals(2));
      expect(expectedStartDate.day, equals(29));
      expect(expectedStartDate.year, equals(2024));
    });

    test('should handle bidirectional date calculation consistency', () async {
      // Test that startDate -> dueDate -> startDate maintains consistency
      final original = FakePregnancy.simple(id: 'preg-1');
      final targetDueDate = DateTime(2024, 10, 15);
      final calculatedStartDate = targetDueDate.subtract(const Duration(days: 280));

      when(() => mockRepository.getPregnancyById('preg-1'))
          .thenAnswer((_) async => original);
      when(() => mockRepository.updatePregnancy(any()))
          .thenAnswer((invocation) async {
        final preg = invocation.positionalArguments[0] as Pregnancy;
        return preg;
      });

      // Act
      final result = await useCase.execute('preg-1', targetDueDate);

      // Assert - verify bidirectional consistency
      final recalculatedDueDate = result.startDate.add(const Duration(days: 280));
      expect(recalculatedDueDate, equals(targetDueDate));
      expect(result.startDate, equals(calculatedStartDate));
    });
  });
}
