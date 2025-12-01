import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_onboarding_provider.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_counter_history_screen.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_counter_landing_screen.dart';

class KickCounterScreen extends ConsumerWidget {
  const KickCounterScreen({super.key});

  static const String routeName = '/kick-counter';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasStarted = ref.watch(kickCounterOnboardingProvider);

    if (hasStarted == null) {
      // Loading state for preference
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasStarted) {
      return const KickCounterHistoryScreen();
    } else {
      return const KickCounterLandingScreen();
    }
  }
}

