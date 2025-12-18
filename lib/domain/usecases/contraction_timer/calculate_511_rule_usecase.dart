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

      return Rule511Status(
        alertActive: false,
        contractionsInWindow: contractionsInWindow.length,
        validDurationCount: validDurationCount,
        validFrequencyCount: validFrequencyCount,
        validityPercentage: 0.0,
        durationProgress: _calculateDurationProgress(contractionsInWindow),
        frequencyProgress: _calculateFrequencyProgress(contractionsInWindow),
        consistencyProgress: contractionsInWindow.length /
            ContractionTimerConstants.minimumContractionsInWindow,
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
    
    // Calculate progress metrics for UI
    final durationProgress = _calculateDurationProgress(contractionsInWindow);
    final frequencyProgress = _calculateFrequencyProgress(contractionsInWindow);
    final consistencyProgress = _calculateConsistencyProgress(contractionsInWindow, validityPercentage);
    
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
  /// Reset when: Gap since last contraction > 20 minutes
  (bool, String?) _checkFrequencyReset(ContractionSession session) {
    if (session.contractions.isEmpty) return (false, null);
    
    final lastContraction = session.contractions.last;
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
  /// Shows what percentage of contractions meet the duration threshold
  double _calculateDurationProgress(List<Contraction> contractions) {
    if (contractions.isEmpty) return 0.0;
    
    final completed = contractions.where((c) => c.duration != null).toList();
    if (completed.isEmpty) return 0.0;
    
    final validCount = completed.where((c) {
      return c.duration! >= ContractionTimerConstants.durationValidThreshold;
    }).length;
    
    return math.min(1.0, validCount / completed.length);
  }

  /// Calculate frequency progress for UI display (0.0 to 1.0)
  /// 
  /// Shows what percentage of intervals meet the frequency threshold
  double _calculateFrequencyProgress(List<Contraction> contractions) {
    if (contractions.length < 2) return 0.0;
    
    final validCount = _countValidFrequencies(contractions);
    final totalIntervals = contractions.length - 1;
    
    return math.min(1.0, validCount / totalIntervals);
  }

  /// Calculate consistency progress for UI display (0.0 to 1.0)
  /// 
  /// Combines:
  /// - How long the pattern has been maintained (time in window)
  /// - What percentage meets the 80% threshold
  double _calculateConsistencyProgress(
    List<Contraction> contractions,
    double validityPercentage,
  ) {
    if (contractions.isEmpty) return 0.0;
    
    // Time progress: how much of the 60-minute window is filled
    final windowDuration = DateTime.now().difference(contractions.first.startTime);
    final timeProgress = math.min(
      1.0,
      windowDuration.inMilliseconds / 
          ContractionTimerConstants.rollingWindowDuration.inMilliseconds,
    );
    
    // Validity progress: how close to 80% threshold
    final validityProgress = math.min(
      1.0,
      validityPercentage / ContractionTimerConstants.validityPercentageRequired,
    );
    
    // Combine both factors (weighted toward validity)
    return (timeProgress * 0.3) + (validityProgress * 0.7); // TODO: tweak this as needed
  }
}

