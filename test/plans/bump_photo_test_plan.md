# Bump Photo Feature - Test Plan

## Overview
This document outlines all tests for the Bump Photo feature. The feature allows pregnant users to document their pregnancy journey through weekly photos and notes, with support for photo-only, note-only, or combined entries. Photos are stored in the file system with database metadata protected by SQLCipher encryption.

---

## Test Coverage Summary

| Test Level | File | Test Groups | Total Tests |
|------------|------|-------------|-------------|
| **Unit - Domain Entities** | `bump_photo_test.dart` | 1 | 6 |
| **Unit - Domain Entities** | `bump_photo_constants_test.dart` | 3 | 5 |
| **Unit - Domain Use Cases** | `save_bump_photo_test.dart` | 1 | 7 |
| **Unit - Domain Use Cases** | `save_bump_photo_note_test.dart` | 1 | 7 |
| **Unit - Domain Use Cases** | `get_bump_photos_test.dart` | 1 | 5 |
| **Unit - Domain Use Cases** | `delete_bump_photo_test.dart` | 1 | 4 |
| **Unit - Domain Use Cases** | `update_bump_photo_note_test.dart` | 1 | 4 |
| **Unit - Domain Exceptions** | `bump_photo_exception_test.dart` | 5 | 18 |
| **Unit - Mappers** | `bump_photo_mapper_test.dart` | 4 | 8 |
| **Unit - DAO** | `bump_photo_dao_test.dart` | 1 | 17 |
| **Unit - Repository** | `bump_photo_repository_impl_test.dart` | 10 | 32 |
| **Unit - Logic** | `bump_photo_notifier_test.dart` | 8 | 24 |
| **Unit - Core Utils** | `image_format_utils_test.dart` | 7 | 24 |
| **Unit - Core Services** | `photo_file_service_test.dart` | 2 | 11 |
| **Integration** | `bump_photo_flow_test.dart` | 1 | 15 |
| **Total** | **15 files** | **47 groups** | **187 tests** |

---

## Running All Bump Photo Tests

### Quick Run with Test Runners (Recommended)

Use the convenient test runner files in `test/runners/bump_photo/`:

```bash
# Quick tests - fastest (~20 seconds) - Core domain and mappers
flutter test test/runners/bump_photo/bump_photo_quick_test.dart

# All tests - everything including integration (~1-2 minutes)
flutter test test/runners/bump_photo/bump_photo_all_test.dart
```

**In your IDE**: Open any of these files and click the Run button next to `main()`!

### Run by Tags

All bump photo tests are tagged with `@Tags(['bump_photo'])`:

```bash
# Run all bump photo tests
flutter test --tags bump_photo

# Run with coverage
flutter test --tags bump_photo --coverage

# Run using preset (from dart_test.yaml)
flutter test --preset=bump_photo
```

### Run Specific Test File

```bash
flutter test test/domain/usecases/bump_photo/save_bump_photo_test.dart
```

---

## 1. Domain Entity Tests

### 1.1 BumpPhoto Entity (`test/domain/entities/bump_photo/bump_photo_test.dart`)

**Purpose:** Validate the `BumpPhoto` domain entity creation and behavior.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.1.1 | creates with all required fields | Creates entity with all properties | Entity instantiation |
| 1.1.2 | creates with null note | Note field is nullable | Null handling |
| 1.1.3 | copyWith creates correct copy | Creates new instance with updated fields | Immutability pattern |
| 1.1.4 | equality is based on id | Equal IDs = equal objects | Equality logic |
| 1.1.5 | different ids are not equal | Different IDs = different objects | Equality logic |
| 1.1.6 | toString includes key info | Debug string contains relevant info | Debugging |
| 1.1.7 | creates with null filePath | filePath is nullable for note-only entries | Null handling |

**Coverage:** Entity creation, null handling, equality, immutability

---

### 1.2 BumpPhotoConstants (`test/domain/entities/bump_photo/bump_photo_constants_test.dart`)

