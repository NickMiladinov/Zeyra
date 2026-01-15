@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';
import 'package:zeyra/domain/usecases/contraction_timer/manage_contraction_session_usecase.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_history_provider.dart';

// ----------------------------------------------------------------------------
// Mocks
// ----------------------------------------------------------------------------

class MockManageContractionSessionUseCase extends Mock
    implements ManageContractionSessionUseCase {}

// ----------------------------------------------------------------------------
// Test Data
// ----------------------------------------------------------------------------

final _baseTime = DateTime(2025, 1, 1, 10, 0);

final _testSession1 = ContractionSession(
  id: 'session-1',
  startTime: _baseTime,
  endTime: _baseTime.add(const Duration(hours: 2)),
  isActive: false,
  contractions: [],
);

final _testSession2 = ContractionSession(
  id: 'session-2',
  startTime: _baseTime.subtract(const Duration(days: 1)),
  endTime: _baseTime.subtract(const Duration(days: 1)).add(const Duration(hours: 1)),
  isActive: false,
  contractions: [],
);

final _testHistory = [_testSession1, _testSession2];

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  late ContractionHistoryNotifier notifier;
  late MockManageContractionSessionUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockManageContractionSessionUseCase();

    // Default stub for getSessionHistory (called in initialization)
    when(() => mockUseCase.getSessionHistory(limit: any(named: 'limit')))
        .thenAnswer((_) async => _testHistory);

    notifier = ContractionHistoryNotifier(manageUseCase: mockUseCase);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('[ContractionHistoryNotifier] Initialization', () {
    test('should load history on creation', () async {
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.history, _testHistory);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
      verify(() => mockUseCase.getSessionHistory(limit: 50)).called(1);
    });

    test('should handle loading error gracefully', () async {
      // Arrange
      when(() => mockUseCase.getSessionHistory(limit: any(named: 'limit')))
          .thenThrow(Exception('Load failed'));

      final notifier2 = ContractionHistoryNotifier(manageUseCase: mockUseCase);

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier2.state.history, isEmpty);
      expect(notifier2.state.isLoading, false);
      expect(notifier2.state.error, contains('Failed to load history'));

      notifier2.dispose();
    });
  });

  group('[ContractionHistoryNotifier] refresh', () {
    test('should reload session history', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Arrange - change the mock return value
      final updatedHistory = [
        _testSession1,
        _testSession2,
        ContractionSession(
          id: 'session-3',
          startTime: _baseTime.subtract(const Duration(days: 2)),
          endTime: _baseTime.subtract(const Duration(days: 2)).add(const Duration(hours: 1)),
          isActive: false,
          contractions: [],
        ),
      ];

      when(() => mockUseCase.getSessionHistory(limit: any(named: 'limit')))
          .thenAnswer((_) async => updatedHistory);

      // Act
      await notifier.refresh();

      // Assert
      expect(notifier.state.history, updatedHistory);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });
  });

  group('[ContractionHistoryNotifier] deleteSession', () {
    test('should remove session from history', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Arrange
      when(() => mockUseCase.deleteHistoricalSession('session-1'))
          .thenAnswer((_) async {});

      // Act
      await notifier.deleteSession('session-1');

      // Assert
      expect(notifier.state.history.length, 1);
      expect(notifier.state.history.first.id, 'session-2');
      verify(() => mockUseCase.deleteHistoricalSession('session-1')).called(1);
    });

    test('should update local state immediately', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Arrange
      when(() => mockUseCase.deleteHistoricalSession('session-1'))
          .thenAnswer((_) async {});

      final historyCountBefore = notifier.state.history.length;

      // Act
      await notifier.deleteSession('session-1');

      // Assert - should be updated immediately
      expect(notifier.state.history.length, historyCountBefore - 1);
    });

    test('should handle delete error', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Arrange
      when(() => mockUseCase.deleteHistoricalSession('session-1'))
          .thenThrow(Exception('Delete failed'));

      // Act
      await notifier.deleteSession('session-1');

      // Assert - history should remain unchanged
      expect(notifier.state.history, _testHistory);
      expect(notifier.state.error, contains('Failed to delete session'));
    });
  });

  group('[ContractionHistoryNotifier] updateSessionNote', () {
    test('should update note in session', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Arrange
      when(() => mockUseCase.updateSessionNote('session-1', 'Test note'))
          .thenAnswer((_) async => _testSession1.copyWith(note: 'Test note'));

      // Act
      await notifier.updateSessionNote('session-1', 'Test note');

      // Assert
      final updatedSession = notifier.state.history
          .firstWhere((s) => s.id == 'session-1');
      expect(updatedSession.note, 'Test note');
      verify(() => mockUseCase.updateSessionNote('session-1', 'Test note'))
          .called(1);
    });

    test('should handle update error', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Arrange
      when(() => mockUseCase.updateSessionNote('session-1', 'Test note'))
          .thenThrow(Exception('Update failed'));

      // Act
      await notifier.updateSessionNote('session-1', 'Test note');

      // Assert
      expect(notifier.state.error, contains('Failed to update note'));
    });
  });

  group('[ContractionHistoryNotifier] clearError', () {
    test('should clear error state', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Arrange - cause an error
      when(() => mockUseCase.deleteHistoricalSession('session-1'))
          .thenThrow(Exception('Delete failed'));

      await notifier.deleteSession('session-1');
      expect(notifier.state.error, isNotNull);

      // Act
      notifier.clearError();

      // Assert
      expect(notifier.state.error, isNull);
    });
  });
}

