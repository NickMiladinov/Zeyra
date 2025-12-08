# Kick Counter Feature - Test Plan

## Overview
This document outlines all existing tests for the Kick Counter feature. The feature allows pregnant users to track baby kicks/movements during pregnancy, with support for session management, pause/resume functionality, and encrypted storage of movement strength data.

---

## Test Coverage Summary

| Test Level | File | Test Groups | Total Tests |
|------------|------|-------------|-------------|
| **Unit - Domain Entities** | `kick_test.dart` | 1 | 6 |
| **Unit - Domain Entities** | `kick_session_test.dart` | 2 | 16 |
| **Unit - Domain Use Cases** | `manage_session_usecase_test.dart` | 10 | 52 |
| **Unit - Domain Exceptions** | `kick_counter_exception_test.dart` | 5 | 19 |
| **Unit - Mappers** | `kick_session_mapper_test.dart` | 1 | 10 |
| **Unit - Repository** | `kick_counter_repository_impl_test.dart` | 13 | 32 |
| **Unit - DAO** | `kick_counter_dao_test.dart` | 4 | 19 |
| **Unit - DAO** | `kick_session_with_kicks_test.dart` | 1 | 5 |
| **Error Handling** | `kick_counter_repository_error_handling_test.dart` | 6 | 24 |
| **Performance** | `kick_counter_performance_test.dart` | 6 | 13 |
| **Integration** | `kick_counter_flow_test.dart` | 1 | 13 |
| **Unit - Logic** | `kick_counter_notifier_test.dart` | 8 | 17 |
| **Unit - Logic** | `kick_history_provider_test.dart` | 5 | 14 |
| **Unit - Logic** | `kick_counter_banner_provider_test.dart` | 4 | 13 |
| **Unit - Logic** | `kick_counter_onboarding_provider_test.dart` | 3 | 7 |
| **Total** | **15 files** | **70 groups** | **256 tests** 🎉 |

---

## Running All Kick Counter Tests

### Quick Run with Test Runners (Recommended)

Use the convenient test runner files in `test/runners/kick_counter/`:

```bash
# Quick tests - fastest (~25 seconds) - 103 tests
flutter test test/runners/kick_counter/quick_test.dart

# Unit tests - comprehensive unit tests (~1-2 minutes) - 228 tests
flutter test test/runners/kick_counter/unit_test.dart

# All tests - everything including integration & performance (~2-3 minutes) - 254 tests
flutter test test/runners/kick_counter/all_test.dart
```

**In your IDE**: Open any of these files and click the ▶️ Run button next to `main()`!

### Run by Tags

All kick counter tests are tagged with `@Tags(['kick_counter'])`:

```bash
# Run all kick counter tests
flutter test --tags kick_counter

# Run with coverage
flutter test --tags kick_counter --coverage

# Run using preset (from dart_test.yaml)
flutter test --preset=kick_counter
```

### Run Specific Test File

```bash
flutter test test/domain/usecases/kick_counter/manage_session_usecase_test.dart
```

---

## 1. Domain Entity Tests

### 1.1 Kick Entity (`test/domain/entities/kick_counter/kick_test.dart`)

**Purpose:** Validate the `Kick` domain entity and `MovementStrength` enum behavior.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.1.1 | should create Kick with all required fields | Creates a Kick with all properties and validates they're set correctly | Entity instantiation |
| 1.1.2 | should serialize MovementStrength enum correctly | Tests weak, moderate, and strong enum values | Enum serialization |
| 1.1.3 | should have correct displayName for each strength | Validates displayName: "Weak", "Moderate", "Strong" | UI display strings |
| 1.1.4 | should have correct name property for each strength | Validates name: "weak", "moderate", "strong" | Enum name property |
| 1.1.5 | should compare kicks correctly with == operator | Tests equality comparison between Kick instances | Equality operator |

**Coverage:** ✅ Entity creation, enum handling, display names, equality

---

### 1.2 KickSession Entity (`test/domain/entities/kick_counter/kick_session_test.dart`)

**Purpose:** Validate the `KickSession` domain entity's computed properties and business logic.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 1.2.1 | should calculate activeDuration correctly when not paused | Active duration = endTime - startTime when no pauses | Active duration calculation |
| 1.2.2 | should calculate activeDuration excluding totalPausedDuration | Active duration excludes accumulated pause time | Pause time exclusion |
| 1.2.3 | should calculate activeDuration excluding current pause when isPaused | For paused sessions, excludes current pause period | Current pause handling |
| 1.2.4 | should return isPaused true when pausedAt is set | `isPaused` getter returns true when `pausedAt` is not null | Pause state detection |
| 1.2.5 | should return isPaused false when pausedAt is null | `isPaused` getter returns false when `pausedAt` is null | Active state detection |
| 1.2.6 | should return kickCount matching kicks list length | `kickCount` returns the number of kicks in the session | Kick counting |
| 1.2.11 | should copyWith update note field | Tests note can be updated via copyWith | Note field in copyWith |
| 1.2.12 | should copyWith preserve note when not specified | Tests note preservation when not updated | Note preservation |
| 1.2.13 | should include note in equality comparison | Tests note affects equality operator | Note in equality |
| 1.2.14 | should include note in hashCode | Tests note affects hashCode | Note in hashCode |
| 1.2.15 | should include note in toString | Tests note appears in string representation | Note in toString |
| 1.2.7 | should calculate averageTime betweenKicks correctly | Calculates average time between consecutive kicks | Average interval calculation |
| 1.2.8 | should return null averageTimeBetweenKicks with less than 2 kicks | Returns null when insufficient kicks for average | Edge case: < 2 kicks |
| 1.2.9 | should copyWith create new instance with updated fields | Creates new instance with specified fields updated | Immutability pattern |

