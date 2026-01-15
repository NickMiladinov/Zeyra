# Contraction Timer Test Plan

## Feature Overview
The contraction timer tracks labor contractions with start/stop timing, intensity tracking, and 5-1-1 rule evaluation for determining when to seek medical attention.

## Test Coverage Goals
- Domain Layer: >90% coverage
- Data Layer: >85% coverage
- Integration: Key user flows

---

## 1. Domain Entity Tests

### 1.1 ContractionIntensity Enum
**File**: `test/domain/entities/contraction_timer/contraction_intensity_test.dart`

| Test Case | Description |
|-----------|-------------|
| `should have correct display names for all intensities` | Verify displayName for mild, moderate, strong |
| `should have exactly 3 intensity values` | Ensure enum completeness |

### 1.2 Contraction Entity
**File**: `test/domain/entities/contraction_timer/contraction_test.dart`

| Test Case | Description |
|-----------|-------------|
| `should create valid contraction with all fields` | Test complete constructor |
| `should calculate duration correctly from start and end time` | Verify duration getter |
| `should return null duration when endTime is null` | Test active contraction |
| `should identify active contraction when endTime is null` | Test isActive getter |
| `should identify completed contraction when endTime is set` | Test isActive getter |
| `should support copyWith for all fields` | Test immutability pattern |
| `should maintain equality based on id` | Test equality operator |
| `should generate correct hashCode` | Test hashCode consistency |

### 1.3 ContractionSession Entity
**File**: `test/domain/entities/contraction_timer/contraction_session_test.dart`

| Test Case | Description |
|-----------|-------------|
| `should create valid session with required fields` | Test basic constructor |
| `should calculate contractionCount correctly` | Test getter with 0, 1, multiple contractions |
| `should calculate totalDuration for active session` | Test current time - start time |
| `should calculate totalDuration for ended session` | Test end time - start time |
| `should calculate totalContractionTime correctly` | Test sum of completed contraction durations |
| `should return activeContraction when one exists` | Test getter |
| `should return null activeContraction when none exists` | Test getter |
| `should return lastCompletedContraction correctly` | Test new getter |
| `should return null lastCompletedContraction when none exist` | Test edge case |
| `should calculate averageFrequency correctly` | Test start-to-start calculation |
| `should return null averageFrequency with less than 2 contractions` | Test edge case |
| `should calculate averageDuration correctly` | Test completed contractions only |
| `should return null averageDuration when no completed contractions` | Test edge case |
| `should calculate longestContraction correctly` | Test max duration |
| `should return null longestContraction when no completed contractions` | Test edge case |
| `should calculate closestFrequency correctly` | Test minimum frequency |
| `should return null closestFrequency with less than 2 contractions` | Test edge case |
| `should identify achieved511Alert when all criteria met` | Test convenience getter |
| `should not identify achieved511Alert when any criterion missing` | Test convenience getter |
| `should support copyWith for all fields` | Test immutability |
| `should maintain equality based on id` | Test equality |

### 1.4 Rule511Status Entity
**File**: `test/domain/entities/contraction_timer/rule_511_status_test.dart`

| Test Case | Description |
|-----------|-------------|
| `should create valid status with all fields` | Test constructor |
| `should identify alert when all criteria met and not reset` | Test isAlertActive |
| `should not show alert when any criterion not met` | Test isAlertActive |
| `should not show alert when any reset flag is true` | Test reset logic |
| `should support copyWith for all fields` | Test immutability |

### 1.5 ContractionTimerConstants
**File**: `test/domain/entities/contraction_timer/contraction_timer_constants_test.dart`

| Test Case | Description |
|-----------|-------------|
| `should have correct duration threshold` | Verify 45 seconds |
| `should have correct frequency threshold` | Verify 6 minutes |
| `should have correct weak duration threshold` | Verify 30 seconds |
| `should have correct validity percentage` | Verify 80% |
| `should have correct rolling window duration` | Verify 60 minutes |
| `should have correct minimum contractions in window` | Verify 6 contractions |
| `should have correct time gap reset threshold` | Verify 20 minutes |
| `should have correct weak contractions reset count` | Verify 3 contractions |

---

## 2. Domain Exception Tests

### 2.1 ContractionTimerException
**File**: `test/domain/exceptions/contraction_timer_exception_test.dart`

