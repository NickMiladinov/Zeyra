import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/domain/entities/contraction_timer/rule_511_status.dart';
import 'package:zeyra/domain/usecases/contraction_timer/manage_contraction_session_usecase.dart';
import 'package:zeyra/domain/usecases/contraction_timer/calculate_511_rule_usecase.dart';
import 'package:zeyra/domain/exceptions/contraction_timer_exception.dart';

/// State for the active contraction timer session
class ContractionTimerState {
  final ContractionSession? activeSession;
  final Rule511Status? rule511Status;
  final bool isLoading;
  final String? error;
  
  const ContractionTimerState({
    this.activeSession,
    this.rule511Status,
    this.isLoading = false,
    this.error,
  });
  
  ContractionTimerState copyWith({
    ContractionSession? Function()? activeSession,
    Rule511Status? Function()? rule511Status,
    bool? isLoading,
    String? Function()? error,
  }) {
    return ContractionTimerState(
      activeSession: activeSession != null ? activeSession() : this.activeSession,
      rule511Status: rule511Status != null ? rule511Status() : this.rule511Status,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// Notifier for managing active contraction timer session
class ContractionTimerNotifier extends StateNotifier<ContractionTimerState> {
  final ManageContractionSessionUseCase _manageUseCase;
  final Calculate511RuleUseCase _calculateUseCase;
  
  ContractionTimerNotifier({
    required ManageContractionSessionUseCase manageUseCase,
    required Calculate511RuleUseCase calculateUseCase,
  })  : _manageUseCase = manageUseCase,
        _calculateUseCase = calculateUseCase,
        super(const ContractionTimerState()) {
    _initialize();
  }
  
  /// Initialize by checking for existing active session on app start
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final session = await _manageUseCase.getActiveSession();
      
      if (session != null) {
        // Check if session needs to be auto-handled based on time elapsed
        await _handleSessionRestore(session);
      } else {
        state = state.copyWith(
          activeSession: () => null,
          rule511Status: () => null,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }
  
  /// Handle session restoration based on time thresholds
  Future<void> _handleSessionRestore(ContractionSession session) async {
    final now = DateTime.now();
    final activeContraction = session.activeContraction;
    
    // Case A: Active contraction exists
    if (activeContraction != null) {
      final elapsed = now.difference(activeContraction.startTime);
      
      if (elapsed.inMinutes > 20) {
        // Auto-stop the contraction - will need user confirmation in UI
        // For now, just load it and let UI handle the dialog
        final rule511 = _calculateUseCase.calculate(session);
        state = state.copyWith(
          activeSession: () => session,
          rule511Status: () => rule511,
          isLoading: false,
          error: () => 'contraction_timeout', // Special error for UI to show dialog
        );
      } else {
        // Resume normally
        final rule511 = _calculateUseCase.calculate(session);
        state = state.copyWith(
          activeSession: () => session,
          rule511Status: () => rule511,
          isLoading: false,
        );
      }
    } 
    // Case B: Session in resting state
    else if (session.contractions.isNotEmpty) {
      final lastContraction = session.contractions.last;
      final elapsed = lastContraction.endTime != null
          ? now.difference(lastContraction.endTime!)
          : Duration.zero;
      
      if (elapsed.inHours >= 4) {
        // Auto-archive session and start fresh
        await _manageUseCase.endSession(session.id);
        state = state.copyWith(
          activeSession: () => null,
          rule511Status: () => null,
          isLoading: false,
        );
      } else {
        // Resume session
        final rule511 = _calculateUseCase.calculate(session);
        state = state.copyWith(
          activeSession: () => session,
          rule511Status: () => rule511,
          isLoading: false,
        );
      }
    } else {
      // Empty session, load normally
      final rule511 = _calculateUseCase.calculate(session);
      state = state.copyWith(
        activeSession: () => session,
        rule511Status: () => rule511,
        isLoading: false,
      );
    }
  }
  
  /// Start a new session
  Future<void> startSession() async {
    try {
      state = state.copyWith(isLoading: true, error: () => null);
      
      final session = await _manageUseCase.startSession();
      final rule511 = _calculateUseCase.calculate(session);
      
      state = state.copyWith(
        activeSession: () => session,
        rule511Status: () => rule511,
        isLoading: false,
      );
    } on ContractionTimerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to start session: $e',
      );
    }
  }
  
  /// Start a new contraction
  Future<void> startContraction({
    ContractionIntensity intensity = ContractionIntensity.moderate,
  }) async {
    final session = state.activeSession;
    if (session == null) return;
    
    try {
      state = state.copyWith(isLoading: true, error: () => null);
      
      final updatedSession = await _manageUseCase.startContraction(
        session.id,
        intensity: intensity,
      );
      final rule511 = _calculateUseCase.calculate(updatedSession);
      
      state = state.copyWith(
        activeSession: () => updatedSession,
        rule511Status: () => rule511,
        isLoading: false,
      );
    } on ContractionTimerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to start contraction: $e',
      );
    }
  }
  
  /// Stop the active contraction
  Future<void> stopContraction() async {
    final session = state.activeSession;
    final activeContraction = session?.activeContraction;
    if (session == null || activeContraction == null) return;
    
    try {
      state = state.copyWith(isLoading: true, error: () => null);
      
      final updatedSession = await _manageUseCase.stopContraction(
        activeContraction.id,
      );
      final rule511 = _calculateUseCase.calculate(updatedSession);
      
      state = state.copyWith(
        activeSession: () => updatedSession,
        rule511Status: () => rule511,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to stop contraction: $e',
      );
    }
  }
  
