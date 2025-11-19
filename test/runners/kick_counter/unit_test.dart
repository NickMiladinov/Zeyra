/// Kick Counter Feature - Unit Tests Only
/// 
/// This file runs all unit tests for kick counter (160 tests).
/// Excludes integration and performance tests for faster execution.
/// Click the ▶️ Run button next to main() to run these tests.
/// 
/// Includes:
/// - Domain entity tests (17 tests)
/// - Domain use case tests (42 tests)
/// - Domain exception tests (19 tests)
/// - Data mapper tests (10 tests)
/// - Data repository tests (44 tests)
/// - Data DAO tests (15 tests)
/// - Error handling tests (24 tests)
/// 
/// Excludes:
/// - Integration tests (13 tests) - use all_tests.dart
/// - Performance tests (13 tests) - use all_tests.dart
@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import only unit test files (no integration/performance)
import '../../data/local/daos/kick_counter_dao_test.dart' as dao_tests;
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

void main() {
  group('[KickCounter] Unit Tests (160 tests)', () {
    // -------------------------------------------------------------------------
    // Domain Layer Unit Tests (78 tests)
    // -------------------------------------------------------------------------

    group('Domain Layer', () {
      group('Entities (17 tests)', () {
        kick_entity_tests.main();
        session_entity_tests.main();
      });

      group('Exceptions (19 tests)', () {
        exception_tests.main();
      });

      group('Use Cases (42 tests)', () {
        usecase_tests.main();
      });
    });

    // -------------------------------------------------------------------------
    // Data Layer Unit Tests (69 tests)
    // -------------------------------------------------------------------------

    group('Data Layer', () {
      group('Mappers (10 tests)', () {
        mapper_tests.main();
      });

      group('Repositories (44 tests)', () {
        repository_tests.main();
        error_handling_tests.main();
      });

      group('DAOs (15 tests)', () {
        dao_tests.main();
      });
    });
  });
}

