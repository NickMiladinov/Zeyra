import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State for tracking which tooltips have been shown.
class TooltipState {
  final Map<String, bool> shownTooltips;
  final bool isLoaded;

  const TooltipState({
    this.shownTooltips = const {},
    this.isLoaded = false,
  });

  TooltipState copyWith({
    Map<String, bool>? shownTooltips,
    bool? isLoaded,
  }) {
    return TooltipState(
      shownTooltips: shownTooltips ?? this.shownTooltips,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  /// Check if a specific tooltip should be shown.
  bool shouldShow(String tooltipId, bool conditionMet) {
    if (!isLoaded || !conditionMet) return false;
    return !(shownTooltips[tooltipId] ?? false);
  }
}

/// Provider for managing JIT tooltip state.
final tooltipProvider = StateNotifierProvider<TooltipNotifier, TooltipState>((ref) {
  return TooltipNotifier();
});

/// Notifier for managing tooltip dismissals.
class TooltipNotifier extends StateNotifier<TooltipState> {
  static const String _prefix = 'jit_tooltip_shown_';

  TooltipNotifier() : super(const TooltipState()) {
    _loadState();
  }

  /// Load tooltip states from SharedPreferences.
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final shownTooltips = <String, bool>{};

    // Load all known tooltip IDs
    for (final tooltipId in KickCounterTooltipIds.all) {
      shownTooltips[tooltipId] = prefs.getBool('$_prefix$tooltipId') ?? false;
    }

    state = state.copyWith(
      shownTooltips: shownTooltips,
      isLoaded: true,
    );
  }

  /// Mark a tooltip as shown/dismissed.
  Future<void> dismissTooltip(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tooltipId', true);

    final updatedTooltips = Map<String, bool>.from(state.shownTooltips);
    updatedTooltips[tooltipId] = true;

    state = state.copyWith(shownTooltips: updatedTooltips);
  }

  /// Check if a tooltip has been shown.
  bool hasBeenShown(String tooltipId) {
    return state.shownTooltips[tooltipId] ?? false;
  }

  /// Reset a specific tooltip (for testing).
  Future<void> resetTooltip(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$tooltipId');

    final updatedTooltips = Map<String, bool>.from(state.shownTooltips);
    updatedTooltips[tooltipId] = false;

    state = state.copyWith(shownTooltips: updatedTooltips);
  }
}

/// Predefined tooltip IDs for the kick counter feature.
class KickCounterTooltipIds {
  KickCounterTooltipIds._();

  /// Shown after recording the first session.
  static const String firstSession = 'kick_counter_first_session';

  /// Shown after recording 7 valid sessions (graph unlocked).
  static const String graphUnlocked = 'kick_counter_graph_unlocked';

  /// All tooltip IDs for this feature.
  static const List<String> all = [firstSession, graphUnlocked];
}