| Test Case | Description |
|-----------|-------------|
| `should create exception with message and type` | Test constructor |
| `should have correct error messages for each type` | Test all error types |
| `should support toString with type information` | Test string representation |
| `should maintain equality based on message and type` | Test equality |

---

## 3. Domain Use Case Tests

### 3.1 ManageContractionSessionUseCase
**File**: `test/domain/usecases/contraction_timer/manage_contraction_session_usecase_test.dart`

| Test Case | Description |
|-----------|-------------|
| **startSession** |
| `should create new session successfully` | Test happy path |
| `should throw when active session already exists` | Test validation |
| **startContraction** |
| `should start contraction in active session` | Test happy path |
| `should throw when no active session` | Test validation |
| `should throw when contraction already active` | Test validation |
| `should use moderate intensity as default` | Test default parameter |
| **stopContraction** |
| `should stop active contraction` | Test happy path |
| `should throw when contraction not found` | Test validation |
| `should throw when contraction already stopped` | Test validation |
| `should refresh 5-1-1 rule after stopping` | Test integration |
| **editContraction** |
| `should update contraction start time` | Test field update |
| `should update contraction duration` | Test field update |
| `should update contraction intensity` | Test field update |
| `should update multiple fields at once` | Test combined update |
| `should recalculate 5-1-1 rule after edit` | Test integration |
| `should throw when contraction not found` | Test validation |
| `should throw when edit creates invalid data` | Test validation |
| **deleteContraction** |
| `should delete contraction successfully` | Test happy path |
| `should recalculate 5-1-1 rule after delete` | Test integration |
| `should throw when contraction not found` | Test validation |
| **endSession** |
| `should end active session` | Test happy path |
| `should stop active contraction when ending session` | Test cleanup |
| `should throw when no active session` | Test validation |
| **updateSessionNote** |
| `should update session note` | Test happy path |
| `should clear note with null` | Test null handling |

### 3.2 Calculate511RuleUseCase
**File**: `test/domain/usecases/contraction_timer/calculate_511_rule_usecase_test.dart`

| Test Case | Description |
|-----------|-------------|
| **Duration Check** |
| `should achieve duration when contractions >= 45 seconds` | Test threshold |
| `should not achieve duration when contractions < 45 seconds` | Test threshold |
| `should handle mix of long and short contractions` | Test 80% rule |
| **Frequency Check** |
| `should achieve frequency when contractions <= 6 minutes apart` | Test threshold |
| `should not achieve frequency when contractions > 6 minutes apart` | Test threshold |
| `should handle frequency in 2-6 minute range` | Test valid range |
| **Consistency Check** |
| `should achieve consistency with 80% valid contractions in 60 min` | Test rolling window |
| `should require minimum 6 contractions` | Test minimum threshold |
| `should not achieve consistency with < 80% valid contractions` | Test 80% rule |
| `should use rolling 60-minute window` | Test time window |
| **Reset Conditions** |
| `should reset duration when last 3 contractions < 30 seconds` | Test weak contraction reset |
| `should reset frequency when gap > 20 minutes` | Test time gap reset |
| `should reset consistency when pattern breaks` | Test consistency reset |
| `should handle independent reset conditions` | Test separate tracking |
| **Progress Calculations (Achievement-Based)** |
| **Note:** Progress circles lock at 100% when achieved. Reset unlocks but shows current progress (not 0%) |
| `should clamp all progress values between 0 and 1` | Test bounds checking |
| `should calculate durationProgress based on last contraction` | Achievement: validDurationCount > 0 AND not reset → 100% (locked) |
| `should show current durationProgress even when reset triggers` | Reset unlocks achievement but shows actual progress (25s/45s ≈ 56%) |
| `should show partial durationProgress when approaching but not achieved` | No valid yet, no reset → show partial progress |
| `should calculate frequencyProgress at 0% for 30+ min intervals` | No valid intervals yet → show 0% (30 min = 0% scale) |
| `should calculate frequencyProgress at 100% for 6 min intervals` | Achievement: validFrequencyCount > 0 → 100% (locked) |
| `should calculate frequencyProgress at ~50% for 18 min intervals` | No valid yet → show partial progress (18 min = 50% scale) |
| `should calculate frequencyProgress at ~83% for 10 min intervals` | No valid yet → show partial progress (10 min = 83% scale) |
| `should calculate frequencyProgress using inverse scale based on last interval` | Test last interval calculation (not average) |
| **evaluateAchievedCriteria (Reuses calculate() logic)** |
| `should return all false for empty session` | Test empty session handling |
| `should achieve duration when at least 1 valid contraction and no reset` | At least 1 contraction ≥45s + no reset |
| `should not achieve duration when no valid contractions` | No valid contractions → false |
| `should not achieve duration when reset (3 consecutive short)` | Duration reset blocks achievement |
| `should achieve frequency when at least 1 valid interval and no reset` | At least 1 interval ≤6min + no reset |
| `should not achieve frequency when no valid intervals` | No valid intervals → false |
| `should achieve consistency when alertActive is true` | Matches alertActive from calculate() |
| `should not achieve consistency when alertActive is false` | Matches alertActive from calculate() |
| `should calculate consistencyProgress even with < 6 contractions` | Shows progress even with < 6 contractions |
| `should calculate consistencyProgress proportional to validity` | No achievement yet: 33% validity → ~41% progress |
| `should calculate 100% consistencyProgress at 80% validity` | Achievement: 5+ valid contractions → 100% (locked, stays locked) |
| `should cap consistencyProgress at 100% for > 80% validity` | Achievement: 5+ valid contractions → 100% (locked, stays locked) |
| **Integration** |
| `should return complete Rule511Status` | Test full status |
| `should track achievement timestamps` | Test timestamp recording |
| `should calculate progress metrics correctly` | Test all metrics |
| `should not show 100% consistency when 6+ valid but < 80% validity (Bug Fix)` | Regression: 8 contractions with 6 valid (75%) should NOT show 100% progress |

