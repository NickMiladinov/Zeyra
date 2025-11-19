/// Constants for kick counter feature business logic.
/// 
/// These values define key thresholds and limits for the kick counting
/// feature based on medical guidelines and UX considerations.
class KickCounterConstants {
  KickCounterConstants._(); // Prevent instantiation
  
  /// Maximum number of kicks allowed per session to prevent abuse/bugs
  /// 
  /// This limit protects against:
  /// - Accidental repeated taps
  /// - Potential bugs causing infinite loops
  /// - Unrealistic medical scenarios (10 kicks typically sufficient)
  static const int maxKicksPerSession = 100;
  
  /// Number of kicks at which to prompt user if they want to end session
  /// 
  /// Medical standard: Count 10 kicks, noting the time taken.
  /// This is a key milestone in fetal movement monitoring.
  static const int promptEndSessionAt = 10;
}

