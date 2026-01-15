import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final contractionTimerOnboardingProvider = StateNotifierProvider<ContractionTimerOnboardingNotifier, bool?>((ref) {
  return ContractionTimerOnboardingNotifier();
});

class ContractionTimerOnboardingNotifier extends StateNotifier<bool?> {
  static const _key = 'contraction_timer_has_started';

  ContractionTimerOnboardingNotifier() : super(null) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setHasStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }
}

