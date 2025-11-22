/// Kick Counter Feature - All Tests Runner
/// 
/// This file imports and runs ALL kick counter tests (188 tests total).
/// Click the ▶️ Run button next to main() to run all tests for this feature.
/// 
/// Includes:
/// - Domain entity tests (17 tests)
/// - Domain use case tests (42 tests)
/// - Domain exception tests (19 tests)
/// - Data mapper tests (10 tests)
/// - Data repository tests (44 tests)
/// - Data DAO tests (15 tests)
/// - Integration tests (13 tests)
/// - Performance tests (13 tests)
/// - Logic tests (15 tests)
@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import all kick counter test files
import '../../data/local/daos/kick_counter_dao_test.dart' as dao_tests;
import '../../data/local/daos/kick_session_with_kicks_test.dart' as dao_extensions_tests;
import '../../data/mappers/kick_session_mapper_test.dart' as mapper_tests;
import '../../data/repositories/kick_counter_repository_error_handling_test.dart'
    as error_handling_tests;
import '../../data/repositories/kick_counter_repository_impl_test.dart'
    as repository_tests;
import '../../domain/entities/kick_counter/kick_session_test.dart'
    as session_entity_tests;
import '../../domain/entities/kick_counter/kick_test.dart'
    as kick_entity_tests;
import '../../domain/exceptions/kick_counter_exception_test.dart'
    as exception_tests;
import '../../domain/usecases/kick_counter/manage_session_usecase_test.dart'
    as usecase_tests;
import '../../features/kick_counter/logic/kick_counter_notifier_test.dart'
    as notifier_tests;
import '../../features/kick_counter/logic/kick_history_provider_test.dart'
    as history_provider_tests;
import '../../integration/kick_counter/kick_counter_flow_test.dart'
    as integration_tests;
import '../../performance/kick_counter_performance_test.dart'
    as performance_tests;

void main() {
  group('[KickCounter] All Tests (188 tests)', () {
    // -------------------------------------------------------------------------
    // Domain Layer Tests (78 tests)
    // -------------------------------------------------------------------------

    group('1. Domain Entities (17 tests)', () {
      kick_entity_tests.main();
      session_entity_tests.main();
    });

    group('2. Domain Exceptions (19 tests)', () {
      exception_tests.main();
    });

    group('3. Domain Use Cases (42 tests)', () {
      usecase_tests.main();
    });

    // -------------------------------------------------------------------------
    // Data Layer Tests (69 tests)
    // -------------------------------------------------------------------------

    group('4. Data Mappers (10 tests)', () {
      mapper_tests.main();
    });

    group('5. Data Repositories (44 tests)', () {
      repository_tests.main();
      error_handling_tests.main();
    });

    group('6. Data Access Objects (20 tests)', () {
      dao_tests.main();
      dao_extensions_tests.main();
    });

    // -------------------------------------------------------------------------
    // Integration Tests (13 tests)
    // -------------------------------------------------------------------------

    group('7. Integration Tests (13 tests)', () {
      integration_tests.main();
    });

    // -------------------------------------------------------------------------
    // Logic Layer Tests (15 tests)
    // -------------------------------------------------------------------------
    
    group('8. Logic Tests (15 tests)', () {
      notifier_tests.main();
      history_provider_tests.main();
    });

    // -------------------------------------------------------------------------
    // Performance Tests (13 tests)
    // -------------------------------------------------------------------------

    group('9. Performance Tests (13 tests)', () {
      performance_tests.main();
      // Note: Set skip: true below if you want to skip performance tests
    }, skip: false);
  });
}
