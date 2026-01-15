import 'dart:math' as math;

import '../../entities/contraction_timer/contraction.dart';
import '../../entities/contraction_timer/contraction_session.dart';
import '../../entities/contraction_timer/contraction_timer_constants.dart';
import '../../entities/contraction_timer/rule_511_status.dart';

/// Use case for calculating 5-1-1 rule status with rolling window and tolerances.
/// 
/// Implements the NHS 5-1-1 guideline for labor detection:
/// - 1 minute: Contractions lasting >= 45 seconds (with tolerance)
/// - 5 minutes: Contractions <= 6 minutes apart (with tolerance)
/// - 1 hour: Pattern sustained for 60 minutes (rolling window)
/// 
/// Uses an 80% validity threshold to account for user input errors.
class Calculate511RuleUseCase {
  const Calculate511RuleUseCase();

  /// Evaluate which 5-1-1 criteria were achieved for a completed session.
  /// 
  /// Uses the existing calculate() logic to determine achievements:
  /// - Duration: At least 1 valid contraction (≥45s) AND no duration reset
  /// - Frequency: At least 1 valid interval (≤6min) AND no frequency reset
  /// - Consistency: Same as alertActive (80% validity, no critical resets, 1hr+)
  /// 
  /// Returns a record with (achievedDuration, achievedFrequency, achievedConsistency)
  ({bool duration, bool frequency, bool consistency}) evaluateAchievedCriteria(
    ContractionSession session,
  ) {
    // Use the existing calculate method to get the status
    final status = calculate(session);
    
    // Duration achieved: at least 1 valid contraction AND not reset
    final achievedDuration = status.validDurationCount > 0 && !status.isDurationReset;
    
    // Frequency achieved: at least 1 valid interval AND not reset
    final achievedFrequency = status.validFrequencyCount > 0 && !status.isFrequencyReset;
    
    // Consistency achieved: same as alertActive (uses existing 80% validity logic)
    final achievedConsistency = status.alertActive;
    
    return (
      duration: achievedDuration,
      frequency: achievedFrequency,
      consistency: achievedConsistency,
    );
  }

