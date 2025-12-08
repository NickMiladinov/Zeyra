@Tags(['tooltip'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeyra/shared/providers/tooltip_provider.dart';

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[Tooltip] TooltipNotifier', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    // ------------------------------------------------------------------------
    // Initial State Tests
    // ------------------------------------------------------------------------

    group('initial state', () {
      test('should start with isLoaded = false', () {
        // Arrange & Act
        final notifier = TooltipNotifier();

        // Assert
        expect(notifier.state.isLoaded, false);
      });

      test('should load tooltip states from SharedPreferences', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'jit_tooltip_shown_${KickCounterTooltipIds.firstSession}': true,
        });
        final notifier = TooltipNotifier();

        // Act - wait for async load
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(notifier.state.isLoaded, true);
        expect(notifier.hasBeenShown(KickCounterTooltipIds.firstSession), true);
      });

      test('should set isLoaded = true after loading', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = TooltipNotifier();

        // Assert initial state
        expect(notifier.state.isLoaded, false);

        // Act - wait for async load
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert loaded state
        expect(notifier.state.isLoaded, true);
      });

      test('should default all tooltips to not shown', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = TooltipNotifier();

        // Act - wait for async load
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(notifier.hasBeenShown(KickCounterTooltipIds.firstSession), false);
        expect(notifier.hasBeenShown(KickCounterTooltipIds.graphUnlocked), false);
      });
    });

    // ------------------------------------------------------------------------
    // TooltipState.shouldShow Tests
    // ------------------------------------------------------------------------

    group('shouldShow()', () {
      test('should return false when condition is not met', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // Act & Assert
        final result = notifier.state.shouldShow(
          KickCounterTooltipIds.firstSession,
          false, // condition not met
        );
        expect(result, false);
      });

      test('should return false when tooltip has been shown before', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'jit_tooltip_shown_${KickCounterTooltipIds.firstSession}': true,
        });
        final notifier = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // Act & Assert
        final result = notifier.state.shouldShow(
          KickCounterTooltipIds.firstSession,
          true, // condition met
        );
        expect(result, false);
      });

      test('should return true when condition is met and tooltip not shown', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // Act & Assert
        final result = notifier.state.shouldShow(
          KickCounterTooltipIds.firstSession,
          true, // condition met
        );
        expect(result, true);
      });

      test('should return false when state is not loaded', () {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = TooltipNotifier();

        // Don't wait - state not loaded yet
        // Act & Assert
        final result = notifier.state.shouldShow(
          KickCounterTooltipIds.firstSession,
          true, // condition met
        );
        expect(result, false);
      });
    });

    // ------------------------------------------------------------------------
    // dismissTooltip Tests
    // ------------------------------------------------------------------------

    group('dismissTooltip()', () {
      test('should persist true to SharedPreferences', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        await notifier.dismissTooltip(KickCounterTooltipIds.firstSession);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getBool('jit_tooltip_shown_${KickCounterTooltipIds.firstSession}'),
          true,
        );
      });

      test('should update state to mark tooltip as shown', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(notifier.hasBeenShown(KickCounterTooltipIds.firstSession), false);

        // Act
        await notifier.dismissTooltip(KickCounterTooltipIds.firstSession);

        // Assert
        expect(notifier.hasBeenShown(KickCounterTooltipIds.firstSession), true);
      });

      test('should cause shouldShow to return false after dismissal', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify it should show before dismissal
        expect(
          notifier.state.shouldShow(KickCounterTooltipIds.firstSession, true),
          true,
        );

        // Act
        await notifier.dismissTooltip(KickCounterTooltipIds.firstSession);

        // Assert
        expect(
          notifier.state.shouldShow(KickCounterTooltipIds.firstSession, true),
          false,
        );
      });
    });

    // ------------------------------------------------------------------------
    // resetTooltip Tests
    // ------------------------------------------------------------------------

    group('resetTooltip()', () {
      test('should remove tooltip from SharedPreferences', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'jit_tooltip_shown_${KickCounterTooltipIds.firstSession}': true,
        });
        final notifier = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        await notifier.resetTooltip(KickCounterTooltipIds.firstSession);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getBool('jit_tooltip_shown_${KickCounterTooltipIds.firstSession}'),
          isNull,
        );
      });

      test('should update state to mark tooltip as not shown', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'jit_tooltip_shown_${KickCounterTooltipIds.firstSession}': true,
        });
        final notifier = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(notifier.hasBeenShown(KickCounterTooltipIds.firstSession), true);

        // Act
        await notifier.resetTooltip(KickCounterTooltipIds.firstSession);

        // Assert
        expect(notifier.hasBeenShown(KickCounterTooltipIds.firstSession), false);
      });
    });

    // ------------------------------------------------------------------------
    // Persistence Tests
    // ------------------------------------------------------------------------

    group('persistence', () {
      test('should persist across notifier instances', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final notifier1 = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // Act - dismiss tooltip
        await notifier1.dismissTooltip(KickCounterTooltipIds.firstSession);
        expect(notifier1.hasBeenShown(KickCounterTooltipIds.firstSession), true);

        // Create new notifier instance
        final notifier2 = TooltipNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - new instance should load saved value
        expect(notifier2.hasBeenShown(KickCounterTooltipIds.firstSession), true);
      });

      test('should load all known tooltip IDs on startup', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'jit_tooltip_shown_${KickCounterTooltipIds.firstSession}': true,
          'jit_tooltip_shown_${KickCounterTooltipIds.graphUnlocked}': false,
        });
        final notifier = TooltipNotifier();

        // Act - wait for async load
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(notifier.hasBeenShown(KickCounterTooltipIds.firstSession), true);
        expect(notifier.hasBeenShown(KickCounterTooltipIds.graphUnlocked), false);
      });
    });

    // ------------------------------------------------------------------------
    // KickCounterTooltipIds Tests
    // ------------------------------------------------------------------------

    group('KickCounterTooltipIds', () {
      test('should have correct ID values', () {
        expect(
          KickCounterTooltipIds.firstSession,
          'kick_counter_first_session',
        );
        expect(
          KickCounterTooltipIds.graphUnlocked,
          'kick_counter_graph_unlocked',
        );
      });

      test('should include all IDs in the all list', () {
        expect(KickCounterTooltipIds.all, contains(KickCounterTooltipIds.firstSession));
        expect(KickCounterTooltipIds.all, contains(KickCounterTooltipIds.graphUnlocked));
        expect(KickCounterTooltipIds.all.length, 2);
      });
    });
  });

  // --------------------------------------------------------------------------
  // TooltipState Tests
  // --------------------------------------------------------------------------

  group('[Tooltip] TooltipState', () {
    test('should create with default values', () {
      // Arrange & Act
      const state = TooltipState();

      // Assert
      expect(state.shownTooltips, isEmpty);
      expect(state.isLoaded, false);
    });

    test('copyWith should preserve unchanged values', () {
      // Arrange
      final state = TooltipState(
        shownTooltips: {'test': true},
        isLoaded: true,
      );

      // Act
      final newState = state.copyWith();

      // Assert
      expect(newState.shownTooltips, {'test': true});
      expect(newState.isLoaded, true);
    });

    test('copyWith should update specified values', () {
      // Arrange
      const state = TooltipState(
        shownTooltips: {},
        isLoaded: false,
      );

      // Act
      final newState = state.copyWith(
        shownTooltips: {'test': true},
        isLoaded: true,
      );

      // Assert
      expect(newState.shownTooltips, {'test': true});
      expect(newState.isLoaded, true);
    });
  });
}