**Purpose:** Validate constants and validation methods.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.2.1 | has correct week range | minWeek=1, maxWeek=42 | Week constraints |
| 1.2.2 | has correct image constraints | maxImageWidth, jpegQuality, maxFileSize, extension | Image constraints |
| 1.2.3 | isValidWeek returns true for valid weeks | Weeks 1, 20, 42 are valid | Validation logic |
| 1.2.4 | isValidWeek returns false for invalid weeks | 0, -1, 43, 100 are invalid | Validation logic |
| 1.2.5 | getInvalidWeekMessage returns correct message | Contains week limits and actual value | Error messages |

**Coverage:** Constants values, week validation, error messages

---

## 2. Domain Use Case Tests

### 2.1 SaveBumpPhoto (`test/domain/usecases/bump_photo/save_bump_photo_test.dart`)

**Purpose:** Unit test the save photo use case with mocked repository.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.1 | saves photo successfully for valid week | Happy path save | Basic save |
| 2.1.2 | saves photo with note | Photo with note text | Note handling |
| 2.1.3 | throws InvalidWeekException for week too low | Week 0 throws | Validation |
| 2.1.4 | throws InvalidWeekException for week too high | Week 43 throws | Validation |
| 2.1.5 | throws InvalidWeekException for negative week | Week -5 throws | Validation |
| 2.1.6 | saves photo at minimum valid week | Week 1 succeeds | Boundary |
| 2.1.7 | saves photo at maximum valid week | Week 42 succeeds | Boundary |
| 2.1.8 | does not call repository for invalid week | Validation fails fast | Error handling |

**Coverage:** Basic operations, week validation, boundary cases

---

### 2.2 SaveBumpPhotoNote (`test/domain/usecases/bump_photo/save_bump_photo_note_test.dart`)

**Purpose:** Unit test the save note-only use case.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.2.1 | saves note successfully for valid week | Happy path save | Basic save |
| 2.2.2 | saves note with null value (clears note) | Null note clears | Note clearing |
| 2.2.3 | throws InvalidWeekException for week too low | Week 0 throws | Validation |
| 2.2.4 | throws InvalidWeekException for week too high | Week 43 throws | Validation |
| 2.2.5 | saves note at minimum valid week | Week 1 succeeds | Boundary |
| 2.2.6 | saves note at maximum valid week | Week 42 succeeds | Boundary |
| 2.2.7 | does not call repository for invalid week | Validation fails fast | Error handling |

**Coverage:** Note-only operations, validation, boundary cases

---

### 2.3 GetBumpPhotos (`test/domain/usecases/bump_photo/get_bump_photos_test.dart`)

**Purpose:** Unit test retrieval of bump photos.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.3.1 | returns all photos for pregnancy | Returns list from repo | Basic retrieval |
| 2.3.2 | returns empty list when no photos exist | Empty list not null | Empty state |
| 2.3.3 | returns photos sorted by weekNumber | Preserves sort order | Sorting |
| 2.3.4 | filters by pregnancyId correctly | Only matching pregnancy | Filtering |
| 2.3.5 | handles repository errors | Propagates exceptions | Error handling |

**Coverage:** Retrieval, empty state, sorting, filtering, error handling

---

### 2.4 DeleteBumpPhoto (`test/domain/usecases/bump_photo/delete_bump_photo_test.dart`)

**Purpose:** Unit test photo deletion.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.4.1 | deletes photo successfully | Calls repository delete | Basic delete |
| 2.4.2 | calls repository with correct id | Verifies ID passed | Parameter passing |
| 2.4.3 | handles non-existent photo gracefully | No error for missing | Graceful handling |
| 2.4.4 | handles repository errors | Propagates exceptions | Error handling |

**Coverage:** Deletion, graceful handling, error propagation

---

### 2.5 UpdateBumpPhotoNote (`test/domain/usecases/bump_photo/update_bump_photo_note_test.dart`)

