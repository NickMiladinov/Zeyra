@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';

void main() {
  group('[ContractionTimer] ContractionIntensity', () {
    test('should have correct display names for all intensities', () {
      // Assert
      expect(ContractionIntensity.mild.displayName, equals('Mild'));
      expect(ContractionIntensity.moderate.displayName, equals('Moderate'));
      expect(ContractionIntensity.strong.displayName, equals('Strong'));
    });

    test('should have exactly 3 intensity values', () {
      // Assert
      expect(ContractionIntensity.values.length, equals(3));
      expect(ContractionIntensity.values, contains(ContractionIntensity.mild));
      expect(ContractionIntensity.values, contains(ContractionIntensity.moderate));
      expect(ContractionIntensity.values, contains(ContractionIntensity.strong));
    });
  });
}



