/// Contraction Timer Feature - Unit Tests Runner
/// 
/// This file imports and runs all unit tests for contraction timer (141 tests).
/// Unit tests include domain entities, exceptions, use cases, and data mappers.
/// 
/// Includes:
/// - Domain entity tests (39 tests)
/// - Domain exception tests (10 tests)
/// - Domain use case tests (82 tests)
/// - Data mapper tests (10 tests)
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

void main() {
  group('[ContractionTimer] Unit Tests (141 tests)', () {
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
  });
}