**Purpose:** Unit test note updates on existing photos.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.5.1 | updates note successfully | Happy path update | Basic update |
| 2.5.2 | clears note when null provided | Null clears note | Note clearing |
| 2.5.3 | handles empty string note | Empty string handling | Edge case |
| 2.5.4 | handles repository errors | Propagates exceptions | Error handling |

**Coverage:** Note updates, clearing, error handling

---

## 3. Domain Exception Tests

### 3.1 BumpPhotoException (`test/domain/exceptions/bump_photo_exception_test.dart`)

**Purpose:** Validate all exception types.

#### 3.1.1 BumpPhotoException (Base) Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.1.1 | creates with message | Basic creation | Constructor |
| 3.1.1.2 | creates with originalError and stackTrace | Full creation | Error wrapping |
| 3.1.1.3 | has correct toString output | Contains "BumpPhotoException: message" | Debug output |

#### 3.1.2 InvalidWeekException Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.2.1 | creates with week number and message | Stores weekNumber | Constructor |
| 3.1.2.2 | has correct toString output | Contains week number | Debug output |
| 3.1.2.3 | is a BumpPhotoException | Type hierarchy | Inheritance |

#### 3.1.3 PhotoFileException Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.3.1 | creates with filePath and message | Stores filePath | Constructor |
| 3.1.3.2 | creates with originalError | Wraps original error | Error wrapping |
| 3.1.3.3 | has correct toString output | Contains file path | Debug output |
| 3.1.3.4 | is a BumpPhotoException | Type hierarchy | Inheritance |

#### 3.1.4 PhotoNotFoundException Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.4.1 | creates with message only | Basic creation | Constructor |
| 3.1.4.2 | creates with pregnancyId and weekNumber | Full creation | Constructor |
| 3.1.4.3 | has correct toString with details | Contains context info | Debug output |
| 3.1.4.4 | is a BumpPhotoException | Type hierarchy | Inheritance |

#### 3.1.5 ImageTooLargeException and ImageProcessingException Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.5.1 | ImageTooLargeException creates with sizes | Stores actualSize, maxSize | Constructor |
| 3.1.5.2 | ImageTooLargeException has correct toString | Contains size details | Debug output |
| 3.1.5.3 | ImageProcessingException creates with message | Basic creation | Constructor |
| 3.1.5.4 | ImageProcessingException wraps original error | Error wrapping | Error wrapping |

**Coverage:** All 5 exception types, constructors, toString, inheritance

---

## 4. Data Layer Tests

### 4.1 BumpPhotoMapper (`test/data/mappers/bump_photo_mapper_test.dart`)

**Purpose:** Validate mapping between database DTOs and domain entities.

#### 4.1.1 toDomain Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.1.1 | converts DTO to domain entity correctly | All fields mapped | Mapping |
| 4.1.1.2 | handles null note | Null preserved | Null handling |
| 4.1.1.3 | converts timestamps correctly | Milliseconds to DateTime | Time conversion |

#### 4.1.2 toDto Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.2.1 | converts domain entity to DTO correctly | All fields mapped | Mapping |
| 4.1.2.2 | handles null note | Null preserved | Null handling |

#### 4.1.3 Round-trip Group (1 test)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.3.1 | maintains data integrity through toDomain and toDto | DTO -> Domain -> DTO | Data integrity |

#### 4.1.4 List Conversions Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.4.1 | toDomainList converts list correctly | List of DTOs | Batch conversion |
| 4.1.4.2 | toDtoList converts list correctly | List of entities | Batch conversion |

#### 4.1.5 Null FilePath Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.5.1 | toDomain handles null filePath | Note-only entries | Null handling |
| 4.1.5.2 | toDto handles null filePath | Note-only entities | Null handling |
| 4.1.5.3 | round-trip with null filePath | Data integrity | Data integrity |

**Coverage:** Mapping, null handling, timestamps, batch operations

---

### 4.2 BumpPhotoDao (`test/data/local/daos/bump_photo_dao_test.dart`)

**Purpose:** Test DAO operations with in-memory database.