**Coverage:** ✅ Computed properties, pause logic, statistics, immutability

---

## 2. Domain Use Case Tests

### 2.1 ManageSessionUseCase (`test/domain/usecases/kick_counter/manage_session_usecase_test.dart`) 🆕

**Purpose:** Unit test the use case layer with mocked repository to validate business logic and rules.

#### 2.1.1 startSession Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.1.1 | should create new session when no active session exists | Happy path - creates session when none exists | Session creation |
| 2.1.1.2 | should throw sessionAlreadyActive when active session exists | **Concurrent session prevention** - throws exception | Business rule enforcement |
| 2.1.1.3 | should throw with descriptive message for concurrent session | Validates error message guides user to complete/discard | User guidance |

#### 2.1.2 recordKick Group (7 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.2.1 | should add kick and return shouldPromptEnd=false when < 10 kicks | Normal kick recording before prompt threshold | Kick recording |
| 2.1.2.2 | should return shouldPromptEnd=true at exactly 10 kicks | 10th kick triggers prompt | 10-kick prompt logic |
| 2.1.2.3 | should return shouldPromptEnd=false after 10 kicks | Prompt only at 10th, not after | Prompt once only |
| 2.1.2.4 | should throw maxKicksReached when session has 100 kicks | Enforces 100 kick maximum | Max limit enforcement |
| 2.1.2.5 | should throw noActiveSession when session is null | Validates session exists | Session validation |
| 2.1.2.6 | should throw noActiveSession when session ID mismatch | Validates correct session ID | ID validation |
| 2.1.2.7 | should handle all movement strength types | Tests weak, moderate, strong | All enum values |

#### 2.1.3 undoLastKick Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.3.1 | should remove last kick when kicks exist | Happy path undo | Undo functionality |
| 2.1.3.2 | should throw noKicksToUndo when session has no kicks | Cannot undo with no kicks | Edge case validation |
| 2.1.3.3 | should throw noActiveSession when session is null | Session validation | Error handling |
| 2.1.3.4 | should throw noActiveSession when session ID mismatch | ID validation | Error handling |

#### 2.1.4 endSession Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.4.1 | should end session when it has kicks | Happy path - ends session | Session completion |
| 2.1.4.2 | should throw noKicksRecorded when session has zero kicks | Cannot end session with 0 kicks | Minimum kick validation |
| 2.1.4.3 | should include medical guidance in noKicksRecorded message | Error message contains "midwife" guidance | Medical safety |
| 2.1.4.4 | should throw noActiveSession when session is null | Session validation | Error handling |
| 2.1.4.5 | should end session with exactly 1 kick | Minimum valid session | Edge case |

#### 2.1.5 discardSession Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.5.1 | should delete session regardless of state | Discard works in any state | Flexible deletion |
| 2.1.5.2 | should allow discarding session with no kicks | Unlike end, discard allows 0 kicks | Different from end |
| 2.1.5.3 | should not validate active session before discarding | No validation needed for discard | Unconditional delete |

#### 2.1.6 pauseSession Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.6.1 | should pause session when not already paused | Happy path pause | Pause functionality |
| 2.1.6.2 | should be idempotent - do nothing if already paused | Multiple pauses safe | Idempotent operation |
| 2.1.6.3 | should throw noActiveSession when session is null | Session validation | Error handling |
| 2.1.6.4 | should throw noActiveSession when session ID mismatch | ID validation | Error handling |

#### 2.1.7 resumeSession Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.7.1 | should resume session when paused | Happy path resume | Resume functionality |
| 2.1.7.2 | should throw sessionNotPaused when session is not paused | Cannot resume non-paused session | State validation |
| 2.1.7.3 | should throw noActiveSession when session is null | Session validation | Error handling |
| 2.1.7.4 | should throw noActiveSession when session ID mismatch | ID validation | Error handling |

#### 2.1.8 updateSessionNote Group (3 tests) 🆕

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.8.1 | should update note and return updated session | Updates note successfully | Note update |
| 2.1.8.2 | should clear note when null is provided | Clears note with null | Note clearing |
| 2.1.8.3 | should clear note when empty string is provided | Clears note with empty string | Note clearing |

