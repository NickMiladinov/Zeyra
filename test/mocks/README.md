# Test Mocks Organization

## Overview

This project uses **mocktail** for creating test mocks. Mocks are organized by feature for better maintainability and discoverability.

## File Structure

```
test/mocks/
├── README.md                    # This file
├── mock_repositories.dart       # Central export point for all mocks
└── fake_data/                   # Feature-specific fakes and mocks
    ├── kick_counter_fakes.dart  # Kick counter fake data + mocks
    └── ...                      # Other feature fakes
```

## Usage Patterns

### 1. Using Mocks in Tests

Import centralized mocks from `mock_repositories.dart`:

```dart
import '../../../mocks/mock_repositories.dart';

void main() {
  late MockKickCounterRepository mockRepository;
  
  setUp(() {
    mockRepository = MockKickCounterRepository();
  });
  
  test('example test', () {
    when(() => mockRepository.getActiveSession())
        .thenAnswer((_) async => null);
    // ... test code
  });
}
```

### 2. Using Fake Data Builders

Import feature-specific fake data from `fake_data/` directory:

```dart
import '../../../mocks/fake_data/kick_counter_fakes.dart';

void main() {
  test('example test with fake data', () {
    final fakeSession = FakeKickSession.simple(
      kickCount: 10,
      startTime: DateTime.now(),
    );
    // ... test code
  });
}
```

### 3. Combined Usage

You can use both mocks and fake data in the same test:

```dart
import '../../../mocks/mock_repositories.dart';
import '../../../mocks/fake_data/kick_counter_fakes.dart';

void main() {
  late MockKickCounterRepository mockRepository;
  
  test('example test', () {
    mockRepository = MockKickCounterRepository();
    
    // Use fake data builder
    final fakeSession = FakeKickSession.simple(kickCount: 10);
    
    // Mock repository response
    when(() => mockRepository.getActiveSession())
        .thenAnswer((_) async => fakeSession);
    
    // ... test code
  });
}
```

## Creating New Mocks

### Step 1: Create Feature Fake File

Create a new file in `fake_data/` for your feature:

```dart
// test/mocks/fake_data/my_feature_fakes.dart
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/repositories/my_feature_repository.dart';

// Fake data builders (if needed)
class FakeMyEntity {
  static MyEntity simple({...}) {
    return MyEntity(...);
  }
}

// Mocks
class MockMyFeatureRepository extends Mock implements MyFeatureRepository {}
class MockMyFeatureDao extends Mock implements MyFeatureDao {}
```

### Step 2: Export from mock_repositories.dart

Add your mocks to the central export file:

```dart
// test/mocks/mock_repositories.dart
export 'fake_data/my_feature_fakes.dart'
    show MockMyFeatureRepository, MockMyFeatureDao;
```

### Step 3: Use in Tests

Now you can import from either location:

```dart
// For mocks only:
import 'test/mocks/mock_repositories.dart';

// For fake data + mocks:
import 'test/mocks/fake_data/my_feature_fakes.dart';
```

## Why Mocktail (Not Mockito)?

- **No code generation**: Simpler, faster development
- **Type-safe**: Compile-time checking
- **Cleaner syntax**: Less boilerplate
- **Better error messages**: Easier debugging

## Architecture Notes

- **Mock classes** are minimal wrappers: `class MockX extends Mock implements X {}`
- **Fake data builders** provide realistic test data
- **One file per feature** keeps related test utilities together
- **Central export** (`mock_repositories.dart`) provides discoverability

## Testing Philosophy

From `@.cursor/rules/testing.mdc`:
- Prefer fake data builders for complex objects
- Use mocks for repository/service dependencies
- Keep test setup minimal and readable
- Reuse common test data across test files
