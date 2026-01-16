@Tags(['onboarding'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:zeyra/domain/entities/onboarding/onboarding_data.dart';
import 'package:zeyra/features/onboarding/logic/onboarding_notifier.dart';
import 'package:zeyra/features/onboarding/logic/onboarding_state.dart';
import '../../../mocks/fake_data/onboarding_fakes.dart';

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(OnboardingData.empty());
  });

  group('[Onboarding] OnboardingNotifier', () {
    late MockOnboardingLocalDataSource mockDataSource;
    late MockPaymentService mockPaymentService;
    late MockNotificationPermissionService mockNotificationService;
    late MockLoggingService mockLogger;
    late OnboardingNotifier notifier;

    setUp(() {
      mockDataSource = MockOnboardingLocalDataSource();
      mockPaymentService = MockPaymentService();
      mockNotificationService = MockNotificationPermissionService();
      mockLogger = MockLoggingService();

      // Default stub for logging
      when(() => mockLogger.info(any())).thenReturn(null);
      when(() => mockLogger.debug(any())).thenReturn(null);
      when(() => mockLogger.warning(any(), error: any(named: 'error')))
          .thenReturn(null);
      when(() => mockLogger.error(
            any(),
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          )).thenReturn(null);

      // Default stub for data source
      when(() => mockDataSource.getOnboardingData()).thenReturn(null);
      when(() => mockDataSource.saveOnboardingData(any()))
          .thenAnswer((_) async {});
      when(() => mockDataSource.clearOnboardingData())
          .thenAnswer((_) async {});
    });

    OnboardingNotifier createNotifier() {
      return OnboardingNotifier(
        localDataSource: mockDataSource,
        paymentService: mockPaymentService,
        notificationService: mockNotificationService,
        logger: mockLogger,
      );
    }

    // -------------------------------------------------------------------------
    // Initialization Tests
    // -------------------------------------------------------------------------
    group('Initialization', () {
      test('should load saved progress on creation', () {
        final savedData = FakeOnboardingData.partial(
          firstName: 'Jane',
          currentStep: 3,
        );
        when(() => mockDataSource.getOnboardingData()).thenReturn(savedData);

        notifier = createNotifier();

        expect(notifier.state.data.firstName, equals('Jane'));
        expect(notifier.state.currentStep, equals(3));
      });

      test('should start with empty state when no saved data', () {
        when(() => mockDataSource.getOnboardingData()).thenReturn(null);

        notifier = createNotifier();

        expect(notifier.state.data.firstName, isNull);
        expect(notifier.state.currentStep, equals(0));
      });

      test('should handle load error gracefully', () {
        when(() => mockDataSource.getOnboardingData())
            .thenThrow(Exception('Load failed'));

        // Should not throw
        notifier = createNotifier();

        expect(notifier.state.data.firstName, isNull);
      });
    });

    // -------------------------------------------------------------------------
    // Step Navigation Tests
    // -------------------------------------------------------------------------
    group('Step Navigation', () {
      setUp(() {
        notifier = createNotifier();
      });

      test('should increment step on nextStep', () async {
        expect(notifier.state.currentStep, equals(0));

        await notifier.nextStep();

        expect(notifier.state.currentStep, equals(1));
      });

      test('should not exceed max step', () async {
        // Go to last step
        for (int i = 0; i < OnboardingState.totalSteps; i++) {
          await notifier.nextStep();
        }

        expect(notifier.state.currentStep, equals(10));

        // Try to go further
        await notifier.nextStep();

        expect(notifier.state.currentStep, equals(10));
      });

      test('should decrement step on previousStep', () async {
        await notifier.nextStep();
        await notifier.nextStep();
        expect(notifier.state.currentStep, equals(2));

        await notifier.previousStep();

        expect(notifier.state.currentStep, equals(1));
      });

      test('should not go below step 0', () async {
        expect(notifier.state.currentStep, equals(0));

        await notifier.previousStep();

        expect(notifier.state.currentStep, equals(0));
      });

      test('should go to specific step', () async {
        await notifier.goToStep(5);

        expect(notifier.state.currentStep, equals(5));
      });

      test('should save progress after step change', () async {
        await notifier.nextStep();

        verify(() => mockDataSource.saveOnboardingData(any())).called(1);
      });

      test('should ignore invalid step values', () async {
        await notifier.goToStep(-1);
        expect(notifier.state.currentStep, equals(0));

        await notifier.goToStep(100);
        expect(notifier.state.currentStep, equals(0));
      });
    });

    // -------------------------------------------------------------------------
    // Data Updates Tests
    // -------------------------------------------------------------------------
    group('Data Updates', () {
      setUp(() {
        notifier = createNotifier();
      });

      test('should update name', () async {
        await notifier.updateName('Jane');

        expect(notifier.state.data.firstName, equals('Jane'));
        verify(() => mockDataSource.saveOnboardingData(any())).called(1);
      });

      test('should trim name whitespace', () async {
        await notifier.updateName('  Jane  ');

        expect(notifier.state.data.firstName, equals('Jane'));
      });

      test('should update due date and calculate LMP', () async {
        final dueDate = DateTime(2026, 7, 15);

        await notifier.updateDueDate(dueDate);

        expect(notifier.state.data.dueDate, equals(dueDate));
        expect(notifier.state.data.startDate, isNotNull);
        // LMP should be 280 days before due date
        expect(
          notifier.state.data.startDate,
          equals(DateTime(2025, 10, 8)),
        );
      });

      test('should update LMP and calculate due date', () async {
        final lmp = DateTime(2025, 10, 8);

        await notifier.updateLMP(lmp);

        expect(notifier.state.data.startDate, equals(lmp));
        expect(notifier.state.data.dueDate, isNotNull);
        // Due date should be 280 days after LMP
        expect(
          notifier.state.data.dueDate,
          equals(DateTime(2026, 7, 15)),
        );
      });

      test('should update birth date', () async {
        final birthDate = DateTime(1990, 5, 20);

        await notifier.updateBirthDate(birthDate);

        expect(notifier.state.data.dateOfBirth, equals(birthDate));
        verify(() => mockDataSource.saveOnboardingData(any())).called(1);
      });
    });

    // -------------------------------------------------------------------------
    // Notification Permission Tests
    // -------------------------------------------------------------------------
    group('Notification Permission', () {
      setUp(() {
        notifier = createNotifier();
      });

      test('should return true when permission granted', () async {
        when(() => mockNotificationService.requestPermission())
            .thenAnswer((_) async => true);

        final result = await notifier.requestNotificationPermission();

        expect(result, isTrue);
        expect(notifier.state.data.notificationsEnabled, isTrue);
      });

      test('should return false when permission denied', () async {
        when(() => mockNotificationService.requestPermission())
            .thenAnswer((_) async => false);

        final result = await notifier.requestNotificationPermission();

        expect(result, isFalse);
        expect(notifier.state.data.notificationsEnabled, isFalse);
      });

      test('should handle permission error', () async {
        when(() => mockNotificationService.requestPermission())
            .thenThrow(Exception('Permission error'));

        final result = await notifier.requestNotificationPermission();

        expect(result, isFalse);
        expect(notifier.state.error, isNotNull);
      });

      test('should skip permission and set false', () async {
        await notifier.skipNotificationPermission();

        expect(notifier.state.data.notificationsEnabled, isFalse);
        verify(() => mockDataSource.saveOnboardingData(any())).called(1);
      });
    });

    // -------------------------------------------------------------------------
    // Payment Tests
    // -------------------------------------------------------------------------
    group('Payment', () {
      late MockOfferings mockOfferings;
      late MockPackage mockPackage;

      setUp(() {
        notifier = createNotifier();
        mockOfferings = MockOfferings();
        mockPackage = MockPackage();

        when(() => mockPaymentService.isInitialized).thenReturn(true);
      });

      test('should get offerings successfully', () async {
        when(() => mockPaymentService.getOfferings())
            .thenAnswer((_) async => mockOfferings);

        final offerings = await notifier.getOfferings();

        expect(offerings, equals(mockOfferings));
      });

      test('should handle get offerings error', () async {
        when(() => mockPaymentService.getOfferings())
            .thenThrow(Exception('Network error'));

        final offerings = await notifier.getOfferings();

        expect(offerings, isNull);
        expect(notifier.state.error, isNotNull);
      });

      test('should purchase package successfully', () async {
        final customerInfo = createPremiumCustomerInfo();

        when(() => mockPaymentService.purchase(mockPackage))
            .thenAnswer((_) async => customerInfo);
        when(() => mockPaymentService.hasZeyraEntitlementFromInfo(customerInfo))
            .thenReturn(true);

        final result = await notifier.purchasePackage(mockPackage);

        expect(result, isTrue);
        expect(notifier.state.data.purchaseCompleted, isTrue);
      });

      test('should handle purchase cancellation', () async {
        when(() => mockPaymentService.purchase(mockPackage))
            .thenThrow(PurchasesErrorCode.purchaseCancelledError);

        final result = await notifier.purchasePackage(mockPackage);

        expect(result, isFalse);
        expect(notifier.state.error, contains('cancelled'));
      });

      test('should handle purchase error', () async {
        when(() => mockPaymentService.purchase(mockPackage))
            .thenThrow(Exception('Unknown error'));

        final result = await notifier.purchasePackage(mockPackage);

        expect(result, isFalse);
        expect(notifier.state.error, isNotNull);
      });

      test('should restore purchases successfully', () async {
        final customerInfo = createPremiumCustomerInfo();

        when(() => mockPaymentService.restore())
            .thenAnswer((_) async => customerInfo);
        when(() => mockPaymentService.hasZeyraEntitlementFromInfo(customerInfo))
            .thenReturn(true);

        final result = await notifier.restorePurchases();

        expect(result, isTrue);
        expect(notifier.state.data.purchaseCompleted, isTrue);
      });

      test('should handle no purchases to restore', () async {
        final customerInfo = createNonPremiumCustomerInfo();

        when(() => mockPaymentService.restore())
            .thenAnswer((_) async => customerInfo);
        when(() => mockPaymentService.hasZeyraEntitlementFromInfo(customerInfo))
            .thenReturn(false);

        final result = await notifier.restorePurchases();

        expect(result, isFalse);
        expect(notifier.state.error, contains('No previous purchases'));
      });
    });

    // -------------------------------------------------------------------------
    // Early Auth Flow Tests
    // -------------------------------------------------------------------------
    group('Early Auth Flow', () {
      setUp(() {
        notifier = createNotifier();
      });

      test('should set early auth flow flag', () {
        notifier.setEarlyAuthFlow(true);

        expect(notifier.state.isEarlyAuthFlow, isTrue);
      });

      test('should clear and restart', () async {
        // First set some data
        await notifier.updateName('Jane');
        await notifier.nextStep();

        // Then clear
        await notifier.clearAndRestart();

        expect(notifier.state.data.firstName, isNull);
        expect(notifier.state.currentStep, equals(0));
        verify(() => mockDataSource.clearOnboardingData()).called(1);
      });

      test('should reset to initial state', () async {
        // Set some state
        await notifier.updateName('Jane');
        notifier.setEarlyAuthFlow(true);

        // Reset
        await notifier.clearAndRestart();

        expect(notifier.state.isEarlyAuthFlow, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // Finalization Tests
    // -------------------------------------------------------------------------
    group('Finalization', () {
      test('should return true for canFinalize when complete', () {
        final completeData = FakeOnboardingData.complete();
        when(() => mockDataSource.getOnboardingData()).thenReturn(completeData);

        notifier = createNotifier();

        expect(notifier.canFinalize, isTrue);
      });

      test('should return false for canFinalize when incomplete', () {
        final incompleteData = FakeOnboardingData.partial();
        when(() => mockDataSource.getOnboardingData())
            .thenReturn(incompleteData);

        notifier = createNotifier();

        expect(notifier.canFinalize, isFalse);
      });

      test('should clear after finalization', () async {
        notifier = createNotifier();

        await notifier.clearAfterFinalization();

        verify(() => mockDataSource.clearOnboardingData()).called(1);
      });
    });

    // -------------------------------------------------------------------------
    // Error Handling Tests
    // -------------------------------------------------------------------------
    group('Error Handling', () {
      setUp(() {
        notifier = createNotifier();
      });

      test('should clear error on successful operation', () async {
        // First set an error
        when(() => mockNotificationService.requestPermission())
            .thenThrow(Exception('Error'));
        await notifier.requestNotificationPermission();
        expect(notifier.state.error, isNotNull);

        // Then do successful operation
        await notifier.updateName('Jane');

        expect(notifier.state.error, isNull);
      });

      test('should set loading state during async operations', () async {
        when(() => mockNotificationService.requestPermission())
            .thenAnswer((_) async {
          // Can't easily test loading state mid-operation in this setup
          return true;
        });

        await notifier.requestNotificationPermission();

        // After completion, loading should be false
        expect(notifier.state.isLoading, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // Data Getter Test
    // -------------------------------------------------------------------------
    group('Data Getter', () {
      test('should return current onboarding data', () {
        final savedData = FakeOnboardingData.complete(firstName: 'Jane');
        when(() => mockDataSource.getOnboardingData()).thenReturn(savedData);

        notifier = createNotifier();

        expect(notifier.data.firstName, equals('Jane'));
      });
    });
  });
}
