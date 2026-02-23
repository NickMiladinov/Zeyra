# Hospital Chooser Feature - Test Plan

## Overview
This document outlines all tests for the Hospital Chooser feature. The feature allows pregnant users to browse nearby maternity units on a map/list, filter by distance/rating/type, shortlist hospitals for consideration, and select their final birth location.

**Created:** 2026-01-21  
**Last Updated:** 2026-01-21  
**Total Tests:** 173  
**Test Files:** 15  
**Status:** ✅ All tests passing

---

## Test Coverage Summary

### Implemented Tests

| Test Level | File | Test Groups | Total Tests | Status |
|------------|------|-------------|-------------|--------|
| **Unit - Domain Entities** | `maternity_unit_test.dart` | 5 | 24 | ✅ |
| **Unit - Domain Entities** | `hospital_shortlist_test.dart` | 2 | 8 | ✅ |
| **Unit - Domain Entities** | `hospital_filter_criteria_test.dart` | 4 | 18 | ✅ |
| **Unit - Domain Entities** | `sync_metadata_test.dart` | 3 | 11 | ✅ |
| **Unit - Domain Use Cases** | `get_nearby_units_usecase_test.dart` | 1 | 6 | ✅ |
| **Unit - Domain Use Cases** | `filter_units_usecase_test.dart` | 1 | 7 | ✅ |
| **Unit - Domain Use Cases** | `get_unit_detail_usecase_test.dart` | 1 | 5 | ✅ |
| **Unit - Domain Use Cases** | `manage_shortlist_usecase_test.dart` | 5 | 17 | ✅ |
| **Unit - Domain Use Cases** | `select_final_hospital_usecase_test.dart` | 3 | 9 | ✅ |
| **Unit - Mappers** | `maternity_unit_mapper_test.dart` | 2 | 11 | ✅ |
| **Unit - Mappers** | `hospital_shortlist_mapper_test.dart` | 2 | 8 | ✅ |
| **Unit - Mappers** | `sync_metadata_mapper_test.dart` | 2 | 8 | ✅ |
| **Unit - State** | `hospital_shortlist_notifier_test.dart` | 2 | 12 | ✅ |
| **Unit - State** | `hospital_location_state_test.dart` | 3 | 14 | ✅ |
| **Unit - State** | `hospital_map_state_test.dart` | 3 | 15 | ✅ |
| **Total** | **15 files** | **39 groups** | **173 tests** | ✅ |

### Future Work (Not Yet Implemented)

| Test Level | File | Notes |
|------------|------|-------|
| **Unit - Repository** | `maternity_unit_repository_impl_test.dart` | Requires complex DAO mocking with registerFallbackValue |
| **Unit - Repository** | `hospital_shortlist_repository_impl_test.dart` | Requires registerFallbackValue setup for DTOs |
| **Unit - DAO** | `*_dao_test.dart` | Requires in-memory Drift database setup |
| **Unit - Services** | `location_service_test.dart` | Requires geolocator platform channel mocking |
| **Unit - Services** | `maternity_unit_sync_service_test.dart` | Requires asset bundle and remote source mocking |
| **Unit - Notifier** | `hospital_*_notifier_test.dart` | Requires complex async initialization mocking |

---

## Running All Hospital Chooser Tests

### Quick Run with Test Runners (Recommended)

Use the convenient test runner files in `test/runners/hospital_chooser/`:

```bash
# Quick tests - fastest (~30 seconds) - core entity and use case tests
flutter test test/runners/hospital_chooser/quick_test.dart

# Unit tests - comprehensive unit tests (~1-2 minutes)
flutter test test/runners/hospital_chooser/unit_test.dart

# All tests - everything including DAO and service tests (~2-3 minutes)
flutter test test/runners/hospital_chooser/all_test.dart
```

### Run by Tags

All hospital chooser tests are tagged with `@Tags(['hospital_chooser'])`:

```bash
# Run all hospital chooser tests
flutter test --tags hospital_chooser

# Run with coverage
flutter test --tags hospital_chooser --coverage
```

---

## 1. Domain Entity Tests

