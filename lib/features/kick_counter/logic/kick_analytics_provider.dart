import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/core/utils/data_minimization.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_analytics.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/usecases/kick_counter/calculate_analytics_usecase.dart';

/// State class for analytics data.
class KickAnalyticsState {
  final KickHistoryAnalytics historyAnalytics;
  final List<KickSessionAnalytics> sessionAnalytics;

  const KickAnalyticsState({
    required this.historyAnalytics,
    required this.sessionAnalytics,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KickAnalyticsState &&
          runtimeType == other.runtimeType &&
          historyAnalytics == other.historyAnalytics &&
          _listEquals(sessionAnalytics, other.sessionAnalytics);

  @override
  int get hashCode => historyAnalytics.hashCode ^ sessionAnalytics.hashCode;

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Provider for kick counter analytics state.
/// 
/// Holds calculated analytics and delegates calculation logic to
/// the CalculateAnalyticsUseCase in the domain layer.
/// 
/// This follows clean architecture by keeping business logic in use cases
/// and state management in the presentation layer.
class KickAnalyticsNotifier extends StateNotifier<KickAnalyticsState> {
  final CalculateAnalyticsUseCase _calculateAnalyticsUseCase;

  KickAnalyticsNotifier(this._calculateAnalyticsUseCase)
      : super(const KickAnalyticsState(
          historyAnalytics: KickHistoryAnalytics(validSessionCount: 0),
          sessionAnalytics: [],
        ));

  /// Calculate analytics from a list of sessions using rolling window.
  /// 
  /// Delegates to the use case for business logic, then updates state.
  /// Call this whenever the session history changes.
  /// 
  /// Each session is evaluated against a safe range calculated from up to
  /// 14 valid sessions that occurred before it chronologically.
  void calculateAnalytics(List<KickSession> sessions) {
    // Create a list of (originalIndex, session) pairs, then sort by startTime
    // Use stable sort by also comparing by original index when times are equal
    final indexedSessions = sessions.asMap().entries.toList()
      ..sort((a, b) {
        final timeCompare = a.value.startTime.compareTo(b.value.startTime);
        return timeCompare != 0 ? timeCompare : a.key.compareTo(b.key);
      });
    
    // Extract just the sorted sessions for the use case
    final sortedSessions = indexedSessions.map((e) => e.value).toList();

    final (historyAnalytics, sortedSessionAnalytics) =
        _calculateAnalyticsUseCase.calculateAllWithRollingWindow(sortedSessions);

    // Verify the use case returned the correct number of analytics
    assert(
      sortedSessionAnalytics.length == sortedSessions.length,
      'Use case returned ${sortedSessionAnalytics.length} analytics for ${sortedSessions.length} sessions',
    );

    // Create reordered analytics matching original input order
    final reorderedAnalytics = <KickSessionAnalytics>[];
    
    for (final session in sessions) {
      // Find this session's position in the sorted list
      final sortedIndex = indexedSessions.indexWhere((e) => e.value.id == session.id);
      if (sortedIndex >= 0 && sortedIndex < sortedSessionAnalytics.length) {
        reorderedAnalytics.add(sortedSessionAnalytics[sortedIndex]);
      } else {
        // Fallback - should never happen but just in case
        reorderedAnalytics.add(KickSessionAnalytics(
          hasMinimumKicks: session.kicks.length >= 10,
          durationToTen: session.durationToTenthKick,
        ));
      }
    }

    state = KickAnalyticsState(
      historyAnalytics: historyAnalytics,
      sessionAnalytics: reorderedAnalytics,
    );
  }

  /// Calculate analytics for graph view with shared safe range.
  ///
  /// All displayed sessions are evaluated against one safe range calculated
  /// from up to 14 valid sessions that occurred before the newest displayed session.
  ///
  /// Returns analytics without updating the main state (graph has its own local state).
  (KickHistoryAnalytics, List<KickSessionAnalytics>) calculateAnalyticsForGraph(
    List<KickSession> graphSessions,
    List<KickSession> allSessions,
  ) {
    return _calculateAnalyticsUseCase.calculateForGraph(
      graphSessions,
      allSessions,
    );
  }

  /// Prepare analytics data for export/sharing (GDPR-compliant).
  ///
  /// Filters analytics to only include non-sensitive fields.
  /// Use this when implementing export or sharing features to ensure
  /// compliance with data minimization principles.
  ///
  /// Example fields included: count, duration, timestamp
  /// Example fields excluded: note, perceivedStrength, symptoms
  Map<String, dynamic> prepareAnalyticsForExport() {
    final data = {
      'valid_session_count': state.historyAnalytics.validSessionCount,
      'timestamp': DateTime.now().toIso8601String(),
      'session_count': state.sessionAnalytics.length,
    };

    // Use data minimization helper to filter only analytics-allowed fields
    return FieldSelectionHelper.filterForAnalytics(data);
  }
}

/// Provider for kick counter analytics.
final kickAnalyticsProvider =
    StateNotifierProvider<KickAnalyticsNotifier, KickAnalyticsState>((ref) {
  final calculateAnalyticsUseCase = ref.watch(calculateAnalyticsUseCaseProvider);
  return KickAnalyticsNotifier(calculateAnalyticsUseCase);
});
