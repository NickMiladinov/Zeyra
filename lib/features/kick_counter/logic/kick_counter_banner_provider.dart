import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_state.dart';

/// Manages the visibility state of the kick counter floating banner.
/// 
/// The banner should be shown when:
/// - There is an active session, AND
/// - The user has navigated away from the active session screen
/// 
/// The banner should be hidden when:
/// - No active session exists, OR
/// - The user is currently on the active session screen
class KickCounterBannerNotifier extends StateNotifier<bool> {
  final Ref _ref;
  
  /// Tracks whether the active session screen is currently being viewed.
  /// This prevents auto-showing the banner when user starts a new session
  /// from the active session screen.
  bool _isActiveScreenVisible = false;
  
  KickCounterBannerNotifier(this._ref) : super(false) {
    // Wait for dependencies to be ready before listening to kick counter state
    _ref.listen(manageSessionUseCaseProvider, (previous, next) {
      next.whenData((_) {
        // Dependencies are ready, start listening to kick counter state
        try {
          _ref.listen<KickCounterState>(kickCounterProvider, (previous, next) {
            // If session ends, hide banner
            if (next.activeSession == null) {
              state = false;
            }
            // If session is restored on app startup (previous was null, now exists)
            // AND user is NOT viewing the active session screen,
            // automatically show the banner so user can access it
            else if (previous?.activeSession == null &&
                     next.activeSession != null &&
                     !_isActiveScreenVisible) {
              state = true;
            }
          });
        } catch (e) {
          // Ignore errors during initialization - dependencies might not be ready yet
        }
      });
    });
  }

  /// Show the banner (called when user leaves active session screen)
  void show() {
    _isActiveScreenVisible = false;
    // Check if dependencies are ready before accessing kick counter provider
    final useCaseAsync = _ref.read(manageSessionUseCaseProvider);
    useCaseAsync.whenData((_) {
      try {
        final kickState = _ref.read(kickCounterProvider);
        // Only show if there's an active session
        if (kickState.activeSession != null) {
          state = true;
        }
      } catch (e) {
        // Dependencies not ready yet, silently ignore
      }
    });
  }

  /// Hide the banner (called when user enters active session screen)
  void hide() {
    _isActiveScreenVisible = true;
    state = false;
  }

  /// Check if banner should be visible based on session state
  bool get shouldShow {
    // Check if dependencies are ready before accessing kick counter provider
    final useCaseAsync = _ref.read(manageSessionUseCaseProvider);
    return useCaseAsync.when(
      data: (_) {
        try {
          final kickState = _ref.read(kickCounterProvider);
          return state && kickState.activeSession != null;
        } catch (e) {
          // Dependencies not ready yet
          return false;
        }
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }
}

/// Provider for kick counter banner visibility state.
/// 
/// Returns `true` when the floating banner should be displayed.
final kickCounterBannerProvider = StateNotifierProvider<KickCounterBannerNotifier, bool>((ref) {
  return KickCounterBannerNotifier(ref);
});

/// Convenience provider that combines banner visibility with session existence.
///
/// Returns `true` only when both:
/// - Banner is set to visible, AND
/// - An active session exists
///
/// Returns `false` while dependencies are initializing.
final shouldShowKickCounterBannerProvider = Provider<bool>((ref) {
  final bannerVisible = ref.watch(kickCounterBannerProvider);

  // Check if async dependencies are ready
  final useCaseAsync = ref.watch(manageSessionUseCaseProvider);

  return useCaseAsync.when(
    data: (_) {
      // Dependencies ready, check kick counter state
      try {
        final kickState = ref.watch(kickCounterProvider);
        return bannerVisible && kickState.activeSession != null;
      } catch (e) {
        // Dependencies not fully initialized yet
        return false;
      }
    },
    loading: () => false, // Don't show banner while initializing
    error: (_, __) => false, // Don't show banner if initialization failed
  );
});

