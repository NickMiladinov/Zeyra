/// Constants for contraction timer feature business logic.
/// 
/// These values define clinical thresholds for the 5-1-1 rule based on
/// NHS guidelines with practical tolerances for user input variability.
class ContractionTimerConstants {
  ContractionTimerConstants._(); // Prevent instantiation
  
  // --------------------------------------------------------------------------
  // Duration Thresholds (The "1" in 5-1-1)
  // --------------------------------------------------------------------------
  
  /// Minimum duration for a valid contraction (>= 45 seconds)
  /// 
  /// Clinical rationale: Active labor contractions typically last 45-60 seconds.
  /// This threshold accounts for reaction time and allows clinically significant
  /// contractions to be counted.
  static const Duration durationValidThreshold = Duration(seconds: 45);
  
  /// Duration below which a contraction is considered too weak/short (< 30 seconds)
  /// 
  /// Contractions shorter than this are likely Braxton Hicks or measurement errors.
  static const Duration durationInvalidThreshold = Duration(seconds: 30);
  
  /// Gray zone threshold (30-45 seconds)
  /// 
  /// Contractions in this range are counted but marked as "weak".
  /// They don't reset the timer but don't count toward the 80% validity requirement.
  static const Duration durationWeakThreshold = Duration(seconds: 30);
  
  // --------------------------------------------------------------------------
  // Frequency Thresholds (The "5" in 5-1-1)
  // --------------------------------------------------------------------------
  
  /// Maximum time between contraction starts for valid frequency (<= 6 minutes)
  /// 
  /// Clinical rationale: "5 minutes apart" means frequent. Setting this to 6 minutes
  /// avoids excluding labor at 5m 15s, which is still clinically significant.
  static const Duration frequencyValidThreshold = Duration(minutes: 6);
  
  /// Minimum time between contractions (>= 2 minutes)
  /// 
  /// Intervals shorter than 2 minutes may indicate hyperstimulation or measurement
  /// error, but are treated as valid/urgent for safety.
  static const Duration frequencyMinThreshold = Duration(minutes: 2);
  
  // --------------------------------------------------------------------------
  // Rolling Window (The "1 Hour" in 5-1-1)
  // --------------------------------------------------------------------------
  
  /// Duration of the rolling window for 5-1-1 evaluation (60 minutes)
  /// 
  /// The algorithm checks if the pattern has been maintained for the last hour,
  /// not if an hour has passed since the first contraction.
  static const Duration rollingWindowDuration = Duration(minutes: 60);
  
  // --------------------------------------------------------------------------
  // Consistency Requirements
  // --------------------------------------------------------------------------
  
  /// Minimum number of contractions needed in the window to evaluate 5-1-1
  /// 
  /// Rationale: Need approximately 6-10 contractions in an hour to mathematically
  /// prove a 5-minute frequency pattern.
  static const int minimumContractionsInWindow = 6;
  
  /// Percentage of contractions that must meet criteria (80%)
  /// 
  /// Allows for 1-2 bad data points due to user error (missed button press,
  /// forgot to stop timer, etc.) without invalidating the entire pattern.
  static const double validityPercentageRequired = 0.80;
  
  // --------------------------------------------------------------------------
  // Reset Conditions (Individual per Check)
  // --------------------------------------------------------------------------
  
  /// Duration Check Reset: Number of consecutive short contractions (3)
  /// 
  /// If the last 3 contractions were all < 30 seconds, the duration
  /// check resets (likely false labor or Braxton Hicks).
  static const int durationResetConsecutiveCount = 3;
  
  /// Duration threshold for "too short" in duration reset (< 30 seconds)
  static const Duration durationResetThreshold = Duration(seconds: 30);
  
  /// Frequency Check Reset: Time gap that resets frequency (> 20 minutes)
  /// 
  /// If no contraction is recorded for more than 20 minutes, the frequency
  /// pattern is broken (common in prodromal labor).
  static const Duration frequencyResetGapThreshold = Duration(minutes: 20);
  
  /// Consistency Check Reset: Number of irregular intervals (3 out of last 5)
  /// 
  /// If 3 or more of the last 5 intervals are invalid (> 6 min or < 2 min),
  /// the consistency check resets.
  static const int consistencyResetCheckCount = 5;
  static const int consistencyResetInvalidThreshold = 3;
  
  // --------------------------------------------------------------------------
  // Session Limits
  // --------------------------------------------------------------------------
  
  /// Maximum number of contractions allowed per session
  /// 
  /// Prevents abuse/bugs and is well beyond typical labor duration.
  static const int maxContractionsPerSession = 200;
  
  /// Minimum contractions required to end a session
  /// 
  /// Ensures meaningful data is collected before completing.
  static const int minContractionsToEnd = 1;
}

