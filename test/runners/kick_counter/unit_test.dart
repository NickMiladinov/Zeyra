/// Kick Counter Feature - Unit Tests Only
/// 
/// This file runs all unit tests for kick counter (228 tests).
/// Excludes integration and performance tests for faster execution.
/// Click the ▶️ Run button next to main() to run these tests.
/// 
/// Includes:
/// - Domain entity tests (22 tests)
/// - Domain use case tests (52 tests)
/// - Domain exception tests (19 tests)
/// - Data mapper tests (10 tests)
/// - Data repository tests (56 tests)
/// - Data DAO tests (24 tests)
/// - Error handling tests (24 tests)
/// - Logic (State) tests (45 tests)
/// 
/// Excludes:
/// - Integration tests (13 tests) - use all_tests.dart
/// - Performance tests (13 tests) - use all_tests.dart
@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import only unit test files (no integration/performance)
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
import '../../features/kick_counter/logic/kick_counter_banner_provider_test.dart'
    as banner_provider_tests;
import '../../features/kick_counter/logic/kick_counter_onboarding_provider_test.dart'
    as onboarding_provider_tests;

void main() {
  group('[KickCounter] Unit Tests (228 tests)', () {
    // -------------------------------------------------------------------------
    // Domain Layer Unit Tests (93 tests)
    // -------------------------------------------------------------------------

    group('Domain Layer', () {
      group('Entities (22 tests)', () {
        kick_entity_tests.main();
        session_entity_tests.main();
      });

      group('Exceptions (19 tests)', () {
        exception_tests.main();
      });

      group('Use Cases (52 tests)', () {
        usecase_tests.main();
      });
    });

    // -------------------------------------------------------------------------
    // Data Layer Unit Tests (90 tests)
    // -------------------------------------------------------------------------

    group('Data Layer', () {
      group('Mappers (10 tests)', () {
        mapper_tests.main();
      });

      group('Repositories (56 tests)', () {
        repository_tests.main();
        error_handling_tests.main();
      });

      group('DAOs (24 tests)', () {
        dao_tests.main();
        dao_extensions_tests.main();
      });
    });

    // -------------------------------------------------------------------------
    // Logic Layer Unit Tests (45 tests)
    // -------------------------------------------------------------------------
    
    group('Logic Layer', () {
      group('Notifiers (45 tests)', () {
        notifier_tests.main();
        history_provider_tests.main();
        banner_provider_tests.main();
        onboarding_provider_tests.main();
      });
    });
  });
}
