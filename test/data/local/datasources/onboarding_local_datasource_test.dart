@Tags(['onboarding'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeyra/data/local/datasources/onboarding_local_datasource.dart';
import 'package:zeyra/domain/entities/onboarding/onboarding_data.dart';

void main() {
  group('[Onboarding] OnboardingLocalDataSource', () {
    late SharedPreferences prefs;
    late OnboardingLocalDataSource dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = OnboardingLocalDataSource(prefs);
    });

    // -------------------------------------------------------------------------
    // Save Data Tests
    // -------------------------------------------------------------------------
    group('Save Data', () {
      test('should save firstName to SharedPreferences', () async {
        final data = const OnboardingData(firstName: 'Jane');
        await dataSource.saveOnboardingData(data);

        expect(prefs.getString('onboarding_first_name'), equals('Jane'));
      });

      test('should save dates as ISO8601 strings', () async {
        final dueDate = DateTime(2026, 7, 15);
        final startDate = DateTime(2025, 10, 8);
        final dateOfBirth = DateTime(1990, 5, 20);

        final data = OnboardingData(
          dueDate: dueDate,
          startDate: startDate,
          dateOfBirth: dateOfBirth,
        );
        await dataSource.saveOnboardingData(data);

        expect(
          prefs.getString('onboarding_due_date'),
          equals('2026-07-15T00:00:00.000'),
        );
        expect(
          prefs.getString('onboarding_start_date'),
          equals('2025-10-08T00:00:00.000'),
        );
        expect(
          prefs.getString('onboarding_date_of_birth'),
          equals('1990-05-20T00:00:00.000'),
        );
      });

      test('should save boolean fields', () async {
        const data = OnboardingData(
          notificationsEnabled: true,
          purchaseCompleted: true,
        );
        await dataSource.saveOnboardingData(data);

        expect(prefs.getBool('onboarding_notifications_enabled'), isTrue);
        expect(prefs.getBool('onboarding_purchase_completed'), isTrue);
      });

      test('should save currentStep as int', () async {
        const data = OnboardingData(currentStep: 5);
        await dataSource.saveOnboardingData(data);

        expect(prefs.getInt('onboarding_current_step'), equals(5));
      });

      test('should not overwrite existing data when optional fields are null', () async {
        // First save with name
        const data1 = OnboardingData(firstName: 'Jane', currentStep: 0);
        await dataSource.saveOnboardingData(data1);

        // Second save without name (null)
        const data2 = OnboardingData(firstName: null, currentStep: 1);
        await dataSource.saveOnboardingData(data2);

        // Name should still be there from first save
        expect(prefs.getString('onboarding_first_name'), equals('Jane'));
        expect(prefs.getInt('onboarding_current_step'), equals(1));
      });
    });

    // -------------------------------------------------------------------------
    // Load Data Tests
    // -------------------------------------------------------------------------
    group('Load Data', () {
      test('should return null when no data exists', () {
        final data = dataSource.getOnboardingData();

        expect(data, isNull);
      });

      test('should load all saved fields correctly', () async {
        final dueDate = DateTime(2026, 7, 15);
        final startDate = DateTime(2025, 10, 8);
        final dateOfBirth = DateTime(1990, 5, 20);

        final savedData = OnboardingData(
          firstName: 'Jane',
          dueDate: dueDate,
          startDate: startDate,
          dateOfBirth: dateOfBirth,
          notificationsEnabled: true,
          purchaseCompleted: true,
          currentStep: 5,
        );
        await dataSource.saveOnboardingData(savedData);

        final loadedData = dataSource.getOnboardingData();

        expect(loadedData, isNotNull);
        expect(loadedData!.firstName, equals('Jane'));
        expect(loadedData.dueDate, equals(dueDate));
        expect(loadedData.startDate, equals(startDate));
        expect(loadedData.dateOfBirth, equals(dateOfBirth));
        expect(loadedData.notificationsEnabled, isTrue);
        expect(loadedData.purchaseCompleted, isTrue);
        expect(loadedData.currentStep, equals(5));
      });

      test('should parse ISO8601 dates correctly', () async {
        // Set values directly in SharedPreferences
        await prefs.setString('onboarding_due_date', '2026-07-15T00:00:00.000');
        await prefs.setInt('onboarding_current_step', 3);

        final data = dataSource.getOnboardingData();

        expect(data, isNotNull);
        expect(data!.dueDate, equals(DateTime(2026, 7, 15)));
      });

      test('should handle partial data', () async {
        // Only set some fields
        await prefs.setString('onboarding_first_name', 'Jane');
        await prefs.setInt('onboarding_current_step', 2);

        final data = dataSource.getOnboardingData();

        expect(data, isNotNull);
        expect(data!.firstName, equals('Jane'));
        expect(data.dueDate, isNull);
        expect(data.startDate, isNull);
        expect(data.dateOfBirth, isNull);
        expect(data.notificationsEnabled, isFalse);
        expect(data.purchaseCompleted, isFalse);
        expect(data.currentStep, equals(2));
      });
    });

    // -------------------------------------------------------------------------
    // Pending Check Tests
    // -------------------------------------------------------------------------
    group('Pending Check', () {
      test('should return false when no data exists', () {
        expect(dataSource.hasPendingOnboardingData(), isFalse);
      });

      test('should return true when step exists', () async {
        await prefs.setInt('onboarding_current_step', 0);

        expect(dataSource.hasPendingOnboardingData(), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Step Management Tests
    // -------------------------------------------------------------------------
    group('Step Management', () {
      test('should return 0 when no step saved', () {
        expect(dataSource.getCurrentStep(), equals(0));
      });

      test('should return saved step value', () async {
        await prefs.setInt('onboarding_current_step', 7);

        expect(dataSource.getCurrentStep(), equals(7));
      });

      test('should update step independently', () async {
        // Initial save
        const data = OnboardingData(firstName: 'Jane', currentStep: 0);
        await dataSource.saveOnboardingData(data);

        // Update just the step
        await dataSource.updateCurrentStep(5);

        expect(dataSource.getCurrentStep(), equals(5));
        expect(prefs.getString('onboarding_first_name'), equals('Jane'));
      });
    });

    // -------------------------------------------------------------------------
    // Clear Data Tests
    // -------------------------------------------------------------------------
    group('Clear Data', () {
      test('should remove all onboarding keys', () async {
        // Save full data
        final data = OnboardingData(
          firstName: 'Jane',
          dueDate: DateTime(2026, 7, 15),
          startDate: DateTime(2025, 10, 8),
          dateOfBirth: DateTime(1990, 5, 20),
          notificationsEnabled: true,
          purchaseCompleted: true,
          currentStep: 5,
        );
        await dataSource.saveOnboardingData(data);

        // Clear
        await dataSource.clearOnboardingData();

        // All keys should be gone
        expect(prefs.getString('onboarding_first_name'), isNull);
        expect(prefs.getString('onboarding_due_date'), isNull);
        expect(prefs.getString('onboarding_start_date'), isNull);
        expect(prefs.getString('onboarding_date_of_birth'), isNull);
        expect(prefs.getBool('onboarding_notifications_enabled'), isNull);
        expect(prefs.getBool('onboarding_purchase_completed'), isNull);
        expect(prefs.getInt('onboarding_current_step'), isNull);
      });

      test('should not affect other SharedPreferences keys', () async {
        // Set a non-onboarding key
        await prefs.setString('other_key', 'other_value');

        // Save and clear onboarding data
        const data = OnboardingData(firstName: 'Jane', currentStep: 0);
        await dataSource.saveOnboardingData(data);
        await dataSource.clearOnboardingData();

        // Other key should still exist
        expect(prefs.getString('other_key'), equals('other_value'));
      });

      test('should allow saving after clear', () async {
        // Save, clear, then save again
        const data1 = OnboardingData(firstName: 'Jane', currentStep: 5);
        await dataSource.saveOnboardingData(data1);
        await dataSource.clearOnboardingData();

        const data2 = OnboardingData(firstName: 'Sarah', currentStep: 0);
        await dataSource.saveOnboardingData(data2);

        final loadedData = dataSource.getOnboardingData();
        expect(loadedData!.firstName, equals('Sarah'));
        expect(loadedData.currentStep, equals(0));
      });

      test('should handle clear when no data exists', () async {
        // Should not throw
        await dataSource.clearOnboardingData();

        expect(dataSource.getOnboardingData(), isNull);
      });
    });
  });
}
