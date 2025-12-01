import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/usecases/kick_counter/manage_session_usecase.dart';

// ----------------------------------------------------------------------------
// State Class
// ----------------------------------------------------------------------------

class KickHistoryState {
  final List<KickSession> history;
  final bool isLoading;
  final Duration? typicalRange; // Average time to 10 kicks (or standard goal)
  final String? error;

  const KickHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.typicalRange,
    this.error,
  });

  KickHistoryState copyWith({
    List<KickSession>? history,
    bool? isLoading,
    Duration? typicalRange,
    String? error,
  }) {
    return KickHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      typicalRange: typicalRange ?? this.typicalRange,
      error: error,
    );
  }
}

// ----------------------------------------------------------------------------
// Notifier
// ----------------------------------------------------------------------------

class KickHistoryNotifier extends StateNotifier<KickHistoryState> {
  final ManageSessionUseCase _manageSessionUseCase;

  KickHistoryNotifier(this._manageSessionUseCase) : super(const KickHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final history = await _manageSessionUseCase.getSessionHistory(limit: 50);
      final typical = _calculateTypicalRange(history);
      
      state = state.copyWith(
        history: history,
        isLoading: false,
        typicalRange: typical,
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

  /// Calculate "Typical Range" - Average time to reach 10 kicks
  Duration? _calculateTypicalRange(List<KickSession> sessions) {
    // Filter completed sessions that reached at least 10 kicks
    final validSessions = sessions.where((s) => 
      !s.isActive && 
      s.endTime != null && 
      s.kickCount >= 10
    ).toList();

    if (validSessions.isEmpty) return null;

    // For each session, find time to 10th kick (or end if we treat completed as valid goal met)
    // If we want stricter "time to 10th kick", we'd need to look at the 10th kick timestamp.
    // But session.activeDuration is a good proxy if user ends at 10 kicks generally.
    // Let's be precise: 10th kick timestamp - start time - pauses before 10th kick.
    // Limitation: KickSession doesn't expose pause timeline easily to calc duration at exact kick index easily without replaying.
    // Simplification: Use activeDuration of the session, assuming users stop shortly after 10.
    
    final totalMilliseconds = validSessions.fold<int>(0, (sum, session) {
      return sum + session.activeDuration.inMilliseconds;
    });

    return Duration(milliseconds: totalMilliseconds ~/ validSessions.length);
  }
}

// ----------------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------------

final kickHistoryProvider = StateNotifierProvider<KickHistoryNotifier, KickHistoryState>((ref) {
  final manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
  return KickHistoryNotifier(manageSessionUseCase);
});

