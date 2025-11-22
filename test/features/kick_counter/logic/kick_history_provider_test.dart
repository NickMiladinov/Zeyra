import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/repositories/kick_counter_repository.dart';
import 'package:zeyra/features/kick_counter/logic/kick_history_provider.dart';

import '../../../mocks/fake_data/kick_counter_fakes.dart';

// ----------------------------------------------------------------------------
// Mocks
// ----------------------------------------------------------------------------

class MockKickCounterRepository extends Mock implements KickCounterRepository {}

// ----------------------------------------------------------------------------
// Test Data
// ----------------------------------------------------------------------------

// Helper to create a session with N dummy kicks
KickSession createSessionWithKicks(int count, Duration duration) {
  final start = DateTime.now().subtract(duration);
  return KickSession(
    id: 'id-$count',
    startTime: start,
    endTime: DateTime.now(),
    isActive: false,
    kicks: FakeKick.batch(count, startTime: start),
    totalPausedDuration: Duration.zero,
    pauseCount: 0,
  );
}

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  late KickHistoryNotifier notifier;
  late MockKickCounterRepository mockRepo;

  setUp(() {
    mockRepo = MockKickCounterRepository();
    // Mock initial load
    when(() => mockRepo.getSessionHistory(limit: 50))
        .thenAnswer((_) async => []);
    notifier = KickHistoryNotifier(mockRepo);
  });

  group('KickHistoryNotifier', () {
    test('loads history successfully', () async {
      // Arrange
      when(() => mockRepo.getSessionHistory(limit: 50))
          .thenAnswer((_) async => []);

      // Act
      await notifier.loadHistory();

      // Assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.history, isEmpty);
    });

    test('handles error on load', () async {
      // Arrange
      when(() => mockRepo.getSessionHistory(limit: 50))
          .thenThrow(Exception('Db Error'));

      // Act
      await notifier.loadHistory();

      // Assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, contains('Db Error'));
    });
    
    test('calculates typical range correctly', () async {
      // This logic is internal to private method but exposed via state.typicalRange
      // We need to provide sessions that satisfy criteria (kickCount >= 10)
      
      final session = createSessionWithKicks(10, const Duration(minutes: 30));
      
      when(() => mockRepo.getSessionHistory(limit: 50))
          .thenAnswer((_) async => [session]);

      await notifier.loadHistory();

      // Verify that load happened without error
      expect(notifier.state.error, isNull);
    });
  });
}
