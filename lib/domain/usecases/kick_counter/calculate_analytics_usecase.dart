import 'dart:math';

import '../../entities/kick_counter/kick_analytics.dart';
import '../../entities/kick_counter/kick_session.dart';

/// Use case for calculating kick counter analytics.
/// 
/// Encapsulates the business logic for statistical analysis of kick sessions,
/// including mean, standard deviation, and outlier detection.
/// 
/// This is pure business logic operating on domain entities, following clean
/// architecture principles by keeping calculation logic separate from state management.
class CalculateAnalyticsUseCase {
  /// Calculate aggregate analytics for all sessions.
  /// 
  /// Returns analytics summary including mean, standard deviation,
  /// and threshold values for outlier detection.
  /// 
  /// Only sessions with >= 10 kicks are included in calculations.
  KickHistoryAnalytics calculateHistoryAnalytics(List<KickSession> sessions) {
    // Filter to sessions with at least 10 kicks
    final validSessions = sessions
        .where((s) => s.kicks.length >= 10 && s.durationToTenthKick != null)
        .toList();

    if (validSessions.isEmpty) {
      return const KickHistoryAnalytics(validSessionCount: 0);
    }

    // Extract durations to 10th kick
    final durations = validSessions
        .map((s) => s.durationToTenthKick!)
        .toList();

    // Calculate mean
    final totalMilliseconds = durations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    final averageMilliseconds = totalMilliseconds / durations.length;
    final averageDuration = Duration(milliseconds: averageMilliseconds.round());

    // Calculate standard deviation and upper threshold
    Duration? standardDeviation;
    Duration? upperThreshold;

    if (durations.length > 1) {
      // Calculate variance
      final variance = durations.fold<double>(
        0.0,
        (sum, duration) {
          final diff = duration.inMilliseconds - averageMilliseconds;
          return sum + (diff * diff);
        },
      ) / durations.length;

      final stdDevMilliseconds = sqrt(variance);
      standardDeviation = Duration(milliseconds: stdDevMilliseconds.round());

      // Calculate upper threshold only (mean + 2*stdDev)
      // We don't flag faster sessions as they're not medically concerning
      final upperMillis = averageMilliseconds + (2 * stdDevMilliseconds);
      upperThreshold = Duration(milliseconds: max(0, upperMillis.round()));
    }

    return KickHistoryAnalytics(
      validSessionCount: validSessions.length,
      averageDurationToTen: averageDuration,
      standardDeviation: standardDeviation,
      upperThreshold: upperThreshold,
    );
  }

  /// Calculate analytics for a single session.
  /// 
  /// Determines if the session meets minimum requirements and whether
  /// it's a statistical outlier (taking significantly longer than average).
  /// 
  /// Only flags sessions that exceed the upper threshold (avg + 2*stdDev),
  /// as faster sessions are not medically concerning.
  KickSessionAnalytics calculateSessionAnalytics(
    KickSession session,
    KickHistoryAnalytics historyAnalytics,
  ) {
    final hasMinimumKicks = session.kicks.length >= 10;
    final durationToTen = session.durationToTenthKick;

    // Can't be an outlier if we don't have enough data or session is invalid
    if (!hasMinimumKicks ||
        durationToTen == null ||
        !historyAnalytics.hasEnoughDataForAnalytics ||
        historyAnalytics.upperThreshold == null) {
      return KickSessionAnalytics(
        durationToTen: durationToTen,
        hasMinimumKicks: hasMinimumKicks,
      );
    }

    // Check if session exceeds upper threshold (slower than average)
    final durationMillis = durationToTen.inMilliseconds;
    final upperMillis = historyAnalytics.upperThreshold!.inMilliseconds;
    final isOutlier = durationMillis > upperMillis;

    return KickSessionAnalytics(
      durationToTen: durationToTen,
      hasMinimumKicks: hasMinimumKicks,
      isOutlier: isOutlier,
    );
  }

  /// Calculate analytics for all sessions at once.
  /// 
  /// This is a convenience method that calculates both history analytics
  /// and per-session analytics in one call.
  (KickHistoryAnalytics, List<KickSessionAnalytics>) calculateAll(
    List<KickSession> sessions,
  ) {
    final historyAnalytics = calculateHistoryAnalytics(sessions);
    final sessionAnalytics = sessions
        .map((session) => calculateSessionAnalytics(session, historyAnalytics))
        .toList();

    return (historyAnalytics, sessionAnalytics);
  }