#### 2.1.9 deleteHistoricalSession Group (2 tests) 🆕

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.9.1 | should delete session by calling repository | Deletes session via repository | Session deletion |
| 2.1.9.2 | should complete without error when session does not exist | Handles non-existent sessions | Error resilience |

#### 2.1.10 getSessionHistory Group (5 tests) 🆕

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 2.1.10.1 | should return session history from repository | Returns history list | History retrieval |
| 2.1.10.2 | should return empty list when no history exists | Handles empty history | Empty state |
| 2.1.10.3 | should pass limit parameter to repository | Passes limit correctly | Pagination |
| 2.1.10.4 | should pass before parameter to repository | Passes before date correctly | Pagination |
| 2.1.10.5 | should pass both limit and before parameters | Passes both parameters | Pagination |

**Coverage:** ✅ All use case methods including note management, session deletion, history retrieval, business rules, concurrent session prevention, validation logic

---

## 3. Domain Exception Tests

### 3.1 KickCounterException (`test/domain/exceptions/kick_counter_exception_test.dart`) 🆕

**Purpose:** Validate exception class and all error types.

#### 3.1.1 Exception Creation Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.1.1 | should create exception with message and type | Basic exception creation | Constructor |
| 3.1.1.2 | should implement Exception interface | Extends Dart Exception | Type hierarchy |
| 3.1.1.3 | should have readable toString output | toString includes message and type | Debug output |

#### 3.1.2 Error Types Group (7 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.2.1 | should have noKicksRecorded type | Tests noKicksRecorded error type | Error type |
| 3.1.2.2 | should have maxKicksReached type | Tests maxKicksReached error type | Error type |
| 3.1.2.3 | should have noActiveSession type | Tests noActiveSession error type | Error type |
| 3.1.2.4 | should have sessionAlreadyActive type | Tests sessionAlreadyActive error type | Error type |
| 3.1.2.5 | should have sessionAlreadyPaused type | Tests sessionAlreadyPaused error type | Error type |
| 3.1.2.6 | should have sessionNotPaused type | Tests sessionNotPaused error type | Error type |
| 3.1.2.7 | should have noKicksToUndo type | Tests noKicksToUndo error type | Error type |

#### 3.1.3 Exception Matching Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.3.1 | should match by type in try-catch | Throwable and catchable | Exception handling |
| 3.1.3.2 | should allow catching by specific type | Can catch as KickCounterException | Type catching |
| 3.1.3.3 | should allow pattern matching on error type | Can switch on error type | Pattern matching |

#### 3.1.4 Use Case Scenarios Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.4.1 | should differentiate between concurrent session and no session | Different types for different errors | Type distinction |
| 3.1.4.2 | should differentiate between pause state errors | Paused vs not paused errors | State errors |
| 3.1.4.3 | should provide context for medical guidance errors | Medical advice in error messages | User safety |

#### 3.1.5 Enum Tests Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 3.1.5.1 | should have all 7 error types defined | Enum has exactly 7 types | Complete enum |
| 3.1.5.2 | should have correct enum names | Names match enum values | Enum naming |
| 3.1.5.3 | should support equality comparison | Enum equality works | Comparison |

**Coverage:** ✅ All 7 exception types, exception behavior, error messages, pattern matching

---

## 4. Data Layer Tests

### 4.1 KickSessionMapper (`test/data/mappers/kick_session_mapper_test.dart`)

**Purpose:** Validate mapping between database DTOs and domain entities.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.1.1 | should map KickSessionDto to KickSession domain entity | Maps full session DTO to domain entity | DTO → Domain mapping |
| 4.1.2 | should convert totalPausedMillis to Duration correctly | Converts milliseconds to Duration (3m 30s test) | Time conversion |
| 4.1.3 | should map Kick with decrypted strength | Maps KickDto to Kick domain entity with decryption | Kick DTO → Kick mapping |
| 4.1.4 | should handle null pausedAt field | Correctly handles null pausedAt in DTO | Null handling: pausedAt |
| 4.1.5 | should handle null endTime field | Correctly handles null endTime for active sessions | Null handling: endTime |
| 4.1.6 | should parse weak strength correctly | Parses "weak" string to MovementStrength.weak | Strength parsing: weak |
| 4.1.7 | should parse moderate strength correctly | Parses "moderate" string to MovementStrength.moderate | Strength parsing: moderate |
| 4.1.8 | should convert MovementStrength to string correctly | Converts enum to string for all values | Enum → String conversion |

**Coverage:** ✅ DTO mapping, time conversions, null handling, strength parsing

---

### 4.2 KickCounterRepositoryImpl (`test/data/repositories/kick_counter_repository_impl_test.dart`)

**Purpose:** Validate repository implementation with Drift database and encryption service.

#### 4.2.1 createSession Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.1.1 | should create session with generated UUID | Session ID is a valid UUID v4 (36 chars) | UUID generation |
| 4.2.1.2 | should set startTime to current DateTime | startTime is set to current time (within tolerance) | Timestamp accuracy |
| 4.2.1.3 | should initialize session with isActive true | New sessions have `isActive = true` | Active state initialization |
| 4.2.1.4 | should initialize pause fields to defaults | pausedAt=null, totalPausedDuration=0, pauseCount=0, kicks=empty | Default values |

