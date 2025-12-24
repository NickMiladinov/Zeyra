import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_timer_state.dart';
import 'package:zeyra/shared/providers/modal_overlay_provider.dart';

/// Manages the visibility state of the contraction timer floating banner.
/// 
/// The banner should be shown when:
/// - There is an active session, AND
/// - The user has navigated away from the active session screen
/// 
/// The banner should be hidden when:
/// - No active session exists, OR
/// - The user is currently on the active session screen
class ContractionTimerBannerNotifier extends StateNotifier<bool> {
  final Ref _ref;
  
  /// Track whether the user is currently on the active session screen
  bool _isActiveScreenVisible = false;
  
  /// Track whether the session listener has been set up
  bool _listenerInitialized = false;
  
  ContractionTimerBannerNotifier(this._ref) : super(false);
  
  /// Set up listener for session state changes (called lazily when auth is ready).
  void _ensureListenerInitialized() {
    if (_listenerInitialized) return;
    _listenerInitialized = true;
    
    _ref.listen(contractionTimerProvider, (previous, next) {
      final previousSession = previous?.valueOrNull?.activeSession;
      final nextSession = next.valueOrNull?.activeSession;
      
      // Auto-hide when session ends
      if (previousSession != null && nextSession == null) {
        state = false;
      }
      // Auto-show when session restored and not on active screen
      else if (previousSession == null && nextSession != null && !_isActiveScreenVisible) {
        state = true;
      }
    });
  }

  /// Show the banner (called when user leaves active session screen)
  /// 
  /// Sets the banner visibility state to true. The actual visibility is 
  /// determined by [shouldShowContractionTimerBannerProvider] which checks if
  /// there's an active session.
  void show() {
    _isActiveScreenVisible = false;
    state = true;
  }

  /// Hide the banner (called when user enters active session screen)
  void hide() {
    _isActiveScreenVisible = true;
    state = false;
  }

  /// Check if banner should be visible based on current state.
  /// Note: Use [shouldShowContractionTimerBannerProvider] for reactive UI updates.
  bool get shouldShow => state;
}

/// Provider for contraction timer banner visibility state.
/// 
/// Returns `true` when the floating banner should be displayed.
final contractionTimerBannerProvider = StateNotifierProvider<ContractionTimerBannerNotifier, bool>((ref) {
  return ContractionTimerBannerNotifier(ref);
});

/// Convenience provider that combines banner visibility with session existence.
///
/// Returns `true` only when both:
/// - Dependencies are ready (user authenticated), AND
/// - Banner is set to visible, AND
/// - An active session exists
///
/// Returns `false` while dependencies are initializing or user is not authenticated.
/// Safely handles cases where providers are not yet available.
final shouldShowContractionTimerBannerProvider = Provider<bool>((ref) {
  // 1. Watch banner state FIRST to establish dependency for reactivity.
  final bannerVisible = ref.watch(contractionTimerBannerProvider);
  
  // 2. Hide banner when any modal overlay is visible (bottom sheets, full-screen modals, etc.)
  final isModalVisible = ref.watch(isModalOverlayVisibleProvider);
  if (isModalVisible) {
    return false;
  }
  
  // 3. Check authentication before accessing auth-dependent providers
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return false;
    }
  } catch (e) {
    // Supabase not initialized - test environment, continue
  }
  
  // 4. User is authenticated - ensure session listener is initialized
  ref.read(contractionTimerBannerProvider.notifier)._ensureListenerInitialized();
  
  // 5. Check if there's an active session
  try {
    final timerStateAsync = ref.watch(contractionTimerProvider);
    return timerStateAsync.when(
      data: (timerState) {
        final hasSession = timerState.activeSession != null;
        return bannerVisible && hasSession;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  } catch (e) {
    return false;
  }
});