---

## 4. Data Mapper Tests

### 4.1 ContractionMapper
**File**: `test/data/mappers/contraction_mapper_test.dart`

| Test Case | Description |
|-----------|-------------|
| `should map DTO to domain entity correctly` | Test toDomain |
| `should map domain entity to DTO correctly` | Test toDto |
| `should handle null endTime in both directions` | Test nullable fields |
| `should map intensity enum correctly` | Test mild, moderate, strong |
| `should be reversible (DTO -> Domain -> DTO)` | Test round-trip |
| `should be reversible (Domain -> DTO -> Domain)` | Test round-trip |

### 4.2 ContractionSessionMapper
**File**: `test/data/mappers/contraction_session_mapper_test.dart`

| Test Case | Description |
|-----------|-------------|
| `should map composite DTO to domain entity` | Test toDomain |
| `should map domain entity to session DTO` | Test toDto |
| `should handle empty contractions list` | Test edge case |
| `should handle multiple contractions` | Test list mapping |
| `should map all 5-1-1 achievement fields` | Test new fields |
| `should handle null timestamps for achievements` | Test nullable fields |
| `should map list of composites to domain list` | Test toDomainList |

---

## 5. Data DAO Tests

### 5.1 ContractionTimerDao
**File**: `test/data/local/daos/contraction_timer_dao_test.dart`

| Test Case | Description |
|-----------|-------------|
| **Session Operations** |
| `should insert session successfully` | Test insert |
| `should update session fields` | Test update with companion |
| `should delete session` | Test delete |
| `should get session by ID` | Test select |
| `should return null for non-existent session` | Test edge case |
| `should get active session` | Test active query |
| `should return null when no active session` | Test edge case |
| `should get session with contractions composite` | Test join query |
| `should get session history ordered by start time desc` | Test ordering |
| `should respect limit in session history` | Test pagination |
| `should delete sessions older than cutoff` | Test bulk delete |
| **Contraction Operations** |
| `should insert contraction successfully` | Test insert |
| `should update contraction fields` | Test update with companion |
| `should delete contraction` | Test delete |
| `should get contraction by ID` | Test select |
| `should get contractions for session ordered by start time` | Test ordering |
| `should get active contraction for session` | Test active query |
| `should return null when no active contraction` | Test edge case |
| **Transaction Handling** |
| `should handle multiple operations in transaction` | Test atomicity |
| `should rollback on error` | Test error handling |

---

## 6. Data Repository Tests

### 6.1 ContractionTimerRepositoryImpl
**File**: `test/data/repositories/contraction_timer_repository_impl_test.dart`

