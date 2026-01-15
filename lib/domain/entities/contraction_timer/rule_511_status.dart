/// Status object for 5-1-1 rule evaluation results.
/// 
/// This class encapsulates the results of evaluating whether contractions
/// meet the NHS 5-1-1 rule criteria (1 minute long, 5 minutes apart, for 1 hour).
class Rule511Status {
  /// Whether the 5-1-1 alert should be shown to the user
  /// 
  /// True when:
  /// - At least 6 contractions in the last 60 minutes
  /// - At least 80% meet duration (>= 45s) and frequency (<= 6 min) criteria
  /// - No critical reset conditions have been triggered
  final bool alertActive;
  
  /// Number of contractions in the rolling 60-minute window
  final int contractionsInWindow;
  
  /// How many contractions meet the duration criteria (>= 45 seconds)
  final int validDurationCount;
  
  /// How many contractions meet the frequency criteria (<= 6 minutes apart)
  final int validFrequencyCount;
  
  /// Overall validity percentage (contractions meeting both criteria / total)
  /// 
  /// Range: 0.0 to 1.0
  /// Alert triggers when this reaches 0.80 (80%)
  final double validityPercentage;
  
  /// Progress toward meeting the duration threshold (for UI display)
  /// 
  /// Range: 0.0 to 1.0
  /// Calculated as: validDurationCount / contractionsInWindow
  final double durationProgress;
  
  /// Progress toward meeting the frequency threshold (for UI display)
  /// 
  /// Range: 0.0 to 1.0
  /// Calculated as: validFrequencyCount / (contractionsInWindow - 1)
  final double frequencyProgress;
  
  /// Progress toward maintaining the pattern for 1 hour (for UI display)
  /// 
  /// Range: 0.0 to 1.0
  /// Based on how long the valid pattern has been sustained
  final double consistencyProgress;
  
  /// Whether the duration check has been reset
  /// 
  /// Reset when recent contractions are consistently too short (< 30s)
  final bool isDurationReset;
  
  /// Whether the frequency check has been reset
  /// 
  /// Reset when contractions are too far apart (> 20 min gap)
  final bool isFrequencyReset;
  
  /// Whether the consistency/time check has been reset
  /// 
  /// Reset when pattern hasn't been maintained or has large gaps
  final bool isConsistencyReset;
  
  /// Reason for duration reset, if applicable
  final String? durationResetReason;
  
  /// Reason for frequency reset, if applicable
  final String? frequencyResetReason;
  
  /// Reason for consistency reset, if applicable
  final String? consistencyResetReason;
  
  /// Time when the first valid contraction in the current window started
  /// 
  /// Used to calculate how long the pattern has been maintained.
  final DateTime? windowStartTime;

  const Rule511Status({
    required this.alertActive,
    required this.contractionsInWindow,
    required this.validDurationCount,
    required this.validFrequencyCount,
    required this.validityPercentage,
    required this.durationProgress,
    required this.frequencyProgress,
    required this.consistencyProgress,
    this.isDurationReset = false,
    this.isFrequencyReset = false,
    this.isConsistencyReset = false,
    this.durationResetReason,
    this.frequencyResetReason,
    this.consistencyResetReason,
    this.windowStartTime,
  });

  /// Create a default "empty" status (no contractions yet)
  factory Rule511Status.empty() {
    return const Rule511Status(
      alertActive: false,
      contractionsInWindow: 0,
      validDurationCount: 0,
      validFrequencyCount: 0,
      validityPercentage: 0.0,
      durationProgress: 0.0,
      frequencyProgress: 0.0,
      consistencyProgress: 0.0,
    );
  }

  /// Whether any reset condition is active
  bool get hasAnyReset => isDurationReset || isFrequencyReset || isConsistencyReset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rule511Status &&
          runtimeType == other.runtimeType &&
          alertActive == other.alertActive &&
          contractionsInWindow == other.contractionsInWindow &&
          validDurationCount == other.validDurationCount &&
          validFrequencyCount == other.validFrequencyCount &&
          validityPercentage == other.validityPercentage &&
          durationProgress == other.durationProgress &&
          frequencyProgress == other.frequencyProgress &&
          consistencyProgress == other.consistencyProgress &&
          isDurationReset == other.isDurationReset &&
          isFrequencyReset == other.isFrequencyReset &&
          isConsistencyReset == other.isConsistencyReset &&
          durationResetReason == other.durationResetReason &&
          frequencyResetReason == other.frequencyResetReason &&
          consistencyResetReason == other.consistencyResetReason &&
          windowStartTime == other.windowStartTime;

  @override
  int get hashCode =>
      alertActive.hashCode ^
      contractionsInWindow.hashCode ^
      validDurationCount.hashCode ^
      validFrequencyCount.hashCode ^
      validityPercentage.hashCode ^
      durationProgress.hashCode ^
      frequencyProgress.hashCode ^
      consistencyProgress.hashCode ^
      isDurationReset.hashCode ^
      isFrequencyReset.hashCode ^
      isConsistencyReset.hashCode ^
      durationResetReason.hashCode ^
      frequencyResetReason.hashCode ^
      consistencyResetReason.hashCode ^
      windowStartTime.hashCode;

  @override
  String toString() =>
      'Rule511Status(alertActive: $alertActive, '
      'contractionsInWindow: $contractionsInWindow, '
      'validDurationCount: $validDurationCount, '
      'validFrequencyCount: $validFrequencyCount, '
      'validityPercentage: ${(validityPercentage * 100).toStringAsFixed(1)}%, '
      'isDurationReset: $isDurationReset, isFrequencyReset: $isFrequencyReset, '
      'isConsistencyReset: $isConsistencyReset)';
}

