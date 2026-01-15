@Tags(['kick_counter'])
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/repositories/kick_counter_repository_impl.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/domain/repositories/pregnancy_repository.dart';

class MockLoggingService extends Mock implements LoggingService {}

class MockPregnancyRepository extends Mock implements PregnancyRepository {}

void main() {
  late AppDatabase database;
  late MockLoggingService mockLogger;
  late MockPregnancyRepository mockPregnancyRepository;
  late KickCounterRepositoryImpl repository;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
    mockLogger = MockLoggingService();
    mockPregnancyRepository = MockPregnancyRepository();
    repository = KickCounterRepositoryImpl(
      dao: database.kickCounterDao,
      pregnancyRepository: mockPregnancyRepository,
      logger: mockLogger,
    );

    // Register fallback values
    registerFallbackValue(MovementStrength.moderate);
  });

  tearDown(() async {
    await database.close();
  });

  group('[KickCounter] Repository Error Handling', () {
    // NOTE: Encryption failures are no longer tested here since we use
    // SQLCipher for full database encryption. Encryption errors would
    // prevent the entire database from being opened.

    // ------------------------------------------------------------------------
    // Null/Invalid ID Tests
    // ------------------------------------------------------------------------

    group('Invalid Session IDs', () {
      test('should handle non-existent session ID in endSession gracefully',
          () async {
        // Act & Assert - Should not throw, just no-op
        await repository.endSession('non-existent-id');
        
        // Verify no crashes occurred
        expect(true, isTrue);
      });

      test('should handle non-existent session ID in deleteSession gracefully',
          () async {
        // Act
        await repository.deleteSession('non-existent-id');
        
        // Assert - Should complete without error
        final sessions = await repository.getSessionHistory();
        expect(sessions, isEmpty);
      });

      test('should handle non-existent session ID in pauseSession gracefully',
          () async {
        // Act & Assert - Should not throw
        await repository.pauseSession('non-existent-id');
        expect(true, isTrue);
      });

      test('should handle non-existent session ID in resumeSession gracefully',
          () async {
        // Act & Assert - Should not throw
        await repository.resumeSession('non-existent-id');
        expect(true, isTrue);
      });

      test('should handle empty string session ID', () async {
        // Act & Assert
        await repository.endSession('');
        await repository.deleteSession('');
        await repository.pauseSession('');
        await repository.resumeSession('');
        await repository.removeLastKick('');
        
        // Should all complete without error
        expect(true, isTrue);
      });

      test('should handle very long session ID', () async {
        // Arrange
        final longId = 'x' * 1000; // 1000 character ID
        
        // Act & Assert - Should not crash
        await repository.endSession(longId);
        await repository.deleteSession(longId);
        
        expect(true, isTrue);
      });

      test('should handle special characters in session ID', () async {
        // Arrange
        const specialId = 'session-!@#\$%^&*()';
        
        // Act & Assert - Should not crash
        await repository.endSession(specialId);
        await repository.deleteSession(specialId);
        
        expect(true, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // Concurrent Operation Tests
    // ------------------------------------------------------------------------

    group('Concurrent Operations', () {
      test('should handle rapid session creation attempts', () async {
        // Act - Try to create multiple sessions rapidly
        final futures = <Future<dynamic>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(repository.createSession());
        }
        
        // Wait for all to complete
        final sessions = await Future.wait(futures);
        
        // Assert - All should have unique IDs
        final ids = sessions.map((s) => s.id).toSet();
        expect(ids.length, equals(10)); // All unique
      });

      test('should handle concurrent kick additions to same session',
          () async {
        // Arrange
        final session = await repository.createSession();
        
        // Act - Add kicks concurrently
        final futures = <Future<dynamic>>[];
        for (int i = 0; i < 5; i++) {
          futures.add(repository.addKick(session.id, MovementStrength.moderate));
        }
        
        await Future.wait(futures);
        
        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.kickCount, equals(5));
      });

      test('should handle concurrent pause/resume operations', () async {
        // Arrange
        final session = await repository.createSession();
        
        // Act - Rapidly pause and resume
        for (int i = 0; i < 5; i++) {
          await repository.pauseSession(session.id);
          await repository.resumeSession(session.id);
        }
        
        // Assert - Should not crash and maintain data integrity
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession, isNotNull);
        expect(loadedSession!.pauseCount, greaterThan(0));
      });
    });

    // ------------------------------------------------------------------------
    // Data Corruption Tests
    // ------------------------------------------------------------------------

    group('Data Corruption Scenarios', () {
      // NOTE: Encryption corruption tests removed since we use SQLCipher
      // for full database encryption. Corrupted encryption would prevent
      // the entire database from being opened.

      test('should handle negative timestamps gracefully', () async {
        // Arrange - Create a session with negative timestamp
        // This would be a database corruption scenario
        final dto = KickSessionDto(
          id: 'session-corrupt',
          startTimeMillis: -1000,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: -1000,
          updatedAtMillis: -1000,
        );
        await database.kickCounterDao.insertSession(dto);
        
        // Act - Should not crash
        final session = await repository.getActiveSession();
        
        // Assert - Should return the session even with invalid timestamp
        expect(session, isNotNull);
      });

      test('should handle negative pause duration', () async {
        // Arrange - Create session with negative totalPausedMillis
        final dto = KickSessionDto(
          id: 'session-negative-pause',
          startTimeMillis: DateTime.now().millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: -5000, // Negative!
          pauseCount: 0,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await database.kickCounterDao.insertSession(dto);
        
        // Act
        final session = await repository.getActiveSession();
        
        // Assert - Should handle negative duration
        expect(session, isNotNull);
        expect(session!.totalPausedDuration.isNegative, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // Edge Case Timestamp Tests
    // ------------------------------------------------------------------------

    group('Timestamp Edge Cases', () {
      test('should handle sessions at epoch 0', () async {
        // Arrange
        final dto = KickSessionDto(
          id: 'session-epoch',
          startTimeMillis: 0,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: 0,
          updatedAtMillis: 0,
        );
        await database.kickCounterDao.insertSession(dto);
        
        // Act
        final session = await repository.getActiveSession();
        
        // Assert
        expect(session, isNotNull);
        expect(session!.startTime.millisecondsSinceEpoch, equals(0));
      });

      test('should handle very far future timestamps', () async {
        // Arrange - Year 3000
        final futureTime = DateTime(3000).millisecondsSinceEpoch;
        final dto = KickSessionDto(
          id: 'session-future',
          startTimeMillis: futureTime,
          endTimeMillis: null,
          isActive: true,
          pausedAtMillis: null,
          totalPausedMillis: 0,
          pauseCount: 0,
          createdAtMillis: futureTime,
          updatedAtMillis: futureTime,
        );
        await database.kickCounterDao.insertSession(dto);
        
        // Act
        final loadedSession = await repository.getActiveSession();
        
        // Assert
        expect(loadedSession, isNotNull);
        expect(loadedSession!.startTime.year, equals(3000));
      });

      test('should handle pause/resume with same timestamp', () async {
        // Arrange
        final createdSession = await repository.createSession();
        final now = DateTime.now();
        
        // Manually set pausedAt to current time
        await database.kickCounterDao.updateSessionFields(
          createdSession.id,
          KickSessionsCompanion(
            pausedAtMillis: Value(now.millisecondsSinceEpoch),
          ),
        );
        
        // Immediately resume (same millisecond if fast enough)
        await repository.resumeSession(createdSession.id);
        
        // Act
        final loadedSession = await repository.getActiveSession();
        
        // Assert - Should handle 0 duration pause
        expect(loadedSession, isNotNull);
        expect(loadedSession!.totalPausedDuration.inMilliseconds,
            greaterThanOrEqualTo(0));
      });
    });

    // ------------------------------------------------------------------------
    // Batch Operation Error Tests
    // ------------------------------------------------------------------------

    group('Batch Operation Errors', () {
      // NOTE: Encryption batch failure tests removed since we use SQLCipher
      // for full database encryption. Encryption happens at the database level.

      test('should handle database lock during batch operations', () async {
        // This is hard to simulate but we can test resilience
        // by performing many operations rapidly
        
        // Act - Rapid operations
        final session1 = await repository.createSession();
        await repository.addKick(session1.id, MovementStrength.moderate);
        await repository.pauseSession(session1.id);
        await repository.resumeSession(session1.id);
        await repository.endSession(session1.id);
        
        final session2 = await repository.createSession();
        await repository.addKick(session2.id, MovementStrength.strong);
        
        // Assert - All operations should complete
        final active = await repository.getActiveSession();
        expect(active, isNotNull);
        expect(active!.id, equals(session2.id));
        
        final history = await repository.getSessionHistory();
        expect(history.length, equals(1));
      });
    });

    // ------------------------------------------------------------------------
    // Memory/Resource Tests
    // ------------------------------------------------------------------------

    group('Resource Handling', () {
      test('should handle loading session with no kicks efficiently', () async {
        // Arrange
        await repository.createSession();
        
        // Act - Multiple loads
        for (int i = 0; i < 100; i++) {
          final loaded = await repository.getActiveSession();
          expect(loaded, isNotNull);
        }
        
        // Assert - Should not crash or leak memory
        expect(true, isTrue);
      });

      test('should handle repeated history queries', () async {
        // Arrange - Create a few sessions
        for (int i = 0; i < 5; i++) {
          final session = await repository.createSession();
          await repository.addKick(session.id, MovementStrength.moderate);
          await repository.endSession(session.id);
        }
        
        // Act - Query history repeatedly
        for (int i = 0; i < 50; i++) {
          final history = await repository.getSessionHistory();
          expect(history.length, equals(5));
        }
        
        // Assert - Should handle repeated queries
        expect(true, isTrue);
      });
    });
  });
}