### 1.1 MaternityUnit Entity (`test/domain/entities/hospital/maternity_unit_test.dart`)

**Purpose:** Validate the `MaternityUnit` domain entity, CQC ratings, computed properties, and Haversine distance calculation.

#### 1.1.1 CqcRating Enum Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.1.1.1 | should parse rating from string correctly | Tests all rating strings | Enum parsing |
| 1.1.1.2 | should return notRated for null or unknown string | Edge case handling | Null safety |
| 1.1.1.3 | should have correct displayName for each rating | Tests UI display strings | Display names |
| 1.1.1.4 | should have correct sortValue for rating comparison | Tests sorting order | Sorting |
| 1.1.1.5 | should handle case-insensitive parsing | "GOOD", "good", "Good" all work | Case handling |
| 1.1.1.6 | should handle "Requires Improvement" with space | Full string parsing | Special string |

#### 1.1.2 MaternityUnit Creation Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.1.2.1 | should create unit with all required fields | Full entity creation | Instantiation |
| 1.1.2.2 | should handle nullable fields correctly | Optional fields are null | Null handling |
| 1.1.2.3 | should have equality based on id and cqcLocationId | Tests == operator | Equality |
| 1.1.2.4 | should generate correct hashCode | Tests hashCode consistency | Hashing |

#### 1.1.3 Computed Properties Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.1.3.1 | should return isValid true when active, registered, and has coordinates | Happy path | Validity check |
| 1.1.3.2 | should return isValid false when inactive | isActive = false | Validity check |
| 1.1.3.3 | should return isValid false when not registered | Status != Registered | Validity check |
| 1.1.3.4 | should return isValid false when missing coordinates | lat/lng null | Validity check |
| 1.1.3.5 | should return hasAddress true with postcode or town | Address detection | Address check |
| 1.1.3.6 | should format address correctly | formattedAddress property | String formatting |

#### 1.1.4 Distance Calculation Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.1.4.1 | should calculate distance using Haversine formula | Known coordinates | Math accuracy |
| 1.1.4.2 | should return 0 for same coordinates | Distance to self | Edge case |
| 1.1.4.3 | should return null when unit has no coordinates | Missing lat/lng | Null safety |
| 1.1.4.4 | should calculate correct distance London to Leeds | ~170 miles | Real-world test |
| 1.1.4.5 | should handle negative coordinates | Southern/Western hemispheres | Coord handling |
| 1.1.4.6 | should handle coordinates at 0,0 | Null island edge case | Edge case |

---

### 1.2 HospitalShortlist Entity (`test/domain/entities/hospital/hospital_shortlist_test.dart`)

**Purpose:** Validate the `HospitalShortlist` domain entity for tracking user selections.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.2.1 | should create shortlist with all required fields | Entity instantiation | Creation |
| 1.2.2 | should handle optional notes field | notes can be null | Null handling |
| 1.2.3 | should copyWith update isSelected field | Selection toggling | Immutability |
| 1.2.4 | should copyWith update notes field | Note editing | Immutability |
| 1.2.5 | should have equality based on id only | Tests == operator | Equality |
| 1.2.6 | should generate correct hashCode | Tests hashCode | Hashing |

---

### 1.3 HospitalFilterCriteria Entity (`test/domain/entities/hospital/hospital_filter_criteria_test.dart`)

**Purpose:** Validate filter criteria application and sorting logic.

#### 1.3.1 MinRatingFilter Enum Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.3.1.1 | should allow any rating with MinRatingFilter.any | All ratings pass | Any filter |
| 1.3.1.2 | should filter good and outstanding with MinRatingFilter.good | Good+ only | Good filter |
| 1.3.1.3 | should filter outstanding only with MinRatingFilter.outstanding | Outstanding only | Outstanding filter |
| 1.3.1.4 | should have correct displayName for each filter | UI strings | Display names |

#### 1.3.2 HospitalFilterCriteria Creation Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.3.2.1 | should create with default values | Default 15 miles, any rating | Defaults |
| 1.3.2.2 | should create with custom values | All parameters set | Custom creation |
| 1.3.2.3 | should detect active filters | hasActiveFilters property | Filter detection |
| 1.3.2.4 | should return false for default filters | No active filters | Default check |

