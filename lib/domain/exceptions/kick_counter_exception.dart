/// Exception thrown by kick counter operations when business rules are violated.
/// 
/// This provides structured error handling with specific error types
/// for different validation failures.
class KickCounterException implements Exception {
  /// Human-readable error message
  final String message;
  
  /// Categorized error type for programmatic handling
  final KickCounterErrorType type;

  const KickCounterException(this.message, this.type);

  @override
  String toString() => 'KickCounterException: $message (type: $type)';
}

/// Categories of kick counter errors for programmatic handling.
enum KickCounterErrorType {
  /// Attempted to end session with zero kicks recorded
  noKicksRecorded,
  
  /// Attempted to add kick beyond maximum limit (100)
  maxKicksReached,
  
  /// Attempted to get active session when none exists
  noActiveSession,
  
  /// Attempted to create session when one is already active
  sessionAlreadyActive,
  
  /// Attempted to pause an already paused session
  sessionAlreadyPaused,
  
  /// Attempted to resume a session that is not paused
  sessionNotPaused,
  
  /// Attempted to undo when no kicks exist
  noKicksToUndo,
}

