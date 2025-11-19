import '../entities/kick_counter/kick.dart';
import '../entities/kick_counter/kick_session.dart';

/// Repository interface for kick counter data operations.
/// 
/// Defines the contract for managing kick counting sessions and their
/// associated kicks. Implementation handles data persistence, encryption,
/// and pregnancy context integration.
abstract class KickCounterRepository {
  // --------------------------------------------------------------------------
  // Session Management
  // --------------------------------------------------------------------------
  
  /// Create a new kick counting session.
  /// 
  /// Initializes a session with current timestamp, generates UUID,
  /// and sets up default values for pause tracking.
  /// 
  /// Throws [KickCounterException] if an active session already exists.
  Future<KickSession> createSession();
  
  /// Get the currently active session, if one exists.
  /// 
  /// Returns null if no active session is found.
  /// Includes all kicks associated with the session.
  Future<KickSession?> getActiveSession();
  
  /// End a session by setting endTime and marking as inactive.
  /// 
  /// [sessionId] - ID of the session to end
  /// 
  /// If session has an active pause, it will be closed automatically.
  Future<void> endSession(String sessionId);
  
  /// Permanently delete a session and all its kicks.
  /// 
  /// [sessionId] - ID of the session to delete
  /// 
  /// Used when user discards a session without completing it.
  /// Cascades to delete all associated kicks.
  Future<void> deleteSession(String sessionId);
  
  // --------------------------------------------------------------------------
  // Kick Operations
  // --------------------------------------------------------------------------
  
  /// Add a kick to the specified session.
  /// 
  /// [sessionId] - ID of the session to add kick to
  /// [strength] - User's perception of movement strength
  /// 
  /// Automatically assigns sequence number and encrypts strength data.
  /// Returns the created kick entity.
  Future<Kick> addKick(String sessionId, MovementStrength strength);
  
  /// Remove the most recently added kick from a session.
  /// 
  /// [sessionId] - ID of the session to remove kick from
  /// 
  /// Deletes the kick with the highest sequence number.
  /// Used for undo functionality.
  Future<void> removeLastKick(String sessionId);
  
  // --------------------------------------------------------------------------
  // Pause Operations
  // --------------------------------------------------------------------------
  
  /// Pause the specified session.
  /// 
  /// [sessionId] - ID of the session to pause
  /// 
  /// Sets pausedAt to current timestamp.
  /// Does NOT modify totalPausedDuration or pauseCount yet.
  Future<void> pauseSession(String sessionId);
  
  /// Resume the specified session.
  /// 
  /// [sessionId] - ID of the session to resume
  /// 
  /// Calculates elapsed pause duration, adds to totalPausedDuration,
  /// increments pauseCount, and clears pausedAt.
  Future<void> resumeSession(String sessionId);
  
  // --------------------------------------------------------------------------
  // History & Context
  // --------------------------------------------------------------------------
  
  /// Get historical kick counting sessions.
  /// 
  /// [limit] - Optional maximum number of sessions to return
  /// [before] - Optional timestamp to get sessions before
  /// 
  /// Returns sessions ordered by startTime descending (most recent first).
  /// Includes all kicks for each session.
  Future<List<KickSession>> getSessionHistory({
    int? limit,
    DateTime? before,
  });
  
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

