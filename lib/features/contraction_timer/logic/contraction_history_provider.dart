import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';
import 'package:zeyra/domain/usecases/contraction_timer/manage_contraction_session_usecase.dart';

/// State for contraction session history
class ContractionHistoryState {
  final List<ContractionSession> history;
  final bool isLoading;
  final String? error;
  
  const ContractionHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.error,
  });
  
  ContractionHistoryState copyWith({
    List<ContractionSession>? history,
    bool? isLoading,
    String? Function()? error,
  }) {
    return ContractionHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// Notifier for managing contraction session history
class ContractionHistoryNotifier extends StateNotifier<ContractionHistoryState> {
  final ManageContractionSessionUseCase _manageUseCase;
  
  ContractionHistoryNotifier({
    required ManageContractionSessionUseCase manageUseCase,
  })  : _manageUseCase = manageUseCase,
        super(const ContractionHistoryState()) {
    _loadHistory();
  }
  
  /// Load session history
  Future<void> _loadHistory() async {
    try {
      state = state.copyWith(isLoading: true, error: () => null);
      
      final history = await _manageUseCase.getSessionHistory(limit: 50);
      
      state = state.copyWith(
        history: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to load history: $e',
      );
    }
  }
  
  /// Refresh history
  Future<void> refresh() async {
    await _loadHistory();
  }
  
  /// Delete a session from history
  Future<void> deleteSession(String sessionId) async {
    try {
      await _manageUseCase.deleteHistoricalSession(sessionId);
      
      // Remove from local state immediately for responsive UI
      final updatedHistory = state.history
          .where((s) => s.id != sessionId)
          .toList();
      
      state = state.copyWith(history: updatedHistory);
    } catch (e) {
      state = state.copyWith(
        error: () => 'Failed to delete session: $e',
      );
    }
  }
  
  /// Update session note
  Future<void> updateSessionNote(String sessionId, String? note) async {
    try {
      await _manageUseCase.updateSessionNote(sessionId, note);
      
      // Update local state
      final updatedHistory = state.history.map((session) {
        if (session.id == sessionId) {
          return session.copyWith(note: note);
        }
        return session;
      }).toList();
      
      state = state.copyWith(history: updatedHistory);
    } catch (e) {
      state = state.copyWith(
        error: () => 'Failed to update note: $e',
      );
    }
  }
  
  /// Clear error
  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

/// Provider for contraction history
final contractionHistoryProvider = StateNotifierProvider<ContractionHistoryNotifier, ContractionHistoryState>((ref) {
  // Watch the async provider
  final manageUseCaseAsync = ref.watch(manageContractionSessionUseCaseProvider);

  // If still loading, throw to indicate provider is not ready
  if (manageUseCaseAsync.isLoading) {
    throw StateError('Dependencies are still loading');
  }

  // If error, rethrow it
  if (manageUseCaseAsync.hasError) {
    throw manageUseCaseAsync.error!;
  }

  // Ready, extract value
  final manageUseCase = manageUseCaseAsync.requireValue;

  return ContractionHistoryNotifier(
    manageUseCase: manageUseCase,
  );
});