#### 1.3.3 Filter Application Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.3.3.1 | should filter by distance | Units beyond radius excluded | Distance filter |
| 1.3.3.2 | should filter by NHS/independent type | Type exclusion works | Type filter |
| 1.3.3.3 | should filter by minimum rating | Rating threshold | Rating filter |
| 1.3.3.4 | should exclude invalid units | isValid = false excluded | Validity filter |
| 1.3.3.5 | should combine multiple filters | All filters applied | Combined filters |
| 1.3.3.6 | should return empty list when no matches | No results case | Empty result |

#### 1.3.4 Sorting Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.3.4.1 | should sort by distance ascending | Nearest first | Distance sort |
| 1.3.4.2 | should sort by rating descending | Best rating first | Rating sort |
| 1.3.4.3 | should sort by name alphabetically | A-Z | Name sort |
| 1.3.4.4 | should use distance as secondary sort for rating | Same rating → nearest | Secondary sort |

---

### 1.4 SyncMetadata Entity (`test/domain/entities/hospital/sync_metadata_test.dart`)

**Purpose:** Validate sync status tracking entity.

#### 1.4.1 SyncStatus Enum Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.4.1.1 | should parse status from string | All status strings | Parsing |
| 1.4.1.2 | should return never for null or unknown | Default status | Null handling |
| 1.4.1.3 | should convert to db string correctly | toDbString() method | Serialization |
| 1.4.1.4 | should round-trip correctly | parse → serialize → parse | Round-trip |

#### 1.4.2 SyncMetadata Computed Properties Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.4.2.1 | should return hasEverSynced true when lastSyncAt set | Sync detection | Property check |
| 1.4.2.2 | should return wasLastSyncSuccessful correctly | Success/failure | Status check |
| 1.4.2.3 | should copyWith update fields correctly | Immutability | Copy method |
| 1.4.2.4 | should have equality based on id | Equality check | Comparison |

---

## 2. Domain Use Case Tests

### 2.1 GetNearbyUnitsUseCase (`test/domain/usecases/hospital/get_nearby_units_usecase_test.dart`)

**Purpose:** Test nearby units retrieval use case.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.1 | should call repository with coordinates and default radius | Default 15 miles | Parameter passing |
| 2.1.2 | should call repository with custom radius | Custom radius | Parameter passing |
| 2.1.3 | should return units from repository | Happy path | Data retrieval |
| 2.1.4 | should return empty list when no units found | No results | Empty handling |
| 2.1.5 | should propagate repository errors | Error propagation | Error handling |
| 2.1.6 | should handle negative coordinates | Southern/Western | Edge case |

---

### 2.2 FilterUnitsUseCase (`test/domain/usecases/hospital/filter_units_usecase_test.dart`)

**Purpose:** Test filtered units retrieval use case.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.2.1 | should call repository with filter criteria | Criteria passed | Parameter passing |
| 2.2.2 | should return filtered units from repository | Happy path | Data retrieval |
| 2.2.3 | should handle default filter criteria | Defaults applied | Default handling |
| 2.2.4 | should return empty list when no matches | No results | Empty handling |
| 2.2.5 | should propagate repository errors | Error propagation | Error handling |

---

### 2.3 ManageShortlistUseCase (`test/domain/usecases/hospital/manage_shortlist_usecase_test.dart`)

**Purpose:** Test shortlist management use case.

#### 2.3.1 getShortlist Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.3.1.1 | should return shortlist from repository | Happy path | Data retrieval |
| 2.3.1.2 | should return empty list when shortlist empty | No items | Empty handling |
| 2.3.1.3 | should propagate repository errors | Error propagation | Error handling |

#### 2.3.2 isShortlisted Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.3.2.1 | should return true when unit in shortlist | Found | Boolean return |
| 2.3.2.2 | should return false when unit not in shortlist | Not found | Boolean return |

