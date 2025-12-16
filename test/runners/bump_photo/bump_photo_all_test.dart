@Tags(['bump_photo'])
library;

import 'package:flutter_test/flutter_test.dart';

// Domain entity tests
import '../../domain/entities/bump_photo/bump_photo_test.dart' as bump_photo_test;
import '../../domain/entities/bump_photo/bump_photo_constants_test.dart' as constants_test;

// Domain use case tests
import '../../domain/usecases/bump_photo/save_bump_photo_test.dart' as save_test;
import '../../domain/usecases/bump_photo/get_bump_photos_test.dart' as get_test;
import '../../domain/usecases/bump_photo/delete_bump_photo_test.dart' as delete_test;
import '../../domain/usecases/bump_photo/update_bump_photo_note_test.dart' as update_note_test;
import '../../domain/usecases/bump_photo/save_bump_photo_note_test.dart' as save_note_test;

// Domain exception tests
import '../../domain/exceptions/bump_photo_exception_test.dart' as exception_test;

// Data layer tests
import '../../data/mappers/bump_photo_mapper_test.dart' as mapper_test;
import '../../data/local/daos/bump_photo_dao_test.dart' as dao_test;
import '../../data/repositories/bump_photo_repository_impl_test.dart' as repository_test;

// Feature layer tests
import '../../features/bump_photo/logic/bump_photo_notifier_test.dart' as notifier_test;

// Integration tests
import '../../integration/bump_photo/bump_photo_flow_test.dart' as flow_test;

// Core utilities and services tests
import '../../core/utils/image_format_utils_test.dart' as image_format_utils_test;
import '../../core/services/photo_file_service_test.dart' as photo_file_service_test;

/// Comprehensive test runner for bump photo feature.
///
/// Runs all tests for the bump photo feature including:
/// - Domain entities, use cases, and exceptions
/// - Data layer (mappers, DAOs, repositories)
/// - Feature layer (providers/notifiers)
/// - Integration tests (complete user flows)
///
/// Run with:
/// ```bash
/// flutter test test/runners/bump_photo/bump_photo_all_test.dart
/// ```
void main() {
  group('[Full] Bump Photo Feature Tests', () {
    group('Domain Layer', () {
      group('Entities', () {
        bump_photo_test.main();
        constants_test.main();
      });

      group('Use Cases', () {
        save_test.main();
        get_test.main();
        delete_test.main();
        update_note_test.main();
        save_note_test.main();
      });

      group('Exceptions', () {
        exception_test.main();
      });
    });

    group('Data Layer', () {
      group('Mappers', () {
        mapper_test.main();
      });

      group('DAOs', () {
        dao_test.main();
      });

      group('Repositories', () {
        repository_test.main();
      });
    });

    group('Feature Layer', () {
      group('Notifiers', () {
        notifier_test.main();
      });
    });

    group('Core Services', () {
      group('Image Format Utils', () {
        image_format_utils_test.main();
      });

      group('Photo File Service', () {
        photo_file_service_test.main();
      });
    });

    group('Integration', () {
      flow_test.main();
    });
  });
}
