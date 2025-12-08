/// Central export point for all mock repository implementations.
/// 
/// This project uses **mocktail** for mocking
/// Mocks are organized by feature in the `fake_data/` directory.
/// 
/// ## Pattern
/// - Each feature has its own `<feature>_fakes.dart` file containing:
///   - Fake data builders
///   - Mock classes for that feature's repositories, DAOs, and services
/// 
/// ## Usage
/// Import this file in your tests to access all available mocks:
/// ```dart
/// import 'package:zeyra/test/mocks/mock_repositories.dart';
/// 
/// final mockRepo = MockKickCounterRepository();
/// ```
/// 
/// ## Adding New Mocks
/// 1. Create/update `fake_data/<feature>_fakes.dart`
/// 2. Define mock class: `class MockXRepository extends Mock implements XRepository {}`
/// 3. Export it from this file
library;

// Kick Counter Feature Mocks
export 'fake_data/kick_counter_fakes.dart'
    show
        MockKickCounterRepository,
        MockKickCounterDao,
        MockEncryptionService;
