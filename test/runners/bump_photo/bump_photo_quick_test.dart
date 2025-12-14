@Tags(['bump_photo'])
library;

import 'package:flutter_test/flutter_test.dart';

// Domain entity tests
import '../../domain/entities/bump_photo/bump_photo_test.dart' as bump_photo_test;
import '../../domain/entities/bump_photo/bump_photo_constants_test.dart' as constants_test;

// Use case tests
import '../../domain/usecases/bump_photo/save_bump_photo_test.dart' as save_test;
import '../../domain/usecases/bump_photo/get_bump_photos_test.dart' as get_test;
import '../../domain/usecases/bump_photo/delete_bump_photo_test.dart' as delete_test;
import '../../domain/usecases/bump_photo/update_bump_photo_note_test.dart' as update_note_test;
import '../../domain/usecases/bump_photo/save_bump_photo_note_test.dart' as save_note_test;

// Exception tests
import '../../domain/exceptions/bump_photo_exception_test.dart' as exception_test;

// Mapper tests
import '../../data/mappers/bump_photo_mapper_test.dart' as mapper_test;

/// Quick test runner for bump photo feature.
///
/// Runs core domain and use case tests for rapid feedback during development.
/// Use this for TDD and quick validation of business logic changes.
///
/// Run with:
/// ```bash
/// flutter test test/runners/bump_photo/bump_photo_quick_test.dart
/// ```
void main() {
  group('[Quick] Bump Photo Feature Tests', () {
    group('Domain Entities', () {
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

    group('Mappers', () {
      mapper_test.main();
    });
  });
}
