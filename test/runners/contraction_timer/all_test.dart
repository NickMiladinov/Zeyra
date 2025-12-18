/// Contraction Timer Feature - All Tests Runner
/// 
/// This file imports and runs ALL contraction timer tests (195 tests total).
/// Click the ▶️ Run button next to main() to run all tests for this feature.
/// 
/// Includes:
/// - Domain entity tests (39 tests)
/// - Domain exception tests (10 tests)
/// - Domain use case tests (82 tests)
/// - Data mapper tests (10 tests)
/// - Data DAO tests (18 tests)
/// - Data repository tests (36 tests)
@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import all contraction timer test files
import '../../data/local/daos/contraction_timer_dao_test.dart' as dao_tests;
import '../../data/mappers/contraction_mapper_test.dart' as contraction_mapper_tests;
import '../../data/mappers/contraction_session_mapper_test.dart' as session_mapper_tests;
import '../../data/repositories/contraction_timer_repository_impl_test.dart' as repository_tests;
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
  group('[ContractionTimer] All Tests (195 tests)', () {
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
    // Data Layer Tests (64 tests)
    // -------------------------------------------------------------------------

    group('4. Data Mappers (10 tests)', () {
      contraction_mapper_tests.main();
      session_mapper_tests.main();
    });

    group('5. Data DAOs (18 tests)', () {
      dao_tests.main();
    });

    group('6. Data Repositories (36 tests)', () {
      repository_tests.main();
    });
  });
}

