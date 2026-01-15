import '../../../core/utils/data_minimization.dart';
import '../../entities/contraction_timer/contraction_intensity.dart';
import '../../entities/contraction_timer/contraction_session.dart';
import '../../entities/contraction_timer/contraction_timer_constants.dart';
import '../../exceptions/contraction_timer_exception.dart';
import '../../repositories/contraction_timer_repository.dart';
import 'calculate_511_rule_usecase.dart';

/// Use case for managing contraction timing sessions.
/// 
/// Orchestrates session lifecycle operations with validation and business rules.
/// Enforces constraints like maximum contractions per session, minimum contractions
/// to end, and proper contraction start/stop sequencing.
class ManageContractionSessionUseCase {
  final ContractionTimerRepository _repository;
  final Calculate511RuleUseCase _calculate511UseCase;

  const ManageContractionSessionUseCase({
    required ContractionTimerRepository repository,
    Calculate511RuleUseCase calculate511UseCase = const Calculate511RuleUseCase(),
  }) : _repository = repository,
       _calculate511UseCase = calculate511UseCase;

  // --------------------------------------------------------------------------
  // State Queries
  // --------------------------------------------------------------------------
  
  /// Get the currently active session, if one exists.
  Future<ContractionSession?> getActiveSession() async {
    return await _repository.getActiveSession();
  }

  // --------------------------------------------------------------------------
  // Session Lifecycle
  // --------------------------------------------------------------------------

  /// Start a new contraction timing session.
  /// 
  /// Validates that no active session exists before creating a new one.
  /// 
  /// Returns the newly created session.
  /// 
  /// Throws [ContractionTimerException] with type [sessionAlreadyActive]
  /// if an active session already exists.
  Future<ContractionSession> startSession() async {
    // Check if active session exists
    final activeSession = await _repository.getActiveSession();
    if (activeSession != null) {
      throw const ContractionTimerException(
        'An active session already exists. Please complete or discard it first.',
        ContractionTimerErrorType.sessionAlreadyActive,
      );
    }

    return await _repository.createSession();
  }

  /// Start timing a new contraction in the specified session.
  /// 
  /// [sessionId] - ID of the session to add contraction to
  /// [intensity] - User's perception of contraction intensity
  /// 
  /// Validates that:
  /// - Session exists and is active
  /// - No contraction is currently being timed
  /// - Session hasn't reached maximum contraction limit
  /// 
  /// Returns the updated session with the new active contraction.
  /// 
  /// Throws [ContractionTimerException] with appropriate type for validation failures.
  Future<ContractionSession> startContraction(
    String sessionId, {
    ContractionIntensity intensity = ContractionIntensity.moderate,
  }) async {
    // Get current session to validate
    final session = await _repository.getActiveSession();
    if (session == null || session.id != sessionId) {
      throw const ContractionTimerException(
        'No active session found.',
        ContractionTimerErrorType.noActiveSession,
      );
    }

    // Check if a contraction is already active
    if (session.activeContraction != null) {
      throw const ContractionTimerException(
        'A contraction is already being timed. Stop the current contraction first.',
        ContractionTimerErrorType.contractionAlreadyActive,
      );
    }

    // Validate max contractions limit
    if (session.contractionCount >= ContractionTimerConstants.maxContractionsPerSession) {
      throw ContractionTimerException(
        'Maximum ${ContractionTimerConstants.maxContractionsPerSession} contractions per session reached.',
        ContractionTimerErrorType.maxContractionsReached,
      );
    }

    // Start the contraction
    await _repository.startContraction(sessionId, intensity: intensity);

    // Fetch updated session
    final updatedSession = await _repository.getActiveSession();
    if (updatedSession == null) {
      throw const ContractionTimerException(
        'Session lost after update.',
        ContractionTimerErrorType.noActiveSession,
      );
    }

    return updatedSession;
  }

  /// Stop timing the currently active contraction.
  /// 
  /// [contractionId] - ID of the contraction to stop
  /// 
  /// Sets endTime to current timestamp.
  /// Returns the updated session.
  /// 
  /// Throws [ContractionTimerException] if no active contraction exists.
  Future<ContractionSession> stopContraction(String contractionId) async {
    // Stop the contraction
    await _repository.stopContraction(contractionId);

    // Fetch updated session
    final updatedSession = await _repository.getActiveSession();
    if (updatedSession == null) {
      throw const ContractionTimerException(
        'Session lost after update.',
        ContractionTimerErrorType.noActiveSession,
      );
    }

    return updatedSession;
  }

  /// Update an existing contraction's properties.
  /// 
  /// [contractionId] - ID of the contraction to update
  /// [startTime] - New start time (optional)
  /// [duration] - New duration (optional)
  /// [intensity] - New intensity (optional)
  /// 
  /// Validates that the contraction exists and data is valid.
  /// Returns the updated session.
  /// 
  /// Throws [ContractionTimerException] with appropriate type for validation failures.
  Future<ContractionSession> updateContraction(
    String contractionId, {
    DateTime? startTime,
    Duration? duration,
    ContractionIntensity? intensity,
  }) async {
    // Update the contraction
    await _repository.updateContraction(
      contractionId,
      startTime: startTime,
      duration: duration,
      intensity: intensity,
    );

    // Fetch updated session
    final updatedSession = await _repository.getActiveSession();
    if (updatedSession == null) {
      throw const ContractionTimerException(
        'Session lost after update.',
        ContractionTimerErrorType.noActiveSession,
      );
    }

    return updatedSession;
  }

