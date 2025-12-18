@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/domain/exceptions/contraction_timer_exception.dart';
import 'package:zeyra/domain/usecases/contraction_timer/manage_contraction_session_usecase.dart';

import '../../../mocks/fake_data/contraction_timer_fakes.dart';

void main() {
  group('[ContractionTimer] ManageContractionSessionUseCase', () {
    late ManageContractionSessionUseCase useCase;
    late MockContractionTimerRepository mockRepository;

    setUp(() {
      mockRepository = MockContractionTimerRepository();
      useCase = ManageContractionSessionUseCase(repository: mockRepository);

      // Register fallback values for mocktail
      registerFallbackValue(ContractionIntensity.moderate);
      registerFallbackValue(DateTime(2024, 1, 1));
      registerFallbackValue(const Duration(seconds: 60));
    });

    // ========================================================================
    // Session Lifecycle Tests
    // ========================================================================

    group('Session Lifecycle', () {
      test('startSession should create new session when none active', () async {
        // Arrange
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);
        
        final newSession = FakeContractionSession.active();
        when(() => mockRepository.createSession())
            .thenAnswer((_) async => newSession);

        // Act
        final result = await useCase.startSession();

        // Assert
        expect(result, equals(newSession));
        verify(() => mockRepository.getActiveSession()).called(1);
        verify(() => mockRepository.createSession()).called(1);
      });

      test('startSession should throw sessionAlreadyActive when session exists', () async {
        // Arrange
        final existingSession = FakeContractionSession.active();
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => existingSession);

        // Act & Assert
        expect(
          () => useCase.startSession(),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.sessionAlreadyActive,
            ),
          ),
        );
        
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.createSession());
      });

      test('endSession should mark session inactive', () async {
        // Arrange
        const sessionId = 'session-1';
        final activeSession = FakeContractionSession.active(
          id: sessionId,
          contractions: FakeContraction.batch(3),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => activeSession);
        when(() => mockRepository.endSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.endSession(sessionId);

        // Assert
        verify(() => mockRepository.getActiveSession()).called(1);
        verify(() => mockRepository.endSession(sessionId)).called(1);
      });

      test('endSession should throw noActiveSession when session not found', () async {
        // Arrange
        const sessionId = 'nonexistent';
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => useCase.endSession(sessionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.noActiveSession,
            ),
          ),
        );
        
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.endSession(any()));
      });

      test('endSession should throw noContractionsRecorded when empty', () async {
        // Arrange
        const sessionId = 'session-1';
        final emptySession = FakeContractionSession.simple(
          id: sessionId,
          contractions: const [],
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => emptySession);

        // Act & Assert
        expect(
          () => useCase.endSession(sessionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.noContractionsRecorded,
            ),
          ),
        );
        
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.endSession(any()));
      });

      test('endSession should stop active contraction automatically', () async {
        // Arrange
        const sessionId = 'session-1';
        final sessionWithActiveContraction = FakeContractionSession.withActiveContraction(
          id: sessionId,
          completedContractions: FakeContraction.batch(2),
        );

        // After stopping contraction
        final stoppedContraction = sessionWithActiveContraction.activeContraction!.copyWith(
          endTime: DateTime.now(),
        );
        final sessionAfterStop = sessionWithActiveContraction.copyWith(
          contractions: [
            ...sessionWithActiveContraction.contractions
                .where((c) => c.endTime != null),
            stoppedContraction,
          ],
        );

        // First call returns session with active contraction, second call returns session after stop
        var callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? sessionWithActiveContraction : sessionAfterStop;
        });

        when(() => mockRepository.stopContraction(
          sessionWithActiveContraction.activeContraction!.id,
        )).thenAnswer((_) async => stoppedContraction);

        when(() => mockRepository.endSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.endSession(sessionId);

        // Assert
        verify(() => mockRepository.stopContraction(
          sessionWithActiveContraction.activeContraction!.id,
        )).called(1);
        verify(() => mockRepository.endSession(sessionId)).called(1);
      });

      test('discardSession should delete session completely', () async {
        // Arrange
        const sessionId = 'session-1';
        final activeSession = FakeContractionSession.active(
          contractions: FakeContraction.batch(2),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => activeSession);
        when(() => mockRepository.deleteSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.discardSession(sessionId);

        // Assert
        verify(() => mockRepository.deleteSession(sessionId)).called(1);
      });

      test('deleteHistoricalSession should remove completed session', () async {
        // Arrange
        const sessionId = 'session-ended';
        final endedSession = FakeContractionSession.ended();
        when(() => mockRepository.getSession(sessionId))
            .thenAnswer((_) async => endedSession);
        when(() => mockRepository.deleteSession(sessionId))
            .thenAnswer((_) async {});

        // Act
        await useCase.deleteHistoricalSession(sessionId);

        // Assert
        verify(() => mockRepository.deleteSession(sessionId)).called(1);
      });

      test('getActiveSession should return active session', () async {
        // Arrange
        final activeSession = FakeContractionSession.active();
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => activeSession);

        // Act
        final result = await useCase.getActiveSession();

        // Assert
        expect(result, equals(activeSession));
        expect(result?.isActive, isTrue);
        verify(() => mockRepository.getActiveSession()).called(1);
      });

      test('getActiveSession should return null when no active session', () async {
        // Arrange
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.getActiveSession();

        // Assert
        expect(result, isNull);
        verify(() => mockRepository.getActiveSession()).called(1);
      });
    });

    // ========================================================================
    // Contraction Lifecycle Tests
    // ========================================================================

    group('Contraction Lifecycle', () {
      test('startContraction should add contraction to session', () async {
        // Arrange
        const sessionId = 'session-1';
        final session = FakeContractionSession.active(
          id: sessionId,
          contractions: FakeContraction.batch(2),
        );

        final newContraction = FakeContraction.active(sessionId: sessionId);
        final updatedSession = session.copyWith(
          contractions: [
            ...session.contractions,
            newContraction,
          ],
        );

        // First call returns session, second call returns updated session
        var callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? session : updatedSession;
        });

        when(() => mockRepository.startContraction(
          sessionId,
          intensity: ContractionIntensity.moderate,
        )).thenAnswer((_) async => newContraction);

        // Act
        final result = await useCase.startContraction(sessionId);

        // Assert
        expect(result.contractionCount, equals(session.contractionCount + 1));
        verify(() => mockRepository.startContraction(
          sessionId,
          intensity: ContractionIntensity.moderate,
        )).called(1);
      });

      test('startContraction should default to moderate intensity', () async {
        // Arrange
        const sessionId = 'session-1';
        final session = FakeContractionSession.active(id: sessionId);

        final newContraction = FakeContraction.active(
          sessionId: sessionId,
          intensity: ContractionIntensity.moderate,
        );
        final updatedSession = session.copyWith(
          contractions: [
            ...session.contractions,
            newContraction,
          ],
        );

        // First call returns session, second call returns updated session
        var callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? session : updatedSession;
        });

        when(() => mockRepository.startContraction(
          sessionId,
          intensity: ContractionIntensity.moderate,
        )).thenAnswer((_) async => newContraction);

        // Act
        await useCase.startContraction(sessionId);

        // Assert
        verify(() => mockRepository.startContraction(
          sessionId,
          intensity: ContractionIntensity.moderate,
        )).called(1);
      });

      test('startContraction should accept custom intensity', () async {
        // Arrange
        const sessionId = 'session-1';
        final session = FakeContractionSession.active(id: sessionId);

        final newContraction = FakeContraction.active(
          sessionId: sessionId,
          intensity: ContractionIntensity.strong,
        );
        final updatedSession = session.copyWith(
          contractions: [
            ...session.contractions,
            newContraction,
          ],
        );

        // First call returns session, second call returns updated session
        var callCount = 0;
        when(() => mockRepository.getActiveSession()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? session : updatedSession;
        });

        when(() => mockRepository.startContraction(
          sessionId,
          intensity: ContractionIntensity.strong,
        )).thenAnswer((_) async => newContraction);

        // Act
        await useCase.startContraction(
          sessionId,
          intensity: ContractionIntensity.strong,
        );

        // Assert
        verify(() => mockRepository.startContraction(
          sessionId,
          intensity: ContractionIntensity.strong,
        )).called(1);
      });

      test('startContraction should throw noActiveSession when session not found', () async {
        // Arrange
        const sessionId = 'nonexistent';
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => useCase.startContraction(sessionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.noActiveSession,
            ),
          ),
        );
        
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.startContraction(any(), intensity: any(named: 'intensity')));
      });

      test('startContraction should throw contractionAlreadyActive', () async {
        // Arrange
        const sessionId = 'session-1';
        final session = FakeContractionSession.withActiveContraction(id: sessionId);
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.startContraction(sessionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.contractionAlreadyActive,
            ),
          ),
        );
        
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.startContraction(any(), intensity: any(named: 'intensity')));
      });

      test('startContraction should throw maxContractionsReached at 200', () async {
        // Arrange
        const sessionId = 'session-max';
        final session = FakeContractionSession.atMaxContractions(id: sessionId);
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.startContraction(sessionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.maxContractionsReached,
            ),
          ),
        );
        
        verify(() => mockRepository.getActiveSession()).called(1);
        verifyNever(() => mockRepository.startContraction(any(), intensity: any(named: 'intensity')));
      });

      test('stopContraction should set endTime', () async {
        // Arrange
        const sessionId = 'session-1';
        const contractionId = 'contraction-active';
        final session = FakeContractionSession.withActiveContraction(id: sessionId);
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        
        final stoppedContraction = session.activeContraction!.copyWith(
          endTime: DateTime.now(),
        );
        when(() => mockRepository.stopContraction(contractionId))
            .thenAnswer((_) async => stoppedContraction);
        
        final updatedSession = session.copyWith(
          contractions: session.contractions.map((c) {
            if (c.id == contractionId) {
              return c.copyWith(endTime: DateTime.now());
            }
            return c;
          }).toList(),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.stopContraction(contractionId);

        // Assert
        expect(result.activeContraction, isNull);
        verify(() => mockRepository.stopContraction(contractionId)).called(1);
      });

      test('stopContraction should return updated session', () async {
        // Arrange
        const contractionId = 'contraction-active';
        final session = FakeContractionSession.withActiveContraction();
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        
        final stoppedContraction = session.activeContraction!.copyWith(
          endTime: DateTime.now(),
        );
        when(() => mockRepository.stopContraction(contractionId))
            .thenAnswer((_) async => stoppedContraction);
        
        final updatedSession = session.copyWith(
          contractions: session.contractions.map((c) {
            if (c.id == contractionId) {
              return c.copyWith(endTime: DateTime.now());
            }
            return c;
          }).toList(),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.stopContraction(contractionId);

        // Assert
        expect(result, equals(updatedSession));
        expect(result.activeContraction, isNull);
      });

      test('updateContraction should modify startTime', () async {
        // Arrange
        const contractionId = 'contraction-1';
        final newStartTime = DateTime(2024, 1, 1, 11, 0);
        final session = FakeContractionSession.active();
        final originalContraction = session.contractions.first;
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        
        final updatedContraction = originalContraction.copyWith(startTime: newStartTime);
        when(() => mockRepository.updateContraction(
          contractionId,
          startTime: newStartTime,
        )).thenAnswer((_) async => updatedContraction);
        
        final updatedSession = session.copyWith(
          contractions: session.contractions.map((c) {
            if (c.id == contractionId) {
              return updatedContraction;
            }
            return c;
          }).toList(),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.updateContraction(
          contractionId,
          startTime: newStartTime,
        );

        // Assert
        expect(result, equals(updatedSession));
        verify(() => mockRepository.updateContraction(
          contractionId,
          startTime: newStartTime,
        )).called(1);
      });

      test('updateContraction should modify duration', () async {
        // Arrange
        const contractionId = 'contraction-1';
        const newDuration = Duration(seconds: 75);
        final session = FakeContractionSession.active();
        final originalContraction = session.contractions.first;
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        
        final updatedContraction = originalContraction.copyWith(
          endTime: originalContraction.startTime.add(newDuration),
        );
        when(() => mockRepository.updateContraction(
          contractionId,
          duration: newDuration,
        )).thenAnswer((_) async => updatedContraction);
        
        final updatedSession = session.copyWith(
          contractions: session.contractions.map((c) {
            if (c.id == contractionId) {
              return updatedContraction;
            }
            return c;
          }).toList(),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.updateContraction(
          contractionId,
          duration: newDuration,
        );

        // Assert
        expect(result, equals(updatedSession));
        verify(() => mockRepository.updateContraction(
          contractionId,
          duration: newDuration,
        )).called(1);
      });

      test('updateContraction should modify intensity', () async {
        // Arrange
        const contractionId = 'contraction-1';
        const newIntensity = ContractionIntensity.strong;
        final session = FakeContractionSession.active();
        final originalContraction = session.contractions.first;
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        
        final updatedContraction = originalContraction.copyWith(intensity: newIntensity);
        when(() => mockRepository.updateContraction(
          contractionId,
          intensity: newIntensity,
        )).thenAnswer((_) async => updatedContraction);
        
        final updatedSession = session.copyWith(
          contractions: session.contractions.map((c) {
            if (c.id == contractionId) {
              return updatedContraction;
            }
            return c;
          }).toList(),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.updateContraction(
          contractionId,
          intensity: newIntensity,
        );

        // Assert
        expect(result, equals(updatedSession));
        verify(() => mockRepository.updateContraction(
          contractionId,
          intensity: newIntensity,
        )).called(1);
      });

      test('deleteContraction should remove contraction from session', () async {
        // Arrange
        const contractionId = 'contraction-2';
        final session = FakeContractionSession.active(
          contractions: FakeContraction.batch(3),
        );
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.deleteContraction(contractionId))
            .thenAnswer((_) async {});
        
        final updatedSession = session.copyWith(
          contractions: session.contractions
              .where((c) => c.id != contractionId)
              .toList(),
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.deleteContraction(contractionId);

        // Assert
        expect(result.contractionCount, equals(session.contractionCount - 1));
        verify(() => mockRepository.deleteContraction(contractionId)).called(1);
      });
    });

    // ========================================================================
    // Validation Rules Tests
    // ========================================================================

    group('Validation Rules', () {
      test('should validate session ownership for startContraction', () async {
        // Arrange
        const wrongSessionId = 'wrong-session';
        final session = FakeContractionSession.active(); // Different ID
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.startContraction(wrongSessionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.noActiveSession,
            ),
          ),
        );
      });

      test('should handle session lost after update', () async {
        // Arrange
        const contractionId = 'contraction-1';
        final session = FakeContractionSession.active();
        final stoppedContraction = session.contractions.first.copyWith(
          endTime: DateTime.now(),
        );
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.stopContraction(contractionId))
            .thenAnswer((_) async => stoppedContraction);
        
        // Session disappears after update
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => useCase.stopContraction(contractionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.noActiveSession,
            ),
          ),
        );
      });

      test('should enforce minimum contractions to end', () async {
        // Arrange - This is already tested in endSession tests
        // The minimum is implicitly enforced by checking contractionCount > 0
        const sessionId = 'session-1';
        final emptySession = FakeContractionSession.simple(
          id: sessionId,
          contractions: const [],
        );
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => emptySession);

        // Act & Assert
        expect(
          () => useCase.endSession(sessionId),
          throwsA(isA<ContractionTimerException>()),
        );
      });

      test('should enforce maximum contractions per session', () async {
        // Arrange
        const sessionId = 'session-max';
        final maxSession = FakeContractionSession.atMaxContractions(id: sessionId);
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => maxSession);

        // Act & Assert
        expect(
          () => useCase.startContraction(sessionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.maxContractionsReached,
            ),
          ),
        );
      });

      test('should handle concurrent contraction start attempts', () async {
        // Arrange - Already active contraction
        const sessionId = 'session-1';
        final session = FakeContractionSession.withActiveContraction(id: sessionId);
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);

        // Act & Assert
        expect(
          () => useCase.startContraction(sessionId),
          throwsA(
            isA<ContractionTimerException>().having(
              (e) => e.type,
              'type',
              ContractionTimerErrorType.contractionAlreadyActive,
            ),
          ),
        );
      });

      test('should validate contraction exists before update', () async {
        // Arrange
        const contractionId = 'nonexistent';
        final session = FakeContractionSession.active();
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.updateContraction(
          contractionId,
          intensity: any(named: 'intensity'),
        )).thenThrow(
          const ContractionTimerException(
            'Contraction not found',
            ContractionTimerErrorType.contractionNotFound,
          ),
        );

        // Act & Assert
        expect(
          () => useCase.updateContraction(
            contractionId,
            intensity: ContractionIntensity.strong,
          ),
          throwsA(isA<ContractionTimerException>()),
        );
      });

      test('should validate contraction exists before delete', () async {
        // Arrange
        const contractionId = 'nonexistent';
        final session = FakeContractionSession.active();
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.deleteContraction(contractionId))
            .thenThrow(
          const ContractionTimerException(
            'Contraction not found',
            ContractionTimerErrorType.contractionNotFound,
          ),
        );

        // Act & Assert
        expect(
          () => useCase.deleteContraction(contractionId),
          throwsA(isA<ContractionTimerException>()),
        );
      });
    });

    // ========================================================================
    // Updates and Notes Tests
    // ========================================================================

    group('Updates and Notes', () {
      test('updateSessionNote should set note', () async {
        // Arrange
        const sessionId = 'session-1';
        const note = 'Contractions getting stronger';
        final session = FakeContractionSession.active();
        final updatedSession = session.copyWith(note: note);
        
        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.updateSessionNote(sessionId, note))
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.updateSessionNote(sessionId, note);

        // Assert
        expect(result.note, equals(note));
        verify(() => mockRepository.updateSessionNote(sessionId, note)).called(1);
      });

      test('updateSessionNote should clear note with null', () async {
        // Arrange
        const sessionId = 'session-1';
        final session = FakeContractionSession.withNote(
          id: sessionId,
          note: 'Old note',
          isActive: true,
        );
        // Create updated session with note explicitly set to null
        final updatedSession = FakeContractionSession.simple(
          id: sessionId,
          isActive: true,
          note: null,
        );

        when(() => mockRepository.getActiveSession())
            .thenAnswer((_) async => session);
        when(() => mockRepository.updateSessionNote(sessionId, null))
            .thenAnswer((_) async => updatedSession);

        // Act
        final result = await useCase.updateSessionNote(sessionId, null);

        // Assert
        expect(result.note, isNull);
        verify(() => mockRepository.updateSessionNote(sessionId, null)).called(1);
      });

      test('updateSessionCriteria should set achievedDuration', () async {
        // Arrange
        const sessionId = 'session-1';
        final now = DateTime.now();
        final session = FakeContractionSession.active();
        final updatedSession = session.copyWith(
          achievedDuration: true,
          durationAchievedAt: now,
        );
        
        when(() => mockRepository.updateSessionCriteria(
          sessionId,
          achievedDuration: true,
          durationAchievedAt: now,
        )).thenAnswer((_) async => updatedSession);

        // Act
        await useCase.updateSessionCriteria(
          sessionId,
          achievedDuration: true,
          durationAchievedAt: now,
        );

        // Assert
        verify(() => mockRepository.updateSessionCriteria(
          sessionId,
          achievedDuration: true,
          durationAchievedAt: now,
        )).called(1);
      });

      test('updateSessionCriteria should set achievedFrequency', () async {
        // Arrange
        const sessionId = 'session-1';
        final now = DateTime.now();
        final session = FakeContractionSession.active();
        final updatedSession = session.copyWith(
          achievedFrequency: true,
          frequencyAchievedAt: now,
        );
        
        when(() => mockRepository.updateSessionCriteria(
          sessionId,
          achievedFrequency: true,
          frequencyAchievedAt: now,
        )).thenAnswer((_) async => updatedSession);

        // Act
        await useCase.updateSessionCriteria(
          sessionId,
          achievedFrequency: true,
          frequencyAchievedAt: now,
        );

        // Assert
        verify(() => mockRepository.updateSessionCriteria(
          sessionId,
          achievedFrequency: true,
          frequencyAchievedAt: now,
        )).called(1);
      });

      test('updateSessionCriteria should set achievedConsistency', () async {
        // Arrange
        const sessionId = 'session-1';
        final now = DateTime.now();
        final session = FakeContractionSession.active();
        final updatedSession = session.copyWith(
          achievedConsistency: true,
          consistencyAchievedAt: now,
        );
        
        when(() => mockRepository.updateSessionCriteria(
          sessionId,
          achievedConsistency: true,
          consistencyAchievedAt: now,
        )).thenAnswer((_) async => updatedSession);

        // Act
        await useCase.updateSessionCriteria(
          sessionId,
          achievedConsistency: true,
          consistencyAchievedAt: now,
        );

        // Assert
        verify(() => mockRepository.updateSessionCriteria(
          sessionId,
          achievedConsistency: true,
          consistencyAchievedAt: now,
        )).called(1);
      });
    });

    // ========================================================================
    // History Operations Tests
    // ========================================================================

    group('History Operations', () {
      test('getSessionHistory should return completed sessions', () async {
        // Arrange
        final sessions = [
          FakeContractionSession.ended(),
          FakeContractionSession.ended(),
          FakeContractionSession.ended(),
        ];
        when(() => mockRepository.getSessionHistory(limit: 20))
            .thenAnswer((_) async => sessions);

        // Act
        final result = await useCase.getSessionHistory();

        // Assert
        expect(result, equals(sessions));
        expect(result.length, equals(3));
        verify(() => mockRepository.getSessionHistory(limit: 20)).called(1);
      });

      test('getSessionHistory should respect limit parameter', () async {
        // Arrange
        final sessions = [
          FakeContractionSession.ended(),
          FakeContractionSession.ended(),
        ];
        when(() => mockRepository.getSessionHistory(limit: 2))
            .thenAnswer((_) async => sessions);

        // Act
        final result = await useCase.getSessionHistory(limit: 2);

        // Assert
        expect(result.length, equals(2));
        verify(() => mockRepository.getSessionHistory(limit: 2)).called(1);
      });

      test('getSessionHistory should respect before parameter', () async {
        // Arrange
        final beforeDate = DateTime(2024, 1, 15);
        final sessions = [
          FakeContractionSession.ended(),
        ];
        when(() => mockRepository.getSessionHistory(
          limit: 20,
          before: beforeDate,
        )).thenAnswer((_) async => sessions);

        // Act
        final result = await useCase.getSessionHistory(before: beforeDate);

        // Assert
        expect(result, equals(sessions));
        verify(() => mockRepository.getSessionHistory(
          limit: 20,
          before: beforeDate,
        )).called(1);
      });

      test('deleteOldSessions should remove sessions older than cutoff', () async {
        // Arrange
        const maxDays = 180; // 6 months
        when(() => mockRepository.deleteSessionsOlderThan(any()))
            .thenAnswer((_) async => 5);

        // Act
        final result = await useCase.deleteOldSessions(maxDays);

        // Assert
        expect(result, equals(5));
        verify(() => mockRepository.deleteSessionsOlderThan(any())).called(1);
      });

      test('deleteOldSessions should use default 365 days', () async {
        // Arrange
        when(() => mockRepository.deleteSessionsOlderThan(any()))
            .thenAnswer((_) async => 3);

        // Act
        final result = await useCase.deleteOldSessions();

        // Assert
        expect(result, equals(3));
        verify(() => mockRepository.deleteSessionsOlderThan(any())).called(1);
      });
    });
  });
}

