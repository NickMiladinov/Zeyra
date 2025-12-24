@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_timer_banner_provider.dart';

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[ContractionTimerBannerNotifier]', () {
    late ProviderContainer container;
    late ContractionTimerBannerNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(contractionTimerBannerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should start hidden (initial state is false)', () {
      expect(notifier.state, false);
      expect(notifier.shouldShow, false);
    });

    test('show() should set isVisible to true', () {
      // Act
      notifier.show();

      // Assert
      expect(notifier.state, true);
      expect(notifier.shouldShow, true);
    });

    test('hide() should set isVisible to false', () {
      // Arrange - first show it
      notifier.show();
      expect(notifier.state, true);

      // Act
      notifier.hide();

      // Assert
      expect(notifier.state, false);
      expect(notifier.shouldShow, false);
    });

    test('show() and hide() should toggle state correctly', () {
      // Initially false
      expect(notifier.state, false);

      // Show
      notifier.show();
      expect(notifier.state, true);

      // Hide
      notifier.hide();
      expect(notifier.state, false);

      // Show again
      notifier.show();
      expect(notifier.state, true);
    });
  });
}