#### 4.2.2 getActiveSession Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.2.1 | should return active session when exists | Returns the active session if one exists | Active session retrieval |
| 4.2.2.2 | should return null when no active session | Returns null when no active sessions in DB | No active session case |
| 4.2.2.3 | should load kicks with session | Loads session with all associated kicks | Kick loading |

#### 4.2.3 addKick Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.3.1 | should encrypt perceived strength before saving | Calls encryption service with strength string | Encryption integration |
| 4.2.3.2 | should set correct timestamp | Kick timestamp is set to current time | Timestamp accuracy |
| 4.2.3.3 | should increment sequenceNumber | Sequence numbers increment: 1, 2, 3... | Sequence numbering |

#### 4.2.4 removeLastKick Group (1 test)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.4.1 | should delete kick with highest sequenceNumber | Removes the most recent kick | Last kick deletion |

#### 4.2.5 pauseSession Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.5.1 | should set pausedAt to current DateTime | Sets pausedAt timestamp when pausing | Pause timestamp |
| 4.2.5.2 | should not modify totalPausedDuration or pauseCount | Only sets pausedAt, doesn't update counters | Pause state isolation |

#### 4.2.6 resumeSession Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.6.1 | should calculate elapsed pause duration correctly | Calculates time between pause and resume | Duration calculation |
| 4.2.6.2 | should add elapsed duration to totalPausedDuration | Accumulates pause time across multiple cycles | Cumulative pause time |
| 4.2.6.3 | should increment pauseCount by 1 | Increments counter on each resume | Pause counter |
| 4.2.6.4 | should clear pausedAt to null | Clears pausedAt when resuming | Pause state cleanup |

#### 4.2.7 endSession Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.7.1 | should set endTime to current DateTime | Sets endTime when ending session | End timestamp |
| 4.2.7.2 | should set isActive to false | Marks session as inactive | Active state update |

#### 4.2.8 deleteSession Group (1 test)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.8.1 | should cascade delete kicks | Deletes session and all associated kicks | Cascade deletion |

#### 4.2.9 getSessionHistory Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.2.9.1 | should return sessions ordered by startTime desc | Returns sessions with most recent first | Sorting order |
| 4.2.9.2 | should respect limit parameter | Returns only requested number of sessions | Pagination |

**Coverage:** ✅ CRUD operations, encryption, timestamps, pause logic, history retrieval

---

### 4.3 KickCounterDao (`test/data/local/daos/kick_counter_dao_test.dart`) 🆕

**Purpose:** Test DAO edge cases, pagination, and data integrity.

#### 4.3.1 Pagination Tests Group (4 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.1.1 | should filter sessions by before timestamp | `before` parameter filters correctly | Time-based filtering |
| 4.3.1.2 | should combine limit and before parameters | Both parameters work together | Combined filtering |
| 4.3.1.3 | should return empty list when all sessions are after before date | Empty result handling | Edge case |
| 4.3.1.4 | should sort by startTime descending (most recent first) | Default sort order | Sorting |

#### 4.3.2 Edge Cases Group (8 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.2.1 | should handle empty kicks list for session | Session with no kicks | Empty collection |
| 4.3.2.2 | should return null for non-existent session | Non-existent ID handling | Null handling |
| 4.3.2.3 | should return null active session when none exists | No active session case | Null handling |
| 4.3.2.4 | should return 0 kick count for session with no kicks | Empty count | Edge case |
| 4.3.2.5 | should return 0 kick count for non-existent session | Non-existent ID returns 0 | Default value |
| 4.3.2.6 | should return 0 when deleting last kick from session with no kicks | Delete from empty | No-op case |
| 4.3.2.7 | should handle session with null endTime and pausedAt | Null optional fields | Null handling |
| 4.3.2.8 | should handle multiple active sessions (defensive check) | Shouldn't happen but handles it | Defensive coding |

#### 4.3.3 Data Integrity Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.3.3.1 | should cascade delete kicks when session is deleted | Foreign key cascade | Referential integrity |
| 4.3.3.2 | should maintain kick sequence numbers correctly | Ordered by sequence | Sorting |
| 4.3.3.3 | should update session fields without affecting others | Partial updates | Update isolation |
| 4.3.3.4 | should only return inactive sessions in history | History excludes active | Filtering |

**Coverage:** ✅ Pagination, edge cases, data integrity, foreign keys, sorting

---

### 4.4 KickSessionWithKicks (`test/data/local/daos/kick_session_with_kicks_test.dart`) 🆕

**Purpose:** Validate equality logic for the composite DTO to ensure data integrity in collections.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 4.4.1 | should support value equality | Equal objects have equal hash codes | Value equality contract |
| 4.4.2 | should differ when session differs | Different sessions are not equal | Identity logic |
| 4.4.3 | should differ when kicks list content differs | Different kicks list = different object | Deep equality |
| 4.4.4 | should differ when kicks list order differs | Order matters for exact equality | List equality |
| 4.4.5 | should have correct toString output | Debug string contains relevant info | Debugging |

