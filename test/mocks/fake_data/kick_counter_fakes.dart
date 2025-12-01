import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/encryption_service.dart';
import 'package:zeyra/data/local/daos/kick_counter_dao.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/repositories/kick_counter_repository.dart';

// ----------------------------------------------------------------------------
// Fake Data Builders
// ----------------------------------------------------------------------------

/// Fake data builders for Kick entities.
class FakeKick {
  /// Create a simple kick with default or custom values.
  static Kick simple({
    String? id,
    String? sessionId,
    DateTime? timestamp,
    int? sequenceNumber,
    MovementStrength? strength,
  }) {
    return Kick(
      id: id ?? 'kick-1',
      sessionId: sessionId ?? 'session-1',
      timestamp: timestamp ?? DateTime(2024, 1, 1, 10, 0),
      sequenceNumber: sequenceNumber ?? 1,
      perceivedStrength: strength ?? MovementStrength.moderate,
    );
  }

  /// Generate a batch of kicks with sequential numbers.
  static List<Kick> batch(
    int count, {
    String? sessionId,
    DateTime? startTime,
  }) {
    final start = startTime ?? DateTime(2024, 1, 1, 10, 0);
    return List.generate(
      count,
      (index) => Kick(
        id: 'kick-${index + 1}',
        sessionId: sessionId ?? 'session-1',
        timestamp: start.add(Duration(minutes: index)),
        sequenceNumber: index + 1,
        perceivedStrength: MovementStrength.values[index % 3],
      ),
    );
  }
}

/// Fake data builders for KickSession entities.
class FakeKickSession {
  /// Create a simple session with default or custom values.
  static KickSession simple({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    List<Kick>? kicks,
    DateTime? pausedAt,
    Duration? totalPausedDuration,
    int? pauseCount,
    String? note,
  }) {
    return KickSession(
      id: id ?? 'session-1',
      startTime: startTime ?? DateTime(2024, 1, 1, 10, 0),
      endTime: endTime,
      isActive: isActive ?? true,
      kicks: kicks ?? const [],
      pausedAt: pausedAt,
      totalPausedDuration: totalPausedDuration ?? Duration.zero,
      pauseCount: pauseCount ?? 0,
      note: note,
    );
  }

  /// Create a session with accumulated pause time.
  static KickSession withPauses({
    required Duration totalPaused,
    int pauseCount = 1,
    List<Kick>? kicks,
    String? note,
  }) {
    return KickSession(
      id: 'session-paused',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: null,
      isActive: true,
      kicks: kicks ?? FakeKick.batch(5),
      pausedAt: null,
      totalPausedDuration: totalPaused,
      pauseCount: pauseCount,
      note: note,
    );
  }

  /// Create an active session (no end time).
  static KickSession active({List<Kick>? kicks, String? note}) {
    return KickSession(
      id: 'session-active',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: null,
      isActive: true,
      kicks: kicks ?? FakeKick.batch(5),
      pausedAt: null,
      totalPausedDuration: Duration.zero,
      pauseCount: 0,
      note: note,
    );
  }

  /// Create an ended session (with end time).
  static KickSession ended({List<Kick>? kicks, String? note}) {
    return KickSession(
      id: 'session-ended',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: DateTime(2024, 1, 1, 10, 30),
      isActive: false,
      kicks: kicks ?? FakeKick.batch(10),
      pausedAt: null,
      totalPausedDuration: Duration.zero,
      pauseCount: 0,
      note: note,
    );
  }

  /// Create a session with maximum kicks (100).
  static KickSession maxKicks({String? note}) {
    return KickSession(
      id: 'session-max',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: null,
      isActive: true,
      kicks: FakeKick.batch(100),
      pausedAt: null,
      totalPausedDuration: Duration.zero,
      pauseCount: 0,
      note: note,
    );
  }

  /// Create a session with a note attached.
  static KickSession withNote({
    String? id,
    required String note,
    List<Kick>? kicks,
    bool isActive = false,
  }) {
    return KickSession(
      id: id ?? 'session-with-note',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: isActive ? null : DateTime(2024, 1, 1, 10, 30),
      isActive: isActive,
      kicks: kicks ?? FakeKick.batch(10),
      pausedAt: null,
      totalPausedDuration: Duration.zero,
      pauseCount: 0,
      note: note,
    );
  }
}

// ----------------------------------------------------------------------------
// Mocks (Mocktail)
// ----------------------------------------------------------------------------

/// Mock implementation of KickCounterRepository for testing.
class MockKickCounterRepository extends Mock
    implements KickCounterRepository {}

/// Mock implementation of KickCounterDao for testing.
class MockKickCounterDao extends Mock implements KickCounterDao {}

/// Mock implementation of EncryptionService for testing.
class MockEncryptionService extends Mock implements EncryptionService {}

