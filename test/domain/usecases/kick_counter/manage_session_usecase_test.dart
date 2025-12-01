@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_counter_constants.dart';
import 'package:zeyra/domain/exceptions/kick_counter_exception.dart';
import 'package:zeyra/domain/repositories/kick_counter_repository.dart';
import 'package:zeyra/domain/usecases/kick_counter/manage_session_usecase.dart';

import '../../../mocks/fake_data/kick_counter_fakes.dart';

// Mock repository
class MockKickCounterRepository extends Mock
    implements KickCounterRepository {}

void main() {
  late MockKickCounterRepository mockRepository;
  late ManageSessionUseCase useCase;

  setUp(() {
    mockRepository = MockKickCounterRepository();
    useCase = ManageSessionUseCase(repository: mockRepository);

    // Register fallback values
    registerFallbackValue(MovementStrength.moderate);
  });

  group('[KickCounter] ManageSessionUseCase', () {
    // ------------------------------------------------------------------------
    // startSession Tests
    // ------------------------------------------------------------------------

    group('startSession', () {
      test('should create new session when no active session exists', () async {
        // Arrange
        final expectedSession = FakeKickSession.simple();
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);
        when(() => mockRepository.createSession())
            .thenAnswer((_) async => expectedSession);

        // Act
        final result = await useCase.startSession();

        // Assert
        expect(result, equals(expectedSession));
        verify(() => mockRepository.getActiveSession()).called(1);
        verify(() => mockRepository.createSession()).called(1);
      });

      test('should throw sessionAlreadyActive when active session exists',
          () async {
        // Arrange
        final activeSession = FakeKickSession.simple();
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => activeSession);

        // Act & Assert
        expect(
          () => useCase.startSession(),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.sessionAlreadyActive,
            ),
          ),
        );
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.createSession());
      });

      test('should throw with descriptive message for concurrent session',
          () async {
        // Arrange
        final activeSession = FakeKickSession.simple();
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => activeSession);

        // Act & Assert
        expect(
          () => useCase.startSession(),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.message,
              'message',
              contains('active session already exists'),
            ),
          ),
        );
      });
    });

    // ------------------------------------------------------------------------
    // recordKick Tests
    // ------------------------------------------------------------------------

    group('recordKick', () {
      test('should add kick and return shouldPromptEnd=false when < 10 kicks',
          () async {
        // Arrange
        final sessionId = 'session-1';
        final initialSession = FakeKickSession.simple(
          id: sessionId,
          kicks: FakeKick.batch(5), // 5 existing kicks
        );
        final newKick = FakeKick.simple(sequenceNumber: 6);
        final updatedSession = FakeKickSession.simple(
          id: sessionId,
          kicks: [...initialSession.kicks, newKick],
        );

        // First call checks validation, second call returns updated session
        int callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return initialSession;
          return updatedSession;
        });
        
        when(() => mockRepository.addKick(sessionId, MovementStrength.strong))
            .thenAnswer((_) async => newKick);

        // Act
        final result = await useCase.recordKick(
          sessionId,
          MovementStrength.strong,
        );

        // Assert
        expect(result.session, equals(updatedSession));
        expect(result.shouldPromptEnd, isFalse);
        verify(() => mockRepository.getActiveSession()).called(2);
        verify(() => mockRepository.addKick(sessionId, MovementStrength.strong))
            .called(1);
      });

      test('should return shouldPromptEnd=true at exactly 10 kicks', () async {
        // Arrange
        final sessionId = 'session-1';
        final initialSession = FakeKickSession.simple(
          id: sessionId,
          kicks: FakeKick.batch(9),
        );
        final newKick = FakeKick.simple(sequenceNumber: 10);
        final updatedSession = FakeKickSession.simple(
          id: sessionId,
          kicks: [...initialSession.kicks, newKick],
        );

        int callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
           callCount++;
           return callCount == 1 ? initialSession : updatedSession;
        });
        
        when(() => mockRepository.addKick(sessionId, MovementStrength.moderate))
            .thenAnswer((_) async => newKick);

        // Act
        final result = await useCase.recordKick(
          sessionId,
          MovementStrength.moderate,
        );

        // Assert
        expect(result.session, equals(updatedSession));
        expect(result.shouldPromptEnd, isTrue);
      });

      test('should return shouldPromptEnd=false after 10 kicks', () async {
        // Arrange
        final sessionId = 'session-1';
        final initialSession = FakeKickSession.simple(
          id: sessionId,
          kicks: FakeKick.batch(15),
        );
        final newKick = FakeKick.simple(sequenceNumber: 16);
        final updatedSession = FakeKickSession.simple(
          id: sessionId,
          kicks: [...initialSession.kicks, newKick],
        );

        int callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
           callCount++;
           return callCount == 1 ? initialSession : updatedSession;
        });

        when(() => mockRepository.addKick(sessionId, MovementStrength.weak))
            .thenAnswer((_) async => newKick);

        // Act
        final result = await useCase.recordKick(
          sessionId,
          MovementStrength.weak,
        );

        // Assert
        expect(result.shouldPromptEnd, isFalse);
      });

      test('should throw maxKicksReached when session has 100 kicks', () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(
          id: sessionId,
          kicks: FakeKick.batch(KickCounterConstants.maxKicksPerSession),
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.recordKick(sessionId, MovementStrength.moderate),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.maxKicksReached,
            ),
          ),
        );
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(
            () => mockRepository.addKick(any(), any()));
      });

      test('should throw noActiveSession when session is null', () async {
        // Arrange
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => useCase.recordKick('invalid-id', MovementStrength.moderate),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });

      test('should throw noActiveSession when session ID mismatch', () async {
        // Arrange
        final session = FakeKickSession.simple(id: 'session-1');
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.recordKick('wrong-id', MovementStrength.moderate),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });

      test('should handle all movement strength types', () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(id: sessionId, kicks: []);

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.addKick(sessionId, any()))
            .thenAnswer((_) async => FakeKick.simple());

        // Act & Assert - weak
        await useCase.recordKick(sessionId, MovementStrength.weak);
        verify(() => mockRepository.addKick(sessionId, MovementStrength.weak))
            .called(1);

        // Act & Assert - moderate
        await useCase.recordKick(sessionId, MovementStrength.moderate);
        verify(
                () => mockRepository.addKick(sessionId, MovementStrength.moderate))
            .called(1);

        // Act & Assert - strong
        await useCase.recordKick(sessionId, MovementStrength.strong);
        verify(() => mockRepository.addKick(sessionId, MovementStrength.strong))
            .called(1);
      });
    });

    // ------------------------------------------------------------------------
    // undoLastKick Tests
    // ------------------------------------------------------------------------

    group('undoLastKick', () {
      test('should remove last kick when kicks exist', () async {
        // Arrange
        final sessionId = 'session-1';
        final initialSession = FakeKickSession.simple(
          id: sessionId,
          kicks: FakeKick.batch(3),
        );
        final updatedSession = FakeKickSession.simple(
          id: sessionId,
          kicks: FakeKick.batch(2),
        );

        int callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
           callCount++;
           return callCount == 1 ? initialSession : updatedSession;
        });
        
        when(() => mockRepository.removeLastKick(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.undoLastKick(sessionId);

        // Assert
        verify(() => mockRepository.getActiveSession()).called(2);
        verify(() => mockRepository.removeLastKick(sessionId)).called(1);
      });

      test('should throw noKicksToUndo when session has no kicks', () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(
          id: sessionId,
          kicks: [], // No kicks
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.undoLastKick(sessionId),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noKicksToUndo,
            ),
          ),
        );
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.removeLastKick(any()));
      });

      test('should throw noActiveSession when session is null', () async {
        // Arrange
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => useCase.undoLastKick('invalid-id'),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });

      test('should throw noActiveSession when session ID mismatch', () async {
        // Arrange
        final session = FakeKickSession.simple(
          id: 'session-1',
          kicks: FakeKick.batch(2),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.undoLastKick('wrong-id'),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });
    });

    // ------------------------------------------------------------------------
    // endSession Tests
    // ------------------------------------------------------------------------

    group('endSession', () {
      test('should end session when it has kicks', () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(
          id: sessionId,
          kicks: FakeKick.batch(10),
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.endSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.endSession(sessionId);

        // Assert
        verify(() => mockRepository.getActiveSession()).called(1);
        verify(() => mockRepository.endSession(sessionId)).called(1);
      });

      test('should throw noKicksRecorded when session has zero kicks',
          () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(
          id: sessionId,
          kicks: [], // No kicks
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.endSession(sessionId),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noKicksRecorded,
            ),
          ),
        );
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.endSession(any()));
      });

      test('should include medical guidance in noKicksRecorded message',
          () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(
          id: sessionId,
          kicks: [],
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.endSession(sessionId),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('no kicks'),
                contains('midwife'),
              ),
            ),
          ),
        );
      });

      test('should throw noActiveSession when session is null', () async {
        // Arrange
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => useCase.endSession('invalid-id'),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });

      test('should end session with exactly 1 kick', () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(
          id: sessionId,
          kicks: FakeKick.batch(1), // Minimum valid
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.endSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.endSession(sessionId);

        // Assert
        verify(() => mockRepository.endSession(sessionId)).called(1);
      });
    });

    // ------------------------------------------------------------------------
    // discardSession Tests
    // ------------------------------------------------------------------------

    group('discardSession', () {
      test('should delete session regardless of state', () async {
        // Arrange
        final sessionId = 'session-1';
        when(() => mockRepository.deleteSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.discardSession(sessionId);

        // Assert
        verify(() => mockRepository.deleteSession(sessionId)).called(1);
      });

      test('should allow discarding session with no kicks', () async {
        // Arrange - Unlike endSession, discard doesn't validate kicks
        final sessionId = 'session-1';
        when(() => mockRepository.deleteSession(sessionId))
            .thenAnswer((_) async {});

        // Act & Assert - No exception thrown
        await useCase.discardSession(sessionId);
        verify(() => mockRepository.deleteSession(sessionId)).called(1);
      });

      test('should not validate active session before discarding', () async {
        // Arrange - discard doesn't check if session is active
        final sessionId = 'session-1';
        when(() => mockRepository.deleteSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.discardSession(sessionId);

        // Assert
        verifyNever(() => mockRepository.getActiveSession());
        verify(() => mockRepository.deleteSession(sessionId)).called(1);
      });
    });

    // ------------------------------------------------------------------------
    // pauseSession Tests
    // ------------------------------------------------------------------------

    group('pauseSession', () {
      test('should pause session when not already paused', () async {
        // Arrange
        final sessionId = 'session-1';
        final initialSession = FakeKickSession.simple(
          id: sessionId,
          pausedAt: null, // Not paused
        );
        final updatedSession = FakeKickSession.simple(
          id: sessionId,
          pausedAt: DateTime.now(),
        );

        int callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
           callCount++;
           return callCount == 1 ? initialSession : updatedSession;
        });

        when(() => mockRepository.pauseSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.pauseSession(sessionId);

        // Assert
        verify(() => mockRepository.getActiveSession()).called(2);
        verify(() => mockRepository.pauseSession(sessionId)).called(1);
      });

      test('should be idempotent - do nothing if already paused', () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(
          id: sessionId,
          pausedAt: DateTime.now(), // Already paused
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act
        final result = await useCase.pauseSession(sessionId);

        // Assert
        expect(result, equals(session));
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.pauseSession(any()));
      });

      test('should throw noActiveSession when session is null', () async {
        // Arrange
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => useCase.pauseSession('invalid-id'),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });

      test('should throw noActiveSession when session ID mismatch', () async {
        // Arrange
        final session = FakeKickSession.simple(id: 'session-1');
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.pauseSession('wrong-id'),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });
    });

    // ------------------------------------------------------------------------
    // resumeSession Tests
    // ------------------------------------------------------------------------

    group('resumeSession', () {
      test('should resume session when paused', () async {
        // Arrange
        final sessionId = 'session-1';
        final initialSession = FakeKickSession.simple(
          id: sessionId,
          pausedAt: DateTime.now(), // Paused
        );
        final updatedSession = FakeKickSession.simple(
          id: sessionId,
          pausedAt: null,
        );

        int callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
           callCount++;
           return callCount == 1 ? initialSession : updatedSession;
        });

        when(() => mockRepository.resumeSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.resumeSession(sessionId);

        // Assert
        verify(() => mockRepository.getActiveSession()).called(2);
        verify(() => mockRepository.resumeSession(sessionId)).called(1);
      });

      test('should throw sessionNotPaused when session is not paused',
          () async {
        // Arrange
        final sessionId = 'session-1';
        final session = FakeKickSession.simple(
          id: sessionId,
          pausedAt: null, // Not paused
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.resumeSession(sessionId),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.sessionNotPaused,
            ),
          ),
        );
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.resumeSession(any()));
      });

      test('should throw noActiveSession when session is null', () async {
        // Arrange
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => useCase.resumeSession('invalid-id'),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });

      test('should throw noActiveSession when session ID mismatch', () async {
        // Arrange
        final session = FakeKickSession.simple(
          id: 'session-1',
          pausedAt: DateTime.now(),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.resumeSession('wrong-id'),
          throwsA(
            isA<KickCounterException>().having(
              (e) => e.type,
              'type',
              KickCounterErrorType.noActiveSession,
            ),
          ),
        );
      });
    });

    // ------------------------------------------------------------------------
    // updateSessionNote Tests
    // ------------------------------------------------------------------------

    group('updateSessionNote', () {
      test('should update note and return updated session', () async {
        // Arrange
        const sessionId = 'session-1';
        const note = 'Felt very active today';
        final updatedSession = FakeKickSession.ended(note: note);
        
        when(() => mockRepository.updateSessionNote(sessionId, note))
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.updateSessionNote(sessionId, note);

        // Assert
        expect(result, equals(updatedSession));
        expect(result.note, equals(note));
        verify(() => mockRepository.updateSessionNote(sessionId, note)).called(1);
      });

      test('should clear note when null is provided', () async {
        // Arrange
        const sessionId = 'session-1';
        final updatedSession = FakeKickSession.ended(note: null);
        
        when(() => mockRepository.updateSessionNote(sessionId, null))
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.updateSessionNote(sessionId, null);

        // Assert
        expect(result, equals(updatedSession));
        expect(result.note, isNull);
        verify(() => mockRepository.updateSessionNote(sessionId, null)).called(1);
      });

      test('should clear note when empty string is provided', () async {
        // Arrange
        const sessionId = 'session-1';
        const note = '';
        final updatedSession = FakeKickSession.ended(note: null);
        
        when(() => mockRepository.updateSessionNote(sessionId, note))
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.updateSessionNote(sessionId, note);

        // Assert
        expect(result, equals(updatedSession));
        verify(() => mockRepository.updateSessionNote(sessionId, note)).called(1);
      });
    });

    // ------------------------------------------------------------------------
    // deleteHistoricalSession Tests
    // ------------------------------------------------------------------------

    group('deleteHistoricalSession', () {
      test('should delete session by calling repository', () async {
        // Arrange
        const sessionId = 'session-1';
        when(() => mockRepository.deleteSession(sessionId))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase.deleteHistoricalSession(sessionId);

        // Assert
        verify(() => mockRepository.deleteSession(sessionId)).called(1);
      });

      test('should complete without error when session does not exist', () async {
        // Arrange
        const sessionId = 'non-existent';
        when(() => mockRepository.deleteSession(sessionId))
            .thenAnswer((_) async => Future.value());

        // Act & Assert
        await expectLater(
          useCase.deleteHistoricalSession(sessionId),
          completes,
        );
      });
    });

    // ------------------------------------------------------------------------
    // getSessionHistory Tests
    // ------------------------------------------------------------------------

    group('getSessionHistory', () {
      test('should return session history from repository', () async {
        // Arrange
        final history = [
          FakeKickSession.ended(note: 'First session'),
          FakeKickSession.ended(note: 'Second session'),
          FakeKickSession.ended(),
        ];
        when(() => mockRepository.getSessionHistory(limit: 50, before: null))
            .thenAnswer((_) async => history);

        // Act
        final result = await useCase.getSessionHistory(limit: 50);

        // Assert
        expect(result, equals(history));
        expect(result.length, equals(3));
        verify(() => mockRepository.getSessionHistory(limit: 50, before: null)).called(1);
      });

      test('should return empty list when no history exists', () async {
        // Arrange
        when(() => mockRepository.getSessionHistory(limit: null, before: null))
            .thenAnswer((_) async => []);

        // Act
        final result = await useCase.getSessionHistory();

        // Assert
        expect(result, isEmpty);
        verify(() => mockRepository.getSessionHistory(limit: null, before: null)).called(1);
      });

      test('should pass limit parameter to repository', () async {
        // Arrange
        const limit = 10;
        when(() => mockRepository.getSessionHistory(limit: limit, before: null))
            .thenAnswer((_) async => []);

        // Act
        await useCase.getSessionHistory(limit: limit);

        // Assert
        verify(() => mockRepository.getSessionHistory(limit: limit, before: null)).called(1);
      });

      test('should pass before parameter to repository', () async {
        // Arrange
        final before = DateTime(2024, 1, 1);
        when(() => mockRepository.getSessionHistory(limit: null, before: before))
            .thenAnswer((_) async => []);

        // Act
        await useCase.getSessionHistory(before: before);

        // Assert
        verify(() => mockRepository.getSessionHistory(limit: null, before: before)).called(1);
      });

      test('should pass both limit and before parameters', () async {
        // Arrange
        const limit = 5;
        final before = DateTime(2024, 1, 1);
        when(() => mockRepository.getSessionHistory(limit: limit, before: before))
            .thenAnswer((_) async => []);

        // Act
        await useCase.getSessionHistory(limit: limit, before: before);

        // Assert
        verify(() => mockRepository.getSessionHistory(limit: limit, before: before)).called(1);
      });
    });
  });
}