**Coverage:** ✅ Value equality, hash code contract, deep list comparison

---

## 5. Error Handling & Propagation Tests

### 5.1 Repository Error Handling (`test/data/repositories/kick_counter_repository_error_handling_test.dart`) 🆕

**Purpose:** Test error scenarios, encryption failures, invalid IDs, concurrent operations, data corruption.

#### 5.1.1 Encryption Failures Group (5 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.1.1 | should propagate encryption error when addKick fails to encrypt | Encryption error propagates | Error propagation |
| 5.1.1.2 | should propagate encryption error with specific message | Error message preserved | Error details |
| 5.1.1.3 | should propagate decryption error when getActiveSession fails | Decryption error propagates | Error propagation |
| 5.1.1.4 | should propagate decryption error in getSessionHistory | Batch decryption error | Error propagation |
| 5.1.1.5 | should handle partial decryption failures in session with multiple kicks | Mid-batch failure handling | Partial failure |

#### 5.1.2 Invalid Session IDs Group (7 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.2.1 | should handle non-existent session ID in endSession gracefully | No crash on invalid ID | Graceful handling |
| 5.1.2.2 | should handle non-existent session ID in deleteSession gracefully | No crash on invalid ID | Graceful handling |
| 5.1.2.3 | should handle non-existent session ID in pauseSession gracefully | No crash on invalid ID | Graceful handling |
| 5.1.2.4 | should handle non-existent session ID in resumeSession gracefully | No crash on invalid ID | Graceful handling |
| 5.1.2.5 | should handle empty string session ID | Empty ID handling | Edge case |
| 5.1.2.6 | should handle very long session ID | 1000 character ID | Edge case |
| 5.1.2.7 | should handle special characters in session ID | Special char handling | Input sanitization |

#### 5.1.3 Concurrent Operations Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.3.1 | should handle rapid session creation attempts | 10 concurrent creates | Concurrency |
| 5.1.3.2 | should handle concurrent kick additions to same session | 5 concurrent kicks | Concurrency |
| 5.1.3.3 | should handle concurrent pause/resume operations | Rapid pause/resume | Race conditions |

#### 5.1.4 Data Corruption Scenarios Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.4.1 | should handle session with corrupted encrypted data | Invalid decrypted strength | Corruption detection |
| 5.1.4.2 | should handle negative timestamps gracefully | Negative milliseconds | Corruption handling |
| 5.1.4.3 | should handle negative pause duration | Negative duration | Corruption handling |

#### 5.1.5 Timestamp Edge Cases Group (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.5.1 | should handle sessions at epoch 0 | Timestamp = 0 | Edge case |
| 5.1.5.2 | should handle very far future timestamps | Year 3000 | Edge case |
| 5.1.5.3 | should handle pause/resume with same timestamp | 0 duration pause | Edge case |

#### 5.1.6 Batch Operation Errors Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.6.1 | should handle error when fetching large history | Error mid-batch | Batch error handling |
| 5.1.6.2 | should handle database lock during batch operations | Lock resilience | Concurrency |

#### 5.1.7 Resource Handling Group (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 5.1.7.1 | should handle loading session with no kicks efficiently | 100 repeated loads | Memory efficiency |
| 5.1.7.2 | should handle repeated history queries | 50 repeated queries | Resource handling |

**Coverage:** ✅ Encryption failures, invalid IDs, concurrency, data corruption, edge cases, resource management

---

## 6. Performance Tests

### 6.1 Performance Tests (`test/performance/kick_counter_performance_test.dart`) 🆕

**Purpose:** Stress test with large datasets - 500 sessions, 100 kicks per session, pagination efficiency.

#### 6.1.1 500 Session Tests Group (4 tests)

| Test # | Test Name | Description | Performance Target |
|--------|-----------|-------------|-------------------|
| 6.1.1.1 | should create 500 sessions efficiently | Create 500 sessions with 1 kick each | < 30 seconds |
| 6.1.1.2 | should retrieve 500 sessions efficiently | Retrieve all 500 sessions | < 5 seconds |
| 6.1.1.3 | should paginate through 500 sessions efficiently | Paginate in batches of 50 | < 10 seconds |
| 6.1.1.4 | should handle deletion of 500 sessions efficiently | Delete all 500 sessions | < 15 seconds |

#### 6.1.2 100 Kicks Per Session Tests Group (4 tests)

| Test # | Test Name | Description | Performance Target |
|--------|-----------|-------------|-------------------|
| 6.1.2.1 | should add 100 kicks to session efficiently | Add 100 kicks sequentially | < 5 seconds |
| 6.1.2.2 | should retrieve session with 100 kicks efficiently | Retrieve 100-kick session 10 times | < 3 seconds |
| 6.1.2.3 | should calculate statistics on 100-kick session efficiently | Calculate stats 50 times | < 5 seconds |
| 6.1.2.4 | should handle undo operations on 100-kick session efficiently | Undo 50 kicks | < 3 seconds |

