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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeShowIntroOverlay();
  }

  void _maybeShowIntroOverlay() {
    // Prevent showing multiple times during rebuild
    if (_hasShownOverlay) return;

    final hasStarted = ref.read(kickCounterOnboardingProvider);

    // Wait for the preference to be loaded
    if (hasStarted == null) return;

    // TODO: Temporarily showing overlay every time for testing.
    // Revert to: if (!hasStarted) { ... }
    // to only show on first launch.
    
    // Show overlay after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasShownOverlay) {
        _hasShownOverlay = true;
        KickCounterIntroOverlay.show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasStarted = ref.watch(kickCounterOnboardingProvider);

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
