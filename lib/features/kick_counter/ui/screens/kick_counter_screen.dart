import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_onboarding_provider.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_counter_history_screen.dart';
import 'package:zeyra/features/kick_counter/ui/widgets/kick_counter_intro_overlay.dart';

/// Main entry point for the kick counter feature.
/// 
/// Shows the intro overlay on first launch, then displays the history screen.
class KickCounterScreen extends ConsumerStatefulWidget {
  const KickCounterScreen({super.key});

  static const String routeName = '/kick-counter';

  @override
  ConsumerState<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends ConsumerState<KickCounterScreen> {
  bool _hasShownOverlay = false;
  bool? _previousHasStarted;

  @override
  Widget build(BuildContext context) {
    final hasStarted = ref.watch(kickCounterOnboardingProvider);

    // Check if we should show the intro overlay when the provider transitions
    // from loading (null) to loaded (false = never started)
    if (!_hasShownOverlay && 
        _previousHasStarted == null && 
        hasStarted == false) {
      _hasShownOverlay = true;
      // Show overlay after the current frame to avoid build-time navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          KickCounterIntroOverlay.show(context);
        }
      });
    }
    
    // Track previous value for detecting transitions
    _previousHasStarted = hasStarted;

    if (hasStarted == null) {
      // Loading state for preference
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Always show history screen, overlay is shown on top
    return const KickCounterHistoryScreen();
  }
}