#### 6.1.3 Combined Stress Tests Group (3 tests)

| Test # | Test Name | Description | Performance Target |
|--------|-----------|-------------|-------------------|
| 6.1.3.1 | should handle 50 sessions with 50 kicks each efficiently | Total 2500 operations | < 20 seconds |
| 6.1.3.2 | should handle rapid pause/resume on 100-kick session | 100 kicks with 9 pause cycles | < 10 seconds |
| 6.1.3.3 | should handle querying history with varying limits | Multiple queries with different limits | < 3 seconds |

#### 6.1.4 Encryption Performance Group (1 test)

| Test # | Test Name | Description | Performance Target |
|--------|-----------|-------------|-------------------|
| 6.1.4.1 | should handle encryption/decryption of 1000 kicks efficiently | 10 sessions × 100 kicks | < 10 seconds |

#### 6.1.5 Memory Efficiency Group (2 tests)

| Test # | Test Name | Description | Performance Target |
|--------|-----------|-------------|-------------------|
| 6.1.5.1 | should handle repeated session loads without memory leak | Load session 500 times | < 15 seconds |
| 6.1.5.2 | should handle history queries without accumulating memory | Query history 100 times | < 20 seconds |

**Coverage:** ✅ Large dataset handling, performance benchmarks, memory efficiency, encryption at scale

---

## 7. Integration Tests

### 7.1 Kick Counter Full Flow (`test/integration/kick_counter/kick_counter_flow_test.dart`)

**Purpose:** End-to-end testing of complete user flows with real EncryptionService and in-memory database.

| Test # | Test Name | Description | User Flow |
|--------|-----------|-------------|-----------|
| 7.1.1 | should complete full session flow: create → kicks → pause → resume → end | Complete happy path: create, add 5 kicks, pause, wait, resume, add 5 more kicks, end | Full session lifecycle |
| 7.1.2 | should discard session and remove all data | Create session, add kicks, discard, verify complete removal | Discard flow |
| 7.1.3 | should prevent ending session with 0 kicks | Try to end session without kicks → throws KickCounterException | Validation: min kicks |
| 7.1.4 | should enforce max 100 kicks per session | Add 100 kicks, try adding 101st → throws KickCounterException | Validation: max kicks |
| 7.1.5 | should handle multiple pause/resume cycles correctly | 3 pause/resume cycles, verify pause count and accumulated duration | Multiple pause cycles |
| 7.1.6 | should handle spam pause button (idempotent pause) | Pause 5 times in a row, verify pauseCount still 0 (no resume) | Idempotent pause |
| 7.1.7 | should calculate activeDuration excluding pauses | Wait 200ms, pause, wait 500ms, resume, end → verify activeDuration ≈ 200ms | Active duration accuracy |
| 7.1.8 | should encrypt kick strength in database and decrypt on retrieval | Add kick, verify DB has encrypted value, verify repository returns decrypted | Encryption end-to-end |
| 7.1.9 | should handle undo last kick correctly | Add 3 kicks, undo twice, verify correct kicks remain | Undo functionality |
| 7.1.10 | should prompt at 10th kick | Add 9 kicks (shouldPromptEnd=false), add 10th (shouldPromptEnd=true), add 11th (shouldPromptEnd=false) | 10-kick prompt logic |

**Coverage:** ✅ Complete user flows, business rules, encryption integration, edge cases

---

## 8. Logic / State Management Tests 🆕

### 8.1 KickCounterNotifier (`test/features/kick_counter/logic/kick_counter_notifier_test.dart`)

**Purpose:** Unit test the Riverpod Notifier for the active session screen.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.1.1 | initial state is correct | Validates start state (null session, loading=false) | Initial state |
| 8.1.2 | starts session successfully | Validates state update on start | Session start |
| 8.1.3 | handles sessionAlreadyActive | Restores existing session if active error occurs | Resume logic |
| 8.1.4 | handles generic error | Sets error state on failure | Error handling |
| 8.1.5 | records kick successfully | Adds kick to local state list | Optimistic updates |
| 8.1.6 | sets shouldPromptEnd | Sets flag when use case returns true | Prompt logic |
| 8.1.7 | pauses session updates state | Sets pausedAt | Pause UI |
| 8.1.8 | resumes session clears pausedAt | Clears pausedAt | Resume UI |
| 8.1.9 | ends session and resets state | Clears session from state | End flow |
| 8.1.10 | updates note before ending session when note is provided | Calls updateSessionNote before ending | Note update |
| 8.1.11 | skips note update when note is null | Only calls endSession | Note handling |
| 8.1.12 | skips note update when note is empty string | Only calls endSession | Note handling |
| 8.1.13 | removes last kick when kicks exist | Updates state with kick removed | Undo functionality |
| 8.1.14 | handles error when undo fails | Sets error state | Undo error handling |
| 8.1.15 | deletes session and resets state on discard | Clears all session state | Discard flow |
| 8.1.16 | handles generic errors gracefully on discard | No crash on error | Error resilience |
| 8.1.17 | auto-pauses session when restoring from app close | Prevents counting time while app closed | App lifecycle |

