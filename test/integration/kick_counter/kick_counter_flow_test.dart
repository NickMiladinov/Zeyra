@Tags(['kick_counter'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/repositories/kick_counter_repository_impl.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/domain/exceptions/kick_counter_exception.dart';
import 'package:zeyra/domain/repositories/pregnancy_repository.dart';
import 'package:zeyra/domain/usecases/kick_counter/manage_session_usecase.dart';

class MockLoggingService extends Mock implements LoggingService {}

class MockPregnancyRepository extends Mock implements PregnancyRepository {}

void main() {
  late AppDatabase database;
  late MockLoggingService mockLogger;
  late MockPregnancyRepository mockPregnancyRepository;
  late KickCounterRepositoryImpl repository;
  late ManageSessionUseCase useCase;

  setUp(() async {
    // Initialize Flutter binding for tests
    TestWidgetsFlutterBinding.ensureInitialized();
    
    mockLogger = MockLoggingService();
    mockPregnancyRepository = MockPregnancyRepository();
    
    // Create in-memory database (unencrypted for tests)
    // NOTE: Production uses SQLCipher for full database encryption
    database = AppDatabase.forTesting(NativeDatabase.memory());
    
    repository = KickCounterRepositoryImpl(
      dao: database.kickCounterDao,
      pregnancyRepository: mockPregnancyRepository,
      logger: mockLogger,
    );
    
    useCase = ManageSessionUseCase(repository: repository);
  });

  tearDown(() async {
    await database.close();
  });

  group('[Integration] Kick Counter Full Flow', () {
    test('should complete full session flow: create → kicks → pause → resume → end',
        () async {
      // 1. Create session
      final session = await useCase.startSession();
      expect(session.isActive, isTrue);
      expect(session.kickCount, equals(0));

      // 2. Add 5 kicks with varying strengths
      await useCase.recordKick(session.id, MovementStrength.weak);
      await useCase.recordKick(session.id, MovementStrength.moderate);
      await useCase.recordKick(session.id, MovementStrength.strong);
      await useCase.recordKick(session.id, MovementStrength.moderate);
      await useCase.recordKick(session.id, MovementStrength.weak);

      var activeSession = await repository.getActiveSession();
      expect(activeSession!.kickCount, equals(5));

      // 3. Pause session
      await useCase.pauseSession(session.id);
      activeSession = await repository.getActiveSession();
      expect(activeSession!.isPaused, isTrue);

      // 4. Wait 100ms to simulate pause
      await Future.delayed(const Duration(milliseconds: 100));

      // 5. Resume session
      await useCase.resumeSession(session.id);
      activeSession = await repository.getActiveSession();
      expect(activeSession!.isPaused, isFalse);
      expect(activeSession.totalPausedDuration.inMilliseconds,
          greaterThanOrEqualTo(100));
      expect(activeSession.pauseCount, equals(1));

      // 6. Add 5 more kicks
      for (int i = 0; i < 5; i++) {
        await useCase.recordKick(session.id, MovementStrength.moderate);
      }

      // 7. End session
      await useCase.endSession(session.id);

      // 8. Verify session in history
      final history = await repository.getSessionHistory(limit: 1);
      expect(history.length, equals(1));
      expect(history.first.kickCount, equals(10));
      expect(history.first.isActive, isFalse);
      expect(history.first.endTime, isNotNull);
    });

    test('should discard session and remove all data', () async {
      // 1. Create session
      final session = await useCase.startSession();

      // 2. Add 3 kicks
      await useCase.recordKick(session.id, MovementStrength.moderate);
      await useCase.recordKick(session.id, MovementStrength.moderate);
      await useCase.recordKick(session.id, MovementStrength.moderate);

      // 3. Discard session
      await useCase.discardSession(session.id);

      // 4. Verify no active session
      final activeSession = await repository.getActiveSession();
      expect(activeSession, isNull);

      // 5. Verify session not in history
      final history = await repository.getSessionHistory();
      expect(history, isEmpty);
    });

    test('should prevent ending session with 0 kicks', () async {
      // 1. Create session
      final session = await useCase.startSession();

      // 2. Try to end without kicks
      expect(
        () => useCase.endSession(session.id),
        throwsA(isA<KickCounterException>().having(
          (e) => e.type,
          'type',
          KickCounterErrorType.noKicksRecorded,
        )),
      );
    });

    test('should enforce max 100 kicks per session', () async {
      // 1. Create session
      final session = await useCase.startSession();

      // 2. Add 100 kicks
      for (int i = 0; i < 100; i++) {
        await useCase.recordKick(session.id, MovementStrength.moderate);
      }

      // 3. Try to add 101st kick
      expect(
        () => useCase.recordKick(session.id, MovementStrength.moderate),
        throwsA(isA<KickCounterException>().having(
          (e) => e.type,
          'type',
          KickCounterErrorType.maxKicksReached,
        )),
      );
    });

    test('should handle multiple pause/resume cycles correctly', () async {
      // 1. Create session and add kick
      final session = await useCase.startSession();
      await useCase.recordKick(session.id, MovementStrength.moderate);

      // 2. Pause → resume (cycle 1)
      await useCase.pauseSession(session.id);
      await Future.delayed(const Duration(milliseconds: 50));
      await useCase.resumeSession(session.id);

      var activeSession = await repository.getActiveSession();
      expect(activeSession!.pauseCount, equals(1));
      final firstPauseDuration = activeSession.totalPausedDuration;

      // 3. Pause → resume (cycle 2)
      await useCase.pauseSession(session.id);
      await Future.delayed(const Duration(milliseconds: 50));
      await useCase.resumeSession(session.id);

      activeSession = await repository.getActiveSession();
      expect(activeSession!.pauseCount, equals(2));
      expect(activeSession.totalPausedDuration,
          greaterThan(firstPauseDuration));

      // 4. Pause → resume (cycle 3)
      await useCase.pauseSession(session.id);
      await Future.delayed(const Duration(milliseconds: 50));
      await useCase.resumeSession(session.id);

      activeSession = await repository.getActiveSession();
      expect(activeSession!.pauseCount, equals(3));
    });

    test('should handle spam pause button (idempotent pause)', () async {
      // 1. Create session
      final session = await useCase.startSession();

      // 2. Pause 5 times in a row
      await useCase.pauseSession(session.id);
      await useCase.pauseSession(session.id);
      await useCase.pauseSession(session.id);
      await useCase.pauseSession(session.id);
      await useCase.pauseSession(session.id);

      // 3. Verify still paused and pauseCount == 0 (no resume yet)
      final activeSession = await repository.getActiveSession();
      expect(activeSession!.isPaused, isTrue);
      expect(activeSession.pauseCount, equals(0));
    });

    test('should calculate activeDuration excluding pauses', () async {
      // 1. Create session
      final session = await useCase.startSession();
      await useCase.recordKick(session.id, MovementStrength.moderate);

      // 2. Wait 200ms
      await Future.delayed(const Duration(milliseconds: 200));

      // 3. Pause
      await useCase.pauseSession(session.id);

      // 4. Wait 500ms (paused)
      await Future.delayed(const Duration(milliseconds: 500));

      // 5. Resume
      await useCase.resumeSession(session.id);

      // 6. End session
      await useCase.endSession(session.id);

      // 7. Verify activeDuration ≈ 200ms (excludes the 500ms pause)
      final history = await repository.getSessionHistory(limit: 1);
      final activeDuration = history.first.activeDuration;
      
      // Active duration should be close to 200ms, allowing some margin
      expect(activeDuration.inMilliseconds, lessThan(400)); // Much less than 700ms total
      expect(activeDuration.inMilliseconds, greaterThanOrEqualTo(150)); // At least 150ms
    });

    test('should store and retrieve kick strength correctly',
        () async {
      // 1. Create session
      final session = await useCase.startSession();

      // 2. Add kick with strength = STRONG
      await useCase.recordKick(session.id, MovementStrength.strong);

      // 3. Read directly from Drift DAO
      // Note: In tests, the database is unencrypted (memory database)
      // In production, SQLCipher encrypts the entire database at rest
      final sessionWithKicks = await database.kickCounterDao
          .getSessionWithKicks(session.id);
      expect(sessionWithKicks, isNotNull);
      expect(sessionWithKicks!.kicks.length, equals(1));

      // The strength is stored as a string representation in the database
      expect(sessionWithKicks.kicks.first.perceivedStrength, equals('strong'));
      expect(sessionWithKicks.kicks.first.perceivedStrength, isNotEmpty);

      // 4. Retrieve via repository (mapper converts string to enum)
      final activeSession = await repository.getActiveSession();
      expect(activeSession!.kicks.length, equals(1));
      expect(activeSession.kicks.first.perceivedStrength,
          equals(MovementStrength.strong));
    });

    test('should handle undo last kick correctly', () async {
      // 1. Create session
      final session = await useCase.startSession();

      // 2. Add 3 kicks
      await useCase.recordKick(session.id, MovementStrength.weak);
      await useCase.recordKick(session.id, MovementStrength.moderate);
      await useCase.recordKick(session.id, MovementStrength.strong);

      var activeSession = await repository.getActiveSession();
      expect(activeSession!.kickCount, equals(3));

      // 3. Undo last kick
      await useCase.undoLastKick(session.id);

      activeSession = await repository.getActiveSession();
      expect(activeSession!.kickCount, equals(2));
      expect(activeSession.kicks.last.perceivedStrength,
          equals(MovementStrength.moderate));

      // 4. Undo again
      await useCase.undoLastKick(session.id);

      activeSession = await repository.getActiveSession();
      expect(activeSession!.kickCount, equals(1));

      // 5. Try to end session (should work with 1 kick)
      await useCase.endSession(session.id);

      final history = await repository.getSessionHistory(limit: 1);
      expect(history.first.kickCount, equals(1));
    });

    test('should prompt at 10th kick', () async {
      // 1. Create session
      final session = await useCase.startSession();

      // 2. Add 9 kicks
      for (int i = 0; i < 9; i++) {
        final result = await useCase.recordKick(
            session.id, MovementStrength.moderate);
        expect(result.shouldPromptEnd, isFalse);
      }

      // 3. Add 10th kick
      final result = await useCase.recordKick(
          session.id, MovementStrength.moderate);
      expect(result.shouldPromptEnd, isTrue);

      // 4. User continues - add 11th kick
      final result11 = await useCase.recordKick(
          session.id, MovementStrength.moderate);
      expect(result11.shouldPromptEnd, isFalse);
    });
  });
}

