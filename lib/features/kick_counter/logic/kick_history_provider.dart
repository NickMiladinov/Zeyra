import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/core/utils/data_minimization.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_analytics.dart';
import 'package:zeyra/domain/usecases/kick_counter/manage_session_usecase.dart';
import 'kick_analytics_provider.dart';

// ----------------------------------------------------------------------------
// State Class
// ----------------------------------------------------------------------------

class KickHistoryState {
  final List<KickSession> history;
  final bool isLoading;
  final KickHistoryAnalytics? analytics;
  final List<KickSessionAnalytics> sessionAnalytics;
  final String? error;

  const KickHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.analytics,
    this.sessionAnalytics = const [],
    this.error,
  });

  KickHistoryState copyWith({
    List<KickSession>? history,
    bool? isLoading,
    KickHistoryAnalytics? analytics,
    List<KickSessionAnalytics>? sessionAnalytics,
    String? error,
  }) {
    return KickHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      analytics: analytics ?? this.analytics,
      sessionAnalytics: sessionAnalytics ?? this.sessionAnalytics,
      error: error,
    );
  }
}

// ----------------------------------------------------------------------------
// Notifier
// ----------------------------------------------------------------------------

class KickHistoryNotifier extends StateNotifier<KickHistoryState> {
  final ManageSessionUseCase _manageSessionUseCase;
  final KickAnalyticsNotifier _analyticsNotifier;

  KickHistoryNotifier(this._manageSessionUseCase, this._analyticsNotifier) 
      : super(const KickHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final history = await _manageSessionUseCase.getSessionHistory(
        limit: DataMinimizationDefaults.maxHistorySessions,
      );
      
      // Calculate analytics
      _analyticsNotifier.calculateAnalytics(history);
      final analyticsState = _analyticsNotifier.state;
      
      state = state.copyWith(
        history: history,
        isLoading: false,
        analytics: analyticsState.historyAnalytics,
        sessionAnalytics: analyticsState.sessionAnalytics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load history: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }

  /// Delete a session from history
  Future<void> deleteSession(String sessionId) async {
    try {
      await _manageSessionUseCase.deleteHistoricalSession(sessionId);
      // Reload history after deletion
      await loadHistory();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete session: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Update the note for a session
  Future<void> updateSessionNote(String sessionId, String? note) async {
    try {
      await _manageSessionUseCase.updateSessionNote(sessionId, note);
      // Reload history after update
      await loadHistory();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update note: ${e.toString()}',
      );
      rethrow;
    }
  }

}

// ----------------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------------

/// Provider that exposes the KickHistoryNotifier.
/// IMPORTANT: Only access this after dependencies are ready.
/// The provider checks for data availability and throws if accessed too early.
final kickHistoryProvider = StateNotifierProvider<KickHistoryNotifier, KickHistoryState>((ref) {
  final useCaseAsync = ref.watch(manageSessionUseCaseProvider);

  // Wait for the dependency to be ready
  if (!useCaseAsync.hasValue) {
    throw StateError(
      'kickHistoryProvider accessed before dependencies are ready. '
      'User must be authenticated first.',
    );
  }

  final manageSessionUseCase = useCaseAsync.requireValue;
  final analyticsNotifier = ref.watch(kickAnalyticsProvider.notifier);
  return KickHistoryNotifier(manageSessionUseCase, analyticsNotifier);
});