  /// Delete a contraction (typically the last one for "undo")
  Future<void> deleteContraction(String contractionId) async {
    final session = state.activeSession;
    if (session == null) return;
    
    try {
      state = state.copyWith(isLoading: true, error: () => null);
      
      final updatedSession = await _manageUseCase.deleteContraction(contractionId);
      final rule511 = _calculateUseCase.calculate(updatedSession);
      
      state = state.copyWith(
        activeSession: () => updatedSession,
        rule511Status: () => rule511,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to delete contraction: $e',
      );
    }
  }
  
  /// Update contraction properties (from edit overlay)
  Future<void> updateContraction(
    String contractionId, {
    DateTime? startTime,
    Duration? duration,
    ContractionIntensity? intensity,
  }) async {
    final session = state.activeSession;
    if (session == null) return;
    
    try {
      state = state.copyWith(isLoading: true, error: () => null);
      
      final updatedSession = await _manageUseCase.updateContraction(
        contractionId,
        startTime: startTime,
        duration: duration,
        intensity: intensity,
      );
      final rule511 = _calculateUseCase.calculate(updatedSession);
      
      state = state.copyWith(
        activeSession: () => updatedSession,
        rule511Status: () => rule511,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to update contraction: $e',
      );
    }
  }
  
  /// Update session note
  Future<void> updateSessionNote(String? note) async {
    final session = state.activeSession;
    if (session == null) return;
    
    try {
      final updatedSession = await _manageUseCase.updateSessionNote(
        session.id,
        note,
      );
      
      state = state.copyWith(
        activeSession: () => updatedSession,
      );
    } catch (e) {
      state = state.copyWith(
        error: () => 'Failed to update note: $e',
      );
    }
  }
  
  /// Finish/complete the session
  Future<void> finishSession({String? note}) async {
    final session = state.activeSession;
    if (session == null) return;
    
    try {
      state = state.copyWith(isLoading: true, error: () => null);
      
      // Stop active contraction if any
      if (session.activeContraction != null) {
        await _manageUseCase.stopContraction(session.activeContraction!.id);
      }
      
      // Update session note if provided
      if (note != null && note.isNotEmpty) {
        await _manageUseCase.updateSessionNote(session.id, note);
      }
      
      // End the session
      await _manageUseCase.endSession(session.id);
      
      state = state.copyWith(
        activeSession: () => null,
        rule511Status: () => null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to finish session: $e',
      );
    }
  }
  
  /// Discard the session without saving
  Future<void> discardSession() async {
    final session = state.activeSession;
    if (session == null) return;
    
    try {
      state = state.copyWith(isLoading: true, error: () => null);
      
      await _manageUseCase.discardSession(session.id);
      
      state = state.copyWith(
        activeSession: () => null,
        rule511Status: () => null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to discard session: $e',
      );
    }
  }
  
  /// Refresh the current session (e.g., after returning from background)
  Future<void> refresh() async {
    try {
      final session = await _manageUseCase.getActiveSession();
      
      if (session != null) {
        final rule511 = _calculateUseCase.calculate(session);
        state = state.copyWith(
          activeSession: () => session,
          rule511Status: () => rule511,
        );
      } else {
        state = state.copyWith(
          activeSession: () => null,
          rule511Status: () => null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: () => 'Failed to refresh: $e',
      );
    }
  }
  
  /// Clear any error messages
  void clearError() {
    state = state.copyWith(error: () => null);
  }
  
  /// Public getter for the current state.
  /// Used by providers that need to read the initial state.
  ContractionTimerState get currentState => state;
}

/// Async provider that creates the ContractionTimerNotifier once dependencies are ready.
///
/// This provider properly waits for all async dependencies before creating the notifier.
final _contractionTimerNotifierProvider = FutureProvider<ContractionTimerNotifier>((ref) async {
  // Wait for async dependencies to be ready
  final manageUseCase = await ref.watch(manageContractionSessionUseCaseProvider.future);
  final calculateUseCase = await ref.watch(calculate511RuleUseCaseProvider.future);

  return ContractionTimerNotifier(
    manageUseCase: manageUseCase,
    calculateUseCase: calculateUseCase,
  );
});

/// Provider for contraction timer state.
///
/// Returns `AsyncValue<ContractionTimerState>` to properly handle the async
/// initialization of dependencies. Uses StreamProvider internally to maintain
/// reactivity to state changes.
///
/// **Usage:**
/// ```dart
/// final timerAsync = ref.watch(contractionTimerProvider);
/// timerAsync.when(
///   data: (state) => /* use state */,
///   loading: () => /* show loading */,
///   error: (e, st) => /* handle error */,
/// );
/// ```
final contractionTimerProvider = StreamProvider<ContractionTimerState>((ref) async* {
  // Wait for the notifier to be ready
  final notifierAsync = ref.watch(_contractionTimerNotifierProvider);
  
  // Handle loading/error states
  if (notifierAsync.hasError) {
    throw notifierAsync.error!;
  }
  
  final notifier = notifierAsync.valueOrNull;
  if (notifier == null) {
    // Still loading - don't yield anything yet
    return;
  }
  
  // Yield initial state
  yield notifier.currentState;
  
  // Listen to state changes and yield them
  await for (final state in notifier.stream) {
    yield state;
  }
});

/// Provider to access the ContractionTimerNotifier for calling methods.
///
/// Returns null if the notifier is not yet initialized.
/// Use this to call methods like `startSession()`, `startContraction()`, etc.
///
/// **Usage:**
/// ```dart
/// final notifier = ref.read(contractionTimerNotifierProvider);
/// notifier?.startSession();
/// ```
final contractionTimerNotifierProvider = Provider<ContractionTimerNotifier?>((ref) {
  final notifierAsync = ref.watch(_contractionTimerNotifierProvider);
  return notifierAsync.valueOrNull;
});

