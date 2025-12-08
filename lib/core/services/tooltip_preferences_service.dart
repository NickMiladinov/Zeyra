import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing tooltip preferences (which JIT tooltips have been shown).
/// 
/// Persists tooltip state to ensure each tooltip is only shown once,
/// even if the app is restarted or the triggering condition changes.
/// 
/// **Initialization:** This service is initialized in `DIGraph.initialize()` during app startup.
/// Access via `tooltipPreferencesServiceProvider` or `DIGraph.tooltipPreferencesService`.
class TooltipPreferencesService {
  static const String _prefix = 'jit_tooltip_shown_';

  final SharedPreferences _prefs;

  TooltipPreferencesService(this._prefs);

  /// Check if a tooltip has been shown before.
  bool hasBeenShown(String tooltipId) {
    return _prefs.getBool('$_prefix$tooltipId') ?? false;
  }

  /// Mark a tooltip as shown.
  Future<void> markAsShown(String tooltipId) async {
    await _prefs.setBool('$_prefix$tooltipId', true);
  }

  /// Reset a tooltip (for testing purposes).
  Future<void> reset(String tooltipId) async {
    await _prefs.remove('$_prefix$tooltipId');
  }

  /// Reset all tooltips (for testing purposes).
  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
