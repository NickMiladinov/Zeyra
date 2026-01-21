/// Onboarding Feature - Unit Tests
///
/// This file runs all unit tests for onboarding (~30 seconds, ~84 tests).
/// Use for comprehensive unit testing.
/// Click the Run button next to main() to run these tests.
///
/// Includes:
/// - Domain entity tests (22 tests)
/// - Data source tests (18 tests)
/// - State tests (12 tests)
/// - Notifier tests (32 tests)
///
/// Excludes:
/// - Service tests (require Supabase which is harder to mock)
@Tags(['onboarding'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../data/local/datasources/onboarding_local_datasource_test.dart'
    as datasource_tests;
import '../../domain/entities/onboarding/onboarding_data_test.dart'
    as entity_tests;
import '../../features/onboarding/logic/onboarding_notifier_test.dart'
    as notifier_tests;
import '../../features/onboarding/logic/onboarding_state_test.dart'
    as state_tests;

void main() {
  group('[Onboarding] Unit Tests (84 tests)', () {
    // -------------------------------------------------------------------------
    // Domain Layer
    // -------------------------------------------------------------------------
    group('Domain Layer', () {
      group('Entities (22 tests)', () {
        entity_tests.main();
      });
    });

    // -------------------------------------------------------------------------
    // Data Layer
    // -------------------------------------------------------------------------
    group('Data Layer', () {
      group('Data Sources (18 tests)', () {
        datasource_tests.main();
      });
    });

    // -------------------------------------------------------------------------
    // Logic Layer
    // -------------------------------------------------------------------------
    group('Logic Layer', () {
      group('State (12 tests)', () {
        state_tests.main();
      });

      group('Notifier (32 tests)', () {
        notifier_tests.main();
      });
    });
  });
}
