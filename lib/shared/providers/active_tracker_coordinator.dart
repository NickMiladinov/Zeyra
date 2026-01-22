import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_state.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_timer_state.dart';

/// Types of active trackers that can run
enum ActiveTrackerType {
  none,
  kickCounter,
  contractionTimer,
}

/// Coordinates active tracking sessions to ensure only one runs at a time.
///
/// Prevents simultaneous kick counting and contraction timing sessions,
/// as they represent mutually exclusive tracking activities.
final activeTrackerProvider = Provider<ActiveTrackerType>((ref) {
  // Guard: These providers require authentication and database access.
  // If no user is authenticated, return none to avoid triggering errors.
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return ActiveTrackerType.none;
  }

  // Watch both trackers - handle async loading gracefully
  try {
    final kickCounterState = ref.watch(kickCounterProvider);

    // Check if kick counter has an active session
    if (kickCounterState.activeSession != null) {
      return ActiveTrackerType.kickCounter;
    }
  } catch (e) {
    // Kick counter provider dependencies still loading
  }

  try {
    final contractionStateAsync = ref.watch(contractionTimerProvider);
    final contractionSession = contractionStateAsync.valueOrNull?.activeSession;

    // Check if contraction timer has an active session
    if (contractionSession != null) {
      return ActiveTrackerType.contractionTimer;
    }
  } catch (e) {
    // Contraction timer provider dependencies still loading
  }

  return ActiveTrackerType.none;
});

/// Whether a new kick counter session can be started
final canStartKickCounterProvider = Provider<bool>((ref) {
  final activeTracker = ref.watch(activeTrackerProvider);
  return activeTracker == ActiveTrackerType.none || 
         activeTracker == ActiveTrackerType.kickCounter;
});

/// Whether a new contraction timer session can be started
final canStartContractionTimerProvider = Provider<bool>((ref) {
  final activeTracker = ref.watch(activeTrackerProvider);
  return activeTracker == ActiveTrackerType.none || 
         activeTracker == ActiveTrackerType.contractionTimer;
});

