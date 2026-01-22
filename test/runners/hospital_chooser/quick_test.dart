/// Hospital Chooser Feature - Quick Tests Runner
///
/// This file runs essential/fast tests for quick iteration during development.
/// Click the ▶️ Run button next to main() to run quick tests for this feature.
///
/// Includes:
/// - Domain entity tests (MaternityUnit, HospitalFilterCriteria)
/// - Domain use case tests (GetNearbyUnits, ManageShortlist)
@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import quick test files
import '../../domain/entities/hospital/maternity_unit_test.dart'
    as maternity_unit_entity_tests;
import '../../domain/entities/hospital/hospital_filter_criteria_test.dart'
    as filter_criteria_entity_tests;
import '../../domain/usecases/hospital/get_nearby_units_usecase_test.dart'
    as get_nearby_units_usecase_tests;
import '../../domain/usecases/hospital/manage_shortlist_usecase_test.dart'
    as manage_shortlist_usecase_tests;

void main() {
  group('[HospitalChooser] Quick Tests', () {
    // -------------------------------------------------------------------------
    // Domain Layer Tests
    // -------------------------------------------------------------------------

    group('1. Domain Entities', () {
      maternity_unit_entity_tests.main();
      filter_criteria_entity_tests.main();
    });

    group('2. Domain Use Cases', () {
      get_nearby_units_usecase_tests.main();
      manage_shortlist_usecase_tests.main();
    });
  });
}
