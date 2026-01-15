import '../entities/contraction_timer/contraction.dart';
import '../entities/contraction_timer/contraction_intensity.dart';
import '../entities/contraction_timer/contraction_session.dart';

/// Repository interface for contraction timer data operations.
/// 
/// Defines the contract for managing contraction timing sessions and their
/// associated contractions. Implementation handles data persistence, encryption,
/// and pregnancy context integration.
abstract class ContractionTimerRepository {
  // --------------------------------------------------------------------------
  // Session Management
  // --------------------------------------------------------------------------
  
  /// Create a new contraction timing session.
  /// 
  /// Initializes a session with current timestamp, generates UUID,
  /// and sets up default values.
  /// 
  /// Throws [ContractionTimerException] if an active session already exists.
  Future<ContractionSession> createSession();
  
  /// Get the currently active session, if one exists.
  /// 
  /// Returns null if no active session is found.
  /// Includes all contractions associated with the session.
  Future<ContractionSession?> getActiveSession();
  
  /// End a session by setting endTime and marking as inactive.
  /// 
  /// [sessionId] - ID of the session to end
  /// 
  /// If session has an active contraction, it will be stopped automatically.
  Future<void> endSession(String sessionId);
  
  /// Permanently delete a session and all its contractions.
  /// 
  /// [sessionId] - ID of the session to delete
  /// 
  /// Used when user discards a session without completing it.
  /// Cascades to delete all associated contractions.
  Future<void> deleteSession(String sessionId);

  /// Get a single session by ID with all its contractions.
  /// 
  /// [sessionId] - ID of the session to retrieve
  /// 
  /// Returns null if session is not found.
  /// Includes all contractions associated with the session, sorted by startTime.
  Future<ContractionSession?> getSession(String sessionId);

  /// Update the note attached to a session.
  /// 
  /// [sessionId] - ID of the session to update
  /// [note] - New note text (null to clear the note)
  /// 
  /// Returns the updated session.
  /// Note will be encrypted before storage.
  Future<ContractionSession> updateSessionNote(String sessionId, String? note);
  
  /// Update individual 5-1-1 criterion achievement status for a session.
  /// 
  /// [sessionId] - ID of the session to update
  /// [achievedDuration] - Whether duration criterion (≥ 1 min) was achieved
  /// [durationAchievedAt] - When duration criterion was first achieved
  /// [achievedFrequency] - Whether frequency criterion (≤ 5 min apart) was achieved
  /// [frequencyAchievedAt] - When frequency criterion was first achieved
  /// [achievedConsistency] - Whether consistency criterion (1 hour) was achieved
  /// [consistencyAchievedAt] - When consistency criterion was first achieved
  /// 
  /// Returns the updated session.
  /// Only provided parameters will be updated (null means no change).
  Future<ContractionSession> updateSessionCriteria(
    String sessionId, {
    bool? achievedDuration,
    DateTime? durationAchievedAt,
    bool? achievedFrequency,
    DateTime? frequencyAchievedAt,
    bool? achievedConsistency,
    DateTime? consistencyAchievedAt,
  });
  
  // --------------------------------------------------------------------------
  // Contraction Operations
  // --------------------------------------------------------------------------
  
  /// Start a new contraction in the specified session.
  /// 
  /// [sessionId] - ID of the session to add contraction to
  /// [intensity] - User's perception of contraction intensity (defaults to moderate)
  /// 
  /// Creates a contraction with startTime set to now and endTime null.
  /// Returns the created contraction entity.
  /// 
  /// Throws [ContractionTimerException] if a contraction is already active.
  Future<Contraction> startContraction(
    String sessionId, {
    ContractionIntensity intensity = ContractionIntensity.moderate,
  });
  
  /// Stop the currently active contraction in the specified session.
  /// 
  /// [contractionId] - ID of the contraction to stop
  /// 
  /// Sets endTime to current timestamp.
  /// Returns the updated contraction.
  /// 
  /// Throws [ContractionTimerException] if contraction doesn't exist or is not active.
  Future<Contraction> stopContraction(String contractionId);
  
  /// Update an existing contraction's properties.
  /// 
  /// [contractionId] - ID of the contraction to update
  /// [startTime] - New start time (optional)
  /// [duration] - New duration, which updates endTime (optional)
  /// [intensity] - New intensity (optional)
  /// 
  /// Returns the updated contraction.
  /// Validates that endTime is after startTime.
  /// 
  /// Throws [ContractionTimerException] if contraction doesn't exist or data is invalid.
  Future<Contraction> updateContraction(
    String contractionId, {
    DateTime? startTime,
    Duration? duration,
    ContractionIntensity? intensity,
  });
  
  /// Delete a specific contraction from a session.
  /// 
  /// [contractionId] - ID of the contraction to delete
  /// 
  /// Used when user wants to remove an incorrectly recorded contraction.
  /// 
  /// Throws [ContractionTimerException] if contraction doesn't exist.
  Future<void> deleteContraction(String contractionId);
  
  // --------------------------------------------------------------------------
  // History & Context
  // --------------------------------------------------------------------------
  
  /// Get historical contraction timing sessions.
  ///
  /// [limit] - Optional maximum number of sessions to return
  /// [before] - Optional timestamp to get sessions before
  ///
  /// Returns sessions ordered by startTime descending (most recent first).
  /// Includes all contractions for each session.
  Future<List<ContractionSession>> getSessionHistory({
    int? limit,
    DateTime? before,
  });

  /// Delete sessions older than the specified date.
  ///
  /// [cutoffDate] - Sessions with startTime before this date will be deleted
  ///
  /// Returns the number of sessions deleted.
  /// Cascades to delete all associated contractions.
  Future<int> deleteSessionsOlderThan(DateTime cutoffDate);
  
  /// Get the pregnancy week associated with a session.
  /// 
  /// [sessionId] - ID of the session
  /// 
  /// Retrieves pregnancy week from user's pregnancy profile based on
  /// the session's start time. Returns null if no pregnancy profile exists.
  /// 
  /// Note: This is derived from pregnancy profile, not stored with session.
  Future<int?> getPregnancyWeekForSession(String sessionId);
}