#### 4.2.1 insertBumpPhoto Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.1.1 | creates record successfully | Insert and retrieve | Basic insert |
| 4.2.1.2 | throws on duplicate (pregnancyId, weekNumber) | Unique constraint | Constraint |

#### 4.2.2 getBumpPhotoByWeek Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.2.1 | returns correct photo | Finds by pregnancy + week | Query |
| 4.2.2.2 | returns null for non-existent week | No match = null | Null handling |

#### 4.2.3 getBumpPhotosForPregnancy Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.3.1 | returns all photos for pregnancy | Full list | Basic query |
| 4.2.3.2 | returns photos sorted by weekNumber | Ascending order | Sorting |
| 4.2.3.3 | returns empty list when no photos exist | Empty not null | Empty state |
| 4.2.3.4 | filters by pregnancyId correctly | Isolation | Filtering |

#### 4.2.4 updateBumpPhoto Group (1 test)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.4.1 | modifies existing record | Updates in place | Update |

#### 4.2.5 upsertBumpPhoto Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.5.1 | inserts new photo | Creates if not exists | Upsert insert |
| 4.2.5.2 | updates existing photo with same id | Updates if exists | Upsert update |

#### 4.2.6 deleteBumpPhoto Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.6.1 | removes record | Deletes successfully | Delete |
| 4.2.6.2 | does nothing for non-existent photo | No error | Graceful |

#### 4.2.7 deleteAllForPregnancy Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.7.1 | removes all photos for pregnancy | Bulk delete | Bulk delete |
| 4.2.7.2 | returns 0 when no photos exist | Returns count | Return value |

#### 4.2.8 getBumpPhotoCount Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.8.1 | returns correct count | Counts matching | Count |
| 4.2.8.2 | returns 0 when no photos exist | Zero count | Empty state |

#### 4.2.9 updateBumpPhotoFields Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.9.1 | updates only specified fields | Partial update | Selective update |
| 4.2.9.2 | clears filePath to null | Note preservation prep | Null update |

**Coverage:** All CRUD operations, constraints, sorting, bulk operations

---

### 4.3 BumpPhotoRepositoryImpl (`test/data/repositories/bump_photo_repository_impl_test.dart`)

**Purpose:** Test repository with mocked DAO and file service.

#### 4.3.1 saveBumpPhoto Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.1.1 | saves file and creates database record | Full save flow | Basic save |
| 4.3.1.2 | replaces existing photo file when upserting | Deletes old file | File cleanup |
| 4.3.1.3 | throws InvalidWeekException for invalid week | Week validation | Validation |
| 4.3.1.4 | handles file service errors | Propagates PhotoFileException | Error handling |
| 4.3.1.5 | wraps database errors in BumpPhotoException | Wraps generic errors | Error wrapping |

#### 4.3.2 getBumpPhotos Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.2.1 | returns mapped domain entities sorted by week | Maps DTOs | Retrieval |
| 4.3.2.2 | returns empty list when no photos exist | Empty list | Empty state |
| 4.3.2.3 | rethrows database errors | Propagates errors | Error handling |

#### 4.3.3 getBumpPhoto Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.3.1 | returns mapped domain entity when found | Single photo | Retrieval |
| 4.3.3.2 | returns null when photo not found | Null if missing | Null handling |

#### 4.3.4 updateNote Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.4.1 | updates note in database | Updates note field | Basic update |
| 4.3.4.2 | throws PhotoNotFoundException when not found | Missing photo error | Error handling |
| 4.3.4.3 | normalizes empty string to null | Empty -> null | Normalization |

#### 4.3.5 deleteBumpPhoto Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.5.1 | deletes file and database record | Full delete | Basic delete |
| 4.3.5.2 | returns early when photo does not exist | No-op for missing | Graceful |
| 4.3.5.3 | continues with DB deletion if file deletion fails | File error resilience | Error resilience |
| 4.3.5.4 | preserves note when deleting photo with note | Sets filePath=null | Note preservation |

