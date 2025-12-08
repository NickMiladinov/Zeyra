@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/kick_counter/pause_event.dart';

void main() {
  group('[Domain] PauseEvent Entity', () {
    test('should create pause event with all required fields', () {
      final pausedAt = DateTime(2024, 12, 1, 10, 30);
      final resumedAt = DateTime(2024, 12, 1, 10, 35);
      
      final pauseEvent = PauseEvent(
        id: 'test-id',
        sessionId: 'session-id',
        pausedAt: pausedAt,
        resumedAt: resumedAt,
        kickCountAtPause: 5,
      );

      expect(pauseEvent.id, 'test-id');
      expect(pauseEvent.sessionId, 'session-id');
      expect(pauseEvent.pausedAt, pausedAt);
      expect(pauseEvent.resumedAt, resumedAt);
      expect(pauseEvent.kickCountAtPause, 5);
    });

    test('should calculate duration correctly when resumed', () {
      final pausedAt = DateTime(2024, 12, 1, 10, 30);
      final resumedAt = DateTime(2024, 12, 1, 10, 35);
      
      final pauseEvent = PauseEvent(
        id: 'test-id',
        sessionId: 'session-id',
        pausedAt: pausedAt,
        resumedAt: resumedAt,
        kickCountAtPause: 5,
      );

      expect(pauseEvent.duration, const Duration(minutes: 5));
    });

    test('should calculate duration from pausedAt to now when not resumed', () {
      final pausedAt = DateTime.now().subtract(const Duration(minutes: 3));
      
      final pauseEvent = PauseEvent(
        id: 'test-id',
        sessionId: 'session-id',
        pausedAt: pausedAt,
        resumedAt: null,
        kickCountAtPause: 5,
      );

      // Duration should be approximately 3 minutes (with some tolerance for execution time)
      expect(pauseEvent.duration.inMinutes, greaterThanOrEqualTo(2));
      expect(pauseEvent.duration.inMinutes, lessThanOrEqualTo(4));
    });

    test('should return true for isBeforeTenthKick when kickCountAtPause < 10', () {
      final pauseEvent = PauseEvent(
        id: 'test-id',
        sessionId: 'session-id',
        pausedAt: DateTime.now(),
        resumedAt: null,
        kickCountAtPause: 5,
      );

      expect(pauseEvent.isBeforeTenthKick, isTrue);
    });

    test('should return false for isBeforeTenthKick when kickCountAtPause >= 10', () {
      final pauseEvent = PauseEvent(
        id: 'test-id',
        sessionId: 'session-id',
        pausedAt: DateTime.now(),
        resumedAt: null,
        kickCountAtPause: 10,
      );

      expect(pauseEvent.isBeforeTenthKick, isFalse);
    });

    test('should support equality comparison', () {
      final pausedAt = DateTime(2024, 12, 1, 10, 30);
      final resumedAt = DateTime(2024, 12, 1, 10, 35);
      
      final event1 = PauseEvent(
        id: 'test-id',
        sessionId: 'session-id',
        pausedAt: pausedAt,
        resumedAt: resumedAt,
        kickCountAtPause: 5,
      );

      final event2 = PauseEvent(
        id: 'test-id',
        sessionId: 'session-id',
        pausedAt: pausedAt,
        resumedAt: resumedAt,
        kickCountAtPause: 5,
      );

      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('should have correct toString format', () {
      final pauseEvent = PauseEvent(
        id: 'test-id',
        sessionId: 'session-id',
        pausedAt: DateTime(2024, 12, 1, 10, 30),
        resumedAt: DateTime(2024, 12, 1, 10, 35),
        kickCountAtPause: 5,
      );

      final string = pauseEvent.toString();
      expect(string, contains('PauseEvent'));
      expect(string, contains('test-id'));
      expect(string, contains('session-id'));
      expect(string, contains('5'));
    });
  });
}

