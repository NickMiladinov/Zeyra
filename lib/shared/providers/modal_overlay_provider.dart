import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the number of active modal overlays (bottom sheets, full-screen modals, etc.).
/// 
/// This is used to hide floating elements (like the kick counter banner)
/// when any modal overlay is showing, ensuring proper z-ordering.
/// 
/// Uses a counter approach to support multiple overlays at once.
final _modalOverlayCountProvider = StateProvider<int>((ref) => 0);

/// Provider that returns true when any modal overlay is currently visible.
/// 
/// Modal overlays include:
/// - Bottom sheets
/// - Full-screen modals (crop screens, etc.)
/// - Dialogs (if needed in the future)
final isModalOverlayVisibleProvider = Provider<bool>((ref) {
  final count = ref.watch(_modalOverlayCountProvider);
  return count > 0;
});

/// Notifier to manage modal overlay visibility state.
/// 
/// Use `show()` when opening a modal and `hide()` when closing it.
/// The counter ensures proper handling of multiple overlays.
class ModalOverlayNotifier {
  final Ref _ref;

  ModalOverlayNotifier(this._ref);

  /// Increment the overlay counter (call when showing a modal)
  void show() {
    final current = _ref.read(_modalOverlayCountProvider);
    _ref.read(_modalOverlayCountProvider.notifier).state = current + 1;
  }

  /// Decrement the overlay counter (call when hiding a modal)
  void hide() {
    final current = _ref.read(_modalOverlayCountProvider);
    if (current > 0) {
      _ref.read(_modalOverlayCountProvider.notifier).state = current - 1;
    }
  }

  /// Reset the counter to 0 (use only if counter gets out of sync)
  void reset() {
    _ref.read(_modalOverlayCountProvider.notifier).state = 0;
  }
}

/// Provider for accessing the modal overlay notifier.
final modalOverlayNotifierProvider = Provider<ModalOverlayNotifier>((ref) {
  return ModalOverlayNotifier(ref);
});