  /// Calculate analytics with rolling 14-session window for history view.
  /// 
  /// Each session is evaluated against a safe range calculated from up to
  /// 14 valid sessions. For early sessions without enough previous data,
  /// uses a hybrid window including sessions before and after (when 7+ valid
  /// sessions exist total).
  /// 
  /// When there are < 14 valid sessions, ALL sessions use ONE shared threshold
  /// calculated from all valid sessions. This ensures consistency with the graph.
  /// 
  /// [sessions] must be in chronological order (oldest first).
  /// 
  /// Returns empty analytics if fewer than 7 valid sessions exist.
  (KickHistoryAnalytics, List<KickSessionAnalytics>) calculateAllWithRollingWindow(
    List<KickSession> sessions,
  ) {
    // Count total valid sessions for minimum threshold check
    final allValidSessions = sessions
        .where((s) => s.kicks.length >= 10 && s.durationToTenthKick != null)
        .toList();

    final hasEnoughData = allValidSessions.length >= KickHistoryAnalytics.minSessionsForAnalytics;

    // Calculate shared threshold from latest 14 valid sessions (or all if < 14)
    // Sessions within this window use the shared threshold for graph consistency
    final sessionsForSharedThreshold = allValidSessions.length > 14
        ? allValidSessions.sublist(allValidSessions.length - 14)
        : allValidSessions;
    
    KickHistoryAnalytics? sharedSafeRange;
    if (hasEnoughData) {
      sharedSafeRange = _calculateSafeRangeFromSessions(
        sessionsForSharedThreshold,
        filterOutliers: true,
      );
    }
    
    // Track which sessions are in the shared threshold window (latest 14)
    final sharedWindowSessionIds = sessionsForSharedThreshold.map((s) => s.id).toSet();

    final sessionAnalyticsList = <KickSessionAnalytics>[];

    // Calculate analytics for each session
    for (int i = 0; i < sessions.length; i++) {
      final currentSession = sessions[i];
      final hasMinimumKicks = currentSession.kicks.length >= 10;
      final durationToTen = currentSession.durationToTenthKick;

      // Sessions with < 10 kicks are never flagged as outliers
      if (!hasMinimumKicks) {
        sessionAnalyticsList.add(KickSessionAnalytics(
          durationToTen: durationToTen,
          hasMinimumKicks: false,
          isOutlier: false,
        ));
        continue;
      }

      // Can't flag sessions if we don't have enough total data
      if (!hasEnoughData) {
        sessionAnalyticsList.add(KickSessionAnalytics(
          durationToTen: durationToTen,
          hasMinimumKicks: true,
          isOutlier: false,
        ));
        continue;
      }

      // Determine safe range for this session
      KickHistoryAnalytics safeRange;
      
      // Sessions within the latest 14 use shared threshold (matches graph)
      // Older sessions use rolling window
      final isInSharedWindow = sharedWindowSessionIds.contains(currentSession.id);
      
      if (isInSharedWindow) {
        // Use shared threshold for sessions in latest 14 (matches graph)
        safeRange = sharedSafeRange!;
      } else {
        // Use rolling window for older sessions (not displayed on graph)
        final sessionsBefore = sessions
            .sublist(0, i)
            .where((s) => s.kicks.length >= 10 && s.durationToTenthKick != null)
            .toList();

        // Determine window sessions for safe range calculation
        List<KickSession> windowSessions;
        
        if (sessionsBefore.length >= 14) {
          // Enough previous sessions - use last 14 before
          windowSessions = sessionsBefore.sublist(sessionsBefore.length - 14);
        } else {
          // 7-13 previous sessions - use all of them
          windowSessions = sessionsBefore;
        }

        // Calculate safe range from window sessions with outlier filtering
        safeRange = _calculateSafeRangeFromSessions(
          windowSessions,
          filterOutliers: true,
        );
      }

      // Determine if current session is an outlier
      bool isOutlier = false;
      if (durationToTen != null && safeRange.upperThreshold != null) {
        isOutlier = durationToTen.inMilliseconds > safeRange.upperThreshold!.inMilliseconds;
      }

      sessionAnalyticsList.add(KickSessionAnalytics(
        durationToTen: durationToTen,
        hasMinimumKicks: true,
        isOutlier: isOutlier,
      ));
    }

    // Calculate overall history analytics from all valid sessions
    final overallAnalytics = calculateHistoryAnalytics(sessions);

    return (overallAnalytics, sessionAnalyticsList);
  }