| Test Case | Description |
|-----------|-------------|
| **Session Management** |
| `should create session with generated UUID` | Test ID generation |
| `should create session with current timestamp` | Test timestamp |
| `should initialize session as active` | Test default state |
| `should initialize 5-1-1 achievement flags to false` | Test defaults |
| `should get active session with contractions` | Test retrieval |
| `should return null when no active session` | Test edge case |
| `should end session and set isActive to false` | Test state change |
| `should stop active contraction when ending session` | Test cleanup |
| `should delete session and cascade delete contractions` | Test cascade |
| `should get session by ID` | Test retrieval |
| `should update session note` | Test update |
| `should update session 5-1-1 criteria` | Test achievement tracking |
| **Contraction Operations** |
| `should start contraction with generated UUID` | Test ID generation |
| `should throw when starting contraction with existing active` | Test validation |
| `should use moderate intensity as default` | Test default |
| `should stop contraction and set end time` | Test update |
| `should throw when stopping non-existent contraction` | Test validation |
| `should throw when stopping already stopped contraction` | Test validation |
| `should update contraction start time` | Test field update |
| `should update contraction duration and calculate end time` | Test calculation |
| `should update contraction intensity` | Test field update |
| `should throw when update creates invalid data` | Test validation |
| `should delete contraction successfully` | Test delete |
| `should throw when deleting non-existent contraction` | Test validation |
| **History & Context** |
| `should get session history ordered by start time desc` | Test ordering |
| `should respect limit parameter in history` | Test pagination |
| `should delete sessions older than cutoff date` | Test bulk delete |
| `should calculate pregnancy week for session` | Test integration |
| `should return null pregnancy week when no pregnancy` | Test edge case |
| **Error Handling** |
| `should log errors appropriately` | Test logging |
| `should rethrow exceptions after logging` | Test error propagation |

---

## Test Data Builders

### Fake Data Builders
**File**: `test/mocks/fake_data/contraction_timer_fakes.dart`

- `FakeContraction` - Builder for test contractions
- `FakeContractionSession` - Builder for test sessions
- `FakeRule511Status` - Builder for test 5-1-1 status

---

## 7. Logic Layer Tests

### 7.1 ContractionTimerNotifier
**File**: `test/features/contraction_timer/logic/contraction_timer_notifier_test.dart`

| Test Group | Test Cases |
|------------|------------|
| **Initialization** | should initialize with null active session |
| | should load existing active session on startup |
| | should handle session restore with active contraction |
| | should auto-archive session after 4 hours of inactivity |
| | should detect contraction timeout after 20 minutes |
| **startSession** | should create new session successfully |
| | should update rule511Status after starting session |
| | should set error when session already exists |
| **startContraction** | should start contraction in active session |
| | should recalculate 5-1-1 rule after starting |
| | should handle error when no active session |
| **stopContraction** | should stop active contraction |
| | should update rule511Status after stopping |
| **deleteContraction** | should delete contraction by ID |
| | should recalculate 5-1-1 rule after delete |
| **updateContraction** | should update contraction properties |
| | should recalculate 5-1-1 rule after update |
| **finishSession** | should end session and clear state |
| | should stop active contraction before finishing |
| | should update note if provided |
| **discardSession** | should delete session and clear state |
| **refresh** | should reload active session from repository |
| **updateSessionNote** | should update session note |
| **clearError** | should clear error state |

### 7.2 ContractionHistoryNotifier
**File**: `test/features/contraction_timer/logic/contraction_history_provider_test.dart`

| Test Group | Test Cases |
|------------|------------|
| **Initialization** | should load history on creation |
| | should handle loading error gracefully |
| **refresh** | should reload session history |
| **deleteSession** | should remove session from history |
| | should update local state immediately |
| | should handle delete error |
| **updateSessionNote** | should update note in session |
| | should handle update error |
| **clearError** | should clear error state |

### 7.3 ContractionTimerBannerNotifier
**File**: `test/features/contraction_timer/logic/contraction_timer_banner_provider_test.dart`

| Test Group | Test Cases |
|------------|------------|
| **Initial state** | should start hidden |
| **show** | should set isVisible to true |
| **hide** | should set isVisible to false |
| **toggle** | show() and hide() should toggle state correctly |

