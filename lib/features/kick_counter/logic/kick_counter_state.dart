import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/exceptions/kick_counter_exception.dart';
import 'package:zeyra/domain/usecases/kick_counter/manage_session_usecase.dart';

// ----------------------------------------------------------------------------
// State Class
// ----------------------------------------------------------------------------

class KickCounterState {
  final KickSession? activeSession;
  final Duration sessionDuration;
  final bool isLoading;
  final KickCounterErrorType? error;
  final bool shouldPromptEnd;

  const KickCounterState({
    this.activeSession,
    this.sessionDuration = Duration.zero,
    this.isLoading = false,
    this.error,
    this.shouldPromptEnd = false,
  });

  KickCounterState copyWith({
    KickSession? activeSession,
    Duration? sessionDuration,
    bool? isLoading,
    KickCounterErrorType? error,
    bool? shouldPromptEnd,
  }) {
    return KickCounterState(
      activeSession: activeSession ?? this.activeSession,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable update to clear error
      shouldPromptEnd: shouldPromptEnd ?? this.shouldPromptEnd,
    );
  }
}

// ----------------------------------------------------------------------------
// Notifier
// ----------------------------------------------------------------------------

class KickCounterNotifier extends StateNotifier<KickCounterState> {
  final ManageSessionUseCase _useCase;
  Timer? _timer;

  KickCounterNotifier(this._useCase) : super(const KickCounterState()) {
    _checkActiveSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Initialization & Timer Logic
  // --------------------------------------------------------------------------

  Future<void> _checkActiveSession() async {
    try {
      final activeSession = await _useCase.getActiveSession();
      if (activeSession != null) {
        // If session was running when app closed, pause it on restart
        // This prevents counting time while app was closed
        if (!activeSession.isPaused) {
          final pausedSession = await _useCase.pauseSession(activeSession.id);
          await restoreSession(pausedSession);
        } else {
          await restoreSession(activeSession);
        }
      }
    } catch (e) {
      // Silently fail on init check
    }
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.activeSession != null && !state.activeSession!.isPaused) {
        _updateDuration();
      }
    });
  }

  void _updateDuration() {
    if (state.activeSession == null) return;
    state = state.copyWith(sessionDuration: state.activeSession!.activeDuration);
  }

  // --------------------------------------------------------------------------
  // Public Actions
  // --------------------------------------------------------------------------
  
  /// Check for existing session on mount
  Future<void> checkActiveSession() async {
    await _checkActiveSession();
  }

  Future<void> startSession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _useCase.startSession();
      state = state.copyWith(
        activeSession: session,
        isLoading: false,
        sessionDuration: Duration.zero,
      );
      _startTimer();
    } on KickCounterException catch (e) {
      if (e.type == KickCounterErrorType.sessionAlreadyActive) {
        // Logic for already active session: fetch and restore it
        try {
          final activeSession = await _useCase.getActiveSession();
          if (activeSession != null) {
            await restoreSession(activeSession);
            state = state.copyWith(isLoading: false);
            return;
          }
        } catch (_) {
          // Fallthrough to error
        }
        state = state.copyWith(isLoading: false, error: e.type);
      } else {
         state = state.copyWith(isLoading: false, error: e.type);
      }
    } catch (e) {
       state = state.copyWith(isLoading: false);
    }
  }
  
  // Helper to restore session if we know one exists (called from UI init if needed)
  Future<void> restoreSession(KickSession session) async {
    state = state.copyWith(activeSession: session);
    if (!session.isPaused) {
      _startTimer();
    } else {
      // If paused, set duration to current static active duration
      state = state.copyWith(sessionDuration: session.activeDuration);
    }
  }

  Future<void> recordKick(MovementStrength strength) async {
    if (state.activeSession == null) return;
    
    try {
      final result = await _useCase.recordKick(state.activeSession!.id, strength);
      
      state = state.copyWith(
        activeSession: result.session,
        shouldPromptEnd: result.shouldPromptEnd,
      );
    } on KickCounterException catch (e) {
      state = state.copyWith(error: e.type);
    }
  }

  Future<void> undoLastKick() async {
    if (state.activeSession == null || state.activeSession!.kicks.isEmpty) return;

    try {
      final updatedSession = await _useCase.undoLastKick(state.activeSession!.id);
      
      state = state.copyWith(activeSession: updatedSession);
    } on KickCounterException catch (e) {
      state = state.copyWith(error: e.type);
    }
  }

  Future<void> pauseSession() async {
    if (state.activeSession == null) return;
    
    try {
      final updatedSession = await _useCase.pauseSession(state.activeSession!.id);
      
      _timer?.cancel();
      
      state = state.copyWith(activeSession: updatedSession);
      
    } on KickCounterException catch (e) {
      state = state.copyWith(error: e.type);
    }
  }

  Future<void> resumeSession() async {
    if (state.activeSession == null) return;

    try {
      final updatedSession = await _useCase.resumeSession(state.activeSession!.id);
      
      state = state.copyWith(activeSession: updatedSession);
      _startTimer();
      
    } on KickCounterException catch (e) {
      state = state.copyWith(error: e.type);
    }
  }

  Future<void> endSession({String? note}) async {
    if (state.activeSession == null) return;

    try {
      // Update note if provided
      if (note != null && note.isNotEmpty) {
        await _useCase.updateSessionNote(state.activeSession!.id, note);
      }
      
      await _useCase.endSession(state.activeSession!.id);
      _timer?.cancel();
      state = const KickCounterState(); // Reset state
    } on KickCounterException catch (e) {
      state = state.copyWith(error: e.type);
    }
  }

  Future<void> discardSession() async {
    if (state.activeSession == null) return;

    try {
      await _useCase.discardSession(state.activeSession!.id);
      _timer?.cancel();
      state = const KickCounterState(); // Reset state
    } catch (e) {
      // Handle generic errors
    }
  }
}

// ----------------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------------

/// Provider that exposes the KickCounterNotifier.
/// IMPORTANT: Only access this after dependencies are ready.
/// The provider checks for data availability and throws if accessed too early.
final kickCounterProvider = StateNotifierProvider<KickCounterNotifier, KickCounterState>((ref) {
  final useCaseAsync = ref.watch(manageSessionUseCaseProvider);

  // Wait for the dependency to be ready
  if (!useCaseAsync.hasValue) {
    throw StateError(
      'kickCounterProvider accessed before dependencies are ready. '
      'User must be authenticated first.',
    );
  }

  return KickCounterNotifier(useCaseAsync.requireValue);
});
