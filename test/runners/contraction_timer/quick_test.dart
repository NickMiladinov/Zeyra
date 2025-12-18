/// Contraction Timer Feature - Quick Tests Runner
/// 
/// This file runs a quick smoke test suite for contraction timer (21 tests).
/// Perfect for fast feedback during development.
/// 
/// Includes:
/// - Domain entity tests (11 tests - subset)
/// - Domain exception tests (10 tests)
@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import selected test files for quick testing
import '../../domain/entities/contraction_timer/contraction_intensity_test.dart'
    as intensity_tests;
import '../../domain/entities/contraction_timer/contraction_test.dart'
    as contraction_tests;
import '../../domain/exceptions/contraction_timer_exception_test.dart'
    as exception_tests;

void main() {
  group('[ContractionTimer] Quick Tests (21 tests)', () {
    group('1. Domain Entities (11 tests)', () {
      intensity_tests.main();
      contraction_tests.main();
    });

    group('2. Domain Exceptions (10 tests)', () {
      exception_tests.main();
    });
  });
}