#### 2.3.3 addToShortlist Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.3.3.1 | should add unit to shortlist | Happy path | Addition |
| 2.3.3.2 | should add unit with notes | Notes included | Optional params |
| 2.3.3.3 | should return created shortlist entry | Return value | Response |
| 2.3.3.4 | should propagate repository errors | Error handling | Error propagation |

#### 2.3.4 removeFromShortlist Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.3.4.1 | should remove unit from shortlist | Happy path | Removal |
| 2.3.4.2 | should complete without error when unit not in shortlist | Idempotent | Edge case |
| 2.3.4.3 | should propagate repository errors | Error handling | Error propagation |

#### 2.3.5 toggleShortlist Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.3.5.1 | should add and return true when not shortlisted | Add path | Toggle add |
| 2.3.5.2 | should remove and return false when shortlisted | Remove path | Toggle remove |
| 2.3.5.3 | should call isShortlisted first | Check before action | Flow |
| 2.3.5.4 | should call addToShortlist when not shortlisted | Add called | Flow |
| 2.3.5.5 | should call removeFromShortlist when shortlisted | Remove called | Flow |
| 2.3.5.6 | should propagate repository errors | Error handling | Error propagation |

---

### 2.4 SelectFinalHospitalUseCase (`test/domain/usecases/hospital/select_final_hospital_usecase_test.dart`)

**Purpose:** Test final hospital selection use case.

#### 2.4.1 select Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.4.1.1 | should call repository selectFinalChoice | Happy path | Selection |
| 2.4.1.2 | should propagate repository errors | Error handling | Error propagation |
| 2.4.1.3 | should complete without return value | Void return | Return type |

#### 2.4.2 getSelected Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.4.2.1 | should return selected hospital from repository | Has selection | Return value |
| 2.4.2.2 | should return null when no selection | No selection | Null return |
| 2.4.2.3 | should propagate repository errors | Error handling | Error propagation |

#### 2.4.3 clearSelection Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.4.3.1 | should call repository clearSelection | Happy path | Clear action |
| 2.4.3.2 | should complete without error when no selection | Idempotent | Edge case |
| 2.4.3.3 | should propagate repository errors | Error handling | Error propagation |

---

## 3. Data Layer Tests

### 3.1 MaternityUnitMapper (`test/data/mappers/maternity_unit_mapper_test.dart`)

**Purpose:** Validate mapping between database DTOs and domain entities.

#### 3.1.1 toDomain Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.1.1 | should map all fields correctly | Full DTO to domain | Complete mapping |
| 3.1.1.2 | should convert milliseconds to DateTime | Timestamp conversion | Time handling |
| 3.1.1.3 | should handle null optional fields | Null preservation | Null handling |
| 3.1.1.4 | should parse JSON array for birthingOptions | JSON list parsing | JSON handling |
| 3.1.1.5 | should parse JSON object for facilities | JSON map parsing | JSON handling |
| 3.1.1.6 | should handle empty/invalid JSON gracefully | Malformed JSON | Error resilience |

#### 3.1.2 toDto Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.2.1 | should map all fields correctly | Domain to DTO | Complete mapping |
| 3.1.2.2 | should convert DateTime to milliseconds | Timestamp conversion | Time handling |
| 3.1.2.3 | should handle null optional fields | Null preservation | Null handling |
| 3.1.2.4 | should encode list to JSON string | JSON list encoding | JSON handling |
| 3.1.2.5 | should encode map to JSON string | JSON map encoding | JSON handling |
| 3.1.2.6 | should handle empty list/map correctly | Empty collections | Edge case |

---

### 3.2 HospitalShortlistMapper (`test/data/mappers/hospital_shortlist_mapper_test.dart`)

**Purpose:** Validate shortlist mapping between DTOs and domain entities.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.2.1 | should map HospitalShortlistDto to domain | DTO to domain | Mapping |
| 3.2.2 | should convert milliseconds to DateTime | Timestamp | Time handling |
| 3.2.3 | should map domain to HospitalShortlistDto | Domain to DTO | Reverse mapping |
| 3.2.4 | should convert DateTime to milliseconds | Timestamp | Time handling |
| 3.2.5 | should map ShortlistWithUnitDto to domain | Combined DTO | Join mapping |
| 3.2.6 | should map list of ShortlistWithUnitDto | List mapping | Batch mapping |