#### 4.3.6 deleteAllForPregnancy Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.6.1 | deletes all photos for pregnancy | Bulk delete | Bulk delete |
| 4.3.6.2 | rethrows errors | Propagates errors | Error handling |

#### 4.3.7 saveNoteOnly Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.7.1 | creates new entry with note only | No file required | Note-only create |
| 4.3.7.2 | updates existing entry with note | Preserves filePath | Note-only update |
| 4.3.7.3 | preserves existing filePath when updating note | Photo retained | Photo preservation |
| 4.3.7.4 | throws InvalidWeekException for invalid week | Week validation | Validation |
| 4.3.7.5 | wraps database errors in BumpPhotoException | Error wrapping | Error handling |

#### 4.3.8 File Cleanup Scenarios Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.8.1 | deletes old file when replacing photo | Old file cleanup | File cleanup |
| 4.3.8.2 | continues if old file already deleted | Missing file resilience | Error resilience |
| 4.3.8.3 | does not delete file when path unchanged | Same path no delete | Optimization |

**Coverage:** All repository operations, file management, note preservation, error handling

---

## 5. Logic / State Management Tests

### 5.1 BumpPhotoNotifier (`test/features/bump_photo/logic/bump_photo_notifier_test.dart`)

**Purpose:** Unit test the StateNotifier for bump photo state management.

#### 5.1.1 Initial State Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.1.1 | starts with empty state | photos=[], isLoading=false | Initial state |
| 5.1.1.2 | calls loadPhotos on creation | Auto-loads on init | Initialization |

#### 5.1.2 loadPhotos Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.2.1 | loads photos and generates week slots | Full load flow | Loading |
| 5.1.2.2 | sets error on failure | Error state | Error handling |
| 5.1.2.3 | generates correct week slots from pregnancy | Slot generation | Week slots |

#### 5.1.3 savePhoto Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.3.1 | saves photo and updates state | Adds to photos list | Basic save |
| 5.1.3.2 | replaces existing photo for same week | Updates in place | Update |
| 5.1.3.3 | sets error on BumpPhotoException | Exception handling | Error handling |
| 5.1.3.4 | sets error on generic exception | Wraps errors | Error handling |

#### 5.1.4 updatePhotoNote Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.4.1 | updates note in state | Note updated | Basic update |
| 5.1.4.2 | regenerates week slots after update | Slots refreshed | State sync |
| 5.1.4.3 | sets error on failure | Error state | Error handling |

#### 5.1.5 saveNoteOnly Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.5.1 | creates new entry with note only | Note-only create | Basic save |
| 5.1.5.2 | updates existing entry with note | Preserves photo | Update |
| 5.1.5.3 | sets error on failure | Error state | Error handling |

#### 5.1.6 deletePhoto Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.6.1 | removes photo from state | Photo removed | Basic delete |
| 5.1.6.2 | preserves note when photo deleted | Note retained | Note preservation |
| 5.1.6.3 | reloads photos after delete | State refreshed | State sync |
| 5.1.6.4 | sets error on failure | Error state | Error handling |

#### 5.1.7 clearError Group (1 test)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.7.1 | clears error from state | error=null | Error clearing |

#### 5.1.8 Week Slot Generation Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.8.1 | generates slots up to current gestational week | Correct range | Slot generation |
| 5.1.8.2 | marks current week correctly | isCurrentWeek flag | Week marking |
| 5.1.8.3 | returns slots in reverse order (newest first) | Most recent first | Ordering |
| 5.1.8.4 | maps photos to correct week slots | Photo association | Photo mapping |

**Coverage:** State management, loading, saving, deletion, note preservation, error handling

---

## 6. Core Utilities & Services Tests

### 6.1 ImageFormatUtils (`test/core/utils/image_format_utils_test.dart`)

**Purpose:** Validate image format detection and validation utilities.

#### 6.1.1 isFormatSupported Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.1.1.1 | returns true for supported formats | jpg, jpeg, png, webp, bmp, gif | Format support |
| 6.1.1.2 | returns true for formats with dots | .jpg, .png accepted | Dot handling |
| 6.1.1.3 | is case insensitive | JPG, PNG work | Case handling |

