@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';

void main() {
  group('[ContractionTimer] Contraction', () {
    final startTime = DateTime(2024, 1, 1, 10, 0);
    final endTime = DateTime(2024, 1, 1, 10, 1);

    test('should create valid contraction with all fields', () {
      // Act
      final contraction = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: endTime,
        intensity: ContractionIntensity.moderate,
      );

      // Assert
      expect(contraction.id, equals('c1'));
      expect(contraction.sessionId, equals('s1'));
      expect(contraction.startTime, equals(startTime));
      expect(contraction.endTime, equals(endTime));
      expect(contraction.intensity, equals(ContractionIntensity.moderate));
    });

    test('should calculate duration correctly from start and end time', () {
      // Arrange
      final contraction = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: startTime.add(const Duration(seconds: 60)),
        intensity: ContractionIntensity.moderate,
      );

      // Act
      final duration = contraction.duration;

      // Assert
      expect(duration, equals(const Duration(seconds: 60)));
    });

    test('should return null duration when endTime is null', () {
      // Arrange
      final contraction = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: null,
        intensity: ContractionIntensity.moderate,
      );

      // Act & Assert
      expect(contraction.duration, isNull);
    });

    test('should identify active contraction when endTime is null', () {
      // Arrange
      final contraction = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: null,
        intensity: ContractionIntensity.moderate,
      );

      // Act & Assert
      expect(contraction.isActive, isTrue);
    });

    test('should identify completed contraction when endTime is set', () {
      // Arrange
      final contraction = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: endTime,
        intensity: ContractionIntensity.moderate,
      );

      // Act & Assert
      expect(contraction.isActive, isFalse);
    });

    test('should support copyWith for all fields', () {
      // Arrange
      final contraction = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: null,
        intensity: ContractionIntensity.mild,
      );

      // Act
      final copied = contraction.copyWith(
        id: 'c2',
        sessionId: 's2',
        startTime: startTime.add(const Duration(minutes: 1)),
        endTime: endTime,
        intensity: ContractionIntensity.strong,
      );

      // Assert
      expect(copied.id, equals('c2'));
      expect(copied.sessionId, equals('s2'));
      expect(copied.startTime, equals(startTime.add(const Duration(minutes: 1))));
      expect(copied.endTime, equals(endTime));
      expect(copied.intensity, equals(ContractionIntensity.strong));
    });

    test('should maintain equality based on all fields', () {
      // Arrange
      final contraction1 = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: endTime,
        intensity: ContractionIntensity.moderate,
      );

      final contraction2 = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: endTime,
        intensity: ContractionIntensity.moderate,
      );

      final contraction3 = Contraction(
        id: 'c2',
        sessionId: 's1',
        startTime: startTime,
        endTime: endTime,
        intensity: ContractionIntensity.moderate,
      );

      // Assert
      expect(contraction1, equals(contraction2));
      expect(contraction1, isNot(equals(contraction3)));
    });

    test('should generate correct hashCode', () {
      // Arrange
      final contraction1 = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: endTime,
        intensity: ContractionIntensity.moderate,
      );

      final contraction2 = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: endTime,
        intensity: ContractionIntensity.moderate,
      );

      // Assert
      expect(contraction1.hashCode, equals(contraction2.hashCode));
    });

    test('should generate toString with relevant information', () {
      // Arrange
      final contraction = Contraction(
        id: 'c1',
        sessionId: 's1',
        startTime: startTime,
        endTime: endTime,
        intensity: ContractionIntensity.moderate,
      );

      // Act
      final stringRep = contraction.toString();

      // Assert
      expect(stringRep, contains('c1'));
      expect(stringRep, contains('s1'));
      expect(stringRep, contains('moderate'));
    });
  });
}