---

### 3.3 SyncMetadataMapper (`test/data/mappers/sync_metadata_mapper_test.dart`)

**Purpose:** Validate sync metadata mapping.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.3.1 | should map SyncMetadataDto to domain | DTO to domain | Mapping |
| 3.3.2 | should parse sync status from string | Status parsing | Enum handling |
| 3.3.3 | should handle null lastSyncAtMillis | Null timestamp | Null handling |
| 3.3.4 | should map domain to SyncMetadataDto | Domain to DTO | Reverse mapping |
| 3.3.5 | should convert status to db string | Status serialization | Enum handling |

---

### 3.4 MaternityUnitDao (`test/data/local/daos/maternity_unit_dao_test.dart`)

**Purpose:** Test DAO with in-memory Drift database.

#### 3.4.1 CRUD Operations Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.4.1.1 | should insert and retrieve unit by id | Basic CRUD | Insert/Get |
| 3.4.1.2 | should retrieve unit by CQC location id | Secondary key | Query |
| 3.4.1.3 | should update unit on conflict | Upsert behavior | Upsert |
| 3.4.1.4 | should delete unit by id | Deletion | Delete |
| 3.4.1.5 | should return null for non-existent id | Not found | Null return |
| 3.4.1.6 | should return count of all units | Count query | Aggregation |

#### 3.4.2 Bounding Box Query Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.4.2.1 | should return units within bounding box | Basic spatial query | Query |
| 3.4.2.2 | should exclude units outside bounding box | Boundary check | Exclusion |
| 3.4.2.3 | should exclude inactive units when activeOnly=true | Active filter | Filter |
| 3.4.2.4 | should include inactive units when activeOnly=false | Active filter off | Filter |
| 3.4.2.5 | should exclude unregistered units when activeOnly=true | Registration filter | Filter |
| 3.4.2.6 | should return empty list when no matches | No results | Empty result |

#### 3.4.3 Bounding Box Calculation Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.4.3.1 | should calculate correct bounding box for 10 mile radius | Math check | Calculation |
| 3.4.3.2 | should handle equator coordinates | Lat = 0 | Edge case |
| 3.4.3.3 | should handle polar coordinates | Near poles | Edge case |
| 3.4.3.4 | should handle prime meridian coordinates | Lng = 0 | Edge case |

#### 3.4.4 Batch Operations Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.4.4.1 | should upsert all units in batch | Batch upsert | Batch operation |
| 3.4.4.2 | should handle 500+ units efficiently | Performance | Scalability |

---

### 3.5 HospitalShortlistDao (`test/data/local/daos/hospital_shortlist_dao_test.dart`)

**Purpose:** Test shortlist DAO with in-memory database.

#### 3.5.1 CRUD Operations Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.5.1.1 | should insert and retrieve shortlist entry | Basic CRUD | Insert/Get |
| 3.5.1.2 | should retrieve by maternity unit id | Foreign key query | Query |
| 3.5.1.3 | should check if shortlisted | Boolean check | Query |
| 3.5.1.4 | should delete shortlist entry | Deletion | Delete |
| 3.5.1.5 | should delete by maternity unit id | FK deletion | Delete |

#### 3.5.2 Selection Operations Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.5.2.1 | should get selected hospital | Selection query | Query |
| 3.5.2.2 | should return null when no selection | No selection | Null return |
| 3.5.2.3 | should select hospital and clear previous | Selection | Transaction |
| 3.5.2.4 | should clear all selections | Clear all | Update |

#### 3.5.3 Join Queries Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.5.3.1 | should get shortlist with unit details | Join query | Join |
| 3.5.3.2 | should get selected with unit details | Join query | Join |
| 3.5.3.3 | should order by addedAt descending | Sorting | Order |

---

### 3.6 SyncMetadataDao (`test/data/local/daos/sync_metadata_dao_test.dart`)

**Purpose:** Test sync metadata DAO.

