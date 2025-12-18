@Tags(['contraction_timer'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/repositories/contraction_timer_repository_impl.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/domain/exceptions/contraction_timer_exception.dart';
import 'package:zeyra/domain/repositories/pregnancy_repository.dart';

class MockLoggingService extends Mock implements LoggingService {}

class MockPregnancyRepository extends Mock implements PregnancyRepository {}

void main() {
  late AppDatabase database;
  late MockLoggingService mockLogger;
  late MockPregnancyRepository mockPregnancyRepository;
  late ContractionTimerRepositoryImpl repository;

  setUp(() {
    // Create in-memory database for testing (unencrypted for tests)
    database = AppDatabase.forTesting(NativeDatabase.memory());
    mockLogger = MockLoggingService();
    mockPregnancyRepository = MockPregnancyRepository();
    repository = ContractionTimerRepositoryImpl(
      dao: database.contractionTimerDao,
      pregnancyRepository: mockPregnancyRepository,
      logger: mockLogger,
    );

    // Register fallback values
    registerFallbackValue(ContractionIntensity.moderate);
  });

  tearDown(() async {
    await database.close();
  });

  group('[ContractionTimer] ContractionTimerRepositoryImpl', () {
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

      test('should initialize session with empty contractions list', () async {
        // Act
        final session = await repository.createSession();

        // Assert
        expect(session.contractions, isEmpty);
      });

      test('should initialize 5-1-1 achievement fields to false', () async {
        // Act
        final session = await repository.createSession();

        // Assert
        expect(session.achievedDuration, isFalse);
        expect(session.achievedFrequency, isFalse);
        expect(session.achievedConsistency, isFalse);
      });
    });

    // ------------------------------------------------------------------------
    // getActiveSession Tests
    // ------------------------------------------------------------------------

    group('getActiveSession', () {
      test('should return active session when one exists', () async {
        // Arrange
        await repository.createSession();

        // Act
        final activeSession = await repository.getActiveSession();

        // Assert
        expect(activeSession, isNotNull);
        expect(activeSession!.isActive, isTrue);
      });

      test('should return null when no active session exists', () async {
        // Act
        final activeSession = await repository.getActiveSession();

        // Assert
        expect(activeSession, isNull);
      });

      test('should return session with contractions', () async {
        // Arrange
        final session = await repository.createSession();
        await repository.startContraction(session.id);

        // Act
        final activeSession = await repository.getActiveSession();

        // Assert
        expect(activeSession, isNotNull);
        expect(activeSession!.contractions, isNotEmpty);
      });
    });

    // ------------------------------------------------------------------------
    // endSession Tests
    // ------------------------------------------------------------------------

    group('endSession', () {
      test('should set isActive to false', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        await repository.endSession(session.id);

        // Assert
        final endedSession = await repository.getSession(session.id);
        expect(endedSession!.isActive, isFalse);
      });

      test('should set endTime', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        await repository.endSession(session.id);

        // Assert
        final endedSession = await repository.getSession(session.id);
        expect(endedSession!.endTime, isNotNull);
      });

    });

    // ------------------------------------------------------------------------
    // startContraction Tests
    // ------------------------------------------------------------------------

    group('startContraction', () {
      test('should create contraction with generated UUID', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        final contraction = await repository.startContraction(session.id);

        // Assert
        expect(contraction.id, isNotEmpty);
        expect(contraction.id.length, equals(36));
      });

      test('should associate contraction with session', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        final contraction = await repository.startContraction(session.id);

        // Assert
        expect(contraction.sessionId, equals(session.id));
      });

      test('should set startTime to current DateTime', () async {
        // Arrange
        final session = await repository.createSession();
        final beforeStart = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
        );

        // Act
        final contraction = await repository.startContraction(session.id);

        // Assert
        final afterStart = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
        );
        expect(
          contraction.startTime.isAfter(beforeStart) ||
              contraction.startTime.isAtSameMomentAs(beforeStart),
          isTrue,
        );
        expect(
          contraction.startTime.isBefore(afterStart) ||
              contraction.startTime.isAtSameMomentAs(afterStart),
          isTrue,
        );
      });

      test('should default to moderate intensity', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        final contraction = await repository.startContraction(session.id);

        // Assert
        expect(contraction.intensity, equals(ContractionIntensity.moderate));
      });

      test('should throw exception when another contraction is active', () async {
        // Arrange
        final session = await repository.createSession();
        await repository.startContraction(session.id);

        // Act & Assert
        expect(
          () => repository.startContraction(session.id),
          throwsA(isA<ContractionTimerException>()),
        );
      });
    });

    // ------------------------------------------------------------------------
    // stopContraction Tests
    // ------------------------------------------------------------------------

    group('stopContraction', () {
      test('should set endTime on contraction', () async {
        // Arrange
        final session = await repository.createSession();
        final contraction = await repository.startContraction(session.id);

        // Act
        final stoppedContraction = await repository.stopContraction(contraction.id);

        // Assert
        expect(stoppedContraction.endTime, isNotNull);
      });

      test('should calculate duration correctly', () async {
        // Arrange
        final session = await repository.createSession();
        final contraction = await repository.startContraction(session.id);
        
        // Wait a bit to ensure duration > 0
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        final stoppedContraction = await repository.stopContraction(contraction.id);

        // Assert
        expect(stoppedContraction.duration, isNotNull);
        expect(stoppedContraction.duration!.inMilliseconds, greaterThan(0));
      });

      test('should throw exception when contraction not found', () async {
        // Act & Assert
        expect(
          () => repository.stopContraction('non-existent-id'),
          throwsA(isA<ContractionTimerException>()),
        );
      });
    });

    // ------------------------------------------------------------------------
    // updateContraction Tests
    // ------------------------------------------------------------------------

    group('updateContraction', () {
      test('should update contraction intensity', () async {
        // Arrange
        final session = await repository.createSession();
        final contraction = await repository.startContraction(session.id);
        await repository.stopContraction(contraction.id);

        // Act
        final updated = await repository.updateContraction(
          contraction.id,
          intensity: ContractionIntensity.strong,
        );

        // Assert
        expect(updated.intensity, equals(ContractionIntensity.strong));
      });

      test('should update start time', () async {
        // Arrange
        final session = await repository.createSession();
        final contraction = await repository.startContraction(session.id);
        await repository.stopContraction(contraction.id);
        final newStartTime = contraction.startTime.subtract(const Duration(minutes: 5));

        // Act
        final updated = await repository.updateContraction(
          contraction.id,
          startTime: newStartTime,
        );

        // Assert
        expect(updated.startTime, equals(newStartTime));
      });

      test('should throw exception when contraction not found', () async {
        // Act & Assert
        expect(
          () => repository.updateContraction('non-existent-id'),
          throwsA(isA<ContractionTimerException>()),
        );
      });
    });

    // ------------------------------------------------------------------------
    // deleteContraction Tests
    // ------------------------------------------------------------------------

    group('deleteContraction', () {
      test('should remove contraction from database', () async {
        // Arrange
        final session = await repository.createSession();
        final contraction = await repository.startContraction(session.id);
        await repository.stopContraction(contraction.id);

        // Act
        await repository.deleteContraction(contraction.id);

        // Assert
        final retrievedSession = await repository.getSession(session.id);
        expect(retrievedSession!.contractions, isEmpty);
      });

      test('should throw exception when contraction not found', () async {
        // Act & Assert
        expect(
          () => repository.deleteContraction('non-existent-id'),
          throwsA(isA<ContractionTimerException>()),
        );
      });
    });

    // ------------------------------------------------------------------------
    // deleteSession Tests
    // ------------------------------------------------------------------------

    group('deleteSession', () {
      test('should remove session from database', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        await repository.deleteSession(session.id);

        // Assert
        final retrievedSession = await repository.getSession(session.id);
        expect(retrievedSession, isNull);
      });

      test('should remove all contractions for session', () async {
        // Arrange
        final session = await repository.createSession();
        await repository.startContraction(session.id);

        // Act
        await repository.deleteSession(session.id);

        // Assert
        final retrievedSession = await repository.getSession(session.id);
        expect(retrievedSession, isNull);
      });

    });

    // ------------------------------------------------------------------------
    // getSession Tests
    // ------------------------------------------------------------------------

    group('getSession', () {
      test('should return session with all contractions', () async {
        // Arrange
        final session = await repository.createSession();
        await repository.startContraction(session.id);

        // Act
        final retrievedSession = await repository.getSession(session.id);

        // Assert
        expect(retrievedSession, isNotNull);
        expect(retrievedSession!.id, equals(session.id));
        expect(retrievedSession.contractions.length, equals(1));
      });

      test('should return null when session not found', () async {
        // Act
        final retrievedSession = await repository.getSession('non-existent-id');

        // Assert
        expect(retrievedSession, isNull);
      });
    });

    // ------------------------------------------------------------------------
    // getSessionHistory Tests
    // ------------------------------------------------------------------------

    group('getSessionHistory', () {
      test('should return only inactive sessions', () async {
        // Arrange
        // ignore: unused_local_variable
        final activeSession = await repository.createSession();
        final completedSession = await repository.createSession();
        await repository.endSession(completedSession.id);

        // Act
        final history = await repository.getSessionHistory();

        // Assert
        expect(history.length, equals(1));
        expect(history.first.id, equals(completedSession.id));
      });

      test('should order sessions by most recent first', () async {
        // Arrange
        final session1 = await repository.createSession();
        await Future.delayed(const Duration(milliseconds: 10));
        final session2 = await repository.createSession();
        
        await repository.endSession(session1.id);
        await repository.endSession(session2.id);

        // Act
        final history = await repository.getSessionHistory();

        // Assert
        expect(history.length, equals(2));
        expect(history.first.id, equals(session2.id)); // Most recent first
        expect(history.last.id, equals(session1.id));
      });

      test('should respect limit parameter', () async {
        // Arrange
        for (int i = 0; i < 5; i++) {
          final session = await repository.createSession();
          await repository.endSession(session.id);
        }

        // Act
        final history = await repository.getSessionHistory(limit: 2);

        // Assert
        expect(history.length, equals(2));
      });
    });

    // ------------------------------------------------------------------------
    // updateSessionCriteria Tests
    // ------------------------------------------------------------------------

    group('updateSessionCriteria', () {
      test('should update duration achievement', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        final updated = await repository.updateSessionCriteria(
          session.id,
          achievedDuration: true,
          durationAchievedAt: DateTime.now(),
        );

        // Assert
        expect(updated.achievedDuration, isTrue);
        expect(updated.durationAchievedAt, isNotNull);
      });

      test('should update frequency achievement', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        final updated = await repository.updateSessionCriteria(
          session.id,
          achievedFrequency: true,
          frequencyAchievedAt: DateTime.now(),
        );

        // Assert
        expect(updated.achievedFrequency, isTrue);
        expect(updated.frequencyAchievedAt, isNotNull);
      });

      test('should update consistency achievement', () async {
        // Arrange
        final session = await repository.createSession();

        // Act
        final updated = await repository.updateSessionCriteria(
          session.id,
          achievedConsistency: true,
          consistencyAchievedAt: DateTime.now(),
        );

        // Assert
        expect(updated.achievedConsistency, isTrue);
        expect(updated.consistencyAchievedAt, isNotNull);
      });

      test('should throw exception when session not found', () async {
        // Act & Assert
        expect(
          () => repository.updateSessionCriteria('non-existent-id'),
          throwsA(isA<ContractionTimerException>()),
        );
      });
    });

    // ------------------------------------------------------------------------
    // deleteSessionsOlderThan Tests
    // ------------------------------------------------------------------------

    group('deleteSessionsOlderThan', () {
      test('should delete sessions older than cutoff date', () async {
        // Arrange
        final oldSession = await repository.createSession();
        await repository.endSession(oldSession.id);
        
        // Wait to ensure time difference
        await Future.delayed(const Duration(milliseconds: 10));
        final cutoffDate = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 10));
        
        final recentSession = await repository.createSession();
        await repository.endSession(recentSession.id);

        // Act
        final deletedCount = await repository.deleteSessionsOlderThan(cutoffDate);

        // Assert
        expect(deletedCount, equals(1));
        final history = await repository.getSessionHistory();
        expect(history.length, equals(1));
        expect(history.first.id, equals(recentSession.id));
      });

      test('should return 0 when no sessions to delete', () async {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 365));

        // Act
        final deletedCount = await repository.deleteSessionsOlderThan(futureDate);

        // Assert
        expect(deletedCount, equals(0));
      });
    });
  });
}

