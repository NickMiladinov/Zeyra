/// Kick Counter Feature - Quick Tests
/// 
/// This file runs the fastest kick counter tests (~88 tests).
/// Perfect for rapid iteration and TDD. No database, no encryption, no integration.
/// Click the ▶️ Run button next to main() to run these tests.
/// 
/// Includes:
/// - Domain entity tests (17 tests) - Pure Dart, no dependencies
/// - Domain exception tests (19 tests) - Pure Dart
/// - Domain use case tests (42 tests) - Mocked repository
/// - Data mapper tests (10 tests) - Pure mapping logic
/// 
/// Excludes:
/// - Repository tests (need database)
/// - DAO tests (need database)
/// - Error handling tests (need database)
/// - Integration tests (slow)
/// - Performance tests (very slow)
@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import only the fastest unit tests
import '../../data/local/daos/kick_session_with_kicks_test.dart' as dao_extensions_tests;
import '../../data/mappers/kick_session_mapper_test.dart' as mapper_tests;
import '../../domain/entities/kick_counter/kick_session_test.dart'
    as session_entity_tests;
import '../../domain/entities/kick_counter/kick_test.dart'
    as kick_entity_tests;
import '../../domain/exceptions/kick_counter_exception_test.dart'
    as exception_tests;
import '../../domain/usecases/kick_counter/manage_session_usecase_test.dart'
    as usecase_tests;

void main() {
  group('[KickCounter] Quick Tests (~88 tests)', () {
    group('Domain Entities (17 tests)', () {
      kick_entity_tests.main();
      session_entity_tests.main();
    });

    group('Domain Exceptions (19 tests)', () {
      exception_tests.main();
    });

    group('Domain Use Cases (42 tests)', () {
      usecase_tests.main();
    });

    group('Data Mappers & DTOs (15 tests)', () {
      mapper_tests.main();
      dao_extensions_tests.main();
    });
  });
}