  /// Calculate the current 5-1-1 rule status for a session.
  /// 
  /// [session] - The contraction session to evaluate
  /// 
  /// Returns a [Rule511Status] object with:
  /// - Whether the alert should be active
  /// - Progress metrics for UI display
  /// - Reset state if pattern has stopped
  Rule511Status calculate(ContractionSession session) {
    // Get contractions in the rolling 60-minute window
    final now = DateTime.now();
    final windowStart = now.subtract(ContractionTimerConstants.rollingWindowDuration);
    
    final contractionsInWindow = session.contractions
        .where((c) => c.startTime.isAfter(windowStart))
        .toList();
    
    // Sort by start time to ensure chronological order
    contractionsInWindow.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Check reset conditions (these apply to the full session, not just window)
    final durationResetInfo = _checkDurationReset(session);
    final frequencyResetInfo = _checkFrequencyReset(session);
    final consistencyResetInfo = _checkConsistencyReset(contractionsInWindow);

    // Check if we have enough contractions to evaluate for alert
    if (contractionsInWindow.length < ContractionTimerConstants.minimumContractionsInWindow) {
      // Still calculate actual counts for progress display, even though alert won't trigger
      final validDurationCount = _countValidDurations(contractionsInWindow);
      final validFrequencyCount = _countValidFrequencies(contractionsInWindow);
      
      // Calculate validity percentage even with < 6 contractions for consistency progress
      final validContractions = _countOverallValid(contractionsInWindow);
      final validityPercentage = contractionsInWindow.isEmpty 
          ? 0.0 
          : validContractions / contractionsInWindow.length;

      return Rule511Status(
        alertActive: false,
        contractionsInWindow: contractionsInWindow.length,
        validDurationCount: validDurationCount,
        validFrequencyCount: validFrequencyCount,
        validityPercentage: validityPercentage,
        durationProgress: _calculateDurationProgress(
          contractionsInWindow,
          validDurationCount,
          durationResetInfo.$1,
        ),
        frequencyProgress: _calculateFrequencyProgress(
          contractionsInWindow,
          validFrequencyCount,
          frequencyResetInfo.$1,
        ),
        consistencyProgress: _calculateConsistencyProgress(
          contractionsInWindow,
          validContractions,
          validityPercentage,
          consistencyResetInfo.$1,
        ),
        isDurationReset: durationResetInfo.$1,
        durationResetReason: durationResetInfo.$2,
        isFrequencyReset: frequencyResetInfo.$1,
        frequencyResetReason: frequencyResetInfo.$2,
        isConsistencyReset: consistencyResetInfo.$1,
        consistencyResetReason: consistencyResetInfo.$2,
        windowStartTime: contractionsInWindow.isNotEmpty
            ? contractionsInWindow.first.startTime
            : null,
      );
    }
    
    // Evaluate duration validity for each contraction
    final validDurationCount = _countValidDurations(contractionsInWindow);
    
    // Evaluate frequency validity between contractions
    final validFrequencyCount = _countValidFrequencies(contractionsInWindow);
    
    // Calculate overall validity
    // A contraction is "valid" if it meets both duration AND its frequency to previous is valid
    final validContractions = _countOverallValid(contractionsInWindow);
    final validityPercentage = validContractions / contractionsInWindow.length;
    
    // Check if alert should be active (only if no critical resets)
    // Duration and frequency resets are critical; consistency reset is just informational
    final hasCriticalReset = durationResetInfo.$1 || frequencyResetInfo.$1;
    final alertActive = !hasCriticalReset && 
        validityPercentage >= ContractionTimerConstants.validityPercentageRequired;
    
    // Calculate progress metrics for UI (achievement-based with reset logic)
    final durationProgress = _calculateDurationProgress(
      contractionsInWindow,
      validDurationCount,
      durationResetInfo.$1,
    );
    final frequencyProgress = _calculateFrequencyProgress(
      contractionsInWindow,
      validFrequencyCount,
      frequencyResetInfo.$1,
    );
    final consistencyProgress = _calculateConsistencyProgress(
      contractionsInWindow,
      validContractions,
      validityPercentage,
      consistencyResetInfo.$1,
    );
    
    return Rule511Status(
      alertActive: alertActive,
      contractionsInWindow: contractionsInWindow.length,
      validDurationCount: validDurationCount,
      validFrequencyCount: validFrequencyCount,
      validityPercentage: validityPercentage,
      durationProgress: durationProgress,
      frequencyProgress: frequencyProgress,
      consistencyProgress: consistencyProgress,
      isDurationReset: durationResetInfo.$1,
      durationResetReason: durationResetInfo.$2,
      isFrequencyReset: frequencyResetInfo.$1,
      frequencyResetReason: frequencyResetInfo.$2,
      isConsistencyReset: consistencyResetInfo.$1,
      consistencyResetReason: consistencyResetInfo.$2,
      windowStartTime: contractionsInWindow.first.startTime,
    );
  }

  /// Count contractions that meet the duration threshold (>= 45 seconds)
  int _countValidDurations(List<Contraction> contractions) {
    return contractions.where((c) {
      final duration = c.duration;
      if (duration == null) return false; // Skip active contractions
      return duration >= ContractionTimerConstants.durationValidThreshold;
    }).length;
  }

  /// Count contraction intervals that meet the frequency threshold (<= 6 minutes)
  int _countValidFrequencies(List<Contraction> contractions) {
    if (contractions.length < 2) return 0;
    
    int validCount = 0;
    for (int i = 1; i < contractions.length; i++) {
      final interval = contractions[i].startTime.difference(contractions[i - 1].startTime);
      
      // Valid if <= 6 minutes, also treat < 2 minutes as valid (urgent/hyperstimulation)
      if (interval <= ContractionTimerConstants.frequencyValidThreshold ||
          interval < ContractionTimerConstants.frequencyMinThreshold) {
        validCount++;
      }
    }
    
    return validCount;
  }

  /// Count contractions that meet both duration AND frequency criteria
  int _countOverallValid(List<Contraction> contractions) {
    if (contractions.isEmpty) return 0;
    
    int validCount = 0;
    
    for (int i = 0; i < contractions.length; i++) {
      final contraction = contractions[i];
      
      // Check duration
      final duration = contraction.duration;
      if (duration == null) continue; // Skip active contractions
      
      final durationValid = duration >= ContractionTimerConstants.durationValidThreshold;
      
      // Check frequency (for all except first)
      bool frequencyValid = true;
      if (i > 0) {
        final interval = contraction.startTime.difference(contractions[i - 1].startTime);
        frequencyValid = interval <= ContractionTimerConstants.frequencyValidThreshold ||
            interval < ContractionTimerConstants.frequencyMinThreshold;
      }
      
      if (durationValid && frequencyValid) {
        validCount++;
      }
    }
    
    return validCount;
  }

