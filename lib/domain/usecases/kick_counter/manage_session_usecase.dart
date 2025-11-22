import '../../entities/kick_counter/kick.dart';
import '../../entities/kick_counter/kick_counter_constants.dart';
import '../../entities/kick_counter/kick_session.dart';
import '../../exceptions/kick_counter_exception.dart';
import '../../repositories/kick_counter_repository.dart';

/// Use case for managing kick counting sessions.
/// 
/// Orchestrates session lifecycle operations with validation and business rules.
/// Enforces constraints like maximum kicks per session, minimum kicks to end,
/// and proper pause/resume sequencing.
class ManageSessionUseCase {
  final KickCounterRepository _repository;

  const ManageSessionUseCase({
    required KickCounterRepository repository,
  }) : _repository = repository;

  // --------------------------------------------------------------------------
  // State Queries
  // --------------------------------------------------------------------------
  
  /// Get the currently active session, if one exists.
  Future<KickSession?> getActiveSession() async {
    return await _repository.getActiveSession();
  }

  // --------------------------------------------------------------------------
  // Session Lifecycle
  // --------------------------------------------------------------------------

  /// Start a new kick counting session.
  /// 
  /// Validates that no active session exists before creating a new one.
  /// 
  /// Returns the newly created session.
  /// 
  /// Throws [KickCounterException] with type [sessionAlreadyActive]
  /// if an active session already exists.
  Future<KickSession> startSession() async {
    // Check if active session exists
    final activeSession = await _repository.getActiveSession();
    if (activeSession != null) {
      throw const KickCounterException(
        'An active session already exists. Please complete or discard it first.',
        KickCounterErrorType.sessionAlreadyActive,
      );
    }

    return await _repository.createSession();
  }

  /// Record a kick in the specified session.
  /// 
  /// [sessionId] - ID of the session to add kick to
  /// [strength] - User's perception of movement strength
  /// 
  /// Validates that session hasn't reached maximum kick limit (100).
  /// Returns the updated session and a flag indicating if the user should
  /// be prompted to end the session (after 10 kicks).
  /// 
  /// Throws [KickCounterException] with type [maxKicksReached]
  /// if session already has 100 kicks.
  Future<({KickSession session, bool shouldPromptEnd})> recordKick(
    String sessionId,
    MovementStrength strength,
  ) async {
    // Get current session to check kick count
    final session = await _repository.getActiveSession();
    if (session == null || session.id != sessionId) {
      throw const KickCounterException(
        'No active session found.',
        KickCounterErrorType.noActiveSession,
      );
    }

    // Validate max kicks limit
    if (session.kickCount >= KickCounterConstants.maxKicksPerSession) {
      throw const KickCounterException(
        'Maximum ${KickCounterConstants.maxKicksPerSession} kicks per session reached.',
        KickCounterErrorType.maxKicksReached,
      );
    }

    // Add the kick
    await _repository.addKick(sessionId, strength);

    // Fetch updated session
    final updatedSession = await _repository.getActiveSession();
    if (updatedSession == null) {
      throw const KickCounterException(
        'Session lost after update.',
        KickCounterErrorType.noActiveSession,
      );
    }

    // Check if should prompt user to end session (at 10 kicks)
    // Note: Use updatedSession.kickCount which includes the new kick
    final shouldPrompt =
        updatedSession.kickCount == KickCounterConstants.promptEndSessionAt;

    return (session: updatedSession, shouldPromptEnd: shouldPrompt);
  }

