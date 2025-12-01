@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_onboarding_provider.dart';

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[KickCounter] KickCounterOnboardingNotifier', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    // ------------------------------------------------------------------------
    // Initial State Tests
    // ------------------------------------------------------------------------

    group('initial state', () {
      test('should start as null before loading', () {
        // Arrange & Act
        final notifier = KickCounterOnboardingNotifier();

        // Assert
        expect(notifier.state, isNull);
      });

      test('should load false when key not set', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = KickCounterOnboardingNotifier();

        // Act - wait for async load
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(notifier.state, false);
      });

      test('should load saved value when exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'kick_counter_has_started': true,
        });
        final notifier = KickCounterOnboardingNotifier();

        // Act - wait for async load
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(notifier.state, true);
      });
    });

    // ------------------------------------------------------------------------
    // setHasStarted Tests
    // ------------------------------------------------------------------------

    group('setHasStarted()', () {
      test('should persist true to SharedPreferences', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = KickCounterOnboardingNotifier();

        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 100));
        expect(notifier.state, false);

        // Act
        await notifier.setHasStarted();

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('kick_counter_has_started'), true);
      });

      test('should update state to true', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = KickCounterOnboardingNotifier();

        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 100));
        expect(notifier.state, false);

        // Act
        await notifier.setHasStarted();

        // Assert
        expect(notifier.state, true);
      });

      test('should transition state from null -> false -> true', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = KickCounterOnboardingNotifier();

        // Assert initial state
        expect(notifier.state, isNull);

        // Wait for load
        await Future.delayed(const Duration(milliseconds: 100));
        expect(notifier.state, false);

        // Act
        await notifier.setHasStarted();

        // Assert final state
        expect(notifier.state, true);
      });
    });

    // ------------------------------------------------------------------------
    // Persistence Tests
    // ------------------------------------------------------------------------

    group('persistence', () {
      test('should persist across notifier instances', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier1 = KickCounterOnboardingNotifier();

        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 100));

        // Act - set value
        await notifier1.setHasStarted();
        expect(notifier1.state, true);

        // Create new notifier instance
        final notifier2 = KickCounterOnboardingNotifier();

        // Wait for load
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - new instance should load saved value
        expect(notifier2.state, true);
      });
    });
  });
}