### 8.2 KickHistoryNotifier (`test/features/kick_counter/logic/kick_history_provider_test.dart`)

**Purpose:** Unit test the Riverpod Notifier for the history screen.

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.2.1 | loads history successfully | Loads list from repository | Data loading |
| 8.2.2 | handles error on load | Sets error message | Error handling |
| 8.2.3 | calculates typical range correctly | Computes average duration to 10 kicks | Business logic |

### 8.3 KickCounterBannerNotifier (`test/features/kick_counter/logic/kick_counter_banner_provider_test.dart`) 🆕

**Purpose:** Unit test the banner visibility provider for floating kick counter banner.

#### 8.3.1 show() Tests (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.3.1.1 | should show banner when active session exists | Banner shown if session active | Show logic |
| 8.3.1.2 | should not show banner when no active session exists | Banner hidden if no session | Show guard |
| 8.3.1.3 | should set _isActiveScreenVisible to false | Internal flag updated | State management |

#### 8.3.2 hide() Tests (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.3.2.1 | should hide banner | Banner state set to false | Hide logic |
| 8.3.2.2 | should set _isActiveScreenVisible to true | Internal flag updated | State management |

#### 8.3.3 shouldShow Getter Tests (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.3.3.1 | should return true when banner visible and session exists | Double-check logic | Getter logic |
| 8.3.3.2 | should return false when banner hidden even if session exists | Hidden overrides | Getter guard |
| 8.3.3.3 | should return false when banner visible but no session | Session check | Getter guard |

#### 8.3.4 Session State Listener Tests (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.3.4.1 | should auto-hide banner when session ends | Listener hides on null session | Auto-hide |
| 8.3.4.2 | should auto-show banner when session restored and not on active screen | Listener shows on restore | Auto-show |
| 8.3.4.3 | should not auto-show banner when session restored but on active screen | Respects screen visibility | Conditional show |

#### 8.3.5 shouldShowKickCounterBannerProvider Tests (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.3.5.1 | should return true when banner visible and session exists | Combined provider logic | Convenience provider |
| 8.3.5.2 | should return false when banner visible but no session | Session check | Convenience provider |
| 8.3.5.3 | should return false when session exists but banner hidden | Banner check | Convenience provider |

**Coverage:** ✅ Banner visibility, auto-show/hide, session lifecycle, convenience provider

### 8.4 KickCounterOnboardingNotifier (`test/features/kick_counter/logic/kick_counter_onboarding_provider_test.dart`) 🆕

**Purpose:** Unit test the onboarding state provider using SharedPreferences.

#### 8.4.1 Initial State Tests (3 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.4.1.1 | should start as null before loading | Initial state before async load | State initialization |
| 8.4.1.2 | should load false when key not set | Default value for new users | Default loading |
| 8.4.1.3 | should load saved value when exists | Persisted value restored | Persistence loading |

#### 8.4.2 setHasStarted() Tests (2 tests)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.4.2.1 | should persist true to SharedPreferences | Value saved to storage | Persistence |
| 8.4.2.2 | should update state to true | State updated | State management |
| 8.4.2.3 | should transition state from null -> false -> true | Full lifecycle | State transitions |

#### 8.4.3 Persistence Tests (1 test)

| Test # | Test Name | Description | Validates |
|--------|-----------|-------------|-----------|
| 8.4.3.1 | should persist across notifier instances | Value survives recreation | Cross-instance persistence |

**Coverage:** ✅ SharedPreferences integration, state loading, persistence, lifecycle transitions

---

## Test Environment Setup

### Mocking Strategy
- **MockEncryptionService:** Used in repository unit tests (mocktail)
- **MockKickCounterRepository:** Used in use case tests (mocktail)
- **MockFlutterSecureStorage:** Used in integration/performance tests to mock secure storage
- **In-memory Drift database:** Used in repository, integration, and performance tests
- **Real EncryptionService:** Used in integration and performance tests for encryption validation

### Test Fixtures
- **FakeKick.simple():** Creates fake Kick entities with default or custom values
- **FakeKick.batch(n):** Creates n fake Kick entities
- **FakeKickSession.simple():** Creates fake KickSession entities with default or custom values

### Dependencies
- `flutter_test`: Core testing framework
- `mocktail`: Mocking library for services
- `drift`: In-memory database support
- `flutter_secure_storage`: Secure storage (mocked in tests)

---

## Business Rules Validated

### Session Management
- ✅ Only one active session at a time (**concurrent session prevention**)
- ✅ Sessions must have at least 1 kick to end
- ✅ Maximum 100 kicks per session
- ✅ Sessions can be discarded at any time (no validation)
- ✅ Prompt user at 10th kick

