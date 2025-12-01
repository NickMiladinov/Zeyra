import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final kickCounterOnboardingProvider = StateNotifierProvider<KickCounterOnboardingNotifier, bool?>((ref) {
  return KickCounterOnboardingNotifier();
});

class KickCounterOnboardingNotifier extends StateNotifier<bool?> {
  static const _key = 'kick_counter_has_started';

  KickCounterOnboardingNotifier() : super(null) {
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