  /// Delete a specific contraction from the session.
  /// 
  /// [contractionId] - ID of the contraction to delete
  /// 
  /// Used when user wants to remove an incorrectly recorded contraction.
  /// Returns the updated session.
  /// 
  /// Throws [ContractionTimerException] if contraction doesn't exist.
  Future<ContractionSession> deleteContraction(String contractionId) async {
    await _repository.deleteContraction(contractionId);

    // Fetch updated session
    final updatedSession = await _repository.getActiveSession();
    if (updatedSession == null) {
      throw const ContractionTimerException(
        'Session lost after update.',
        ContractionTimerErrorType.noActiveSession,
      );
    }

    return updatedSession;
  }

  /// End the specified session.
  ///
  /// [sessionId] - ID of the session to end
  ///
  /// Validates that at least one contraction has been recorded.
  /// Sets endTime to current timestamp and marks session as inactive.
  /// If a contraction is currently active, it will be stopped.
  ///
  /// Throws [ContractionTimerException] with type [noContractionsRecorded]
  /// if session has zero contractions.
  Future<void> endSession(String sessionId) async {
    // Get current session to validate contractions exist
    var session = await _repository.getActiveSession();
    if (session == null || session.id != sessionId) {
      throw const ContractionTimerException(
        'No active session found.',
        ContractionTimerErrorType.noActiveSession,
      );
    }

    // Stop any active contraction before ending the session
    if (session.activeContraction != null) {
      await _repository.stopContraction(session.activeContraction!.id);
      // Re-fetch session to get updated state
      session = await _repository.getActiveSession();
      if (session == null) {
        throw const ContractionTimerException(
          'Session lost after stopping contraction.',
          ContractionTimerErrorType.noActiveSession,
        );
      }
    }

    if (session.contractionCount == 0) {
      throw const ContractionTimerException(
        'Cannot end session with no contractions recorded. '
        'Please record at least one contraction or discard the session.',
        ContractionTimerErrorType.noContractionsRecorded,
      );
    }

    // Use Calculate511RuleUseCase as single source of truth for criteria evaluation
    final achieved = _calculate511UseCase.evaluateAchievedCriteria(session);
    
    // Update session with achieved flags before ending
    await _repository.updateSessionCriteria(
      sessionId,
      achievedDuration: achieved.duration,
      durationAchievedAt: achieved.duration && session.durationAchievedAt == null 
          ? DateTime.now() 
          : null, // Don't overwrite if already set
      achievedFrequency: achieved.frequency,
      frequencyAchievedAt: achieved.frequency && session.frequencyAchievedAt == null 
          ? DateTime.now() 
          : null,
      achievedConsistency: achieved.consistency,
      consistencyAchievedAt: achieved.consistency && session.consistencyAchievedAt == null 
          ? DateTime.now() 
          : null,
    );

    await _repository.endSession(sessionId);
  }

  /// Permanently delete a session.
  /// 
  /// [sessionId] - ID of the session to discard
  /// 
  /// Used when user wants to discard a session without completing it.
  /// Removes session and all associated contractions from database.
  Future<void> discardSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
  }

  /// Delete a historical (completed) session.
  /// 
  /// [sessionId] - ID of the session to delete
  /// 
  /// Used when user wants to remove a completed session from their history.
  /// Removes session and all associated contractions from database.
  Future<void> deleteHistoricalSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
  }

  /// Update the note attached to a session.
  /// 
  /// [sessionId] - ID of the session to update
  /// [note] - New note text (null or empty to clear the note)
  /// 
  /// Returns the updated session with the new note.
  Future<ContractionSession> updateSessionNote(String sessionId, String? note) async {
    return await _repository.updateSessionNote(sessionId, note);
  }

  /// Update individual 5-1-1 criterion achievement status for a session.
  /// 
  /// [sessionId] - ID of the session to update
  /// Optional parameters for each criterion (only provided values will be updated)
  /// 
  /// This is called when any of the 5-1-1 criteria are first met.
  /// Returns the updated session.
  Future<ContractionSession> updateSessionCriteria(
    String sessionId, {
    bool? achievedDuration,
    DateTime? durationAchievedAt,
    bool? achievedFrequency,
    DateTime? frequencyAchievedAt,
    bool? achievedConsistency,
    DateTime? consistencyAchievedAt,
  }) async {
    return await _repository.updateSessionCriteria(
      sessionId,
      achievedDuration: achievedDuration,
      durationAchievedAt: durationAchievedAt,
      achievedFrequency: achievedFrequency,
      frequencyAchievedAt: frequencyAchievedAt,
      achievedConsistency: achievedConsistency,
      consistencyAchievedAt: consistencyAchievedAt,
    );
  }

  // --------------------------------------------------------------------------
  // History Operations
  // --------------------------------------------------------------------------

  /// Default number of sessions to return in history queries
  static const int defaultHistoryLimit = 20;

  /// Get historical contraction timing sessions.
  ///
  /// [limit] - Maximum number of sessions to return (default: 20)
  /// [before] - Optional timestamp to get sessions before
  ///
  /// Returns sessions ordered by startTime descending (most recent first).
  Future<List<ContractionSession>> getSessionHistory({
    int? limit,
    DateTime? before,
  }) async {
    return await _repository.getSessionHistory(
      limit: limit ?? defaultHistoryLimit,
      before: before,
    );
  }

  /// Delete old sessions beyond the retention period.
  ///
  /// Removes sessions older than [maxDays] (defaults to GDPR-compliant 365 days).
  /// This helps comply with data minimization principles by not retaining
  /// medical data longer than necessary.
  ///
  /// Returns the number of sessions deleted.
  Future<int> deleteOldSessions([int? maxDays]) async {
    final cutoffDate = DataRetentionHelper.retentionCutoffDate(maxDays);
    return await _repository.deleteSessionsOlderThan(cutoffDate);
  }
}