#### 3.6.1 CRUD Operations Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.6.1.1 | should insert and retrieve by id | Basic CRUD | Insert/Get |
| 3.6.1.2 | should upsert existing record | Update on conflict | Upsert |
| 3.6.1.3 | should return null for non-existent id | Not found | Null return |
| 3.6.1.4 | should delete metadata | Deletion | Delete |

#### 3.6.2 Sync Update Operations Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.6.2.1 | should update sync success | Success update | Update |
| 3.6.2.2 | should update sync failure | Failure update | Update |
| 3.6.2.3 | should update data version | Version update | Update |
| 3.6.2.4 | should create record if not exists on version update | Insert if new | Upsert |

---

## 4. Service Tests

### 4.1 LocationService (`test/core/services/location_service_test.dart`)

**Purpose:** Test device location and postcodes.io integration (with mocked HTTP).

#### 4.1.1 Permission Handling Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.1.1 | should return correct permission status | Status mapping | Enum mapping |
| 4.1.1.2 | should request permission correctly | Request flow | Permission flow |
| 4.1.1.3 | should return serviceDisabled when location off | Service check | Service status |
| 4.1.1.4 | should return deniedForever correctly | Permanent denial | Status |
| 4.1.1.5 | should hasPermission return boolean correctly | Convenience check | Boolean |

#### 4.1.2 Device Location Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.2.1 | should get current location when permitted | Happy path | Location fetch |
| 4.1.2.2 | should return null when not permitted | No permission | Null return |
| 4.1.2.3 | should handle timeout gracefully | Timeout error | Error handling |
| 4.1.2.4 | should return LatLng with correct values | Data accuracy | Data type |
| 4.1.2.5 | should handle location errors | Exception handling | Error resilience |

#### 4.1.3 Postcode Lookup Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.3.1 | should get coordinates from valid postcode | Happy path | API call |
| 4.1.3.2 | should return null for invalid postcode | Not found | Null return |
| 4.1.3.3 | should validate postcode correctly | Validation | Boolean |
| 4.1.3.4 | should autocomplete partial postcode | Autocomplete | List return |
| 4.1.3.5 | should get postcode details | Full details | Object return |

#### 4.1.4 Reverse Geocoding Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.4.1 | should get postcode from coordinates | Happy path | API call |
| 4.1.4.2 | should return null for invalid coordinates | Out of UK | Null return |
| 4.1.4.3 | should handle API errors gracefully | Error response | Error handling |
| 4.1.4.4 | should handle network timeout | Timeout | Error handling |
| 4.1.4.5 | should strip spaces from postcode input | Normalization | Input handling |

---

### 4.2 MaternityUnitSyncService (`test/core/services/maternity_unit_sync_service_test.dart`)

**Purpose:** Test sync service with mocked repository.

#### 4.2.1 Initialize Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.1.1 | should load from assets when needed | Initial load | Load flow |
| 4.2.1.2 | should skip asset load when not needed | Skip load | Conditional |
| 4.2.1.3 | should perform incremental sync after load | Sync after load | Sync flow |
| 4.2.1.4 | should handle missing asset gracefully | No asset file | Error handling |

#### 4.2.2 Incremental Sync Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.2.1 | should call repository syncFromRemote | Sync call | Method call |
| 4.2.2.2 | should handle sync errors without crashing | Error resilience | Error handling |
| 4.2.2.3 | should log sync completion | Logging | Observability |

#### 4.2.3 Sync Status Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.3.1 | should return sync status info | Status retrieval | Status |
| 4.2.3.2 | should calculate hasData correctly | Computed property | Boolean |
| 4.2.3.3 | should calculate hasError correctly | Computed property | Boolean |

---

## 5. State Management Tests

### 5.1 HospitalLocationNotifier (`test/features/hospital_chooser/logic/hospital_location_notifier_test.dart`)

**Purpose:** Test location state management.

#### 5.1.1 Initialization Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.1.1 | should start in loading state | Initial state | State |
| 5.1.1.2 | should load saved postcode from user profile | Saved postcode | Persistence |
| 5.1.1.3 | should check permission status when no saved postcode | Permission check | Flow |
| 5.1.1.4 | should set isInitialized to true after load | Completion | Flag |