  /// Remove the most recently added kick from the session.
  /// 
  /// [sessionId] - ID of the session to remove kick from
  /// 
  /// Provides undo functionality for accidental taps.
  /// Returns the updated session.
  /// 
  /// Throws [KickCounterException] with type [noKicksToUndo]
  /// if session has no kicks.
  Future<KickSession> undoLastKick(String sessionId) async {
    // Get current session to check if kicks exist
    final session = await _repository.getActiveSession();
    if (session == null || session.id != sessionId) {
      throw const KickCounterException(
        'No active session found.',
        KickCounterErrorType.noActiveSession,
      );
    }

    if (session.kickCount == 0) {
      throw const KickCounterException(
        'No kicks to undo.',
        KickCounterErrorType.noKicksToUndo,
      );
    }

    await _repository.removeLastKick(sessionId);

    final updatedSession = await _repository.getActiveSession();
    if (updatedSession == null) {
      throw const KickCounterException(
        'Session lost after update.',
        KickCounterErrorType.noActiveSession,
      );
    }
    return updatedSession;
  }

  /// End the specified session.
  /// 
  /// [sessionId] - ID of the session to end
  /// 
  /// Validates that at least one kick has been recorded.
  /// Sets endTime to current timestamp and marks session as inactive.
  /// 
  /// Throws [KickCounterException] with type [noKicksRecorded]
  /// if session has zero kicks. Medical guidance requires contacting
  /// healthcare provider if no movement is felt.
  Future<void> endSession(String sessionId) async {
    // Get current session to validate kicks exist
    final session = await _repository.getActiveSession();
    if (session == null || session.id != sessionId) {
      throw const KickCounterException(
        'No active session found.',
        KickCounterErrorType.noActiveSession,
      );
    }

    if (session.kickCount == 0) {
      throw const KickCounterException(
        'Cannot end session with no kicks recorded. If you feel no movement, '
        'please contact your midwife immediately.',
        KickCounterErrorType.noKicksRecorded,
      );
    }

    await _repository.endSession(sessionId);
  }

  /// Permanently delete a session.
  /// 
  /// [sessionId] - ID of the session to discard
  /// 
  /// Used when user wants to discard a session without completing it.
  /// Removes session and all associated kicks from database.
  Future<void> discardSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
  }

  // --------------------------------------------------------------------------
  // Pause/Resume Operations
  // --------------------------------------------------------------------------

  /// Pause the specified session.
  /// 
  /// [sessionId] - ID of the session to pause
  /// 
  /// Idempotent operation - if session is already paused, this is a no-op.
  /// Sets pausedAt timestamp to track pause duration.
  /// Returns the updated session.
  Future<KickSession> pauseSession(String sessionId) async {
    // Get current session to check if already paused
    var session = await _repository.getActiveSession();
    if (session == null || session.id != sessionId) {
      throw const KickCounterException(
        'No active session found.',
        KickCounterErrorType.noActiveSession,
      );
    }

    // Idempotent - if already paused, return current session
    if (session.isPaused) {
      return session;
    }

    await _repository.pauseSession(sessionId);

    session = await _repository.getActiveSession();
    if (session == null) {
       throw const KickCounterException(
        'Session lost after update.',
        KickCounterErrorType.noActiveSession,
      );
    }
    return session;
  }

  /// Resume the specified session.
  /// 
  /// [sessionId] - ID of the session to resume
  /// 
  /// Calculates elapsed pause duration, adds to total paused time,
  /// increments pause count, and clears pausedAt timestamp.
  /// Returns the updated session.
  /// 
  /// Throws [KickCounterException] with type [sessionNotPaused]
  /// if session is not currently paused.
  Future<KickSession> resumeSession(String sessionId) async {
    // Get current session to validate it's paused
    var session = await _repository.getActiveSession();
    if (session == null || session.id != sessionId) {
      throw const KickCounterException(
        'No active session found.',
        KickCounterErrorType.noActiveSession,
      );
    }

    if (!session.isPaused) {
      throw const KickCounterException(
        'Session is not paused.',
        KickCounterErrorType.sessionNotPaused,
      );
    }

    await _repository.resumeSession(sessionId);

    session = await _repository.getActiveSession();
    if (session == null) {
       throw const KickCounterException(
        'Session lost after update.',
        KickCounterErrorType.noActiveSession,
      );
    }
    return session;
  }
}

