@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_timer_onboarding_provider.dart';

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[ContractionTimerOnboardingNotifier]', () {
    late ContractionTimerOnboardingNotifier notifier;

    setUp(() async {
      // Initialize SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
      notifier = ContractionTimerOnboardingNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should load onboarding status (initially null, then false)', () async {
      // Initially null while loading
      expect(notifier.state, isNull);

      // Wait for load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Should be false when no value is stored
      expect(notifier.state, false);
    });

    test('setHasStarted() should mark onboarding complete', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.state, false);

      // Act
      await notifier.setHasStarted();

      // Assert
      expect(notifier.state, true);
    });

    test('should persist onboarding status across instances', () async {
      // Arrange - set has started
      await notifier.setHasStarted();
      expect(notifier.state, true);

      // Create new instance to test persistence
      final notifier2 = ContractionTimerOnboardingNotifier();

      // Wait for load
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - should load true from storage
      expect(notifier2.state, true);

      notifier2.dispose();
    });
  });
}