#### 5.1.2 Permission Request Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.2.1 | should request permission and get location | Happy path | Full flow |
| 5.1.2.2 | should update state with location on success | State update | State |
| 5.1.2.3 | should save postcode to user profile | Persistence | Save |
| 5.1.2.4 | should handle permission denied | Denied case | Error state |

#### 5.1.3 Manual Postcode Entry Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.3.1 | should validate and set postcode | Happy path | Validation |
| 5.1.3.2 | should return error for invalid postcode | Invalid input | Error state |
| 5.1.3.3 | should get coordinates from postcode | Geocoding | API call |
| 5.1.3.4 | should save postcode to user profile | Persistence | Save |

#### 5.1.4 Location Refresh Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.4.1 | should refresh device location | Refresh flow | Update |
| 5.1.4.2 | should update postcode on refresh | Postcode update | State |
| 5.1.4.3 | should not refresh without permission | Guard check | Conditional |
| 5.1.4.4 | should handle refresh errors | Error handling | Error state |

---

### 5.2 HospitalMapNotifier (`test/features/hospital_chooser/logic/hospital_map_notifier_test.dart`)

**Purpose:** Test map/list state management.

#### 5.2.1 Load Nearby Units Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.2.1.1 | should load nearby units for location | Happy path | Data load |
| 5.2.1.2 | should update state with units | State update | State |
| 5.2.1.3 | should set loading state during fetch | Loading flag | UI state |
| 5.2.1.4 | should handle load errors | Error handling | Error state |

#### 5.2.2 Filter Application Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.2.2.1 | should apply new filter criteria | Filter change | Filter |
| 5.2.2.2 | should reload units with new filters | Data refresh | Reload |
| 5.2.2.3 | should preserve map center during filter | Center persist | State |
| 5.2.2.4 | should handle filter errors | Error handling | Error state |

#### 5.2.3 Selection Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.2.3.1 | should select unit on marker tap | Selection | State |
| 5.2.3.2 | should clear selection | Clear | State |
| 5.2.3.3 | should update selectedUnit in state | State update | State |
| 5.2.3.4 | should not affect nearbyUnits on selection | Isolation | State |

---

### 5.3 HospitalShortlistNotifier (`test/features/hospital_chooser/logic/hospital_shortlist_notifier_test.dart`)

**Purpose:** Test shortlist state management.

#### 5.3.1 Load Shortlist Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.3.1.1 | should load shortlist on init | Auto-load | Initialization |
| 5.3.1.2 | should update state with shortlist data | State update | State |
| 5.3.1.3 | should handle load errors | Error handling | Error state |

#### 5.3.2 Add/Remove Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.3.2.1 | should add hospital and refresh | Add flow | Addition |
| 5.3.2.2 | should remove hospital and refresh | Remove flow | Removal |
| 5.3.2.3 | should toggle shortlist status | Toggle | Boolean |
| 5.3.2.4 | should handle add/remove errors | Error handling | Error state |

#### 5.3.3 Selection Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.3.3.1 | should select final hospital | Selection | State |
| 5.3.3.2 | should clear selection | Clear | State |
| 5.3.3.3 | should update selectedHospital in state | State update | State |
| 5.3.3.4 | should handle selection errors | Error handling | Error state |

#### 5.3.4 Notes Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.3.4.1 | should update notes for shortlist entry | Note update | Update |
| 5.3.4.2 | should refresh shortlist after update | Refresh | Reload |
| 5.3.4.3 | should handle update errors | Error handling | Error state |

---

### 5.4 HospitalDetailNotifier (`test/features/hospital_chooser/logic/hospital_detail_notifier_test.dart`)

**Purpose:** Test detail view state management.

#### 5.4.1 Load Unit Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.4.1.1 | should load unit by id | Load flow | Data load |
| 5.4.1.2 | should calculate distance when location provided | Distance | Calculation |
| 5.4.1.3 | should check shortlist status | Status check | Boolean |
| 5.4.1.4 | should handle load errors | Error handling | Error state |