  /// Check if duration pattern has reset
  /// 
  /// Returns (isReset, reason) tuple
  /// 
  /// Reset when: Last 3 consecutive contractions are all < 30 seconds
  (bool, String?) _checkDurationReset(ContractionSession session) {
    if (session.contractions.length < ContractionTimerConstants.durationResetConsecutiveCount) {
      return (false, null);
    }
    
    final recentCount = ContractionTimerConstants.durationResetConsecutiveCount;
    final recentContractions = session.contractions.sublist(
      session.contractions.length - recentCount,
    );
    
    final allTooShort = recentContractions.every((c) {
      final duration = c.duration;
      if (duration == null) return false; // Active contraction doesn't count
      return duration < ContractionTimerConstants.durationResetThreshold;
    });
    
    if (allTooShort) {
      return (true, 'consecutive_short');
    }
    
    return (false, null);
  }

  /// Check if frequency pattern has reset
  /// 
  /// Returns (isReset, reason) tuple
  /// 
  /// Reset when EITHER:
  /// 1. Gap between last two contractions > 20 minutes
  /// 2. Time since last contraction to now > 20 minutes (user stopped recording)
  (bool, String?) _checkFrequencyReset(ContractionSession session) {
    if (session.contractions.isEmpty) return (false, null);
    
    final lastContraction = session.contractions.last;
    
    // Check 1: Gap between last two contractions (if we have at least 2)
    if (session.contractions.length >= 2) {
      final secondToLast = session.contractions[session.contractions.length - 2];
      final gapBetweenLastTwo = lastContraction.startTime.difference(secondToLast.startTime);
      
      if (gapBetweenLastTwo > ContractionTimerConstants.frequencyResetGapThreshold) {
        return (true, 'gap_too_long');
      }
    }
    
    // Check 2: Time since last contraction to now
    final timeSinceLastContraction = DateTime.now().difference(lastContraction.startTime);
    
    if (timeSinceLastContraction > ContractionTimerConstants.frequencyResetGapThreshold) {
      return (true, 'gap_too_long');
    }
    
    return (false, null);
  }

  /// Check if consistency pattern has reset
  /// 
  /// Returns (isReset, reason) tuple
  /// 
  /// Reset when: 3 or more of the last 5 intervals are invalid
  (bool, String?) _checkConsistencyReset(List<Contraction> contractionsInWindow) {
    if (contractionsInWindow.length < ContractionTimerConstants.consistencyResetCheckCount) {
      return (false, null);
    }
    
    // Get last 5 contractions
    final recentCount = ContractionTimerConstants.consistencyResetCheckCount;
    final recentContractions = contractionsInWindow.sublist(
      contractionsInWindow.length - recentCount,
    );
    
    // Count invalid intervals
    int invalidCount = 0;
    for (int i = 1; i < recentContractions.length; i++) {
      final interval = recentContractions[i].startTime.difference(
        recentContractions[i - 1].startTime,
      );
      
      // Invalid if > 6 minutes
      final tooLong = interval > ContractionTimerConstants.frequencyValidThreshold;
      
      if (tooLong) {
        invalidCount++;
      }
    }
    
    if (invalidCount >= ContractionTimerConstants.consistencyResetInvalidThreshold) {
      return (true, 'pattern_irregular');
    }
    
    return (false, null);
  }

  /// Calculate duration progress for UI display (0.0 to 1.0)
  ///
  /// Achievement-based: Once a valid contraction (≥45s) is achieved AND no reset,
  /// stays at 100% (locked). When reset triggers, unlocks and shows current progress.
  /// 
  /// Otherwise shows progress towards first valid contraction.
  double _calculateDurationProgress(
    List<Contraction> contractions,
    int validDurationCount,
    bool isDurationReset,
  ) {
    // If at least 1 valid contraction achieved AND not reset → 100% (locked)
    if (validDurationCount > 0 && !isDurationReset) return 1.0;
    
    // Otherwise (not achieved OR reset), show current progress based on last contraction
    if (contractions.isEmpty) return 0.0;

    // Find the last completed contraction
    final completed = contractions.where((c) => c.duration != null).toList();
    if (completed.isEmpty) return 0.0;

    final lastContraction = completed.last;
    final durationSeconds = lastContraction.duration!.inSeconds;
    final targetSeconds =
        ContractionTimerConstants.durationValidThreshold.inSeconds;

    return math.min(1.0, durationSeconds / targetSeconds);
  }