#### 6.1.2 isMimeTypeSupported Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.1.2.1 | returns true for supported MIME types | image/jpeg, image/png, etc. | MIME validation |
| 6.1.2.2 | is case insensitive | IMAGE/JPEG works | Case handling |
| 6.1.2.3 | returns false for unsupported MIME types | image/tiff rejected | Rejection |

#### 6.1.3 detectFormatFromFileName Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.1.3.1 | detects format from file name | photo.jpg → jpg | Extension detection |
| 6.1.3.2 | detects format from full path | /path/to/photo.jpg → jpg | Path parsing |
| 6.1.3.3 | returns null for unsupported formats | photo.heic → null | Unsupported handling |

#### 6.1.4 detectFormatFromBytes Group (6 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.1.4.1 | detects JPEG format | FF D8 FF magic number | JPEG detection |
| 6.1.4.2 | detects PNG format | 89 50 4E 47 magic number | PNG detection |
| 6.1.4.3 | detects GIF format | 47 49 46 38 magic number | GIF detection |
| 6.1.4.4 | detects BMP format | 42 4D magic number | BMP detection |
| 6.1.4.5 | detects WebP format | RIFF + WEBP signature | WebP detection |
| 6.1.4.6 | returns null for unrecognized format | Unknown bytes → null | Unknown handling |

#### 6.1.5 validateImageBytes Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.1.5.1 | returns true for valid formats | JPEG, PNG validated | Validation |
| 6.1.5.2 | returns false for invalid format | Invalid bytes rejected | Rejection |

#### 6.1.6 Error Messages Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.1.6.1 | returns generic message for null format | "Unable to detect" | Error message |
| 6.1.6.2 | returns specific message for unsupported | Contains format name | Error message |

#### 6.1.7 Display Helpers Group (1 test)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.1.7.1 | returns formatted list of formats | "JPG, JPEG, PNG..." | Display helper |

**Coverage:** Format detection, magic number validation, MIME types, error messages

---

### 6.2 PhotoFileService (`test/core/services/photo_file_service_test.dart`)

**Purpose:** Integration test for photo file operations with format conversion.

#### 6.2.1 Format Validation & Compression Group (9 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.2.1.1 | accepts JPEG format and compresses | JPEG input → JPEG 85% | JPEG handling |
| 6.2.1.2 | accepts PNG format and converts to JPEG | PNG → JPEG conversion | PNG conversion |
| 6.2.1.3 | accepts BMP format and converts to JPEG | BMP → JPEG conversion | BMP conversion |
| 6.2.1.4 | accepts GIF format and converts to JPEG | GIF → JPEG conversion | GIF conversion |
| 6.2.1.5 | rejects unsupported format | Invalid bytes throw error | Rejection |
| 6.2.1.6 | resizes large images to maxImageWidth | 3000px → 1920px | Resizing |
| 6.2.1.7 | does not resize small images | 800px unchanged | Size preservation |
| 6.2.1.8 | throws ImageTooLargeException | Huge image rejected | Size limits |
| 6.2.1.9 | validates format before decoding | Early validation | Validation order |

#### 6.2.2 File Operations Group (1 test)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 6.2.2.1 | creates directory structure correctly | User/pregnancy isolation | Directory creation |

**Coverage:** Format conversion, validation, resizing, compression, error handling

---

## 7. Integration Tests

### 7.1 Bump Photo Flow (`test/integration/bump_photo/bump_photo_flow_test.dart`)

**Purpose:** End-to-end testing of complete user flows with in-memory database.

