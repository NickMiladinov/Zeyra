@Tags(['kick_counter'])
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/local/daos/kick_counter_dao.dart';

void main() {
  late AppDatabase database;
  late KickCounterDao dao;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    database = AppDatabase.forTesting(NativeDatabase.memory());
    // Explicitly enable foreign keys for in-memory test database
    await database.customStatement('PRAGMA foreign_keys = ON');
    dao = database.kickCounterDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('[KickCounter] KickCounterDao', () {
    // ------------------------------------------------------------------------
    // Pagination Tests
    // ------------------------------------------------------------------------

    group('getSessionHistory - Pagination', () {
      test('should filter sessions by before timestamp', () async {
        // Arrange - Create 3 sessions at different times
        final now = DateTime.now();
        final session1 = KickSessionDto(
          id: 'session-1',
          startTimeMillis: now.subtract(const Duration(days: 3))
              .millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(days: 3))
              .millisecondsSinceEpoch,
          isActive: false,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: now.subtract(const Duration(days: 3))
              .millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(days: 3))
              .millisecondsSinceEpoch,
        );

        final session2 = KickSessionDto(
          id: 'session-2',
          startTimeMillis: now.subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
          isActive: false,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: now.subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
        );

        final session3 = KickSessionDto(
          id: 'session-3',
          startTimeMillis: now.subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
          isActive: false,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: now.subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
        );

        await dao.insertSession(session1);
        await dao.insertSession(session2);
        await dao.insertSession(session3);

        // Act - Get sessions before 2 days ago
        final beforeDate = now.subtract(const Duration(days: 2));
        final result = await dao.getSessionHistory(before: beforeDate);

        // Assert - Should only return session1 (3 days ago)
        expect(result.length, equals(1));
        expect(result.first.session.id, equals('session-1'));
      });

      test('should combine limit and before parameters', () async {
        // Arrange - Create 5 sessions
        final now = DateTime.now();
        for (int i = 5; i > 0; i--) {
          final session = KickSessionDto(
            id: 'session-$i',
            startTimeMillis: now.subtract(Duration(days: i))
                .millisecondsSinceEpoch,
            endTimeMillis: now.subtract(Duration(days: i))
                .millisecondsSinceEpoch,
            isActive: false,
            pausedAtMillis: null,
            totalPausedMillis: 0,
            pauseCount: 0,
            createdAtMillis: now.subtract(Duration(days: i))
                .millisecondsSinceEpoch,
            updatedAtMillis: now.subtract(Duration(days: i))
                .millisecondsSinceEpoch,
          );
          await dao.insertSession(session);
        }

        // Act - Get 2 sessions before 2 days ago
        final beforeDate = now.subtract(const Duration(days: 2));
        final result = await dao.getSessionHistory(
          limit: 2,
          before: beforeDate,
        );

        // Assert - Should return 2 sessions (4 and 5 days ago)
        expect(result.length, equals(2));
        expect(result[0].session.id, equals('session-3')); // 3 days ago (most recent within filter)
        expect(result[1].session.id, equals('session-4')); // 4 days ago
      });

      test('should return empty list when all sessions are after before date',
          () async {
        // Arrange
        final now = DateTime.now();
        final session = KickSessionDto(
          id: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: now.millisecondsSinceEpoch,
          isActive: false,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act - Query with before date in past
        final beforeDate = now.subtract(const Duration(days: 1));
        final result = await dao.getSessionHistory(before: beforeDate);

        // Assert
        expect(result, isEmpty);
      });

      test('should sort by startTime descending (most recent first)',
          () async {
        // Arrange - Create sessions with different start times
        final now = DateTime.now();
        final session1 = KickSessionDto(
          id: 'session-1',
          startTimeMillis: now.subtract(const Duration(hours: 3))
              .millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(hours: 3))
              .millisecondsSinceEpoch,
          isActive: false,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: now.subtract(const Duration(hours: 3))
              .millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(hours: 3))
              .millisecondsSinceEpoch,
        );

        final session2 = KickSessionDto(
          id: 'session-2',
          startTimeMillis: now.subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          isActive: false,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: now.subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
        );

        // Insert in random order
        await dao.insertSession(session1);
        await dao.insertSession(session2);

        // Act
        final result = await dao.getSessionHistory();

        // Assert - Should be ordered by start time desc
        expect(result.length, equals(2));
        expect(result[0].session.id, equals('session-2')); // Most recent
        expect(result[1].session.id, equals('session-1'));
      });
    });

    // ------------------------------------------------------------------------
    // Edge Cases
    // ------------------------------------------------------------------------

    group('Edge Cases', () {
      test('should handle empty kicks list for session', () async {
        // Arrange
        final session = KickSessionDto(
          id: 'session-1',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act
        final result = await dao.getSessionWithKicks('session-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.kicks, isEmpty);
      });

      test('should return null for non-existent session', () async {
        // Act
        final result = await dao.getSessionWithKicks('non-existent-id');

        // Assert
        expect(result, isNull);
      });

      test('should return null active session when none exists', () async {
        // Act
        final result = await dao.getActiveSession();

        // Assert
        expect(result, isNull);
      });

      test('should return 0 kick count for session with no kicks', () async {
        // Arrange
        final session = KickSessionDto(
          id: 'session-1',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act
        final count = await dao.getKickCount('session-1');

        // Assert
        expect(count, equals(0));
      });

      test('should return 0 kick count for non-existent session', () async {
        // Act
        final count = await dao.getKickCount('non-existent-id');

        // Assert
        expect(count, equals(0));
      });

      test('should return 0 when deleting last kick from session with no kicks',
          () async {
        // Arrange
        final session = KickSessionDto(
          id: 'session-1',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act
        final deletedCount = await dao.deleteLastKick('session-1');

        // Assert
        expect(deletedCount, equals(0));
      });

      test('should handle session with null endTime and pausedAt', () async {
        // Arrange
        final session = KickSessionDto(
          id: 'session-1',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act
        final result = await dao.getSessionWithKicks('session-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.session.endTimeMillis, isNull);
        expect(result.session.pausedAtMillis, isNull);
      });

      test('should handle multiple active sessions (defensive check)', () async {
        // Arrange - Shouldn't happen in practice, but test DB behavior
        final session1 = KickSessionDto(
          id: 'session-1',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );

        final session2 = KickSessionDto(
          id: 'session-2',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );

        await dao.insertSession(session1);
        await dao.insertSession(session2);

        // Act - Should return only one (limit 1 in query)
        final result = await dao.getActiveSession();

        // Assert
        expect(result, isNotNull);
        expect(result!.isActive, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // Data Integrity Tests
    // ------------------------------------------------------------------------

    group('Data Integrity', () {
      test('should cascade delete kicks when session is deleted', () async {
        // Arrange
        final session = KickSessionDto(
          id: 'session-1',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Add kicks
        for (int i = 1; i <= 5; i++) {
          final kick = KickDto(
            id: 'kick-$i',
            sessionId: 'session-1',
            timestampMillis: DateTime.now().millisecondsSinceEpoch,
            sequenceNumber: i,
            perceivedStrength: 'encrypted_moderate',
          );
          await dao.insertKick(kick);
        }

        // Act - Delete session
        await dao.deleteSession('session-1');

        // Assert - Kicks should be gone
        final kicks = await dao.getKicksForSession('session-1');
        expect(kicks, isEmpty);
      });

      test('should maintain kick sequence numbers correctly', () async {
        // Arrange
        final session = KickSessionDto(
          id: 'session-1',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Add kicks in random order
        final kick3 = KickDto(
          id: 'kick-3',
          sessionId: 'session-1',
          timestampMillis: DateTime.now().millisecondsSinceEpoch,
          sequenceNumber: 3,
          perceivedStrength: 'encrypted_strong',
        );
        final kick1 = KickDto(
          id: 'kick-1',
          sessionId: 'session-1',
          timestampMillis: DateTime.now().millisecondsSinceEpoch,
          sequenceNumber: 1,
          perceivedStrength: 'encrypted_weak',
        );
        final kick2 = KickDto(
          id: 'kick-2',
          sessionId: 'session-1',
          timestampMillis: DateTime.now().millisecondsSinceEpoch,
          sequenceNumber: 2,
          perceivedStrength: 'encrypted_moderate',
        );

        await dao.insertKick(kick3);
        await dao.insertKick(kick1);
        await dao.insertKick(kick2);

        // Act
        final kicks = await dao.getKicksForSession('session-1');

        // Assert - Should be ordered by sequence
        expect(kicks.length, equals(3));
        expect(kicks[0].sequenceNumber, equals(1));
        expect(kicks[1].sequenceNumber, equals(2));
        expect(kicks[2].sequenceNumber, equals(3));
      });

      test('should update session fields without affecting others', () async {
        // Arrange
        final now = DateTime.now();
        final session = KickSessionDto(
          id: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 100,
          pauseCount: 1,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act - Update only pausedAt
        final pauseTime = now.add(const Duration(minutes: 5));
        await dao.updateSessionFields(
          'session-1',
          KickSessionsCompanion(
            pausedAtMillis: Value(pauseTime.millisecondsSinceEpoch),
          ),
        );

        // Assert - Other fields should remain unchanged
        final updated = await dao.getSessionWithKicks('session-1');
        expect(updated, isNotNull);
        expect(updated!.session.pausedAtMillis,
            equals(pauseTime.millisecondsSinceEpoch));
        expect(updated.session.totalPausedMillis, equals(100)); // Unchanged
        expect(updated.session.pauseCount, equals(1)); // Unchanged
        expect(updated.session.isActive, isTrue); // Unchanged
      });

      test('should only return inactive sessions in history', () async {
        // Arrange
        final now = DateTime.now();
        final activeSession = KickSessionDto(
          id: 'active-session',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        final inactiveSession = KickSessionDto(
          id: 'inactive-session',
          startTimeMillis: now.subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          isActive: false,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: now.subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
        );

        await dao.insertSession(activeSession);
        await dao.insertSession(inactiveSession);

        // Act
        final history = await dao.getSessionHistory();

        // Assert - Only inactive session should be in history
        expect(history.length, equals(1));
        expect(history.first.session.id, equals('inactive-session'));
        expect(history.first.session.isActive, isFalse);
      });
    });

    // ------------------------------------------------------------------------
    // getSessionById Tests
    // ------------------------------------------------------------------------

    group('getSessionById', () {
      test('should retrieve session by ID without kicks', () async {
        // Arrange
        final now = DateTime.now();
        final session = KickSessionDto(
          id: 'test-session',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          note: 'Test note',
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        await dao.insertSession(session);

        // Act
        final result = await dao.getSessionById('test-session');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('test-session'));
        expect(result.note, equals('Test note'));
      });

      test('should return null when session does not exist', () async {
        // Act
        final result = await dao.getSessionById('non-existent-id');

        // Assert
        expect(result, isNull);
      });

      test('should retrieve session with note field', () async {
        // Arrange
        final now = DateTime.now();
        const note = 'Session note';
        final session = KickSessionDto(
          id: 'session-with-note',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          note: note,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        await dao.insertSession(session);

        // Act
        final result = await dao.getSessionById('session-with-note');

        // Assert
        expect(result, isNotNull);
        expect(result!.note, equals(note));
      });

      test('should retrieve session with null note', () async {
        // Arrange
        final now = DateTime.now();
        final session = KickSessionDto(
          id: 'session-no-note',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          note: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        await dao.insertSession(session);

        // Act
        final result = await dao.getSessionById('session-no-note');

        // Assert
        expect(result, isNotNull);
        expect(result!.note, isNull);
      });
    });
  });
}

