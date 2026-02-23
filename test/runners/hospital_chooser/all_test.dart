/// Hospital Chooser Feature - All Tests Runner
///
/// This file imports and runs ALL hospital chooser tests.
/// Click the ▶️ Run button next to main() to run all tests for this feature.
///
/// Includes:
/// - Domain entity tests (MaternityUnit, HospitalFilterCriteria, HospitalShortlist, SyncMetadata)
/// - Domain use case tests (GetNearbyUnits, ManageShortlist, SelectFinalHospital)
/// - Data mapper tests (MaternityUnitMapper, HospitalShortlistMapper, SyncMetadataMapper)
/// - Logic/state management tests (HospitalShortlistState, HospitalLocationState, HospitalMapState)
@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';

// Import all hospital chooser test files
import '../../data/mappers/maternity_unit_mapper_test.dart'
    as maternity_unit_mapper_tests;
import '../../data/mappers/hospital_shortlist_mapper_test.dart'
    as hospital_shortlist_mapper_tests;
import '../../data/mappers/sync_metadata_mapper_test.dart'
    as sync_metadata_mapper_tests;
import '../../domain/entities/hospital/maternity_unit_test.dart'
    as maternity_unit_entity_tests;
import '../../domain/entities/hospital/hospital_filter_criteria_test.dart'
    as filter_criteria_entity_tests;
import '../../domain/entities/hospital/hospital_shortlist_test.dart'
    as hospital_shortlist_entity_tests;
import '../../domain/entities/hospital/sync_metadata_test.dart'
    as sync_metadata_entity_tests;
import '../../domain/usecases/hospital/get_nearby_units_usecase_test.dart'
    as get_nearby_units_usecase_tests;
import '../../domain/usecases/hospital/filter_units_usecase_test.dart'
    as filter_units_usecase_tests;
import '../../domain/usecases/hospital/get_unit_detail_usecase_test.dart'
    as get_unit_detail_usecase_tests;
import '../../domain/usecases/hospital/manage_shortlist_usecase_test.dart'
    as manage_shortlist_usecase_tests;
import '../../domain/usecases/hospital/select_final_hospital_usecase_test.dart'
    as select_final_hospital_usecase_tests;
import '../../features/hospital_chooser/logic/hospital_shortlist_notifier_test.dart'
    as hospital_shortlist_state_tests;
import '../../features/hospital_chooser/logic/hospital_location_state_test.dart'
    as hospital_location_state_tests;
import '../../features/hospital_chooser/logic/hospital_map_state_test.dart'
    as hospital_map_state_tests;

void main() {
  group('[HospitalChooser] All Tests', () {
    // -------------------------------------------------------------------------
    // Domain Layer Tests
    // -------------------------------------------------------------------------

    group('1. Domain Entities', () {
      maternity_unit_entity_tests.main();
      filter_criteria_entity_tests.main();
      hospital_shortlist_entity_tests.main();
      sync_metadata_entity_tests.main();
    });

    group('2. Domain Use Cases', () {
      get_nearby_units_usecase_tests.main();
      filter_units_usecase_tests.main();
      get_unit_detail_usecase_tests.main();
      manage_shortlist_usecase_tests.main();
      select_final_hospital_usecase_tests.main();
    });

    // -------------------------------------------------------------------------
    // Data Layer Tests
    // -------------------------------------------------------------------------

    group('3. Data Mappers', () {
      maternity_unit_mapper_tests.main();
      hospital_shortlist_mapper_tests.main();
      sync_metadata_mapper_tests.main();
    });

    // -------------------------------------------------------------------------
    // Logic/State Management Tests
    // -------------------------------------------------------------------------

    group('4. State Tests', () {
      hospital_shortlist_state_tests.main();
      hospital_location_state_tests.main();
      hospital_map_state_tests.main();
    });
  });
}
