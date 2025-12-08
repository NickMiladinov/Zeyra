@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/entities/kick_counter/pause_event.dart';

void main() {
  group('[Domain] KickSession.durationToTenthKick', () {
    final startTime = DateTime(2024, 12, 1, 10, 0);

    List<Kick> generateKicks(int count, DateTime startTime) {
      return List.generate(count, (i) {
        return Kick(
          id: 'kick-$i',
          sessionId: 'session-1',
          timestamp: startTime.add(Duration(minutes: i)),
          sequenceNumber: i + 1,
          perceivedStrength: MovementStrength.moderate,
        );
      });
    }

    test('should return null when session has fewer than 10 kicks', () {
      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        kicks: generateKicks(9, startTime),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      expect(session.durationToTenthKick, isNull);
    });

    test('should calculate correctly with exactly 10 kicks and no pauses', () {
      final kicks = generateKicks(10, startTime);
      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        kicks: kicks,
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      // 10th kick is at startTime + 9 minutes (index 9)
      expect(session.durationToTenthKick, const Duration(minutes: 9));
    });

    test('should exclude pauses that occurred before the 10th kick', () {
      final kicks = generateKicks(15, startTime);
      
      // Pause after 5 kicks, resume after 3 minutes
      final pauseEvent1 = PauseEvent(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 5)),
        resumedAt: startTime.add(const Duration(minutes: 8)),
        kickCountAtPause: 5,
      );

      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: kicks,
        pauseEvents: [pauseEvent1],
        totalPausedDuration: const Duration(minutes: 3),
        pauseCount: 1,
      );

      // 10th kick at minute 9, minus 3-minute pause = 6 minutes
      expect(session.durationToTenthKick, const Duration(minutes: 6));
    });

    test('should NOT exclude pauses that occurred after the 10th kick', () {
      final kicks = generateKicks(15, startTime);
      
      // Pause after 12 kicks (after 10th kick)
      final pauseEvent1 = PauseEvent(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 12)),
        resumedAt: startTime.add(const Duration(minutes: 15)),
        kickCountAtPause: 12,
      );

      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: kicks,
        pauseEvents: [pauseEvent1],
        totalPausedDuration: const Duration(minutes: 3),
        pauseCount: 1,
      );

      // 10th kick at minute 9, pause was after 10th kick so not subtracted
      expect(session.durationToTenthKick, const Duration(minutes: 9));
    });

    test('should handle multiple pause/resume cycles correctly', () {
      final kicks = generateKicks(15, startTime);
      
      // First pause after 3 kicks
      final pauseEvent1 = PauseEvent(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 3)),
        resumedAt: startTime.add(const Duration(minutes: 5)),
        kickCountAtPause: 3,
      );

      // Second pause after 7 kicks
      final pauseEvent2 = PauseEvent(
        id: 'pause-2',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 7)),
        resumedAt: startTime.add(const Duration(minutes: 10)),
        kickCountAtPause: 7,
      );

      // Third pause after 12 kicks (after 10th)
      final pauseEvent3 = PauseEvent(
        id: 'pause-3',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 12)),
        resumedAt: startTime.add(const Duration(minutes: 14)),
        kickCountAtPause: 12,
      );

      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: kicks,
        pauseEvents: [pauseEvent1, pauseEvent2, pauseEvent3],
        totalPausedDuration: const Duration(minutes: 7),
        pauseCount: 3,
      );

      // 10th kick at minute 9
      // Subtract pause 1 (2 minutes) and pause 2 (3 minutes) = 5 minutes total
      // Don't subtract pause 3 (happened after kick 10)
      // Result: 9 - 5 = 4 minutes
      expect(session.durationToTenthKick, const Duration(minutes: 4));
    });

    test('should handle pause at exactly kick 10', () {
      final kicks = generateKicks(15, startTime);
      
      // Pause right at 10 kicks
      final pauseEvent1 = PauseEvent(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 9)),
        resumedAt: startTime.add(const Duration(minutes: 12)),
        kickCountAtPause: 10,
      );

      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: kicks,
        pauseEvents: [pauseEvent1],
        totalPausedDuration: const Duration(minutes: 3),
        pauseCount: 1,
      );

      // Pause happened at kick 10, so kickCountAtPause is NOT < 10
      // Therefore pause is NOT excluded
      expect(session.durationToTenthKick, const Duration(minutes: 9));
    });

    test('should handle unresolved pause (resumedAt is null) before 10th kick', () {
      final kicks = generateKicks(12, startTime);
      
      // Pause that was never resumed (session ended while paused)
      final pauseEvent1 = PauseEvent(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 5)),
        resumedAt: null, // Never resumed
        kickCountAtPause: 5,
      );

      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: startTime.add(const Duration(minutes: 12)),
        isActive: false,
        kicks: kicks,
        pauseEvents: [pauseEvent1],
        totalPausedDuration: const Duration(minutes: 7),
        pauseCount: 0,
      );

      // Should skip pauses without resumedAt
      // 10th kick at minute 9, no pauses subtracted (since resumedAt is null)
      expect(session.durationToTenthKick, const Duration(minutes: 9));
    });

    test('should handle session with more than 10 kicks', () {
      final kicks = generateKicks(25, startTime);
      
      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: kicks,
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      // Should still calculate to 10th kick, not the last kick
      expect(session.durationToTenthKick, const Duration(minutes: 9));
    });

    test('should work with empty pause events list', () {
      final kicks = generateKicks(10, startTime);
      
      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        kicks: kicks,
        pauseEvents: const [],
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      expect(session.durationToTenthKick, const Duration(minutes: 9));
    });

    test('should handle pause with zero duration', () {
      final kicks = generateKicks(12, startTime);
      
      // Pause and immediate resume (0 duration)
      final pauseEvent1 = PauseEvent(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 5)),
        resumedAt: startTime.add(const Duration(minutes: 5)),
        kickCountAtPause: 5,
      );

      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: kicks,
        pauseEvents: [pauseEvent1],
        totalPausedDuration: Duration.zero,
        pauseCount: 1,
      );

      // Zero duration pause doesn't change the result
      expect(session.durationToTenthKick, const Duration(minutes: 9));
    });

    test('should handle very long pause before 10th kick', () {
      final kicks = generateKicks(12, startTime);
      
      // 30-minute pause after 5 kicks
      final pauseEvent1 = PauseEvent(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAt: startTime.add(const Duration(minutes: 5)),
        resumedAt: startTime.add(const Duration(minutes: 35)),
        kickCountAtPause: 5,
      );

      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: kicks,
        pauseEvents: [pauseEvent1],
        totalPausedDuration: const Duration(minutes: 30),
        pauseCount: 1,
      );

      // 10th kick at minute 9, minus 30-minute pause
      // But this would give negative, which shouldn't happen in real scenario
      // The implementation should handle this gracefully
      final result = session.durationToTenthKick;
      expect(result, isNotNull);
    });
  });
}

