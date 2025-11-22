import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/exceptions/kick_counter_exception.dart';
import 'package:zeyra/domain/usecases/kick_counter/manage_session_usecase.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_state.dart';

// ----------------------------------------------------------------------------
// Mocks
// ----------------------------------------------------------------------------

class MockManageSessionUseCase extends Mock implements ManageSessionUseCase {}

// ----------------------------------------------------------------------------
// Test Data
// ----------------------------------------------------------------------------

final tKickSession = KickSession(
  id: 'session-1',
  startTime: DateTime.now(),
  isActive: true,
  kicks: [],
  totalPausedDuration: Duration.zero,
  pauseCount: 0,
);

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  late KickCounterNotifier notifier;
  late MockManageSessionUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(MovementStrength.weak);
  });

  setUp(() {
    mockUseCase = MockManageSessionUseCase();
    notifier = KickCounterNotifier(mockUseCase);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('KickCounterNotifier', () {
    test('initial state is correct', () {
      expect(notifier.state.activeSession, isNull);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.sessionDuration, Duration.zero);
    });

    group('startSession', () {
      test('starts session successfully', () async {
        // Arrange
        when(() => mockUseCase.startSession())
            .thenAnswer((_) async => tKickSession);

        // Act
        await notifier.startSession();

        // Assert
        expect(notifier.state.activeSession, tKickSession);
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
      });

      test('handles sessionAlreadyActive by restoring existing session', () async {
        // Arrange
        when(() => mockUseCase.startSession()).thenThrow(
          const KickCounterException(
            'Active',
            KickCounterErrorType.sessionAlreadyActive,
          ),
        );
        when(() => mockUseCase.getActiveSession())
            .thenAnswer((_) async => tKickSession);

        // Act
        await notifier.startSession();

        // Assert
        verify(() => mockUseCase.getActiveSession()).called(2); // Called on init + on error recovery
        expect(notifier.state.activeSession, tKickSession);
        expect(notifier.state.isLoading, false);
      });

      test('handles generic error', () async {
        // Arrange
        when(() => mockUseCase.startSession()).thenThrow(Exception('Error'));

        // Act
        await notifier.startSession();

        // Assert
        expect(notifier.state.activeSession, isNull);
        expect(notifier.state.isLoading, false);
      });
    });

    group('recordKick', () {
      test('records kick successfully', () async {
        // Arrange - Set active session first
        when(() => mockUseCase.startSession())
            .thenAnswer((_) async => tKickSession);
        await notifier.startSession();

        final tKick = Kick(
          id: 'kick-1',
          sessionId: 'session-1',
          timestamp: DateTime.now(),
          sequenceNumber: 1,
          perceivedStrength: MovementStrength.moderate,
        );
        
        final updatedSession = tKickSession.copyWith(kicks: [tKick]);
        
        when(() => mockUseCase.recordKick(any(), any()))
            .thenAnswer((_) async => (session: updatedSession, shouldPromptEnd: false));

        // Act
        await notifier.recordKick(MovementStrength.moderate);

        // Assert
        expect(notifier.state.activeSession!.kicks.length, 1);
        expect(notifier.state.activeSession!.kicks.first, tKick);
        expect(notifier.state.shouldPromptEnd, false);
      });

      test('sets shouldPromptEnd when prompted', () async {
        // Arrange
        when(() => mockUseCase.startSession())
            .thenAnswer((_) async => tKickSession);
        await notifier.startSession();

        final tKick = Kick(
          id: 'kick-10',
          sessionId: 'session-1',
          timestamp: DateTime.now(),
          sequenceNumber: 10,
          perceivedStrength: MovementStrength.strong,
        );

        final updatedSession = tKickSession.copyWith(kicks: [tKick]);

        when(() => mockUseCase.recordKick(any(), any()))
            .thenAnswer((_) async => (session: updatedSession, shouldPromptEnd: true));

        // Act
        await notifier.recordKick(MovementStrength.strong);

        // Assert
        expect(notifier.state.shouldPromptEnd, true);
      });
    });

    group('pause/resume', () {
      test('pauses session updates state', () async {
        // Arrange
        when(() => mockUseCase.startSession()).thenAnswer((_) async => tKickSession);
        await notifier.startSession();
        
        final pausedSession = tKickSession.copyWith(pausedAt: DateTime.now());
        when(() => mockUseCase.pauseSession(any())).thenAnswer((_) async => pausedSession);

        // Act
        await notifier.pauseSession();

        // Assert
        expect(notifier.state.activeSession!.pausedAt, isNotNull);
      });
      
      test('resumes session clears pausedAt', () async {
        // Arrange
        // Use a paused session where pausedAt is definitely set
        final pausedTime = DateTime.now();
        final pausedSession = tKickSession.copyWith(pausedAt: pausedTime);
        final activeSession = tKickSession.copyWith(pausedAt: null);
        
        // Manually set state to paused using restore
        await notifier.restoreSession(pausedSession); 
        
        when(() => mockUseCase.resumeSession(any())).thenAnswer((_) async => activeSession);

        // Act
        await notifier.resumeSession();

        // Assert
        expect(notifier.state.activeSession!.pausedAt, isNull);
      });
    });
    
    group('endSession', () {
      test('ends session and resets state', () async {
        // Arrange
        when(() => mockUseCase.startSession()).thenAnswer((_) async => tKickSession);
        await notifier.startSession();
        when(() => mockUseCase.endSession(any())).thenAnswer((_) async {});

        // Act
        await notifier.endSession();

        // Assert
        expect(notifier.state.activeSession, isNull);
        expect(notifier.state.sessionDuration, Duration.zero);
      });
    });
  });
}