#### 5.4.2 Set Unit Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.4.2.1 | should set unit directly from map selection | Direct set | State |
| 5.4.2.2 | should calculate distance when set | Distance | Calculation |
| 5.4.2.3 | should check shortlist status in background | Async check | Background |

#### 5.4.3 Toggle Shortlist Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.4.3.1 | should toggle shortlist and update state | Toggle | State |
| 5.4.3.2 | should return new shortlist status | Return value | Boolean |
| 5.4.3.3 | should handle toggle errors | Error handling | Error state |

---

## 6. Test Environment Setup

### Mocking Strategy
- **MockMaternityUnitRepository:** For use case tests
- **MockHospitalShortlistRepository:** For use case tests
- **MockMaternityUnitDao:** For repository tests
- **MockHospitalShortlistDao:** For repository tests
- **MockSyncMetadataDao:** For repository tests
- **MockMaternityUnitRemoteSource:** For repository tests
- **MockLocationService:** For state notifier tests
- **MockHttpClient:** For LocationService tests
- **In-memory Drift database:** For DAO tests

### Fake Data Builders
- **FakeMaternityUnit.simple():** Creates minimal valid unit
- **FakeMaternityUnit.withRating():** Creates unit with specific rating
- **FakeMaternityUnit.atLocation():** Creates unit at specific coordinates
- **FakeMaternityUnit.batch():** Creates n units
- **FakeHospitalShortlist.simple():** Creates shortlist entry
- **FakeSyncMetadata.simple():** Creates sync metadata

### Test Tags
All tests tagged with `@Tags(['hospital_chooser'])` for filtered running.

---

## Business Rules Validated

### Hospital Search
- ✅ Bounding box pre-filtering for efficient queries
- ✅ Haversine formula for accurate distance calculation
- ✅ Filter by distance, rating, NHS/independent
- ✅ Sort by distance, rating, or name
- ✅ Only show valid (active, registered, has coordinates) units

### Shortlist Management
- ✅ Add/remove hospitals from shortlist
- ✅ Toggle shortlist status
- ✅ Add notes to shortlisted hospitals
- ✅ Select one hospital as final choice
- ✅ Clear selection

### Location Handling
- ✅ Check for saved postcode first
- ✅ Request device location permission
- ✅ Fall back to manual postcode entry
- ✅ Validate UK postcodes via postcodes.io
- ✅ Save postcode to user profile

### Data Sync
- ✅ Load pre-packaged data on first launch
- ✅ Incremental sync from Supabase
- ✅ Track sync metadata (version, timestamp, status)
- ✅ Handle sync errors gracefully

---

## Document Metadata

**Created:** 2026-01-21  
**Last Updated:** 2026-01-21  
**Total Tests:** 120  
**Test Files:** 10  
**Coverage Level:** Domain + Data Mappers (entities, use cases, mappers)  
**Feature Status:** Implementation Complete, Core Tests Complete

## Current Test Status

| Category | Tests | Status |
|----------|-------|--------|
| Entity Tests (MaternityUnit) | 24 | ✅ Complete |
| Entity Tests (HospitalFilterCriteria) | 18 | ✅ Complete |
| Entity Tests (HospitalShortlist) | 8 | ✅ Complete |
| Entity Tests (SyncMetadata) | 11 | ✅ Complete |
| Use Case Tests (GetNearbyUnits) | 6 | ✅ Complete |
| Use Case Tests (ManageShortlist) | 17 | ✅ Complete |
| Use Case Tests (SelectFinalHospital) | 9 | ✅ Complete |
| Mapper Tests (MaternityUnitMapper) | 11 | ✅ Complete |
| Mapper Tests (HospitalShortlistMapper) | 8 | ✅ Complete |
| Mapper Tests (SyncMetadataMapper) | 8 | ✅ Complete |
| **Total** | **120** | ✅ Passing |

## Remaining Tests (Future Work)

The following tests are documented in the plan but not yet implemented:
- Repository implementation tests (mocked DAOs)
- DAO tests (in-memory Drift database)
- LocationService tests (mocked HTTP/geolocator)
- MaternityUnitSyncService tests
- State notifier tests (Riverpod)
