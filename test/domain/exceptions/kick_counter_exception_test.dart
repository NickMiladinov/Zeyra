@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/exceptions/kick_counter_exception.dart';

void main() {
  group('[KickCounter] KickCounterException', () {
    // ------------------------------------------------------------------------
    // Exception Creation Tests
    // ------------------------------------------------------------------------

    group('Exception Creation', () {
      test('should create exception with message and type', () {
        // Arrange & Act
        const exception = KickCounterException(
          'Test message',
          KickCounterErrorType.noKicksRecorded,
        );

        // Assert
        expect(exception.message, equals('Test message'));
        expect(exception.type, equals(KickCounterErrorType.noKicksRecorded));
      });

      test('should implement Exception interface', () {
        // Arrange & Act
        const exception = KickCounterException(
          'Test',
          KickCounterErrorType.noActiveSession,
        );

        // Assert
        expect(exception, isA<Exception>());
      });

      test('should have readable toString output', () {
        // Arrange
        const exception = KickCounterException(
          'Session not found',
          KickCounterErrorType.noActiveSession,
        );

        // Act
        final stringValue = exception.toString();

        // Assert
        expect(stringValue, contains('KickCounterException'));
        expect(stringValue, contains('Session not found'));
        expect(stringValue, contains('noActiveSession'));
      });
    });

    // ------------------------------------------------------------------------
    // Error Type Tests
    // ------------------------------------------------------------------------

    group('Error Types', () {
      test('should have noKicksRecorded type', () {
        // Arrange & Act
        const exception = KickCounterException(
          'No kicks recorded',
          KickCounterErrorType.noKicksRecorded,
        );

        // Assert
        expect(exception.type, equals(KickCounterErrorType.noKicksRecorded));
      });

      test('should have maxKicksReached type', () {
        // Arrange & Act
        const exception = KickCounterException(
          'Max kicks reached',
          KickCounterErrorType.maxKicksReached,
        );

        // Assert
        expect(exception.type, equals(KickCounterErrorType.maxKicksReached));
      });

      test('should have noActiveSession type', () {
        // Arrange & Act
        const exception = KickCounterException(
          'No active session',
          KickCounterErrorType.noActiveSession,
        );

        // Assert
        expect(exception.type, equals(KickCounterErrorType.noActiveSession));
      });

      test('should have sessionAlreadyActive type', () {
        // Arrange & Act
        const exception = KickCounterException(
          'Session already active',
          KickCounterErrorType.sessionAlreadyActive,
        );

        // Assert
        expect(exception.type, equals(KickCounterErrorType.sessionAlreadyActive));
      });

      test('should have sessionAlreadyPaused type', () {
        // Arrange & Act
        const exception = KickCounterException(
          'Session already paused',
          KickCounterErrorType.sessionAlreadyPaused,
        );

        // Assert
        expect(exception.type, equals(KickCounterErrorType.sessionAlreadyPaused));
      });

      test('should have sessionNotPaused type', () {
        // Arrange & Act
        const exception = KickCounterException(
          'Session not paused',
          KickCounterErrorType.sessionNotPaused,
        );

        // Assert
        expect(exception.type, equals(KickCounterErrorType.sessionNotPaused));
      });

      test('should have noKicksToUndo type', () {
        // Arrange & Act
        const exception = KickCounterException(
          'No kicks to undo',
          KickCounterErrorType.noKicksToUndo,
        );

        // Assert
        expect(exception.type, equals(KickCounterErrorType.noKicksToUndo));
      });
    });

    // ------------------------------------------------------------------------
    // Exception Matching Tests
    // ------------------------------------------------------------------------

    group('Exception Matching', () {
      test('should match by type in try-catch', () {
        // Arrange
        void throwException() {
          throw const KickCounterException(
            'Test',
            KickCounterErrorType.maxKicksReached,
          );
        }

        // Act & Assert
        expect(() => throwException(), throwsA(isA<KickCounterException>()));
      });

      test('should allow catching by specific type', () {
        // Arrange
        KickCounterErrorType? caughtType;
        String? caughtMessage;

        void throwException() {
          throw const KickCounterException(
            'Cannot end without kicks',
            KickCounterErrorType.noKicksRecorded,
          );
        }

        // Act
        try {
          throwException();
        } on KickCounterException catch (e) {
          caughtType = e.type;
          caughtMessage = e.message;
        }

        // Assert
        expect(caughtType, equals(KickCounterErrorType.noKicksRecorded));
        expect(caughtMessage, contains('Cannot end without kicks'));
      });

      test('should allow pattern matching on error type', () {
        // Arrange
        const exception1 = KickCounterException(
          'Test1',
          KickCounterErrorType.noKicksRecorded,
        );
        const exception2 = KickCounterException(
          'Test2',
          KickCounterErrorType.maxKicksReached,
        );

        // Act & Assert
        expect(
          exception1.type == KickCounterErrorType.noKicksRecorded,
          isTrue,
        );
        expect(
          exception2.type == KickCounterErrorType.maxKicksReached,
          isTrue,
        );
        expect(exception1.type == exception2.type, isFalse);
      });
    });

    // ------------------------------------------------------------------------
    // Use Case Scenario Tests
    // ------------------------------------------------------------------------

    group('Use Case Scenarios', () {
      test('should differentiate between concurrent session and no session',
          () {
        // Arrange
        const concurrentException = KickCounterException(
          'Active session exists',
          KickCounterErrorType.sessionAlreadyActive,
        );
        const noSessionException = KickCounterException(
          'No active session',
          KickCounterErrorType.noActiveSession,
        );

        // Act & Assert
        expect(
          concurrentException.type,
          isNot(equals(noSessionException.type)),
        );
      });

      test('should differentiate between pause state errors', () {
        // Arrange
        const alreadyPausedException = KickCounterException(
          'Already paused',
          KickCounterErrorType.sessionAlreadyPaused,
        );
        const notPausedException = KickCounterException(
          'Not paused',
          KickCounterErrorType.sessionNotPaused,
        );

        // Act & Assert
        expect(
          alreadyPausedException.type,
          equals(KickCounterErrorType.sessionAlreadyPaused),
        );
        expect(
          notPausedException.type,
          equals(KickCounterErrorType.sessionNotPaused),
        );
        expect(
          alreadyPausedException.type,
          isNot(equals(notPausedException.type)),
        );
      });

      test('should provide context for medical guidance errors', () {
        // Arrange - noKicksRecorded should suggest contacting healthcare
        const exception = KickCounterException(
          'Cannot end session with no kicks recorded. If you feel no movement, '
          'please contact your midwife immediately.',
          KickCounterErrorType.noKicksRecorded,
        );

        // Act & Assert
        expect(exception.message, contains('midwife'));
        expect(exception.message, contains('no movement'));
        expect(exception.type, equals(KickCounterErrorType.noKicksRecorded));
      });

      test('should provide clear validation error messages', () {
        // Arrange
        const maxKicksException = KickCounterException(
          'Maximum 100 kicks per session reached.',
          KickCounterErrorType.maxKicksReached,
        );
        const noUndoException = KickCounterException(
          'No kicks to undo.',
          KickCounterErrorType.noKicksToUndo,
        );

        // Act & Assert
        expect(maxKicksException.message, contains('100'));
        expect(maxKicksException.message, contains('Maximum'));
        expect(noUndoException.message, contains('No kicks'));
        expect(noUndoException.message, contains('undo'));
      });
    });

    // ------------------------------------------------------------------------
    // Enum Tests
    // ------------------------------------------------------------------------

    group('KickCounterErrorType Enum', () {
      test('should have all 7 error types defined', () {
        // Act
        final allTypes = KickCounterErrorType.values;

        // Assert
        expect(allTypes.length, equals(7));
        expect(allTypes, contains(KickCounterErrorType.noKicksRecorded));
        expect(allTypes, contains(KickCounterErrorType.maxKicksReached));
        expect(allTypes, contains(KickCounterErrorType.noActiveSession));
        expect(allTypes, contains(KickCounterErrorType.sessionAlreadyActive));
        expect(allTypes, contains(KickCounterErrorType.sessionAlreadyPaused));
        expect(allTypes, contains(KickCounterErrorType.sessionNotPaused));
        expect(allTypes, contains(KickCounterErrorType.noKicksToUndo));
      });

      test('should have correct enum names', () {
        // Act & Assert
        expect(
          KickCounterErrorType.noKicksRecorded.name,
          equals('noKicksRecorded'),
        );
        expect(
          KickCounterErrorType.maxKicksReached.name,
          equals('maxKicksReached'),
        );
        expect(
          KickCounterErrorType.noActiveSession.name,
          equals('noActiveSession'),
        );
        expect(
          KickCounterErrorType.sessionAlreadyActive.name,
          equals('sessionAlreadyActive'),
        );
        expect(
          KickCounterErrorType.sessionAlreadyPaused.name,
          equals('sessionAlreadyPaused'),
        );
        expect(
          KickCounterErrorType.sessionNotPaused.name,
          equals('sessionNotPaused'),
        );
        expect(
          KickCounterErrorType.noKicksToUndo.name,
          equals('noKicksToUndo'),
        );
      });

      test('should support equality comparison', () {
        // Arrange
        const type1 = KickCounterErrorType.noKicksRecorded;
        const type2 = KickCounterErrorType.noKicksRecorded;
        const type3 = KickCounterErrorType.maxKicksReached;

        // Act & Assert
        expect(type1 == type2, isTrue);
        expect(type1 == type3, isFalse);
      });
    });
  });
}

