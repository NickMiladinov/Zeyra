@Tags(['contraction_timer'])
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/local/daos/contraction_timer_dao.dart';

void main() {
  late AppDatabase database;
  late ContractionTimerDao dao;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    database = AppDatabase.forTesting(NativeDatabase.memory());
    // Explicitly enable foreign keys for in-memory test database
    await database.customStatement('PRAGMA foreign_keys = ON');
    dao = database.contractionTimerDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('[ContractionTimer] ContractionTimerDao', () {
    // ------------------------------------------------------------------------
    // Session CRUD Operations
    // ------------------------------------------------------------------------

    group('Session CRUD', () {
      test('should insert and retrieve session', () async {
        // Arrange
        final now = DateTime.now();
        final session = ContractionSessionDto(
          id: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        await dao.insertSession(session);
        final retrieved = await dao.getSessionById('session-1');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('session-1'));
        expect(retrieved.isActive, isTrue);
      });

      test('should update session', () async {
        // Arrange
        final now = DateTime.now();
        final session = ContractionSessionDto(
          id: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act
        final updated = session.copyWith(
          isActive: false,
          endTimeMillis: Value(now.add(const Duration(hours: 1)).millisecondsSinceEpoch),
        );
        await dao.updateSession(updated);
        final retrieved = await dao.getSessionById('session-1');

        // Assert
        expect(retrieved!.isActive, isFalse);
        expect(retrieved.endTimeMillis, isNotNull);
      });

      test('should delete session', () async {
        // Arrange
        final now = DateTime.now();
        final session = ContractionSessionDto(
          id: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act
        final deleteCount = await dao.deleteSession('session-1');
        final retrieved = await dao.getSessionById('session-1');

        // Assert
        expect(deleteCount, equals(1));
        expect(retrieved, isNull);
      });

      test('should get active session', () async {
        // Arrange
        final now = DateTime.now();
        final activeSession = ContractionSessionDto(
          id: 'active-session',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        final completedSession = ContractionSessionDto(
          id: 'completed-session',
          startTimeMillis: now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
          isActive: false,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        );

        await dao.insertSession(completedSession);
        await dao.insertSession(activeSession);

        // Act
        final retrieved = await dao.getActiveSession();

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('active-session'));
        expect(retrieved.isActive, isTrue);
      });

      test('should return null when no active session exists', () async {
        // Arrange
        final now = DateTime.now();
        final completedSession = ContractionSessionDto(
          id: 'completed-session',
          startTimeMillis: now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
          isActive: false,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        );
        await dao.insertSession(completedSession);

        // Act
        final retrieved = await dao.getActiveSession();

        // Assert
        expect(retrieved, isNull);
      });

      test('should update session fields using companion', () async {
        // Arrange
        final now = DateTime.now();
        final session = ContractionSessionDto(
          id: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        // Act
        await dao.updateSessionFields(
          'session-1',
          ContractionSessionsCompanion(
            achievedDuration: const Value(true),
            durationAchievedAtMillis: Value(now.millisecondsSinceEpoch),
          ),
        );
        final retrieved = await dao.getSessionById('session-1');

        // Assert
        expect(retrieved!.achievedDuration, isTrue);
        expect(retrieved.durationAchievedAtMillis, isNotNull);
      });
    });

    // ------------------------------------------------------------------------
    // Contraction CRUD Operations
    // ------------------------------------------------------------------------

    group('Contraction CRUD', () {
      late ContractionSessionDto session;

      setUp(() async {
        final now = DateTime.now();
        session = ContractionSessionDto(
          id: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertSession(session);
      });

      test('should insert and retrieve contraction', () async {
        // Arrange
        final now = DateTime.now();
        final contraction = ContractionDto(
          id: 'contraction-1',
          sessionId: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: now.add(const Duration(seconds: 60)).millisecondsSinceEpoch,
          intensity: 1, // moderate
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        await dao.insertContraction(contraction);
        final retrieved = await dao.getContractionById('contraction-1');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('contraction-1'));
        expect(retrieved.sessionId, equals('session-1'));
        expect(retrieved.intensity, equals(1)); // moderate
      });

      test('should update contraction', () async {
        // Arrange
        final now = DateTime.now();
        final contraction = ContractionDto(
          id: 'contraction-1',
          sessionId: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: now.add(const Duration(seconds: 60)).millisecondsSinceEpoch,
          intensity: 1, // moderate
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertContraction(contraction);

        // Act
        final updated = contraction.copyWith(
          intensity: 2, // strong
          endTimeMillis: Value(now.add(const Duration(seconds: 90)).millisecondsSinceEpoch),
        );
        await dao.updateContraction(updated);
        final retrieved = await dao.getContractionById('contraction-1');

        // Assert
        expect(retrieved!.intensity, equals(2)); // strong
        expect(
          retrieved.endTimeMillis,
          equals(now.add(const Duration(seconds: 90)).millisecondsSinceEpoch),
        );
      });

      test('should delete contraction', () async {
        // Arrange
        final now = DateTime.now();
        final contraction = ContractionDto(
          id: 'contraction-1',
          sessionId: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: now.add(const Duration(seconds: 60)).millisecondsSinceEpoch,
          intensity: 1, // moderate
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertContraction(contraction);

        // Act
        final deleteCount = await dao.deleteContraction('contraction-1');
        final retrieved = await dao.getContractionById('contraction-1');

        // Assert
        expect(deleteCount, equals(1));
        expect(retrieved, isNull);
      });

      test('should get contractions for session ordered by start time', () async {
        // Arrange
        final now = DateTime.now();
        final contraction1 = ContractionDto(
          id: 'contraction-1',
          sessionId: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: now.add(const Duration(seconds: 60)).millisecondsSinceEpoch,
          intensity: 1, // moderate
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        final contraction2 = ContractionDto(
          id: 'contraction-2',
          sessionId: 'session-1',
          startTimeMillis: now.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
          endTimeMillis: now.add(const Duration(minutes: 6)).millisecondsSinceEpoch,
          intensity: 1, // moderate
          createdAtMillis: now.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
          updatedAtMillis: now.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        );

        // Insert in reverse order
        await dao.insertContraction(contraction2);
        await dao.insertContraction(contraction1);

        // Act
        final contractions = await dao.getContractionsForSession('session-1');

        // Assert
        expect(contractions.length, equals(2));
        expect(contractions[0].id, equals('contraction-1')); // Earlier contraction first
        expect(contractions[1].id, equals('contraction-2'));
      });

      test('should get contraction count for session', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 0; i < 3; i++) {
          final contraction = ContractionDto(
            id: 'contraction-$i',
            sessionId: 'session-1',
            startTimeMillis: now.add(Duration(minutes: i * 5)).millisecondsSinceEpoch,
            endTimeMillis: now.add(Duration(minutes: i * 5, seconds: 60)).millisecondsSinceEpoch,
            intensity: 1, // moderate
          createdAtMillis: now.add(Duration(minutes: i * 5)).millisecondsSinceEpoch,
          updatedAtMillis: now.add(Duration(minutes: i * 5)).millisecondsSinceEpoch,
        );
          await dao.insertContraction(contraction);
        }

        // Act
        final count = await dao.getContractionCount('session-1');

        // Assert
        expect(count, equals(3));
      });

      test('should get active contraction', () async {
        // Arrange
        final now = DateTime.now();
        final completedContraction = ContractionDto(
          id: 'completed-contraction',
          sessionId: 'session-1',
          startTimeMillis: now.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(minutes: 9)).millisecondsSinceEpoch,
          intensity: 1, // moderate
          createdAtMillis: now.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
        );
        final activeContraction = ContractionDto(
          id: 'active-contraction',
          sessionId: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          intensity: 1, // moderate
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        await dao.insertContraction(completedContraction);
        await dao.insertContraction(activeContraction);

        // Act
        final retrieved = await dao.getActiveContraction('session-1');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('active-contraction'));
        expect(retrieved.endTimeMillis, isNull);
      });

      test('should update contraction fields using companion', () async {
        // Arrange
        final now = DateTime.now();
        final contraction = ContractionDto(
          id: 'contraction-1',
          sessionId: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          intensity: 1, // moderate
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertContraction(contraction);

        // Act
        await dao.updateContractionFields(
          'contraction-1',
          ContractionsCompanion(
            endTimeMillis: Value(now.add(const Duration(seconds: 60)).millisecondsSinceEpoch),
            intensity: const Value(2), // strong
          ),
        );
        final retrieved = await dao.getContractionById('contraction-1');

        // Assert
        expect(retrieved!.endTimeMillis, isNotNull);
        expect(retrieved.intensity, equals(2)); // strong
      });
    });

    // ------------------------------------------------------------------------
    // Complex Queries
    // ------------------------------------------------------------------------

    group('Complex Queries', () {
      test('should get session with contractions', () async {
        // Arrange
        final now = DateTime.now();
        final session = ContractionSessionDto(
          id: 'session-1',
          startTimeMillis: now.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );
        await dao.insertSession(session);

        for (int i = 0; i < 3; i++) {
          final contraction = ContractionDto(
            id: 'contraction-$i',
            sessionId: 'session-1',
            startTimeMillis: now.add(Duration(minutes: i * 5)).millisecondsSinceEpoch,
            endTimeMillis: now.add(Duration(minutes: i * 5, seconds: 60)).millisecondsSinceEpoch,
            intensity: 1, // moderate
          createdAtMillis: now.add(Duration(minutes: i * 5)).millisecondsSinceEpoch,
          updatedAtMillis: now.add(Duration(minutes: i * 5)).millisecondsSinceEpoch,
        );
          await dao.insertContraction(contraction);
        }

        // Act
        final result = await dao.getSessionWithContractions('session-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.session.id, equals('session-1'));
        expect(result.contractions.length, equals(3));
      });

      test('should return null when session not found', () async {
        // Act
        final result = await dao.getSessionWithContractions('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('should get session history ordered by most recent first', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 3; i > 0; i--) {
          final session = ContractionSessionDto(
            id: 'session-$i',
            startTimeMillis: now.subtract(Duration(days: i)).millisecondsSinceEpoch,
            endTimeMillis: now.subtract(Duration(days: i, hours: -1)).millisecondsSinceEpoch,
            isActive: false,
            achievedDuration: false,
            durationAchievedAtMillis: null,
            achievedFrequency: false,
            frequencyAchievedAtMillis: null,
            achievedConsistency: false,
            consistencyAchievedAtMillis: null,
            createdAtMillis: now.subtract(Duration(days: i)).millisecondsSinceEpoch,
            updatedAtMillis: now.subtract(Duration(days: i, hours: -1)).millisecondsSinceEpoch,
          );
          await dao.insertSession(session);
        }

        // Act
        final result = await dao.getSessionHistory();

        // Assert
        expect(result.length, equals(3));
        expect(result[0].session.id, equals('session-1')); // Most recent
        expect(result[1].session.id, equals('session-2'));
        expect(result[2].session.id, equals('session-3')); // Oldest
      });

      test('should get session history with limit', () async {
        // Arrange
        final now = DateTime.now();
        for (int i = 5; i > 0; i--) {
          final session = ContractionSessionDto(
            id: 'session-$i',
            startTimeMillis: now.subtract(Duration(days: i)).millisecondsSinceEpoch,
            endTimeMillis: now.subtract(Duration(days: i, hours: -1)).millisecondsSinceEpoch,
            isActive: false,
            achievedDuration: false,
            durationAchievedAtMillis: null,
            achievedFrequency: false,
            frequencyAchievedAtMillis: null,
            achievedConsistency: false,
            consistencyAchievedAtMillis: null,
            createdAtMillis: now.subtract(Duration(days: i)).millisecondsSinceEpoch,
            updatedAtMillis: now.subtract(Duration(days: i, hours: -1)).millisecondsSinceEpoch,
          );
          await dao.insertSession(session);
        }

        // Act
        final result = await dao.getSessionHistory(limit: 2);

        // Assert
        expect(result.length, equals(2));
        expect(result[0].session.id, equals('session-1'));
        expect(result[1].session.id, equals('session-2'));
      });

      test('should delete sessions older than cutoff', () async {
        // Arrange
        final now = DateTime.now();
        final oldSession = ContractionSessionDto(
          id: 'old-session',
          startTimeMillis: now.subtract(const Duration(days: 100)).millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(days: 100, hours: -1)).millisecondsSinceEpoch,
          isActive: false,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.subtract(const Duration(days: 100)).millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(days: 100, hours: -1)).millisecondsSinceEpoch,
        );
        final recentSession = ContractionSessionDto(
          id: 'recent-session',
          startTimeMillis: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          endTimeMillis: now.subtract(const Duration(days: 1, hours: -1)).millisecondsSinceEpoch,
          isActive: false,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          updatedAtMillis: now.subtract(const Duration(days: 1, hours: -1)).millisecondsSinceEpoch,
        );

        await dao.insertSession(oldSession);
        await dao.insertSession(recentSession);

        // Act
        final cutoff = now.subtract(const Duration(days: 30)).millisecondsSinceEpoch;
        final deleteCount = await dao.deleteSessionsOlderThan(cutoff);
        final remainingSessions = await dao.getSessionHistory();

        // Assert
        expect(deleteCount, equals(1));
        expect(remainingSessions.length, equals(1));
        expect(remainingSessions[0].session.id, equals('recent-session'));
      });
    });
  });
}

