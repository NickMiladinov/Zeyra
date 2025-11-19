# Test Runners

This directory contains test runner files that aggregate and execute groups of tests for easy running from the IDE.

## Purpose

Test runner files allow you to:
- Click the ▶️ "Run" button in your IDE to run entire test suites
- Group tests by feature, speed, or type
- Run comprehensive test sets without command-line arguments
- Navigate test hierarchies in your IDE's test explorer

## Structure

```
test/runners/
├── README.md                    # This file
└── kick_counter/                # Kick Counter feature test runners
    ├── all_test.dart            # All 173 tests (~2-3 min)
    ├── unit_test.dart           # 160 unit tests (~1-2 min)
    └── quick_test.dart          # 88 fast tests (~20 sec)
```

## How to Use

### In VS Code / Cursor / IntelliJ

1. Open any test runner file (e.g., `kick_counter/quick_test.dart`)
2. Click the ▶️ button next to `void main()` to run all tests
3. Click ▶️ next to any `group()` to run just that group
4. Click ▶️ next to any `test()` to run a single test

### From Command Line

```bash
# Run specific test runner
flutter test test/runners/kick_counter/quick_test.dart
flutter test test/runners/kick_counter/unit_test.dart
flutter test test/runners/kick_counter/all_test.dart

# Or use dart_test.yaml presets
flutter test --preset=kick_counter
```

## Test Runner Guidelines

### Quick Tests
- **Purpose**: Fast feedback during active development (TDD)
- **Duration**: < 30 seconds
- **Includes**: Pure unit tests with no external dependencies
- **Use when**: Actively coding, want immediate feedback

### Unit Tests
- **Purpose**: Comprehensive unit test coverage
- **Duration**: 1-2 minutes
- **Includes**: All unit tests (domain, data layer)
- **Excludes**: Integration, performance tests
- **Use when**: Before committing code

### All Tests
- **Purpose**: Complete feature validation
- **Duration**: 2-3 minutes
- **Includes**: Everything (unit, integration, performance)
- **Use when**: Before merging to main branch

## Adding New Features

When adding a new feature (e.g., "biomarkers"):

1. Create a feature directory:
   ```
   test/runners/biomarkers/
   ```

2. Create test runner files:
   ```
   test/runners/biomarkers/
   ├── all_test.dart
   ├── unit_test.dart
   └── quick_test.dart
   ```

3. Import relevant test files and organize by layer/type

4. Add preset to `dart_test.yaml` if needed

## Best Practices

- **Keep imports relative**: Use `../../` to import test files
- **Add `@Tags(['feature_name'])`**: For filtering by tag
- **Document test counts**: Include test counts in comments
- **Organize by layer**: Group tests by domain, data, integration
- **Skip when needed**: Use `skip: true` for slow tests in quick runners

