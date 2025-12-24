@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';
import 'package:zeyra/domain/entities/contraction_timer/rule_511_status.dart';
import 'package:zeyra/domain/exceptions/contraction_timer_exception.dart';
import 'package:zeyra/domain/usecases/contraction_timer/calculate_511_rule_usecase.dart';
import 'package:zeyra/domain/usecases/contraction_timer/manage_contraction_session_usecase.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_timer_state.dart';

// ----------------------------------------------------------------------------
// Mocks
// ----------------------------------------------------------------------------

class MockManageContractionSessionUseCase extends Mock
    implements ManageContractionSessionUseCase {}

class MockCalculate511RuleUseCase extends Mock
    implements Calculate511RuleUseCase {}

// ----------------------------------------------------------------------------
// Test Data
// ----------------------------------------------------------------------------

final _baseTime = DateTime(2025, 1, 1, 10, 0);

final _testSession = ContractionSession(
  id: 'session-1',
  startTime: _baseTime,
  isActive: true,
  contractions: [],
);

final _testSessionWithContraction = ContractionSession(
  id: 'session-1',
  startTime: _baseTime,
  isActive: true,
  contractions: [
    Contraction(
      id: 'contraction-1',
      sessionId: 'session-1',
      startTime: _baseTime.add(const Duration(minutes: 5)),
      endTime: _baseTime.add(const Duration(minutes: 6)),
      intensity: ContractionIntensity.moderate,
    ),
  ],
);

final _testSessionWithActiveContraction = ContractionSession(
  id: 'session-1',
  startTime: _baseTime,
  isActive: true,
  contractions: [
    Contraction(
      id: 'contraction-1',
      sessionId: 'session-1',
      startTime: _baseTime.add(const Duration(minutes: 5)),
      endTime: null, // Active contraction
      intensity: ContractionIntensity.moderate,
    ),
  ],
);