| Test # | Test Name | Description | User Flow |
|--------|-----------|-------------|-----------|
| 7.1.1 | should save photo and retrieve it | Save -> Get | Basic flow |
| 7.1.2 | should save note only without photo | Note-only entry | Note-only flow |
| 7.1.3 | should save photo with note | Combined entry | Full entry |
| 7.1.4 | should update note on existing photo | Photo -> Update note | Note update |
| 7.1.5 | should delete photo and preserve note | Delete photo, keep note | Note preservation |
| 7.1.6 | should delete photo without note completely | Delete removes record | Full delete |
| 7.1.7 | should replace photo when saving to same week | Old file deleted | Photo replace |
| 7.1.8 | should handle multiple weeks | Multi-week diary | Multi-entry |
| 7.1.9 | should reject invalid week number (too low) | Week 0 rejected | Validation |
| 7.1.10 | should reject invalid week number (too high) | Week 43 rejected | Validation |
| 7.1.11 | should preserve note when changing photo | Replace photo, keep note | Note preservation |
| 7.1.12 | should clear note when null provided | Note cleared | Note clearing |
| 7.1.13 | should delete all photos for pregnancy | Bulk delete | Cleanup |
| 7.1.14 | should handle empty pregnancy (no photos) | Empty state | Empty handling |
| 7.1.15 | should handle concurrent saves to different weeks | Multi-week parallel | Concurrency |

**Coverage:** Complete user flows, note preservation, file cleanup, validation, edge cases

---

## Business Rules Validated

### Photo Management
- One photo per week per pregnancy (unique constraint)
- Photo files stored in user/pregnancy isolated directory
- Old photo file deleted when replaced
- Invalid weeks (0, 43+, negative) rejected

### Note Management
- Notes can exist without photos (note-only entries)
- Notes preserved when photo deleted (filePath set to null)
- Empty string notes normalized to null
- Notes can be updated independently of photos

### File Cleanup
- Old file deleted before saving new photo for same week
- File deletion failures don't prevent database updates
- Files deleted when photo deleted (but record may remain for note)
- All files deleted when pregnancy deleted

### Data Integrity
- Week slots generated from current gestational week
- Photos sorted by week number ascending
- Database protected by SQLCipher encryption
- File paths isolated by user and pregnancy

---

## Test Environment Setup

### Mocking Strategy
- **MockBumpPhotoRepository:** Used in use case tests (mocktail)
- **MockBumpPhotoDao:** Used in repository tests (mocktail)
- **MockPhotoFileService:** Used in repository tests (mocktail)
- **MockLoggingService:** Used in repository tests (mocktail)
- **In-memory Drift database:** Used in DAO and integration tests (unencrypted)

### Test Fixtures
- **BumpPhotoFakes.bumpPhoto():** Creates fake BumpPhoto entities
- **BumpPhotoFakes.bumpPhotoList(n):** Creates n fake BumpPhoto entities
- **BumpPhotoFakes.forWeek(week):** Creates fake BumpPhoto for specific week
- **BumpPhotoFakes.noteOnly(week):** Creates fake note-only entry (no filePath)

### Dependencies
- `flutter_test`: Core testing framework
- `mocktail`: Mocking library for services
- `drift`: In-memory database support

---

## Test Maintenance Notes

### When Adding New Features
1. Add domain entity tests for new entities/properties
2. Add use case tests for new business logic
3. Add mapper tests if new DTOs introduced
4. Add repository tests for new operations
5. Add DAO tests for new queries
6. Add integration tests for new user flows
7. Update this document with new test cases

### When Modifying Existing Features
1. Update affected unit tests first
2. Verify integration tests still pass
3. Update test plan documentation
4. Check for new edge cases that need coverage

### Code Review Checklist
- [ ] All new code has corresponding tests
- [ ] Test names clearly describe what is being tested
- [ ] Tests are isolated (no interdependencies)
- [ ] Mocks are used appropriately
- [ ] Integration tests cover happy path and error cases
- [ ] All tests have `@Tags(['bump_photo'])`
- [ ] Test plan document is updated

---

## Document Metadata

**Last Updated:** 2025-12-15
**Total Tests:** 187 (includes image format validation & file service tests)
**Test Files:** 15
**Coverage Level:** Comprehensive (Unit + Integration + Core Services)
**Feature Status:** Fully Implemented & Tested (including note-only entries, file cleanup, image format validation)