### Pause/Resume Logic
- ✅ Pause is idempotent (multiple pauses don't cause issues)
- ✅ Resume calculates elapsed pause duration
- ✅ Pause count only increments on resume
- ✅ Active duration excludes all pause time
- ✅ Can pause and resume multiple times

### Data Security
- ✅ Perceived strength is encrypted in database
- ✅ Strength is decrypted when retrieved
- ✅ Encryption service is called for all kick operations
- ✅ Encryption failures propagate correctly

### Time Tracking
- ✅ Millisecond precision for timestamps
- ✅ Active duration calculation excludes pauses
- ✅ Average time between kicks (when ≥2 kicks)
- ✅ Current pause time excluded from active duration

### Error Handling
- ✅ All 7 exception types tested
- ✅ Graceful handling of invalid/null IDs
- ✅ Encryption/decryption error propagation
- ✅ Data corruption resilience
- ✅ Concurrent operation handling

---


## Running Tests by Category

### Using Test Runners (Easiest)

```bash
# Run quick tests (~88 tests, ~20 seconds)
flutter test test/runners/kick_counter/quick_tests.dart

# Run unit tests (~160 tests, ~1-2 minutes)
flutter test test/runners/kick_counter/unit_tests.dart

# Run all tests (~173 tests, ~2-3 minutes)
flutter test test/runners/kick_counter/all_tests.dart
```

### Using Tags and Paths

```bash
# Run all kick counter tests
flutter test --tags kick_counter

# Run with coverage
flutter test --tags kick_counter --coverage
```

---

## Test Maintenance Notes

### When Adding New Features
1. **Add domain entity tests** for new entities/computed properties
2. **Add use case tests** for new business logic
3. **Add mapper tests** if new DTOs are introduced
4. **Add repository tests** for new CRUD operations
5. **Add DAO tests** for complex queries
6. **Add error handling tests** for new error scenarios
7. **Add integration tests** for new user flows
8. **Add performance tests** if dealing with large data
9. Update this document with new test cases

### When Modifying Existing Features
1. Update affected unit tests first
2. Verify integration tests still pass
3. Check performance tests if data structures changed
4. Update test plan documentation
5. Check for new edge cases that need coverage

### Code Review Checklist
- [ ] All new code has corresponding tests
- [ ] Test names clearly describe what is being tested
- [ ] Tests are isolated (no interdependencies)
- [ ] Mocks are used appropriately
- [ ] Integration tests cover happy path and error cases
- [ ] Performance tests have reasonable thresholds
- [ ] All tests have `@Tags(['kick_counter'])`
- [ ] Test plan document is updated

---

---

## Recent Updates

### 2025-12-01: Added Tests for Banner & Onboarding Providers 🆕

**New Test Coverage (+21 tests):**
- ✅ Logic Provider: 13 new tests for `KickCounterBannerNotifier` (banner visibility management)
- ✅ Logic Provider: 7 new tests for `KickCounterOnboardingNotifier` (SharedPreferences persistence)
- ✅ Logic Provider: 5 additional tests for `KickCounterNotifier` (discard, undo, auto-pause)

**Test Files Added:**
- `test/features/kick_counter/logic/kick_counter_banner_provider_test.dart`
- `test/features/kick_counter/logic/kick_counter_onboarding_provider_test.dart`

**Test Files Updated:**
- Added `@Tags(['kick_counter'])` to `kick_counter_notifier_test.dart`
- Added missing tests for `undoLastKick()`, `discardSession()`, and `checkActiveSession()`

**Documentation Updated:**
- Updated test plan with new provider test sections
- Updated all test runners with new imports and counts
- Updated test count summary: 235 → 256 tests

### 2025-11-26: Added Tests for Note-Taking & Session Deletion

**New Test Coverage (+47 tests):**
- ✅ Domain Entity: 5 new tests for note field in KickSession
- ✅ Domain Use Cases: 10 new tests (updateSessionNote, deleteHistoricalSession, getSessionHistory)
- ✅ Data DAO: 4 new tests (getSessionById with note support)
- ✅ Data Repository: 12 new tests (getSession, updateSessionNote with encryption, note in history)
- ✅ State Provider: 11 new tests (deleteSession, updateSessionNote, comprehensive state management)

**Test Helpers Updated:**
- Updated all `FakeKickSession` factory methods to support optional `note` parameter
- Added new `withNote()` factory method for creating sessions with notes

**Documentation Added:**
- Created `kick_counter_notes_test_summary.md` with detailed test breakdown
- Updated all test runners with new test counts
- Updated this test plan with new test groups

For detailed information about the new tests, see: `test/plans/kick_counter_notes_test_summary.md`

---

## Document Metadata

**Last Updated:** 2025-12-01  
**Total Tests:** 256 🎉 (+21 from banner/onboarding providers)  
**Test Files:** 15  
**Coverage Level:** Comprehensive (Unit + Integration + Performance + Error Handling + Logic + Notes + UI State)  
**Feature Status:** ✅ Fully Implemented & Tested (including notes, deletion, banner, onboarding)
