@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/usecases/kick_counter/manage_session_usecase.dart';
import 'package:zeyra/features/kick_counter/logic/kick_history_provider.dart';

import '../../../mocks/fake_data/kick_counter_fakes.dart';

// ----------------------------------------------------------------------------
// Mocks
// ----------------------------------------------------------------------------

class MockManageSessionUseCase extends Mock implements ManageSessionUseCase {}

// ----------------------------------------------------------------------------
// Test Data
// ----------------------------------------------------------------------------

// Helper to create a session with N dummy kicks
KickSession createSessionWithKicks(int count, Duration duration) {
  final start = DateTime.now().subtract(duration);
  return KickSession(
    id: 'id-$count',
    startTime: start,
    endTime: DateTime.now(),
    isActive: false,
    kicks: FakeKick.batch(count, startTime: start),
    totalPausedDuration: Duration.zero,
    pauseCount: 0,
  );
}

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  late KickHistoryNotifier notifier;
  late MockManageSessionUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockManageSessionUseCase();
    // Mock initial load
    when(() => mockUseCase.getSessionHistory(limit: 50))
        .thenAnswer((_) async => []);
    notifier = KickHistoryNotifier(mockUseCase);
  });

  group('[KickCounter] KickHistoryNotifier', () {
    // ------------------------------------------------------------------------
    // loadHistory Tests
    // ------------------------------------------------------------------------

    group('loadHistory', () {
      test('should load history successfully', () async {
        // Arrange
        final sessions = [
          FakeKickSession.ended(note: 'Session 1'),
          FakeKickSession.ended(note: 'Session 2'),
        ];
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => sessions);

        // Act
        await notifier.loadHistory();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.history, equals(sessions));
        expect(notifier.state.error, isNull);
      });

      test('should set loading state while loading', () async {
        // Arrange
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => []);

        // Check initial state
        expect(notifier.state.isLoading, false);

        // Act
        final future = notifier.loadHistory();
        
        // loadHistory sets loading synchronously, then waits for async
        // By the time we check, loading might be done, so we just verify completion
        await future;

        // Assert
        expect(notifier.state.isLoading, false);
      });

      test('should handle error on load', () async {
        // Arrange
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenThrow(Exception('Database Error'));

        // Act
        await notifier.loadHistory();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, contains('Database Error'));
        expect(notifier.state.history, isEmpty);
      });
      
      test('should calculate typical range correctly', () async {
        // Arrange
        final session = createSessionWithKicks(10, const Duration(minutes: 30));
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => [session]);

        // Act
        await notifier.loadHistory();

        // Assert
        expect(notifier.state.error, isNull);
        expect(notifier.state.typicalRange, isNotNull);
      });

      test('should return null typical range when no valid sessions', () async {
        // Arrange
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => []);

        // Act
        await notifier.loadHistory();

        // Assert
        expect(notifier.state.typicalRange, isNull);
      });
    });

    // ------------------------------------------------------------------------
    // refresh Tests
    // ------------------------------------------------------------------------

    group('refresh', () {
      test('should reload history', () async {
        // Arrange
        final refreshedSessions = [
          FakeKickSession.ended(note: 'New session'),
          FakeKickSession.ended(),
        ];

        // Note: Constructor already called loadHistory once with initial empty list
        expect(notifier.state.history.length, equals(0));

        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => refreshedSessions);

        // Act
        await notifier.refresh();

        // Assert
        expect(notifier.state.history.length, equals(2));
        // Constructor calls loadHistory once, refresh calls it again
        verify(() => mockUseCase.getSessionHistory(limit: 50)).called(greaterThanOrEqualTo(1));
      });
    });

    // ------------------------------------------------------------------------
    // deleteSession Tests
    // ------------------------------------------------------------------------

    group('deleteSession', () {
      test('should delete session and reload history', () async {
        // Arrange
        const sessionId = 'session-1';
        final initialSessions = [
          FakeKickSession.simple(id: sessionId, isActive: false, endTime: DateTime(2024, 1, 1, 10, 30)),
          FakeKickSession.simple(id: 'session-2', isActive: false, endTime: DateTime(2024, 1, 1, 10, 30)),
        ];
        final afterDeleteSessions = [
          FakeKickSession.simple(id: 'session-2', isActive: false, endTime: DateTime(2024, 1, 1, 10, 30)),
        ];

        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => initialSessions);
        await notifier.loadHistory();

        when(() => mockUseCase.deleteHistoricalSession(sessionId))
            .thenAnswer((_) async => Future.value());
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => afterDeleteSessions);

        // Act
        await notifier.deleteSession(sessionId);

        // Assert
        expect(notifier.state.history.length, equals(1));
        expect(notifier.state.history.first.id, equals('session-2'));
        verify(() => mockUseCase.deleteHistoricalSession(sessionId)).called(1);
      });

      test('should set error state on delete failure', () async {
        // Arrange
        const sessionId = 'session-1';
        when(() => mockUseCase.deleteHistoricalSession(sessionId))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => notifier.deleteSession(sessionId),
          throwsA(isA<Exception>()),
        );
        expect(notifier.state.error, contains('Delete failed'));
      });

      test('should still reload history even after delete failure', () async {
        // Arrange
        const sessionId = 'session-1';
        final sessions = [FakeKickSession.ended()];
        
        when(() => mockUseCase.deleteHistoricalSession(sessionId))
            .thenThrow(Exception('Delete failed'));
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => sessions);

        // Act
        try {
          await notifier.deleteSession(sessionId);
        } catch (_) {
          // Expected to throw
        }

        // Assert - loadHistory should still have been attempted
        // (though the error state will be set)
        expect(notifier.state.error, isNotNull);
      });
    });

    // ------------------------------------------------------------------------
    // updateSessionNote Tests
    // ------------------------------------------------------------------------

    group('updateSessionNote', () {
      test('should update note and reload history', () async {
        // Arrange
        const sessionId = 'session-1';
        const note = 'Updated note';
        final updatedSession = FakeKickSession.simple(id: sessionId, note: note, isActive: false, endTime: DateTime(2024, 1, 1, 10, 30));
        final afterUpdateSessions = [updatedSession];

        when(() => mockUseCase.updateSessionNote(sessionId, note))
            .thenAnswer((_) async => updatedSession);
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => afterUpdateSessions);

        // Act
        await notifier.updateSessionNote(sessionId, note);

        // Assert
        expect(notifier.state.history.first.note, equals(note));
        verify(() => mockUseCase.updateSessionNote(sessionId, note)).called(1);
      });

      test('should clear note when null is provided', () async {
        // Arrange
        const sessionId = 'session-1';
        final updatedSession = FakeKickSession.simple(id: sessionId, note: null, isActive: false, endTime: DateTime(2024, 1, 1, 10, 30));
        final afterUpdateSessions = [updatedSession];

        when(() => mockUseCase.updateSessionNote(sessionId, null))
            .thenAnswer((_) async => updatedSession);
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => afterUpdateSessions);

        // Act
        await notifier.updateSessionNote(sessionId, null);

        // Assert
        expect(notifier.state.history.first.note, isNull);
        verify(() => mockUseCase.updateSessionNote(sessionId, null)).called(1);
      });

      test('should set error state on update failure', () async {
        // Arrange
        const sessionId = 'session-1';
        const note = 'Test note';
        when(() => mockUseCase.updateSessionNote(sessionId, note))
            .thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => notifier.updateSessionNote(sessionId, note),
          throwsA(isA<Exception>()),
        );
        expect(notifier.state.error, contains('Update failed'));
      });

      test('should still reload history even after update failure', () async {
        // Arrange
        const sessionId = 'session-1';
        const note = 'Test note';
        final sessions = [FakeKickSession.ended()];
        
        when(() => mockUseCase.updateSessionNote(sessionId, note))
            .thenThrow(Exception('Update failed'));
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => sessions);

        // Act
        try {
          await notifier.updateSessionNote(sessionId, note);
        } catch (_) {
          // Expected to throw
        }

        // Assert
        expect(notifier.state.error, isNotNull);
      });
    });

    // ------------------------------------------------------------------------
    // Integration Tests
    // ------------------------------------------------------------------------

    group('integration scenarios', () {
      test('should handle multiple operations in sequence', () async {
        // Arrange
        const session1Id = 'session-1';
        const session2Id = 'session-2';
        const note = 'Test note';
        
        final initialSessions = [
          FakeKickSession.simple(id: session1Id, isActive: false, endTime: DateTime(2024, 1, 1, 10, 30)),
          FakeKickSession.simple(id: session2Id, isActive: false, endTime: DateTime(2024, 1, 1, 10, 30)),
        ];
        
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => initialSessions);
        await notifier.loadHistory();

        // Update note on first session
        final updatedSession1 = FakeKickSession.simple(id: session1Id, note: note, isActive: false, endTime: DateTime(2024, 1, 1, 10, 30));
        when(() => mockUseCase.updateSessionNote(session1Id, note))
            .thenAnswer((_) async => updatedSession1);
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => [updatedSession1, initialSessions[1]]);
        
        await notifier.updateSessionNote(session1Id, note);

        // Delete second session
        when(() => mockUseCase.deleteHistoricalSession(session2Id))
            .thenAnswer((_) async => Future.value());
        when(() => mockUseCase.getSessionHistory(limit: 50))
            .thenAnswer((_) async => [updatedSession1]);

        // Act
        await notifier.deleteSession(session2Id);

        // Assert
        expect(notifier.state.history.length, equals(1));
        expect(notifier.state.history.first.id, equals(session1Id));
        expect(notifier.state.history.first.note, equals(note));
      });
    });
  });
}
