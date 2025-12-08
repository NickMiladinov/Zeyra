@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/mappers/pause_event_mapper.dart';

void main() {
  group('[Mapper] PauseEventMapper', () {
    test('should map PauseEventDto to domain PauseEvent', () {
      final now = DateTime.now();
      final dto = PauseEventDto(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAtMillis: now.millisecondsSinceEpoch,
        resumedAtMillis: now.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        kickCountAtPause: 7,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      final domain = PauseEventMapper.toDomain(dto);

      expect(domain.id, 'pause-1');
      expect(domain.sessionId, 'session-1');
      expect(domain.pausedAt, DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch));
      expect(domain.resumedAt, isNotNull);
      expect(domain.kickCountAtPause, 7);
    });

    test('should handle null resumedAtMillis', () {
      final now = DateTime.now();
      final dto = PauseEventDto(
        id: 'pause-1',
        sessionId: 'session-1',
        pausedAtMillis: now.millisecondsSinceEpoch,
        resumedAtMillis: null,
        kickCountAtPause: 5,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      final domain = PauseEventMapper.toDomain(dto);

      expect(domain.resumedAt, isNull);
    });

    test('should convert list of DTOs to list of domain entities', () {
      final now = DateTime.now();
      final dtos = [
        PauseEventDto(
          id: 'pause-1',
          sessionId: 'session-1',
          pausedAtMillis: now.millisecondsSinceEpoch,
          resumedAtMillis: now.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
          kickCountAtPause: 3,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        ),
        PauseEventDto(
          id: 'pause-2',
          sessionId: 'session-1',
          pausedAtMillis: now.add(const Duration(minutes: 10)).millisecondsSinceEpoch,
          resumedAtMillis: now.add(const Duration(minutes: 12)).millisecondsSinceEpoch,
          kickCountAtPause: 7,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        ),
      ];

      final domains = PauseEventMapper.toDomainList(dtos);

      expect(domains.length, 2);
      expect(domains[0].id, 'pause-1');
      expect(domains[1].id, 'pause-2');
    });

    test('should handle empty list', () {
      final domains = PauseEventMapper.toDomainList([]);

      expect(domains, isEmpty);
    });
  });
}

