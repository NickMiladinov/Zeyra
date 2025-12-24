/// Contraction Timer Feature - Unit Tests Runner
/// 
/// This file imports and runs all unit tests for contraction timer (186 tests).
/// Unit tests include domain entities, exceptions, use cases, data mappers, and logic tests.
/// 
/// Includes:
/// - Domain entity tests (39 tests)
/// - Domain exception tests (10 tests)
/// - Domain use case tests (82 tests)
/// - Data mapper tests (10 tests)
/// - Logic/state management tests (45 tests)
@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import all unit test files
import '../../data/mappers/contraction_mapper_test.dart' as contraction_mapper_tests;
import '../../data/mappers/contraction_session_mapper_test.dart' as session_mapper_tests;
import '../../domain/entities/contraction_timer/contraction_intensity_test.dart'
    as intensity_entity_tests;
import '../../domain/entities/contraction_timer/contraction_session_test.dart'
    as session_entity_tests;
import '../../domain/entities/contraction_timer/contraction_test.dart'
    as contraction_entity_tests;
import '../../domain/entities/contraction_timer/rule_511_status_test.dart'
    as rule_entity_tests;
import '../../domain/exceptions/contraction_timer_exception_test.dart'
    as exception_tests;
import '../../domain/usecases/contraction_timer/calculate_511_rule_usecase_test.dart'
    as calculate_usecase_tests;
import '../../domain/usecases/contraction_timer/manage_contraction_session_usecase_test.dart'
    as manage_usecase_tests;
import '../../features/contraction_timer/logic/contraction_history_provider_test.dart'
    as history_provider_tests;
import '../../features/contraction_timer/logic/contraction_timer_banner_provider_test.dart'
    as banner_provider_tests;
import '../../features/contraction_timer/logic/contraction_timer_notifier_test.dart'
    as timer_notifier_tests;
import '../../features/contraction_timer/logic/contraction_timer_onboarding_provider_test.dart'
    as onboarding_provider_tests;

void main() {
  group('[ContractionTimer] Unit Tests (186 tests)', () {
    // -------------------------------------------------------------------------
    // Domain Layer Tests (131 tests)
    // -------------------------------------------------------------------------

    group('1. Domain Entities (39 tests)', () {
      intensity_entity_tests.main();
      contraction_entity_tests.main();
      session_entity_tests.main();
      rule_entity_tests.main();
    });

    group('2. Domain Exceptions (10 tests)', () {
      exception_tests.main();
    });

    group('3. Domain Use Cases (82 tests)', () {
      calculate_usecase_tests.main();
      manage_usecase_tests.main();
    });

    // -------------------------------------------------------------------------
    // Data Layer Tests (10 tests)
    // -------------------------------------------------------------------------

    group('4. Data Mappers (10 tests)', () {
      contraction_mapper_tests.main();
      session_mapper_tests.main();
    });

    // -------------------------------------------------------------------------
    // Logic/State Management Tests (45 tests)
    // -------------------------------------------------------------------------

    group('5. Logic Tests (45 tests)', () {
      timer_notifier_tests.main();
      history_provider_tests.main();
      banner_provider_tests.main();
      onboarding_provider_tests.main();
    });
  });
}

