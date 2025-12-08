/// Analytics data for a single kick counting session.
/// 
/// Provides information about whether a session meets minimum requirements
/// for inclusion in analytics and whether it's a statistical outlier.
class KickSessionAnalytics {
  /// Duration from session start to the 10th kick (null if < 10 kicks)
  final Duration? durationToTen;
  
  /// Whether this session has at least 10 kicks and can be included in analytics
  final bool hasMinimumKicks;
  
  /// Whether this session took significantly longer than average (> avg + 2 std dev)
  /// Faster sessions are not flagged as outliers since they're not medically concerning.
  final bool isOutlier;

  const KickSessionAnalytics({
    this.durationToTen,
    required this.hasMinimumKicks,
    this.isOutlier = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KickSessionAnalytics &&
          runtimeType == other.runtimeType &&
          durationToTen == other.durationToTen &&
          hasMinimumKicks == other.hasMinimumKicks &&
          isOutlier == other.isOutlier;

  @override
  int get hashCode =>
      durationToTen.hashCode ^
      hasMinimumKicks.hashCode ^
      isOutlier.hashCode;

  @override
  String toString() =>
      'KickSessionAnalytics(durationToTen: $durationToTen, hasMinimumKicks: $hasMinimumKicks, '
      'isOutlier: $isOutlier)';
}

/// Aggregate analytics for a collection of kick counting sessions.
/// 
/// Provides statistical analysis including mean, standard deviation,
/// and outlier thresholds. Used to identify concerning patterns in
/// fetal movement timing.
class KickHistoryAnalytics {
  /// Number of sessions that have >= 10 kicks and are included in analytics
  final int validSessionCount;
  
  /// Average duration to reach 10 kicks across valid sessions
  final Duration? averageDurationToTen;
  
  /// Standard deviation of durations to reach 10 kicks
  final Duration? standardDeviation;
  
  /// Upper threshold for outliers (average + 2 * standard deviation)
  /// Sessions above this threshold take significantly longer than usual and are flagged
  final Duration? upperThreshold;
  
  /// Whether there are enough valid sessions (>= 7) to show meaningful analytics
  final bool hasEnoughDataForAnalytics;

  const KickHistoryAnalytics({
    required this.validSessionCount,
    this.averageDurationToTen,
    this.standardDeviation,
    this.upperThreshold,
  }) : hasEnoughDataForAnalytics = validSessionCount >= 7;

  /// Minimum number of valid sessions required to show analytics
  static const int minSessionsForAnalytics = 7;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KickHistoryAnalytics &&
          runtimeType == other.runtimeType &&
          validSessionCount == other.validSessionCount &&
          averageDurationToTen == other.averageDurationToTen &&
          standardDeviation == other.standardDeviation &&
          upperThreshold == other.upperThreshold;

  @override
  int get hashCode =>
      validSessionCount.hashCode ^
      averageDurationToTen.hashCode ^
      standardDeviation.hashCode ^
      upperThreshold.hashCode;

  @override
  String toString() =>
      'KickHistoryAnalytics(validSessionCount: $validSessionCount, '
      'averageDurationToTen: $averageDurationToTen, '
      'standardDeviation: $standardDeviation, '
      'hasEnoughDataForAnalytics: $hasEnoughDataForAnalytics)';
}