  /// Calculate analytics for graph view with shared safe range.
  /// 
  /// All displayed sessions are evaluated against one safe range calculated
  /// from up to 14 valid sessions that occurred before the newest displayed session.
  /// 
  /// [graphSessions] are the sessions to display (typically 7 most recent).
  /// [allFetchedSessions] are all available sessions (typically 50 most recent).
  /// 
  /// Returns empty analytics if fewer than 7 valid sessions exist in total.
  (KickHistoryAnalytics, List<KickSessionAnalytics>) calculateForGraph(
    List<KickSession> graphSessions,
    List<KickSession> allFetchedSessions,
  ) {
    // Sort all sessions chronologically
    final sortedSessions = List<KickSession>.from(allFetchedSessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Get all valid sessions
    final allValidSessions = sortedSessions
        .where((s) => s.kicks.length >= 10 && s.durationToTenthKick != null)
        .toList();

    // Early exit if insufficient data (< 7 valid sessions)
    if (allValidSessions.length < KickHistoryAnalytics.minSessionsForAnalytics) {
      return (
        const KickHistoryAnalytics(validSessionCount: 0),
        List.filled(graphSessions.length, const KickSessionAnalytics(hasMinimumKicks: false)),
      );
    }

    // For the graph, use ONE shared threshold for all displayed sessions.
    // This ensures the displayed threshold line matches the outlier detection.
    // Use the latest 14 valid sessions (or all if < 14).
    final sessionsForThreshold = allValidSessions.length > 14
        ? allValidSessions.sublist(allValidSessions.length - 14)
        : allValidSessions;
    
    final sharedSafeRange = _calculateSafeRangeFromSessions(
      sessionsForThreshold,
      filterOutliers: true,
    );

    // Evaluate all graph sessions against this single shared safe range
    final sessionAnalyticsList = graphSessions.map((session) {
      final hasMinimumKicks = session.kicks.length >= 10;
      final durationToTen = session.durationToTenthKick;

      bool isOutlier = false;
      if (hasMinimumKicks &&
          durationToTen != null &&
          sharedSafeRange.upperThreshold != null) {
        isOutlier = durationToTen.inMilliseconds > sharedSafeRange.upperThreshold!.inMilliseconds;
      }

      return KickSessionAnalytics(
        durationToTen: durationToTen,
        hasMinimumKicks: hasMinimumKicks,
        isOutlier: isOutlier,
      );
    }).toList();

    return (sharedSafeRange, sessionAnalyticsList);
  }

  // --------------------------------------------------------------------------
  // Private Helper Methods
  // --------------------------------------------------------------------------

  /// Calculate safe range from a list of sessions with optional outlier filtering.
  /// 
  /// [filterOutliers] if true, applies IQR method to exclude extreme outliers
  /// before calculating mean and standard deviation.
  /// 
  /// Returns analytics with safe range or empty analytics if insufficient data.
  KickHistoryAnalytics _calculateSafeRangeFromSessions(
    List<KickSession> sessions, {
    bool filterOutliers = true,
  }) {
    // Filter to sessions with at least 10 kicks
    final validSessions = sessions
        .where((s) => s.kicks.length >= 10 && s.durationToTenthKick != null)
        .toList();

    if (validSessions.isEmpty) {
      return const KickHistoryAnalytics(validSessionCount: 0);
    }

    // Extract durations to 10th kick
    var durations = validSessions
        .map((s) => s.durationToTenthKick!)
        .toList();

    // Apply IQR filtering if enabled and we have enough data
    if (filterOutliers && durations.length >= 4) {
      durations = _filterOutliersIQR(durations);
      
      // Check if we still have enough data after filtering
      if (durations.isEmpty) {
        return const KickHistoryAnalytics(validSessionCount: 0);
      }
    }

    // Calculate mean
    final totalMilliseconds = durations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    final averageMilliseconds = totalMilliseconds / durations.length;
    final averageDuration = Duration(milliseconds: averageMilliseconds.round());

    // Calculate standard deviation and upper threshold
    Duration? standardDeviation;
    Duration? upperThreshold;

    if (durations.length > 1) {
      // Calculate variance
      final variance = durations.fold<double>(
        0.0,
        (sum, duration) {
          final diff = duration.inMilliseconds - averageMilliseconds;
          return sum + (diff * diff);
        },
      ) / durations.length;

      final stdDevMilliseconds = sqrt(variance);
      standardDeviation = Duration(milliseconds: stdDevMilliseconds.round());

      // Calculate upper threshold only (mean + 2*stdDev)
      // We don't flag faster sessions as they're not medically concerning
      final upperMillis = averageMilliseconds + (2 * stdDevMilliseconds);
      upperThreshold = Duration(milliseconds: max(0, upperMillis.round()));
    }

    return KickHistoryAnalytics(
      validSessionCount: validSessions.length,
      averageDurationToTen: averageDuration,
      standardDeviation: standardDeviation,
      upperThreshold: upperThreshold,
    );
  }

  /// Filter outliers using the IQR (Interquartile Range) method.
  /// 
  /// Removes durations that exceed Q3 + 1.5 * IQR, which identifies
  /// extreme outliers that could skew the safe range calculation.
  /// 
  /// Returns filtered list with outliers removed, or original list if
  /// fewer than 4 durations (IQR not meaningful with small samples).
  List<Duration> _filterOutliersIQR(List<Duration> durations) {
    // Need at least 4 data points for meaningful quartile calculation
    if (durations.length < 4) {
      return durations;
    }

    // Sort durations for percentile calculation
    final sortedDurations = List<Duration>.from(durations)
      ..sort((a, b) => a.inMilliseconds.compareTo(b.inMilliseconds));

    // Calculate quartile positions
    final q1Index = (sortedDurations.length * 0.25).floor();
    final q3Index = (sortedDurations.length * 0.75).floor();

    final q1 = sortedDurations[q1Index].inMilliseconds;
    final q3 = sortedDurations[q3Index].inMilliseconds;
    final iqr = q3 - q1;

    // Calculate upper fence (we only care about slow outliers, not fast ones)
    final upperFence = q3 + (1.5 * iqr);

    // Filter out durations exceeding upper fence
    return sortedDurations
        .where((d) => d.inMilliseconds <= upperFence)
        .toList();
  }
}