### 7.4 ContractionTimerOnboardingNotifier
**File**: `test/features/contraction_timer/logic/contraction_timer_onboarding_provider_test.dart`

| Test Group | Test Cases |
|------------|------------|
| **Initial state** | should load onboarding status (initially null, then false) |
| **setHasStarted** | should mark onboarding complete |
| **persistence** | should persist onboarding status across instances |

---

## 8. Widget Layer Tests

### 8.1 Rule511Progress Widget
**File**: `test/features/contraction_timer/ui/widgets/rule_511_progress_test.dart`

| Test Cases |
|------------|
| should display progress tracking header |
| should show alert message when alertActive is true |
| should show duration/frequency achieved message |
| should show frequency achieved message when only frequency met |
| should show duration achieved message when only duration met |
| should show default message when no criteria met |
| should display three progress indicators |
| should show check icon when progress is complete |
| should apply alert styling when alertActive |

### 8.2 Session511StatusCard Widget
**File**: `test/features/contraction_timer/ui/widgets/session_511_status_card_test.dart`

| Test Cases |
|------------|
| should display 5-1-1 Rule Progress header |
| should show all three checklist items |
| should check items when criteria achieved |
| should not check items when criteria not achieved |
| should show alert message when all criteria met |
| should show partial progress message for two criteria |
| should show single criterion message |
| should show no criteria message when none achieved |
| should apply alert styling when achieved511Alert |
| should check exactly two items for partial achievement |

### 8.3 LabourOverviewScreen Widget
**File**: `test/features/contraction_timer/ui/screens/labour_overview_screen_test.dart`

| Test Cases |
|------------|
| should display Labour Overview title |
| should show empty state when no history |
| should display session history cards |
| should navigate to session detail on card tap |
| should show FAB when no active session |
| should hide FAB when active session exists |
| should show info card with warning message |

### 8.4 ContractionSessionDetailScreen Widget
**File**: `test/features/contraction_timer/ui/screens/contraction_session_detail_screen_test.dart`

| Test Cases |
|------------|
| should display session summary stats |
| should display 5-1-1 status card |
| should display note card with note text |
| should display no note placeholder when no note |
| should display complete log table |
| should show popup menu with edit/delete options |
| should navigate back on back button |
| should display contractions in descending order |
| should display intensity badges in log |

---

## Test Runners

### Quick Test Runner
**File**: `test/runners/contraction_timer/quick_test.dart`
- Domain entity tests
- Domain exception tests
- Data mapper tests

### Unit Test Runner
**File**: `test/runners/contraction_timer/unit_test.dart` (194 tests)
- All quick tests
- Domain use case tests (90 tests)
- Data DAO tests (18 tests)
- Data repository tests (36 tests)
- Logic/state management tests (45 tests)

### All Tests Runner
**File**: `test/runners/contraction_timer/all_test.dart` (273 tests)
- All unit tests (194 tests)
- Widget tests (25 tests)
- Data DAO tests (18 tests)
- Data repository tests (36 tests)

### Widget Test Runner
**File**: `test/runners/all_widget_test.dart`
- Includes all contraction timer widget tests

---

## Coverage Requirements

| Layer | Minimum Coverage |
|-------|------------------|
| Domain Entities | 95% |
| Domain Use Cases | 90% |
| Data Mappers | 90% |
| Data DAO | 85% |
| Data Repository | 85% |
| Logic/State Management | 85% |
| Widgets | 75% |

---

## Test Summary

| Test Category | Test Count |
|---------------|------------|
| Domain Entity Tests | 39 tests |
| Domain Exception Tests | 10 tests |
| Domain Use Case Tests | 107 tests |
| Data Mapper Tests | 10 tests |
| Data DAO Tests | 18 tests |
| Data Repository Tests | 36 tests |
| Logic/State Management Tests | 45 tests |
| Widget Tests | 25 tests |
| **Total** | **290 tests** |

---

## Notes
- All tests use in-memory Drift database
- Mock PregnancyRepository for pregnancy week calculations
- Use mocktail for all mocking
- Follow AAA pattern (Arrange, Act, Assert)
- Tag all tests with `@Tags(['contraction_timer'])`
- Widget tests use ProviderScope overrides for state management
- Screen-level widget tests focus on key UI elements and interactions



