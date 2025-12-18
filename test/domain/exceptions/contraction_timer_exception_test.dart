@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/exceptions/contraction_timer_exception.dart';

void main() {
  group('[ContractionTimer] ContractionTimerException', () {
    test('should create exception with message and type', () {
      // Act
      final exception = ContractionTimerException(
        'Test error',
        ContractionTimerErrorType.noActiveSession,
      );

      // Assert
      expect(exception.message, equals('Test error'));
      expect(exception.type, equals(ContractionTimerErrorType.noActiveSession));
    });

    test('should generate toString with message and type', () {
      // Arrange
      final exception = ContractionTimerException(
        'Test error',
        ContractionTimerErrorType.contractionNotFound,
      );

      // Act
      final stringRep = exception.toString();

      // Assert
      expect(stringRep, contains('Test error'));
      expect(stringRep, contains('contractionNotFound'));
    });

    test('should have all exception types defined', () {
      // Assert
      expect(ContractionTimerErrorType.values.length, greaterThanOrEqualTo(9));
      expect(
        ContractionTimerErrorType.values,
        contains(ContractionTimerErrorType.noActiveSession),
      );
      expect(
        ContractionTimerErrorType.values,
        contains(ContractionTimerErrorType.contractionNotFound),
      );
      expect(
        ContractionTimerErrorType.values,
        contains(ContractionTimerErrorType.contractionAlreadyActive),
      );
      expect(
        ContractionTimerErrorType.values,
        contains(ContractionTimerErrorType.noActiveContraction),
      );
      expect(
        ContractionTimerErrorType.values,
        contains(ContractionTimerErrorType.invalidContractionData),
      );
    });

    test('should create exception for no active session', () {
      // Act
      final exception = ContractionTimerException(
        'No active session',
        ContractionTimerErrorType.noActiveSession,
      );

      // Assert
      expect(exception.type, equals(ContractionTimerErrorType.noActiveSession));
    });

    test('should create exception for session already active', () {
      // Act
      final exception = ContractionTimerException(
        'Session already active',
        ContractionTimerErrorType.sessionAlreadyActive,
      );

      // Assert
      expect(exception.type, equals(ContractionTimerErrorType.sessionAlreadyActive));
    });

    test('should create exception for contraction not found', () {
      // Act
      final exception = ContractionTimerException(
        'Contraction not found',
        ContractionTimerErrorType.contractionNotFound,
      );

      // Assert
      expect(exception.type, equals(ContractionTimerErrorType.contractionNotFound));
    });

    test('should create exception for contraction already active', () {
      // Act
      final exception = ContractionTimerException(
        'Contraction already active',
        ContractionTimerErrorType.contractionAlreadyActive,
      );

      // Assert
      expect(exception.type, equals(ContractionTimerErrorType.contractionAlreadyActive));
    });

    test('should create exception for no active contraction', () {
      // Act
      final exception = ContractionTimerException(
        'No active contraction',
        ContractionTimerErrorType.noActiveContraction,
      );

      // Assert
      expect(exception.type, equals(ContractionTimerErrorType.noActiveContraction));
    });

    test('should create exception for invalid contraction data', () {
      // Act
      final exception = ContractionTimerException(
        'Invalid contraction data',
        ContractionTimerErrorType.invalidContractionData,
      );

      // Assert
      expect(exception.type, equals(ContractionTimerErrorType.invalidContractionData));
    });

    test('should create exception for kick counter active', () {
      // Act
      final exception = ContractionTimerException(
        'Cannot start while kick counter is active',
        ContractionTimerErrorType.kickCounterActive,
      );

      // Assert
      expect(exception.type, equals(ContractionTimerErrorType.kickCounterActive));
    });
  });
}

