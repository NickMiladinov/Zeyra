@Tags(['kick_counter'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/repositories/kick_counter_repository_impl.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';

class MockLoggingService extends Mock implements LoggingService {}

void main() {
  late AppDatabase database;
  late MockLoggingService mockLogger;
  late KickCounterRepositoryImpl repository;

  setUp(() {
    // Create in-memory database for testing (unencrypted for tests)
    database = AppDatabase.forTesting(NativeDatabase.memory());
    mockLogger = MockLoggingService();
    repository = KickCounterRepositoryImpl(
      dao: database.kickCounterDao,
      logger: mockLogger,
    );

    // Register fallback values
    registerFallbackValue(MovementStrength.moderate);
  });

  tearDown(() async {
    await database.close();
  });

  group('[KickCounter] KickCounterRepositoryImpl', () {
    // ------------------------------------------------------------------------
    // createSession Tests
    // ------------------------------------------------------------------------

    group('createSession', () {
      test('should create session with generated UUID', () async {
        // Act
        final session = await repository.createSession();

        // Assert
        expect(session.id, isNotEmpty);
        expect(session.id.length, equals(36)); // UUID v4 length
      });

      test('should set startTime to current DateTime', () async {
        // Arrange
        // Truncate to milliseconds since that's our storage precision
        final beforeCreate = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
        );

        // Act
        final session = await repository.createSession();

        // Assert
        final afterCreate = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
        );
        expect(
          session.startTime.isAfter(beforeCreate) ||
              session.startTime.isAtSameMomentAs(beforeCreate),
          isTrue,
        );
        expect(
          session.startTime.isBefore(afterCreate) ||
              session.startTime.isAtSameMomentAs(afterCreate),
          isTrue,
        );
      });

      test('should initialize session with isActive true', () async {
        // Act
        final session = await repository.createSession();

        // Assert
        expect(session.isActive, isTrue);
      });

      test('should initialize pause fields to defaults', () async {
        // Act
        final session = await repository.createSession();

        // Assert
        expect(session.pausedAt, isNull);
        expect(session.totalPausedDuration, equals(Duration.zero));
        expect(session.pauseCount, equals(0));
        expect(session.kicks, isEmpty);
      });
    });

    // ------------------------------------------------------------------------
    // getActiveSession Tests
    // ------------------------------------------------------------------------

    group('getActiveSession', () {
      test('should return active session when exists', () async {
        // Arrange
        final createdSession = await repository.createSession();

        // Act
        final activeSession = await repository.getActiveSession();

        // Assert
        expect(activeSession, isNotNull);
        expect(activeSession!.id, equals(createdSession.id));
      });

      test('should return null when no active session', () async {
        // Act
        final activeSession = await repository.getActiveSession();

        // Assert
        expect(activeSession, isNull);
      });

      test('should load kicks with session', () async {
        // Arrange
        final session = await repository.createSession();

        // Add some kicks
        await repository.addKick(session.id, MovementStrength.moderate);
        await repository.addKick(session.id, MovementStrength.strong);

        // Act
        final loadedSession = await repository.getActiveSession();

        // Assert
        expect(loadedSession, isNotNull);
        expect(loadedSession!.kicks.length, equals(2));
      });
    });

    // ------------------------------------------------------------------------
    // addKick Tests
    // ------------------------------------------------------------------------

    group('addKick', () {
      test('should set correct timestamp', () async {
        // Arrange
        final session = await repository.createSession();
        
        // Truncate to milliseconds since that's our storage precision
        final beforeKick = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
        );

        // Act
        final kick = await repository.addKick(session.id, MovementStrength.moderate);

        // Assert
        final afterKick = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
        );
        expect(
          kick.timestamp.isAfter(beforeKick) ||
              kick.timestamp.isAtSameMomentAs(beforeKick),
          isTrue,
        );
        expect(
          kick.timestamp.isBefore(afterKick) ||
              kick.timestamp.isAtSameMomentAs(afterKick),
          isTrue,
        );
      });

      test('should increment sequenceNumber', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        final kick1 = await repository.addKick(session.id, MovementStrength.weak);
        final kick2 = await repository.addKick(session.id, MovementStrength.moderate);
        final kick3 = await repository.addKick(session.id, MovementStrength.strong);

        // Assert
        expect(kick1.sequenceNumber, equals(1));
        expect(kick2.sequenceNumber, equals(2));
        expect(kick3.sequenceNumber, equals(3));
      });
    });

    // ------------------------------------------------------------------------
    // removeLastKick Tests
    // ------------------------------------------------------------------------

    group('removeLastKick', () {
      test('should delete kick with highest sequenceNumber', () async {
        // Arrange
        final session = await repository.createSession();

        await repository.addKick(session.id, MovementStrength.moderate);
        await repository.addKick(session.id, MovementStrength.moderate);
        await repository.addKick(session.id, MovementStrength.moderate);

        // Act
        await repository.removeLastKick(session.id);

        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.kicks.length, equals(2));
        expect(loadedSession.kicks.last.sequenceNumber, equals(2));
      });
    });

    // ------------------------------------------------------------------------
    // pauseSession Tests
    // ------------------------------------------------------------------------

    group('pauseSession', () {
      test('should set pausedAt to current DateTime', () async {
        // Arrange
        final session = await repository.createSession();
        final beforePause = DateTime.now();

        // Act
        await repository.pauseSession(session.id);

        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.pausedAt, isNotNull);
        // SQLite stores DateTime with millisecond precision, so use that for comparison
        expect(
          loadedSession.pausedAt!.millisecondsSinceEpoch,
          greaterThanOrEqualTo(beforePause.millisecondsSinceEpoch),
        );
      });

      test('should not modify totalPausedDuration or pauseCount', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        await repository.pauseSession(session.id);

        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.totalPausedDuration, equals(Duration.zero));
        expect(loadedSession.pauseCount, equals(0));
      });
    });

    // ------------------------------------------------------------------------
    // resumeSession Tests
    // ------------------------------------------------------------------------

    group('resumeSession', () {
      test('should calculate elapsed pause duration correctly', () async {
        // Arrange
        final session = await repository.createSession();
        await repository.pauseSession(session.id);
        
        // Wait a bit to simulate pause
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        await repository.resumeSession(session.id);

        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.totalPausedDuration.inMilliseconds,
            greaterThanOrEqualTo(100));
      });

      test('should add elapsed duration to totalPausedDuration', () async {
        // Arrange
        final session = await repository.createSession();
        
        // First pause/resume
        await repository.pauseSession(session.id);
        await Future.delayed(const Duration(milliseconds: 50));
        await repository.resumeSession(session.id);
        
        final afterFirst = await repository.getActiveSession();
        final firstDuration = afterFirst!.totalPausedDuration;

        // Second pause/resume
        await repository.pauseSession(session.id);
        await Future.delayed(const Duration(milliseconds: 50));
        await repository.resumeSession(session.id);

        // Assert
        final afterSecond = await repository.getActiveSession();
        expect(afterSecond!.totalPausedDuration.inMilliseconds,
            greaterThan(firstDuration.inMilliseconds));
      });

      test('should increment pauseCount by 1', () async {
        // Arrange
        final session = await repository.createSession();

        // Act - Pause and resume twice
        await repository.pauseSession(session.id);
        await repository.resumeSession(session.id);
        
        await repository.pauseSession(session.id);
        await repository.resumeSession(session.id);

        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.pauseCount, equals(2));
      });

      test('should clear pausedAt to null', () async {
        // Arrange
        final session = await repository.createSession();
        await repository.pauseSession(session.id);

        // Act
        await repository.resumeSession(session.id);

        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.pausedAt, isNull);
      });
    });

    // ------------------------------------------------------------------------
    // endSession Tests
    // ------------------------------------------------------------------------

    group('endSession', () {
      test('should set endTime to current DateTime', () async {
        // Arrange
        final session = await repository.createSession();
        
        await repository.addKick(session.id, MovementStrength.moderate);
        final beforeEnd = DateTime.now();

        // Act
        await repository.endSession(session.id);

        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession, isNull); // No active session
        
        // Get from history
        final history = await repository.getSessionHistory(limit: 1);
        expect(history.first.endTime, isNotNull);
        // SQLite stores DateTime with millisecond precision
        expect(
          history.first.endTime!.millisecondsSinceEpoch,
          greaterThanOrEqualTo(beforeEnd.millisecondsSinceEpoch),
        );
      });

      test('should set isActive to false', () async {
        // Arrange
        final session = await repository.createSession();
        
        await repository.addKick(session.id, MovementStrength.moderate);

        // Act
        await repository.endSession(session.id);

        // Assert
        final activeSession = await repository.getActiveSession();
        expect(activeSession, isNull);
        
        final history = await repository.getSessionHistory(limit: 1);
        expect(history.first.isActive, isFalse);
      });
    });

    // ------------------------------------------------------------------------
    // deleteSession Tests
    // ------------------------------------------------------------------------

    group('deleteSession', () {
      test('should cascade delete kicks', () async {
        // Arrange
        final session = await repository.createSession();
        
        await repository.addKick(session.id, MovementStrength.moderate);
        await repository.addKick(session.id, MovementStrength.moderate);

        // Act
        await repository.deleteSession(session.id);

        // Assert
        final activeSession = await repository.getActiveSession();
        expect(activeSession, isNull);
        
        final history = await repository.getSessionHistory();
        expect(history, isEmpty);
      });
    });

    // ------------------------------------------------------------------------
    // getSessionHistory Tests
    // ------------------------------------------------------------------------

    group('getSessionHistory', () {
      test('should return sessions ordered by startTime desc', () async {
        // Arrange
        final session1 = await repository.createSession();
        await repository.addKick(session1.id, MovementStrength.moderate);
        await repository.endSession(session1.id);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final session2 = await repository.createSession();
        await repository.addKick(session2.id, MovementStrength.moderate);
        await repository.endSession(session2.id);

        // Act
        final history = await repository.getSessionHistory();

        // Assert
        expect(history.length, equals(2));
        expect(history[0].id, equals(session2.id)); // Most recent first
        expect(history[1].id, equals(session1.id));
      });

      test('should respect limit parameter', () async {
        // Arrange
        for (int i = 0; i < 5; i++) {
          final session = await repository.createSession();
          await repository.addKick(session.id, MovementStrength.moderate);
          await repository.endSession(session.id);
          await Future.delayed(const Duration(milliseconds: 10));
        }

        // Act
        final history = await repository.getSessionHistory(limit: 3);

        // Assert
        expect(history.length, equals(3));
      });
    });

    // ------------------------------------------------------------------------
    // getSession Tests
    // ------------------------------------------------------------------------

    group('getSession', () {
      test('should retrieve session by ID with kicks', () async {
        // Arrange
        final createdSession = await repository.createSession();
        await repository.addKick(createdSession.id, MovementStrength.moderate);
        await repository.addKick(createdSession.id, MovementStrength.strong);

        // Act
        final session = await repository.getSession(createdSession.id);

        // Assert
        expect(session, isNotNull);
        expect(session!.id, equals(createdSession.id));
        expect(session.kicks.length, equals(2));
      });

      test('should return null when session does not exist', () async {
        // Act
        final session = await repository.getSession('non-existent-id');

        // Assert
        expect(session, isNull);
      });

      test('should load note if present', () async {
        // Arrange
        const note = 'Test note';

        final createdSession = await repository.createSession();
        await repository.updateSessionNote(createdSession.id, note);

        // Act
        final session = await repository.getSession(createdSession.id);

        // Assert
        expect(session, isNotNull);
        expect(session!.note, equals(note));
      });

      test('should handle session with no note', () async {
        // Arrange
        final createdSession = await repository.createSession();

        // Act
        final session = await repository.getSession(createdSession.id);

        // Assert
        expect(session, isNotNull);
        expect(session!.note, isNull);
      });
    });

    // ------------------------------------------------------------------------
    // updateSessionNote Tests
    // ------------------------------------------------------------------------

    group('updateSessionNote', () {
      test('should store note', () async {
        // Arrange
        const note = 'Felt very active today';
        final session = await repository.createSession();

        // Act
        final updatedSession = await repository.updateSessionNote(session.id, note);

        // Assert
        expect(updatedSession.note, equals(note));
      });

      test('should clear note when null is provided', () async {
        // Arrange
        const note = 'Initial note';
        final session = await repository.createSession();
        
        await repository.updateSessionNote(session.id, note);

        // Act
        final updatedSession = await repository.updateSessionNote(session.id, null);

        // Assert
        expect(updatedSession.note, isNull);
      });

      test('should clear note when empty string is provided', () async {
        // Arrange
        const note = 'Initial note';
        final session = await repository.createSession();
        
        await repository.updateSessionNote(session.id, note);

        // Act
        final updatedSession = await repository.updateSessionNote(session.id, '');

        // Assert
        expect(updatedSession.note, isNull);
      });

      test('should throw when session does not exist', () async {
        // Arrange
        const note = 'Test note';

        // Act & Assert
        expect(
          () => repository.updateSessionNote('non-existent-id', note),
          throwsA(isA<Exception>()),
        );
      });

      test('should preserve session metadata when updating note', () async {
        // Arrange
        const note = 'Test note';

        final session = await repository.createSession();
        await repository.addKick(session.id, MovementStrength.moderate);
        
        // Act
        final updatedSession = await repository.updateSessionNote(session.id, note);

        // Assert
        expect(updatedSession.id, equals(session.id));
        expect(updatedSession.startTime, equals(session.startTime));
        expect(updatedSession.isActive, equals(session.isActive));
        expect(updatedSession.kicks.length, equals(1));
      });

      test('should update note multiple times', () async {
        // Arrange
        const note1 = 'First note';
        const note2 = 'Second note';
        final session = await repository.createSession();

        // Act
        await repository.updateSessionNote(session.id, note1);
        final finalSession = await repository.updateSessionNote(session.id, note2);

        // Assert
        expect(finalSession.note, equals(note2));
      });
    });

    // ------------------------------------------------------------------------
    // Integration Tests - Note in History
    // ------------------------------------------------------------------------

    group('note in session history', () {
      test('should include notes in session history', () async {
        // Arrange
        const note1 = 'Session 1 note';
        const note2 = 'Session 2 note';

        final session1 = await repository.createSession();
        await repository.addKick(session1.id, MovementStrength.moderate);
        await repository.updateSessionNote(session1.id, note1);
        await repository.endSession(session1.id);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final session2 = await repository.createSession();
        await repository.addKick(session2.id, MovementStrength.moderate);
        await repository.updateSessionNote(session2.id, note2);
        await repository.endSession(session2.id);

        // Act
        final history = await repository.getSessionHistory();

        // Assert
        expect(history.length, equals(2));
        expect(history[0].note, equals(note2));
        expect(history[1].note, equals(note1));
      });

      test('should handle mix of sessions with and without notes', () async {
        // Arrange
        const note = 'Has a note';

        final session1 = await repository.createSession();
        await repository.addKick(session1.id, MovementStrength.moderate);
        await repository.endSession(session1.id);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final session2 = await repository.createSession();
        await repository.addKick(session2.id, MovementStrength.moderate);
        await repository.updateSessionNote(session2.id, note);
        await repository.endSession(session2.id);

        // Act
        final history = await repository.getSessionHistory();

        // Assert
        expect(history.length, equals(2));
        expect(history[0].note, equals(note));
        expect(history[1].note, isNull);
      });
    });

    // ------------------------------------------------------------------------
    // Data Retention Tests
    // ------------------------------------------------------------------------

    group('deleteSessionsOlderThan', () {
      test('should delete old sessions and return count', () async {
        // Arrange - Create sessions at different times
        final now = DateTime.now();

        // Create old session (400 days ago)
        final oldSession = await repository.createSession();
        await repository.addKick(oldSession.id, MovementStrength.moderate);
        await repository.endSession(oldSession.id);

        // Manually update the session's timestamp to be old
        await database.customStatement(
          'UPDATE kick_sessions SET start_time_millis = ?, end_time_millis = ?, created_at_millis = ? WHERE id = ?',
          [
            now.subtract(const Duration(days: 400)).millisecondsSinceEpoch,
            now.subtract(const Duration(days: 400)).millisecondsSinceEpoch,
            now.subtract(const Duration(days: 400)).millisecondsSinceEpoch,
            oldSession.id,
          ],
        );

        // Create recent session (30 days ago)
        await Future.delayed(const Duration(milliseconds: 10));
        final recentSession = await repository.createSession();
        await repository.addKick(recentSession.id, MovementStrength.moderate);
        await repository.endSession(recentSession.id);

        // Act - Delete sessions older than 365 days
        final cutoffDate = now.subtract(const Duration(days: 365));
        final deletedCount = await repository.deleteSessionsOlderThan(cutoffDate);

        // Assert
        expect(deletedCount, equals(1));

        // Verify only recent session remains
        final history = await repository.getSessionHistory();
        expect(history.length, equals(1));
        expect(history.first.id, equals(recentSession.id));
      });

      test('should return 0 when no old sessions exist', () async {
        // Arrange - Create only recent session
        final session = await repository.createSession();
        await repository.addKick(session.id, MovementStrength.moderate);
        await repository.endSession(session.id);

        // Act - Delete sessions older than 365 days
        final cutoffDate = DateTime.now().subtract(const Duration(days: 365));
        final deletedCount = await repository.deleteSessionsOlderThan(cutoffDate);

        // Assert
        expect(deletedCount, equals(0));

        // Verify session still exists
        final history = await repository.getSessionHistory();
        expect(history.length, equals(1));
      });
    });
  });
}

