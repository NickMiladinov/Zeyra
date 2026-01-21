import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zeyra/app/router/auth_notifier.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';
import 'package:zeyra/core/services/notification_permission_service.dart';
import 'package:zeyra/core/services/payment_service.dart';
import 'package:zeyra/data/local/datasources/onboarding_local_datasource.dart';
import 'package:zeyra/domain/entities/onboarding/onboarding_data.dart';
import 'package:zeyra/domain/usecases/pregnancy/create_pregnancy_usecase.dart';
import 'package:zeyra/domain/usecases/user_profile/create_user_profile_usecase.dart';

// ----------------------------------------------------------------------------
// Fake Data Builders
// ----------------------------------------------------------------------------

/// Fake data builders for OnboardingData entities.
class FakeOnboardingData {
  /// Create empty onboarding data.
  static OnboardingData empty() => OnboardingData.empty();

  /// Create complete onboarding data ready for finalization.
  static OnboardingData complete({
    String? firstName,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? dateOfBirth,
    bool? notificationsEnabled,
    int? currentStep,
  }) {
    final effectiveDueDate = dueDate ?? DateTime(2026, 7, 15);
    final effectiveStartDate = startDate ?? 
        OnboardingData.calculateLMPFromDueDate(effectiveDueDate);
    
    return OnboardingData(
      firstName: firstName ?? 'Jane',
      dueDate: effectiveDueDate,
      startDate: effectiveStartDate,
      dateOfBirth: dateOfBirth ?? DateTime(1990, 5, 20),
      notificationsEnabled: notificationsEnabled ?? true,
      purchaseCompleted: true,
      currentStep: currentStep ?? 10,
    );
  }

  /// Create partial onboarding data (name and step only).
  static OnboardingData partial({
    String? firstName,
    int? currentStep,
  }) {
    return OnboardingData(
      firstName: firstName ?? 'Jane',
      dueDate: null,
      startDate: null,
      dateOfBirth: null,
      notificationsEnabled: false,
      purchaseCompleted: false,
      currentStep: currentStep ?? 2,
    );
  }

  /// Create onboarding data with due date (auto-calculates LMP).
  static OnboardingData withDueDate({
    required DateTime dueDate,
    String? firstName,
    int? currentStep,
  }) {
    return OnboardingData(
      firstName: firstName ?? 'Jane',
      dueDate: dueDate,
      startDate: OnboardingData.calculateLMPFromDueDate(dueDate),
      dateOfBirth: null,
      notificationsEnabled: false,
      purchaseCompleted: false,
      currentStep: currentStep ?? 3,
    );
  }

  /// Create onboarding data with LMP (auto-calculates due date).
  static OnboardingData withLMP({
    required DateTime lmp,
    String? firstName,
    int? currentStep,
  }) {
    return OnboardingData(
      firstName: firstName ?? 'Jane',
      dueDate: OnboardingData.calculateDueDateFromLMP(lmp),
      startDate: lmp,
      dateOfBirth: null,
      notificationsEnabled: false,
      purchaseCompleted: false,
      currentStep: currentStep ?? 3,
    );
  }

  /// Create onboarding data at a specific step.
  static OnboardingData atStep(int step) {
    return OnboardingData(
      firstName: step >= 2 ? 'Jane' : null,
      dueDate: step >= 3 ? DateTime(2026, 7, 15) : null,
      startDate: step >= 3 
          ? OnboardingData.calculateLMPFromDueDate(DateTime(2026, 7, 15)) 
          : null,
      dateOfBirth: step >= 8 ? DateTime(1990, 5, 20) : null,
      notificationsEnabled: step >= 9,
      purchaseCompleted: step >= 10,
      currentStep: step,
    );
  }
}

// ----------------------------------------------------------------------------
// Mocks (Mocktail)
// ----------------------------------------------------------------------------

/// Mock implementation of PaymentService for testing.
class MockPaymentService extends Mock implements PaymentService {}

/// Mock implementation of NotificationPermissionService for testing.
class MockNotificationPermissionService extends Mock 
    implements NotificationPermissionService {}

/// Mock implementation of OnboardingLocalDataSource for testing.
class MockOnboardingLocalDataSource extends Mock 
    implements OnboardingLocalDataSource {}

/// Mock implementation of AuthNotifier for testing.
class MockAuthNotifier extends Mock implements AuthNotifier {}

/// Mock implementation of LoggingService for testing.
class MockLoggingService extends Mock implements LoggingService {}

/// Mock implementation of CreateUserProfileUseCase for testing.
class MockCreateUserProfileUseCase extends Mock 
    implements CreateUserProfileUseCase {}

/// Mock implementation of CreatePregnancyUseCase for testing.
class MockCreatePregnancyUseCase extends Mock 
    implements CreatePregnancyUseCase {}

/// Mock implementation of Offerings for testing.
class MockOfferings extends Mock implements Offerings {}

/// Mock implementation of Offering for testing.
class MockOffering extends Mock implements Offering {}

/// Mock implementation of Package for testing.
class MockPackage extends Mock implements Package {}

/// Mock implementation of CustomerInfo for testing.
class MockCustomerInfo extends Mock implements CustomerInfo {}

/// Mock implementation of EntitlementInfos for testing.
class MockEntitlementInfos extends Mock implements EntitlementInfos {}

/// Mock implementation of EntitlementInfo for testing.
class MockEntitlementInfo extends Mock implements EntitlementInfo {}

// ----------------------------------------------------------------------------
// Test Helpers
// ----------------------------------------------------------------------------

/// Sets up SharedPreferences with test values for onboarding tests.
Future<SharedPreferences> setupTestSharedPreferences({
  String? firstName,
  DateTime? dueDate,
  DateTime? startDate,
  DateTime? dateOfBirth,
  bool? notificationsEnabled,
  bool? purchaseCompleted,
  int? currentStep,
}) async {
  final values = <String, Object>{};
  
  if (firstName != null) {
    values['onboarding_first_name'] = firstName;
  }
  if (dueDate != null) {
    values['onboarding_due_date'] = dueDate.toIso8601String();
  }
  if (startDate != null) {
    values['onboarding_start_date'] = startDate.toIso8601String();
  }
  if (dateOfBirth != null) {
    values['onboarding_date_of_birth'] = dateOfBirth.toIso8601String();
  }
  if (notificationsEnabled != null) {
    values['onboarding_notifications_enabled'] = notificationsEnabled;
  }
  if (purchaseCompleted != null) {
    values['onboarding_purchase_completed'] = purchaseCompleted;
  }
  if (currentStep != null) {
    values['onboarding_current_step'] = currentStep;
  }
  
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

/// Creates a mock CustomerInfo with Zeyra entitlement.
MockCustomerInfo createPremiumCustomerInfo() {
  final customerInfo = MockCustomerInfo();
  final entitlementInfos = MockEntitlementInfos();
  final entitlementInfo = MockEntitlementInfo();
  
  when(() => customerInfo.entitlements).thenReturn(entitlementInfos);
  when(() => entitlementInfos.active).thenReturn({
    PaymentService.entitlementId: entitlementInfo,
  });
  
  return customerInfo;
}

/// Creates a mock CustomerInfo without premium entitlement.
MockCustomerInfo createNonPremiumCustomerInfo() {
  final customerInfo = MockCustomerInfo();
  final entitlementInfos = MockEntitlementInfos();
  
  when(() => customerInfo.entitlements).thenReturn(entitlementInfos);
  when(() => entitlementInfos.active).thenReturn({});
  
  return customerInfo;
}