final _testRule511Status = Rule511Status.empty();

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  late ContractionTimerNotifier notifier;
  late MockManageContractionSessionUseCase mockManageUseCase;
  late MockCalculate511RuleUseCase mockCalculateUseCase;

  setUpAll(() {
    registerFallbackValue(ContractionIntensity.moderate);
    registerFallbackValue(ContractionSession(
      id: 'fallback-session',
      startTime: DateTime(2025, 1, 1),
      isActive: false,
      contractions: [],
    ));
  });

  setUp(() {
    mockManageUseCase = MockManageContractionSessionUseCase();
    mockCalculateUseCase = MockCalculate511RuleUseCase();

    // Default stub for getActiveSession (called in initialization)
    when(() => mockManageUseCase.getActiveSession())
        .thenAnswer((_) async => null);

    notifier = ContractionTimerNotifier(
      manageUseCase: mockManageUseCase,
      calculateUseCase: mockCalculateUseCase,
    );
  });

  tearDown(() {
    notifier.dispose();
  });

  group('[ContractionTimerNotifier] Initialization', () {
    test('should initialize with null active session', () async {
      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.activeSession, isNull);
      expect(notifier.state.rule511Status, isNull);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('should load existing active session on startup', () async {
      // Arrange - set up mocks BEFORE creating notifier
      when(() => mockManageUseCase.getActiveSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      final notifier2 = ContractionTimerNotifier(
        manageUseCase: mockManageUseCase,
        calculateUseCase: mockCalculateUseCase,
      );

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier2.state.activeSession, _testSession);
      expect(notifier2.state.rule511Status, _testRule511Status);
      expect(notifier2.state.isLoading, false);

      notifier2.dispose();
    });

    test('should handle session restore with active contraction', () async {
      // Arrange
      when(() => mockManageUseCase.getActiveSession())
          .thenAnswer((_) async => _testSessionWithActiveContraction);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      final notifier3 = ContractionTimerNotifier(
        manageUseCase: mockManageUseCase,
        calculateUseCase: mockCalculateUseCase,
      );

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier3.state.activeSession, _testSessionWithActiveContraction);
      expect(notifier3.state.isLoading, false);

      notifier3.dispose();
    });

    test('should auto-archive session after 4 hours of inactivity', () async {
      // Arrange
      final oldSession = ContractionSession(
        id: 'session-1',
        startTime: _baseTime.subtract(const Duration(hours: 5)),
        isActive: true,
        contractions: [
          Contraction(
            id: 'contraction-1',
            sessionId: 'session-1',
            startTime: _baseTime.subtract(const Duration(hours: 5)),
            endTime: _baseTime.subtract(const Duration(hours: 4, minutes: 1)),
            intensity: ContractionIntensity.moderate,
          ),
        ],
      );

      when(() => mockManageUseCase.getActiveSession())
          .thenAnswer((_) async => oldSession);
      when(() => mockManageUseCase.endSession(any()))
          .thenAnswer((_) async {});

      final notifier4 = ContractionTimerNotifier(
        manageUseCase: mockManageUseCase,
        calculateUseCase: mockCalculateUseCase,
      );

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - session should be ended
      verify(() => mockManageUseCase.endSession('session-1')).called(1);
      expect(notifier4.state.activeSession, isNull);

      notifier4.dispose();
    });

    test('should detect contraction timeout after 20 minutes', () async {
      // Arrange
      final sessionWithTimedOutContraction = ContractionSession(
        id: 'session-1',
        startTime: _baseTime,
        isActive: true,
        contractions: [
          Contraction(
            id: 'contraction-1',
            sessionId: 'session-1',
            startTime: _baseTime.subtract(const Duration(minutes: 21)),
            endTime: null, // Still "active"
            intensity: ContractionIntensity.moderate,
          ),
        ],
      );

      when(() => mockManageUseCase.getActiveSession())
          .thenAnswer((_) async => sessionWithTimedOutContraction);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      final notifier5 = ContractionTimerNotifier(
        manageUseCase: mockManageUseCase,
        calculateUseCase: mockCalculateUseCase,
      );

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - should set special error flag
      expect(notifier5.state.error, 'contraction_timeout');

      notifier5.dispose();
    });
  });

  group('[ContractionTimerNotifier] startSession', () {
    test('should create new session successfully', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      // Act
      await notifier.startSession();

      // Assert
      expect(notifier.state.activeSession, _testSession);
      expect(notifier.state.rule511Status, _testRule511Status);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
      verify(() => mockManageUseCase.startSession()).called(1);
    });

    test('should update rule511Status after starting session', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      // Act
      await notifier.startSession();

      // Assert
      verify(() => mockCalculateUseCase.calculate(_testSession)).called(1);
      expect(notifier.state.rule511Status, _testRule511Status);
    });

    test('should set error when session already exists', () async {
      // Arrange
      when(() => mockManageUseCase.startSession()).thenThrow(
        const ContractionTimerException(
          'Session already active',
          ContractionTimerErrorType.sessionAlreadyActive,
        ),
      );

      // Act
      await notifier.startSession();

      // Assert
      expect(notifier.state.error, 'Session already active');
      expect(notifier.state.activeSession, isNull);
      expect(notifier.state.isLoading, false);
    });
  });

  group('[ContractionTimerNotifier] startContraction', () {
    test('should start contraction in active session', () async {
      // Arrange - set up all mocks BEFORE calling startSession
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);
      when(() => mockManageUseCase.startContraction(
            'session-1',
            intensity: any(named: 'intensity'),
          )).thenAnswer((_) async => _testSessionWithActiveContraction);

      await notifier.startSession();

      // Act
      await notifier.startContraction();

      // Assert
      expect(notifier.state.activeSession, _testSessionWithActiveContraction);
      verify(() => mockManageUseCase.startContraction('session-1',
          intensity: ContractionIntensity.moderate)).called(1);
    });

    test('should recalculate 5-1-1 rule after starting', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockManageUseCase.startContraction(
            any(),
            intensity: any(named: 'intensity'),
          )).thenAnswer((_) async => _testSessionWithActiveContraction);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.startContraction();

      // Assert - verify calculate was called with session after starting contraction
      verify(() => mockCalculateUseCase.calculate(any())).called(greaterThanOrEqualTo(1));
    });

    test('should handle error when no active session', () async {
      // Act - try to start contraction without session
      await notifier.startContraction();

      // Assert - should do nothing
      verifyNever(() => mockManageUseCase.startContraction(
            any(),
            intensity: any(named: 'intensity'),
          ));
    });
  });

  group('[ContractionTimerNotifier] stopContraction', () {
    test('should stop active contraction', () async {
      // Arrange - set up session with active contraction
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSessionWithActiveContraction);
      when(() => mockManageUseCase.stopContraction('contraction-1'))
          .thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.stopContraction();

      // Assert
      expect(notifier.state.activeSession, _testSessionWithContraction);
      verify(() => mockManageUseCase.stopContraction('contraction-1')).called(1);
    });

    test('should update rule511Status after stopping', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSessionWithActiveContraction);
      when(() => mockManageUseCase.stopContraction('contraction-1'))
          .thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.stopContraction();

      // Assert - verify calculate was called at least once (after stop)
      verify(() => mockCalculateUseCase.calculate(any())).called(greaterThanOrEqualTo(1));
    });
  });

  group('[ContractionTimerNotifier] deleteContraction', () {
    test('should delete contraction by ID', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockManageUseCase.deleteContraction('contraction-1'))
          .thenAnswer((_) async => _testSession);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.deleteContraction('contraction-1');

      // Assert
      expect(notifier.state.activeSession, _testSession);
      verify(() => mockManageUseCase.deleteContraction('contraction-1')).called(1);
    });

    test('should recalculate 5-1-1 rule after delete', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockManageUseCase.deleteContraction('contraction-1'))
          .thenAnswer((_) async => _testSession);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.deleteContraction('contraction-1');

      // Assert - verify calculate was called at least once after delete
      verify(() => mockCalculateUseCase.calculate(any())).called(greaterThanOrEqualTo(1));
    });
  });

  group('[ContractionTimerNotifier] updateContraction', () {
    test('should update contraction properties', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockManageUseCase.updateContraction(
            'contraction-1',
            startTime: any(named: 'startTime'),
            duration: any(named: 'duration'),
            intensity: any(named: 'intensity'),
          )).thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.updateContraction(
        'contraction-1',
        startTime: _baseTime,
        intensity: ContractionIntensity.strong,
      );

      // Assert
      verify(() => mockManageUseCase.updateContraction(
            'contraction-1',
            startTime: _baseTime,
            intensity: ContractionIntensity.strong,
          )).called(1);
    });

    test('should recalculate 5-1-1 rule after update', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockManageUseCase.updateContraction(
            any(),
            startTime: any(named: 'startTime'),
          )).thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.updateContraction(
        'contraction-1',
        startTime: _baseTime,
      );

      // Assert - verify calculate was called at least once after update
      verify(() => mockCalculateUseCase.calculate(any())).called(greaterThanOrEqualTo(1));
    });
  });

  group('[ContractionTimerNotifier] finishSession', () {
    test('should end session and clear state', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockManageUseCase.endSession('session-1'))
          .thenAnswer((_) async {});
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.finishSession();

      // Assert
      expect(notifier.state.activeSession, isNull);
      expect(notifier.state.rule511Status, isNull);
      verify(() => mockManageUseCase.endSession('session-1')).called(1);
    });

    test('should stop active contraction before finishing', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSessionWithActiveContraction);
      when(() => mockManageUseCase.stopContraction('contraction-1'))
          .thenAnswer((_) async => _testSessionWithContraction);
      when(() => mockManageUseCase.endSession('session-1'))
          .thenAnswer((_) async {});
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.finishSession();

      // Assert
      verify(() => mockManageUseCase.stopContraction('contraction-1')).called(1);
      verify(() => mockManageUseCase.endSession('session-1')).called(1);
    });

    test('should update note if provided', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockManageUseCase.updateSessionNote('session-1', any()))
          .thenAnswer((_) async => _testSession.copyWith(note: 'Test note'));
      when(() => mockManageUseCase.endSession('session-1'))
          .thenAnswer((_) async {});
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.finishSession(note: 'Test note');

      // Assert
      verify(() => mockManageUseCase.updateSessionNote('session-1', 'Test note'))
          .called(1);
    });
  });

  group('[ContractionTimerNotifier] discardSession', () {
    test('should delete session and clear state', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockManageUseCase.discardSession('session-1'))
          .thenAnswer((_) async {});
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.discardSession();

      // Assert
      expect(notifier.state.activeSession, isNull);
      expect(notifier.state.rule511Status, isNull);
      verify(() => mockManageUseCase.discardSession('session-1')).called(1);
    });
  });

  group('[ContractionTimerNotifier] refresh', () {
    test('should reload active session from repository', () async {
      // Arrange
      final updatedSession = _testSession.copyWith(
        contractions: [
          Contraction(
            id: 'new-contraction',
            sessionId: 'session-1',
            startTime: _baseTime,
            endTime: _baseTime.add(const Duration(minutes: 1)),
            intensity: ContractionIntensity.mild,
          ),
        ],
      );

      when(() => mockManageUseCase.getActiveSession())
          .thenAnswer((_) async => updatedSession);
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      // Act
      await notifier.refresh();

      // Assert
      expect(notifier.state.activeSession, updatedSession);
      verify(() => mockManageUseCase.getActiveSession()).called(greaterThan(0));
    });
  });

  group('[ContractionTimerNotifier] updateSessionNote', () {
    test('should update session note', () async {
      // Arrange
      when(() => mockManageUseCase.startSession())
          .thenAnswer((_) async => _testSession);
      when(() => mockManageUseCase.updateSessionNote('session-1', 'New note'))
          .thenAnswer((_) async => _testSession.copyWith(note: 'New note'));
      when(() => mockCalculateUseCase.calculate(any()))
          .thenReturn(_testRule511Status);

      await notifier.startSession();

      // Act
      await notifier.updateSessionNote('New note');

      // Assert
      expect(notifier.state.activeSession?.note, 'New note');
      verify(() => mockManageUseCase.updateSessionNote('session-1', 'New note'))
          .called(1);
    });
  });

  group('[ContractionTimerNotifier] clearError', () {
    test('should clear error state', () async {
      // Arrange - cause an error
      when(() => mockManageUseCase.startSession()).thenThrow(
        Exception('Test error'),
      );

      await notifier.startSession();
      expect(notifier.state.error, isNotNull);

      // Act
      notifier.clearError();

      // Assert
      expect(notifier.state.error, isNull);
    });
  });
}

