import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // Listen to kick counter state changes
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
  }

  /// Show the banner (called when user leaves active session screen)
  void show() {
    _isActiveScreenVisible = false;
    final kickState = _ref.read(kickCounterProvider);
    // Only show if there's an active session
    if (kickState.activeSession != null) {
      state = true;
    }
  }

  /// Hide the banner (called when user enters active session screen)
  void hide() {
    _isActiveScreenVisible = true;
    state = false;
  }

  /// Check if banner should be visible based on session state
  bool get shouldShow {
    final kickState = _ref.read(kickCounterProvider);
    return state && kickState.activeSession != null;
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
final shouldShowKickCounterBannerProvider = Provider<bool>((ref) {
  final bannerVisible = ref.watch(kickCounterBannerProvider);
  final kickState = ref.watch(kickCounterProvider);
  return bannerVisible && kickState.activeSession != null;
});