  /// Calculate frequency progress for UI display (0.0 to 1.0)
  /// 
  /// Achievement-based: Once a valid interval (≤6min) is achieved AND no reset,
  /// stays at 100% (locked). When reset triggers, unlocks and shows current progress.
  /// 
  /// Otherwise shows progress towards first valid interval using inverse scale:
  /// - 30+ minutes apart → 0% (too far apart)
  /// - 6 minutes apart → 100% (meets criterion)
  double _calculateFrequencyProgress(
    List<Contraction> contractions,
    int validFrequencyCount,
    bool isFrequencyReset,
  ) {
    // If at least 1 valid interval achieved AND not reset → 100% (locked)
    if (validFrequencyCount > 0 && !isFrequencyReset) return 1.0;
    
    // Otherwise (not achieved OR reset), show current progress based on last interval
    if (contractions.length < 2) return 0.0;
    
    // Get the last interval (most recent contraction pattern)
    final lastInterval = contractions.last.startTime.difference(
      contractions[contractions.length - 2].startTime,
    );
    final lastIntervalMinutes = lastInterval.inSeconds / 60.0;
    
    // Thresholds in minutes
    const maxMinutes = 30.0; // 30 min apart = 0% progress
    const targetMinutes = 6.0; // 6 min apart = 100% progress (matches frequencyValidThreshold)
    
    // Inverse linear scale: closer intervals = higher progress
    // progress = (maxMinutes - lastInterval) / (maxMinutes - targetMinutes)
    if (lastIntervalMinutes >= maxMinutes) return 0.0;
    if (lastIntervalMinutes <= targetMinutes) return 1.0;
    
    final progress = (maxMinutes - lastIntervalMinutes) / (maxMinutes - targetMinutes);
    return progress.clamp(0.0, 1.0);
  }

  /// Calculate consistency progress for UI display (0.0 to 1.0)
  /// 
  /// Achievement-based: Once 80% validity is achieved (validityPercentage >= 0.8) AND no reset,
  /// stays at 100% (locked). When reset triggers, unlocks and shows current progress.
  /// 
  /// This ensures the consistency progress accurately reflects when the alert will trigger,
  /// preventing situations where all 3 checks show 100% but the alert doesn't activate.
  /// 
  /// Otherwise:
  /// - If < 6 contractions: progress based on count (e.g., 3/6 = 50%)
  /// - If >= 6 contractions: progress based on validity % scaled to 80% threshold
  double _calculateConsistencyProgress(
    List<Contraction> contractions,
    int validContractionCount,
    double validityPercentage,
    bool isConsistencyReset,
  ) {
    
    // If we have achieved 80% validity (the actual alert trigger threshold) AND not reset → 100% (locked)
    // Also require minimum contractions to prevent premature locking (e.g., 1/1 = 100% but only 1 contraction)
    if (validityPercentage >= ContractionTimerConstants.validityPercentageRequired &&
        contractions.length >= ContractionTimerConstants.minimumContractionsInWindow &&
        !isConsistencyReset) {
      return 1.0;
    }
    
    // Otherwise (not achieved OR reset), show current progress
    if (contractions.isEmpty) return 0.0;
    
    // If we have fewer than 6 contractions, progress is based on valid count out of 6
    // This prevents 1 valid contraction from showing high progress
    // Only counts contractions meeting BOTH frequency and duration requirements
    if (contractions.length < ContractionTimerConstants.minimumContractionsInWindow) {
      return validContractionCount / ContractionTimerConstants.minimumContractionsInWindow.toDouble();
    }
    
    // If we have 6+ contractions, progress is based on validity percentage
    // Progress = validityPercentage / requiredThreshold (80%)
    // So 40% validity = 50% progress, 80% validity = 100% progress
    final progress = validityPercentage / 
        ContractionTimerConstants.validityPercentageRequired;
    
    return progress.clamp(0.0, 1.0);
  }
}
