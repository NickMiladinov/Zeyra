/// Exception thrown by contraction timer operations when business rules are violated.
/// 
/// This provides structured error handling with specific error types
/// for different validation failures.
class ContractionTimerException implements Exception {
  /// Human-readable error message
  final String message;
  
  /// Categorized error type for programmatic handling
  final ContractionTimerErrorType type;

  const ContractionTimerException(this.message, this.type);

  @override
  String toString() => 'ContractionTimerException: $message (type: $type)';
}

/// Categories of contraction timer errors for programmatic handling.
enum ContractionTimerErrorType {
  /// Attempted to end session with zero contractions recorded
  noContractionsRecorded,
  
  /// Attempted to add contraction beyond maximum limit (200)
  maxContractionsReached,
  
  /// Attempted to get active session when none exists
  noActiveSession,
  
  /// Attempted to create session when one is already active
  sessionAlreadyActive,
  
  /// Attempted to start a contraction while another is already active
  contractionAlreadyActive,
  
  /// Attempted to stop a contraction that doesn't exist or isn't active
  noActiveContraction,
  
  /// Attempted to update/delete a contraction that doesn't exist
  contractionNotFound,
  
  /// Attempted to update a contraction with invalid data (e.g., end before start)
  invalidContractionData,
  
  /// Cannot start contraction timer while kick counter is active
  kickCounterActive,
}

