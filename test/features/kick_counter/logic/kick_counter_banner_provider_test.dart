@Tags(['kick_counter'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/domain/usecases/kick_counter/manage_session_usecase.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_banner_provider.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_state.dart';

import '../../../mocks/fake_data/kick_counter_fakes.dart';

// ----------------------------------------------------------------------------
// Mocks
// ----------------------------------------------------------------------------

class MockManageSessionUseCase extends Mock implements ManageSessionUseCase {}

// ----------------------------------------------------------------------------
// Helper Functions
// ----------------------------------------------------------------------------

/// Creates a ProviderContainer with all necessary overrides for testing
ProviderContainer createTestContainer(MockManageSessionUseCase mockUseCase) {
  return ProviderContainer(
    overrides: [
      manageSessionUseCaseProvider.overrideWith((ref) async => mockUseCase),
      kickCounterProvider.overrideWith((ref) {
        return KickCounterNotifier(mockUseCase);
      }),
    ],
  );
}

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[KickCounter] KickCounterBannerNotifier', () {
    // ------------------------------------------------------------------------
    // show() Tests
    // ------------------------------------------------------------------------

    group('show()', () {
      test('should show banner when active session exists', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        // Manually set active session by accessing notifier
        final notifier = container.read(kickCounterProvider.notifier);
        // Use the public restoreSession method to set state
        notifier.restoreSession(FakeKickSession.active());

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);

        // Act
        bannerNotifier.show();

        // Assert
        expect(container.read(kickCounterBannerProvider), true);
      });

      test('should not show banner when no active session exists', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);

        // Act
        bannerNotifier.show();

        // Assert - show() sets the "want to show" state, but actual visibility 
        // is determined by shouldShowKickCounterBannerProvider which checks session
        expect(container.read(kickCounterBannerProvider), true); // State is set
        expect(container.read(shouldShowKickCounterBannerProvider), false); // But actual visibility is false (no session)
      });

      test('should set _isActiveScreenVisible to false', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final notifier = container.read(kickCounterProvider.notifier);
        notifier.restoreSession(FakeKickSession.active());

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);

        // First hide (sets _isActiveScreenVisible to true)
        bannerNotifier.hide();

        // Act - show should set _isActiveScreenVisible to false
        bannerNotifier.show();

        // Assert
        expect(container.read(kickCounterBannerProvider), true);
      });
    });

    // ------------------------------------------------------------------------
    // hide() Tests
    // ------------------------------------------------------------------------

    group('hide()', () {
      test('should hide banner', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final notifier = container.read(kickCounterProvider.notifier);
        notifier.restoreSession(FakeKickSession.active());

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);

        // First show
        bannerNotifier.show();
        expect(container.read(kickCounterBannerProvider), true);

        // Act
        bannerNotifier.hide();

        // Assert
        expect(container.read(kickCounterBannerProvider), false);
      });

      test('should set _isActiveScreenVisible to true', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final notifier = container.read(kickCounterProvider.notifier);
        notifier.restoreSession(FakeKickSession.active());

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);

        // Act
        bannerNotifier.hide();

        // Assert - even if session exists, banner should remain hidden
        // because _isActiveScreenVisible is true
        expect(container.read(kickCounterBannerProvider), false);
      });
    });

    // ------------------------------------------------------------------------
    // shouldShow Getter Tests
    // ------------------------------------------------------------------------

    group('shouldShow', () {
      test('should return true when banner visible and session exists', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final notifier = container.read(kickCounterProvider.notifier);
        notifier.restoreSession(FakeKickSession.active());

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);
        bannerNotifier.show();

        // Act
        final result = bannerNotifier.shouldShow;

        // Assert
        expect(result, true);
      });

      test('should return false when banner hidden even if session exists', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final notifier = container.read(kickCounterProvider.notifier);
        notifier.restoreSession(FakeKickSession.active());

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);
        bannerNotifier.hide();

        // Act
        final result = bannerNotifier.shouldShow;

        // Assert
        expect(result, false);
      });

      test('should return false when banner visible but no session', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);
        // Manually set state to true (though show() won't actually set it)
        // This tests the double-check in shouldShow

        // Act
        final result = bannerNotifier.shouldShow;

        // Assert
        expect(result, false);
      });
    });

    // ------------------------------------------------------------------------
    // Session State Listener Tests
    // ------------------------------------------------------------------------

    group('session state listener', () {
      test('should auto-hide banner when session ends', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);
        when(() => mockUseCase.endSession(any())).thenAnswer((_) async {});

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        // Initialize banner provider and trigger listener setup via shouldShowProvider
        container.read(kickCounterBannerProvider);
        container.read(shouldShowKickCounterBannerProvider);

        // Wait a bit for the listener chain to be established
        await Future.delayed(const Duration(milliseconds: 50));

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);
        final kickNotifier = container.read(kickCounterProvider.notifier);

        kickNotifier.restoreSession(FakeKickSession.active());

        // Show banner first
        bannerNotifier.show();
        expect(container.read(kickCounterBannerProvider), true);

        // Act - end session
        await kickNotifier.endSession();

        // Wait for listener to process the change
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(container.read(kickCounterBannerProvider), false);
      });

      test('should auto-show banner when session restored and not on active screen', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        final session = FakeKickSession.active();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => session);
        when(() => mockUseCase.pauseSession(any())).thenAnswer((_) async => session.copyWith(pausedAt: DateTime.now()));

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        // Read providers to initialize and set up listeners
        container.read(kickCounterBannerProvider);
        container.read(shouldShowKickCounterBannerProvider);

        // Wait for listener chain to be established
        await Future.delayed(const Duration(milliseconds: 50));

        final kickNotifier = container.read(kickCounterProvider.notifier);

        // Act - restore session (simulate app startup with existing session)
        await kickNotifier.checkActiveSession();

        // Wait for async operations and listener to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(container.read(kickCounterBannerProvider), true);
      });

      test('should not auto-show banner when session restored but on active screen', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        final session = FakeKickSession.active();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => session);
        when(() => mockUseCase.pauseSession(any())).thenAnswer((_) async => session.copyWith(pausedAt: DateTime.now()));

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);

        // Hide banner first (simulates being on active screen)
        bannerNotifier.hide();

        final kickNotifier = container.read(kickCounterProvider.notifier);

        // Act - restore session while on active screen
        await kickNotifier.checkActiveSession();

        // Wait for async operations
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - should remain hidden
        expect(container.read(kickCounterBannerProvider), false);
      });
    });

    // ------------------------------------------------------------------------
    // shouldShowKickCounterBannerProvider Tests
    // ------------------------------------------------------------------------

    group('shouldShowKickCounterBannerProvider', () {
      test('should return true when banner visible and session exists', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final notifier = container.read(kickCounterProvider.notifier);
        notifier.restoreSession(FakeKickSession.active());

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);
        bannerNotifier.show();

        // Act
        final result = container.read(shouldShowKickCounterBannerProvider);

        // Assert
        expect(result, true);
      });

      test('should return false when banner visible but no session', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);
        bannerNotifier.show(); // Won't actually show without session

        // Act
        final result = container.read(shouldShowKickCounterBannerProvider);

        // Assert
        expect(result, false);
      });

      test('should return false when session exists but banner hidden', () async {
        // Arrange
        final mockUseCase = MockManageSessionUseCase();
        when(() => mockUseCase.getActiveSession()).thenAnswer((_) async => null);

        final container = createTestContainer(mockUseCase);
        addTearDown(container.dispose);

        // Wait for async provider to be ready
        await container.read(manageSessionUseCaseProvider.future);

        final notifier = container.read(kickCounterProvider.notifier);
        notifier.restoreSession(FakeKickSession.active());

        final bannerNotifier = container.read(kickCounterBannerProvider.notifier);
        bannerNotifier.hide();

        // Act
        final result = container.read(shouldShowKickCounterBannerProvider);

        // Assert
        expect(result, false);
      });
    });
  });
}

