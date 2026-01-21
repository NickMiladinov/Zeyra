/// Onboarding Feature - Quick Tests
///
/// This file runs the fastest tests for onboarding (~15 seconds, ~34 tests).
/// Use for quick verification during development.
/// Click the Run button next to main() to run these tests.
///
/// Includes:
/// - Domain entity tests (22 tests)
/// - State tests (12 tests)
///
/// Excludes:
/// - Data source tests (require SharedPreferences setup)
/// - Notifier tests (require mock setup)
/// - Service tests (require mock setup)
@Tags(['onboarding'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../domain/entities/onboarding/onboarding_data_test.dart'
    as entity_tests;
import '../../features/onboarding/logic/onboarding_state_test.dart'
    as state_tests;

void main() {
  group('[Onboarding] Quick Tests (34 tests)', () {
    // -------------------------------------------------------------------------
    // Domain Layer
    // -------------------------------------------------------------------------
    group('Domain Layer', () {
      group('Entities (22 tests)', () {
        entity_tests.main();
      });
    });

    // -------------------------------------------------------------------------
    // Logic Layer
    // -------------------------------------------------------------------------
    group('Logic Layer', () {
      group('State (12 tests)', () {
        state_tests.main();
      });
    });
  });
}
