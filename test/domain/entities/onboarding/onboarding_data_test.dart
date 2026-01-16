@Tags(['onboarding'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/onboarding/onboarding_data.dart';

void main() {
  group('[Onboarding] OnboardingData Entity', () {
    // -------------------------------------------------------------------------
    // Entity Creation Tests
    // -------------------------------------------------------------------------
    group('Entity Creation', () {
      test('should create OnboardingData with default values', () {
        const data = OnboardingData();

        expect(data.firstName, isNull);
        expect(data.dueDate, isNull);
        expect(data.startDate, isNull);
        expect(data.dateOfBirth, isNull);
        expect(data.notificationsEnabled, isFalse);
        expect(data.purchaseCompleted, isFalse);
        expect(data.currentStep, equals(0));
      });

      test('should create OnboardingData with all fields', () {
        final dueDate = DateTime(2026, 7, 15);
        final startDate = DateTime(2025, 10, 8);
        final dateOfBirth = DateTime(1990, 5, 20);

        final data = OnboardingData(
          firstName: 'Jane',
          dueDate: dueDate,
          startDate: startDate,
          dateOfBirth: dateOfBirth,
          notificationsEnabled: true,
          purchaseCompleted: true,
          currentStep: 5,
        );

        expect(data.firstName, equals('Jane'));
        expect(data.dueDate, equals(dueDate));
        expect(data.startDate, equals(startDate));
        expect(data.dateOfBirth, equals(dateOfBirth));
        expect(data.notificationsEnabled, isTrue);
        expect(data.purchaseCompleted, isTrue);
        expect(data.currentStep, equals(5));
      });

      test('should create empty OnboardingData via factory', () {
        final data = OnboardingData.empty();

        expect(data.firstName, isNull);
        expect(data.dueDate, isNull);
        expect(data.startDate, isNull);
        expect(data.dateOfBirth, isNull);
        expect(data.notificationsEnabled, isFalse);
        expect(data.purchaseCompleted, isFalse);
        expect(data.currentStep, equals(0));
      });

      test('should copy with updated fields', () {
        const original = OnboardingData(
          firstName: 'Jane',
          currentStep: 2,
        );

        final updated = original.copyWith(
          firstName: 'Sarah',
          currentStep: 3,
        );

        expect(updated.firstName, equals('Sarah'));
        expect(updated.currentStep, equals(3));
        // Original unchanged
        expect(original.firstName, equals('Jane'));
        expect(original.currentStep, equals(2));
      });
    });

    // -------------------------------------------------------------------------
    // Date Calculation Tests
    // -------------------------------------------------------------------------
    group('Date Calculations', () {
      test('should calculate due date from LMP correctly', () {
        final lmp = DateTime(2025, 10, 8);
        final dueDate = OnboardingData.calculateDueDateFromLMP(lmp);

        // LMP + 280 days = Due date
        expect(dueDate, equals(DateTime(2026, 7, 15)));
      });

      test('should calculate LMP from due date correctly', () {
        final dueDate = DateTime(2026, 7, 15);
        final lmp = OnboardingData.calculateLMPFromDueDate(dueDate);

        // Due date - 280 days = LMP
        expect(lmp, equals(DateTime(2025, 10, 8)));
      });

      test('should have bidirectional consistency', () {
        final originalLMP = DateTime(2025, 10, 8);

        // LMP → Due date → LMP should return original
        final dueDate = OnboardingData.calculateDueDateFromLMP(originalLMP);
        final calculatedLMP = OnboardingData.calculateLMPFromDueDate(dueDate);

        expect(calculatedLMP, equals(originalLMP));
      });

      test('should use correct pregnancy duration constant', () {
        expect(OnboardingData.pregnancyDurationDays, equals(280));
      });

      test('should handle edge case dates', () {
        // Leap year
        final leapYearLMP = DateTime(2024, 2, 29);
        final leapYearDue = OnboardingData.calculateDueDateFromLMP(leapYearLMP);
        expect(leapYearDue.year, equals(2024));

        // Year boundary
        final decemberLMP = DateTime(2025, 12, 15);
        final nextYearDue = OnboardingData.calculateDueDateFromLMP(decemberLMP);
        expect(nextYearDue.year, equals(2026));
      });
    });

    // -------------------------------------------------------------------------
    // Gestational Age Tests
    // -------------------------------------------------------------------------
    group('Gestational Age Calculation', () {
      test('should return 0 week when startDate is null', () {
        const data = OnboardingData();

        expect(data.gestationalWeek, equals(0));
        expect(data.gestationalDaysInWeek, equals(0));
      });

      test('should return 0 when startDate is in future', () {
        final futureDate = DateTime.now().add(const Duration(days: 30));
        final data = OnboardingData(startDate: futureDate);

        expect(data.gestationalWeek, equals(0));
        expect(data.gestationalDaysInWeek, equals(0));
      });

      test('should calculate gestational week correctly', () {
        // Set LMP to 20 weeks and 3 days ago
        final startDate = DateTime.now().subtract(const Duration(days: 143));
        final data = OnboardingData(startDate: startDate);

        expect(data.gestationalWeek, equals(20));
      });

      test('should calculate days within week correctly', () {
        // Set LMP to 20 weeks and 3 days ago
        final startDate = DateTime.now().subtract(const Duration(days: 143));
        final data = OnboardingData(startDate: startDate);

        expect(data.gestationalDaysInWeek, equals(3));
      });

      test('should format gestational age correctly', () {
        // Set LMP to 20 weeks and 3 days ago
        final startDate = DateTime.now().subtract(const Duration(days: 143));
        final data = OnboardingData(startDate: startDate);

        expect(data.gestationalAgeFormatted, equals('20w 3d'));
      });
    });

    // -------------------------------------------------------------------------
    // Completion Check Tests
    // -------------------------------------------------------------------------
    group('Completion Check', () {
      test('should return false when firstName is null', () {
        final data = OnboardingData(
          firstName: null,
          dueDate: DateTime(2026, 7, 15),
          startDate: DateTime(2025, 10, 8),
          dateOfBirth: DateTime(1990, 5, 20),
          purchaseCompleted: true,
        );

        expect(data.isComplete, isFalse);
      });

      test('should return false when firstName is empty', () {
        final data = OnboardingData(
          firstName: '',
          dueDate: DateTime(2026, 7, 15),
          startDate: DateTime(2025, 10, 8),
          dateOfBirth: DateTime(1990, 5, 20),
          purchaseCompleted: true,
        );

        expect(data.isComplete, isFalse);
      });

      test('should return false when dates are null', () {
        const data = OnboardingData(
          firstName: 'Jane',
          dueDate: null,
          startDate: null,
          dateOfBirth: null,
          purchaseCompleted: true,
        );

        expect(data.isComplete, isFalse);
      });

      test('should return false when purchase not completed', () {
        final data = OnboardingData(
          firstName: 'Jane',
          dueDate: DateTime(2026, 7, 15),
          startDate: DateTime(2025, 10, 8),
          dateOfBirth: DateTime(1990, 5, 20),
          purchaseCompleted: false,
        );

        expect(data.isComplete, isFalse);
      });

      test('should return true when all required data present', () {
        final data = OnboardingData(
          firstName: 'Jane',
          dueDate: DateTime(2026, 7, 15),
          startDate: DateTime(2025, 10, 8),
          dateOfBirth: DateTime(1990, 5, 20),
          purchaseCompleted: true,
        );

        expect(data.isComplete, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Equality Tests
    // -------------------------------------------------------------------------
    group('Equality', () {
      test('should compare equal when all fields match', () {
        final dueDate = DateTime(2026, 7, 15);
        final startDate = DateTime(2025, 10, 8);
        final dateOfBirth = DateTime(1990, 5, 20);

        final data1 = OnboardingData(
          firstName: 'Jane',
          dueDate: dueDate,
          startDate: startDate,
          dateOfBirth: dateOfBirth,
          notificationsEnabled: true,
          purchaseCompleted: true,
          currentStep: 5,
        );

        final data2 = OnboardingData(
          firstName: 'Jane',
          dueDate: dueDate,
          startDate: startDate,
          dateOfBirth: dateOfBirth,
          notificationsEnabled: true,
          purchaseCompleted: true,
          currentStep: 5,
        );

        expect(data1, equals(data2));
      });

      test('should have matching hashCode for equal objects', () {
        final dueDate = DateTime(2026, 7, 15);
        final startDate = DateTime(2025, 10, 8);

        final data1 = OnboardingData(
          firstName: 'Jane',
          dueDate: dueDate,
          startDate: startDate,
        );

        final data2 = OnboardingData(
          firstName: 'Jane',
          dueDate: dueDate,
          startDate: startDate,
        );

        expect(data1.hashCode, equals(data2.hashCode));
      });
    });

    // -------------------------------------------------------------------------
    // toString Tests
    // -------------------------------------------------------------------------
    group('toString', () {
      test('should include firstName in toString', () {
        const data = OnboardingData(firstName: 'Jane');
        final string = data.toString();

        expect(string, contains('Jane'));
      });

      test('should include gestational age in toString', () {
        final startDate = DateTime.now().subtract(const Duration(days: 143));
        final data = OnboardingData(startDate: startDate);
        final string = data.toString();

        expect(string, contains('20w 3d'));
      });

      test('should include step in toString', () {
        const data = OnboardingData(currentStep: 5);
        final string = data.toString();

        expect(string, contains('5'));
      });
    });
  });
}
