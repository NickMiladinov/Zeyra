@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_analytics.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/usecases/kick_counter/calculate_analytics_usecase.dart';

void main() {
  late CalculateAnalyticsUseCase useCase;

  setUp(() {
    useCase = CalculateAnalyticsUseCase();
  });

  List<Kick> generateKicks(int count, DateTime startTime, String sessionId) {
    return List.generate(count, (i) {
      return Kick(
        id: 'kick-$i-$sessionId',
        sessionId: sessionId,
        timestamp: startTime.add(Duration(minutes: i)),
        sequenceNumber: i + 1,
        perceivedStrength: MovementStrength.moderate,
      );
    });
  }

  group('[UseCase] calculateHistoryAnalytics', () {
    test('should return empty analytics when no sessions provided', () {
      final analytics = useCase.calculateHistoryAnalytics([]);

      expect(analytics.validSessionCount, 0);
      expect(analytics.averageDurationToTen, isNull);
      expect(analytics.standardDeviation, isNull);
      expect(analytics.upperThreshold, isNull);
      expect(analytics.hasEnoughDataForAnalytics, isFalse);
    });

    test('should return empty analytics when all sessions have < 10 kicks', () {
      final sessions = [
        KickSession(
          id: 'session-1',
          startTime: DateTime.now(),
          endTime: null,
          isActive: false,
          kicks: generateKicks(5, DateTime.now(), 'session-1'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
        KickSession(
          id: 'session-2',
          startTime: DateTime.now(),
          endTime: null,
          isActive: false,
          kicks: generateKicks(8, DateTime.now(), 'session-2'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
      ];

      final analytics = useCase.calculateHistoryAnalytics(sessions);

      expect(analytics.validSessionCount, 0);
      expect(analytics.hasEnoughDataForAnalytics, isFalse);
    });

    test('should calculate average duration correctly with 7 valid sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = List.generate(7, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });

      final analytics = useCase.calculateHistoryAnalytics(sessions);

      expect(analytics.validSessionCount, 7);
      expect(analytics.averageDurationToTen, const Duration(minutes: 9));
      expect(analytics.hasEnoughDataForAnalytics, isTrue);
    });

    test('should calculate standard deviation correctly', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      
      // Create sessions with varying durations
      final sessions = [
        // Session 1: 10 minutes to 10 kicks
        KickSession(
          id: 'session-1',
          startTime: baseTime,
          endTime: null,
          isActive: false,
          kicks: List.generate(10, (i) => Kick(
            id: 'kick-$i-1',
            sessionId: 'session-1',
            timestamp: baseTime.add(Duration(minutes: i + 1)),
            sequenceNumber: i + 1,
            perceivedStrength: MovementStrength.moderate,
          )),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
        // Session 2: 20 minutes to 10 kicks
        KickSession(
          id: 'session-2',
          startTime: baseTime.add(const Duration(hours: 1)),
          endTime: null,
          isActive: false,
          kicks: List.generate(10, (i) => Kick(
            id: 'kick-$i-2',
            sessionId: 'session-2',
            timestamp: baseTime.add(Duration(hours: 1, minutes: (i + 1) * 2)),
            sequenceNumber: i + 1,
            perceivedStrength: MovementStrength.moderate,
          )),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
      ];

      final analytics = useCase.calculateHistoryAnalytics(sessions);

      expect(analytics.validSessionCount, 2);
      expect(analytics.averageDurationToTen, const Duration(minutes: 15));
      expect(analytics.standardDeviation, isNotNull);
      expect(analytics.upperThreshold, isNotNull);
    });

    test('should set hasEnoughDataForAnalytics to true when >= 7 sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = List.generate(7, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });

      final analytics = useCase.calculateHistoryAnalytics(sessions);

      expect(analytics.hasEnoughDataForAnalytics, isTrue);
    });

    test('should set hasEnoughDataForAnalytics to false when < 7 sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = List.generate(6, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });

      final analytics = useCase.calculateHistoryAnalytics(sessions);

      expect(analytics.hasEnoughDataForAnalytics, isFalse);
    });

    test('should handle all sessions with same duration (stdDev = 0)', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = List.generate(10, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });

      final analytics = useCase.calculateHistoryAnalytics(sessions);

      expect(analytics.validSessionCount, 10);
      expect(analytics.averageDurationToTen, const Duration(minutes: 9));
      expect(analytics.standardDeviation, const Duration(minutes: 0));
      expect(analytics.upperThreshold, const Duration(minutes: 9));
    });

    test('should filter out sessions without durationToTenthKick', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = [
        // Valid session
        KickSession(
          id: 'session-1',
          startTime: baseTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, baseTime, 'session-1'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
        // Invalid session (< 10 kicks)
        KickSession(
          id: 'session-2',
          startTime: baseTime.add(const Duration(hours: 1)),
          endTime: null,
          isActive: false,
          kicks: generateKicks(5, baseTime.add(const Duration(hours: 1)), 'session-2'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
      ];

      final analytics = useCase.calculateHistoryAnalytics(sessions);

      expect(analytics.validSessionCount, 1);
    });
  });

  group('[UseCase] calculateSessionAnalytics', () {
    test('should return non-outlier for session with < 10 kicks', () {
      final session = KickSession(
        id: 'session-1',
        startTime: DateTime.now(),
        endTime: null,
        isActive: false,
        kicks: generateKicks(5, DateTime.now(), 'session-1'),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      final historyAnalytics = KickHistoryAnalytics(
        validSessionCount: 10,
        averageDurationToTen: Duration(minutes: 15),
        standardDeviation: Duration(minutes: 3),
        upperThreshold: Duration(minutes: 21),
      );

      final sessionAnalytics = useCase.calculateSessionAnalytics(session, historyAnalytics);

      expect(sessionAnalytics.hasMinimumKicks, isFalse);
      expect(sessionAnalytics.isOutlier, isFalse);
    });

    test('should flag session as outlier when above upper threshold', () {
      final startTime = DateTime(2024, 12, 1, 10, 0);
      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: List.generate(10, (i) => Kick(
          id: 'kick-$i',
          sessionId: 'session-1',
          timestamp: startTime.add(Duration(minutes: i * 3)), // 27 minutes total
          sequenceNumber: i + 1,
          perceivedStrength: MovementStrength.moderate,
        )),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      final historyAnalytics = KickHistoryAnalytics(
        validSessionCount: 10,
        averageDurationToTen: Duration(minutes: 15),
        standardDeviation: Duration(minutes: 3),
        upperThreshold: Duration(minutes: 21), // avg + 2*stdDev
      );

      final sessionAnalytics = useCase.calculateSessionAnalytics(session, historyAnalytics);

      expect(sessionAnalytics.hasMinimumKicks, isTrue);
      expect(sessionAnalytics.isOutlier, isTrue);
    });

    test('should NOT flag session as outlier when within threshold', () {
      final startTime = DateTime(2024, 12, 1, 10, 0);
      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: generateKicks(10, startTime, 'session-1'),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      final historyAnalytics = KickHistoryAnalytics(
        validSessionCount: 10,
        averageDurationToTen: Duration(minutes: 10),
        standardDeviation: Duration(minutes: 5),
        upperThreshold: Duration(minutes: 20),
      );

      final sessionAnalytics = useCase.calculateSessionAnalytics(session, historyAnalytics);

      expect(sessionAnalytics.hasMinimumKicks, isTrue);
      expect(sessionAnalytics.isOutlier, isFalse);
    });

    test('should NOT flag faster sessions as outliers', () {
      final startTime = DateTime(2024, 12, 1, 10, 0);
      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: List.generate(10, (i) => Kick(
          id: 'kick-$i',
          sessionId: 'session-1',
          timestamp: startTime.add(Duration(seconds: i * 30)), // 4.5 minutes total
          sequenceNumber: i + 1,
          perceivedStrength: MovementStrength.moderate,
        )),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      final historyAnalytics = KickHistoryAnalytics(
        validSessionCount: 10,
        averageDurationToTen: Duration(minutes: 15),
        standardDeviation: Duration(minutes: 3),
        upperThreshold: Duration(minutes: 21),
      );

      final sessionAnalytics = useCase.calculateSessionAnalytics(session, historyAnalytics);

      // Fast session should NOT be flagged
      expect(sessionAnalytics.hasMinimumKicks, isTrue);
      expect(sessionAnalytics.isOutlier, isFalse);
    });

    test('should return non-outlier when not enough history data', () {
      final startTime = DateTime(2024, 12, 1, 10, 0);
      final session = KickSession(
        id: 'session-1',
        startTime: startTime,
        endTime: null,
        isActive: false,
        kicks: generateKicks(10, startTime, 'session-1'),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      );

      final historyAnalytics = KickHistoryAnalytics(
        validSessionCount: 5, // < 7
      );

      final sessionAnalytics = useCase.calculateSessionAnalytics(session, historyAnalytics);

      expect(sessionAnalytics.isOutlier, isFalse);
    });
  });

  group('[UseCase] calculateAll', () {
    test('should calculate both history and session analytics', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = List.generate(7, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });

      final (historyAnalytics, sessionAnalytics) = useCase.calculateAll(sessions);

      expect(historyAnalytics.validSessionCount, 7);
      expect(historyAnalytics.hasEnoughDataForAnalytics, isTrue);
      expect(sessionAnalytics.length, 7);
      expect(sessionAnalytics.every((s) => s.hasMinimumKicks), isTrue);
    });

    test('should handle mixed valid and invalid sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = [
        // 5 valid sessions
        ...List.generate(5, (i) {
          final startTime = baseTime.add(Duration(hours: i));
          return KickSession(
            id: 'valid-$i',
            startTime: startTime,
            endTime: null,
            isActive: false,
            kicks: generateKicks(10, startTime, 'valid-$i'),
            totalPausedDuration: Duration.zero,
            pauseCount: 0,
          );
        }),
        // 3 invalid sessions
        ...List.generate(3, (i) {
          final startTime = baseTime.add(Duration(hours: i + 5));
          return KickSession(
            id: 'invalid-$i',
            startTime: startTime,
            endTime: null,
            isActive: false,
            kicks: generateKicks(7, startTime, 'invalid-$i'),
            totalPausedDuration: Duration.zero,
            pauseCount: 0,
          );
        }),
      ];

      final (historyAnalytics, sessionAnalytics) = useCase.calculateAll(sessions);

      expect(historyAnalytics.validSessionCount, 5);
      expect(sessionAnalytics.length, 8);
      expect(sessionAnalytics.where((s) => s.hasMinimumKicks).length, 5);
    });
  });

  group('[UseCase] calculateAllWithRollingWindow', () {
    test('should return empty analytics when < 7 valid sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = List.generate(5, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });

      final (historyAnalytics, sessionAnalytics) = 
          useCase.calculateAllWithRollingWindow(sessions);

      expect(historyAnalytics.validSessionCount, 0);
      expect(historyAnalytics.hasEnoughDataForAnalytics, isFalse);
      expect(sessionAnalytics.length, 5);
      
      // All sessions should have hasMinimumKicks = true (they have 10 kicks)
      // even though there's not enough data for outlier flagging
      for (final analytics in sessionAnalytics) {
        expect(analytics.hasMinimumKicks, isTrue);
        expect(analytics.isOutlier, isFalse);
      }
    });

    test('should set hasMinimumKicks correctly for mixed sessions with < 7 valid', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      // Create 3 sessions: 2 valid (10 kicks), 1 invalid (5 kicks)
      final sessions = <KickSession>[
        KickSession(
          id: 'session-0',
          startTime: baseTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, baseTime, 'session-0'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
        KickSession(
          id: 'session-1',
          startTime: baseTime.add(const Duration(hours: 1)),
          endTime: null,
          isActive: false,
          kicks: generateKicks(5, baseTime.add(const Duration(hours: 1)), 'session-1'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
        KickSession(
          id: 'session-2',
          startTime: baseTime.add(const Duration(hours: 2)),
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, baseTime.add(const Duration(hours: 2)), 'session-2'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ),
      ];

      final (historyAnalytics, sessionAnalytics) = 
          useCase.calculateAllWithRollingWindow(sessions);

      // Only 2 valid sessions, so hasEnoughDataForAnalytics should be false
      expect(historyAnalytics.hasEnoughDataForAnalytics, isFalse);
      expect(sessionAnalytics.length, 3);
      
      // Session 0: 10 kicks - hasMinimumKicks should be true
      expect(sessionAnalytics[0].hasMinimumKicks, isTrue);
      expect(sessionAnalytics[0].isOutlier, isFalse);
      
      // Session 1: 5 kicks - hasMinimumKicks should be false
      expect(sessionAnalytics[1].hasMinimumKicks, isFalse);
      expect(sessionAnalytics[1].isOutlier, isFalse);
      
      // Session 2: 10 kicks - hasMinimumKicks should be true
      expect(sessionAnalytics[2].hasMinimumKicks, isTrue);
      expect(sessionAnalytics[2].isOutlier, isFalse);
    });

    test('should calculate rolling window for each session', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      // Create 10 sessions in chronological order
      final sessions = List.generate(10, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });

      final (historyAnalytics, sessionAnalytics) = 
          useCase.calculateAllWithRollingWindow(sessions);

      expect(historyAnalytics.validSessionCount, 10);
      expect(sessionAnalytics.length, 10);
      
      // With hybrid window, early sessions can now be flagged
      // since we have 10 total valid sessions (>= 7)
      // Early sessions use a hybrid window (sessions before + after)
      // All sessions have same duration (9 mins), so none should be outliers
      expect(sessionAnalytics.every((s) => !s.isOutlier), isTrue);
    });

    test('should use only up to 14 previous sessions for each window', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      // Create 20 sessions with consistent duration
      final sessions = List.generate(19, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });
      
      // Add one outlier session at the end (30 minutes)
      final outlierStartTime = baseTime.add(Duration(hours: 19));
      sessions.add(KickSession(
        id: 'outlier',
        startTime: outlierStartTime,
        endTime: null,
        isActive: false,
        kicks: List.generate(10, (i) => Kick(
          id: 'kick-$i-outlier',
          sessionId: 'outlier',
          timestamp: outlierStartTime.add(Duration(minutes: i * 3)),
          sequenceNumber: i + 1,
          perceivedStrength: MovementStrength.moderate,
        )),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      ));

      final (historyAnalytics, sessionAnalytics) = 
          useCase.calculateAllWithRollingWindow(sessions);

      expect(historyAnalytics.validSessionCount, 20);
      expect(sessionAnalytics.length, 20);
      
      // The outlier session should be flagged based on the 14 sessions before it
      expect(sessionAnalytics[19].isOutlier, isTrue);
    });

    test('should filter outliers using IQR before calculating safe range', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      // Create 10 normal sessions with varying durations (8-12 minutes)
      final sessions = <KickSession>[];
      for (int i = 0; i < 10; i++) {
        final startTime = baseTime.add(Duration(hours: i));
        // Vary the duration between 8-12 minutes
        final minutesPerKick = 1.0 + (i % 3) * 0.2; // 1.0, 1.2, 1.4, 1.0, 1.2...
        sessions.add(KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: List.generate(10, (j) => Kick(
            id: 'kick-$j-$i',
            sessionId: 'session-$i',
            timestamp: startTime.add(Duration(milliseconds: (j * minutesPerKick * 60000).round())),
            sequenceNumber: j + 1,
            perceivedStrength: MovementStrength.moderate,
          )),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ));
      }
      
      // Add extreme outlier that should be filtered from calculations
      final extremeOutlierTime = baseTime.add(Duration(hours: 10));
      sessions.add(KickSession(
        id: 'extreme-outlier',
        startTime: extremeOutlierTime,
        endTime: null,
        isActive: false,
        kicks: List.generate(10, (i) => Kick(
          id: 'kick-$i-extreme',
          sessionId: 'extreme-outlier',
          timestamp: extremeOutlierTime.add(Duration(hours: i)), // 9 hours total
          sequenceNumber: i + 1,
          perceivedStrength: MovementStrength.moderate,
        )),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      ));
      
      // Add normal session after outlier (around 11 minutes)
      final normalTime = baseTime.add(Duration(hours: 11));
      sessions.add(KickSession(
        id: 'normal-after',
        startTime: normalTime,
        endTime: null,
        isActive: false,
        kicks: List.generate(10, (i) => Kick(
          id: 'kick-$i-normal',
          sessionId: 'normal-after',
          timestamp: normalTime.add(Duration(milliseconds: (i * 1.2 * 60000).round())),
          sequenceNumber: i + 1,
          perceivedStrength: MovementStrength.moderate,
        )),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      ));

      final (historyAnalytics, sessionAnalytics) = 
          useCase.calculateAllWithRollingWindow(sessions);

      // The normal session after the extreme outlier should not be flagged
      // because the extreme outlier is filtered out by IQR
      expect(sessionAnalytics[11].isOutlier, isFalse);
    });

    test('should handle sessions with mixed valid and invalid sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = [
        // 8 valid sessions
        ...List.generate(8, (i) {
          final startTime = baseTime.add(Duration(hours: i));
          return KickSession(
            id: 'valid-$i',
            startTime: startTime,
            endTime: null,
            isActive: false,
            kicks: generateKicks(10, startTime, 'valid-$i'),
            totalPausedDuration: Duration.zero,
            pauseCount: 0,
          );
        }),
        // 2 invalid sessions (< 10 kicks)
        ...List.generate(2, (i) {
          final startTime = baseTime.add(Duration(hours: i + 8));
          return KickSession(
            id: 'invalid-$i',
            startTime: startTime,
            endTime: null,
            isActive: false,
            kicks: generateKicks(7, startTime, 'invalid-$i'),
            totalPausedDuration: Duration.zero,
            pauseCount: 0,
          );
        }),
      ];

      final (historyAnalytics, sessionAnalytics) = 
          useCase.calculateAllWithRollingWindow(sessions);

      expect(historyAnalytics.validSessionCount, 8);
      expect(sessionAnalytics.length, 10);
      
      // Invalid sessions should not be flagged
      expect(sessionAnalytics[8].hasMinimumKicks, isFalse);
      expect(sessionAnalytics[8].isOutlier, isFalse);
    });

    test('should use hybrid window (before + after) for early sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      // Create 10 normal sessions with varying durations
      final sessions = <KickSession>[];
      for (int i = 0; i < 9; i++) {
        final startTime = baseTime.add(Duration(hours: i));
        sessions.add(KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        ));
      }
      
      // Add outlier as 4th session (30 minutes)
      final outlierTime = baseTime.add(Duration(hours: 3, minutes: 30));
      sessions.insert(3, KickSession(
        id: 'outlier-early',
        startTime: outlierTime,
        endTime: null,
        isActive: false,
        kicks: List.generate(10, (i) => Kick(
          id: 'kick-$i-outlier',
          sessionId: 'outlier-early',
          timestamp: outlierTime.add(Duration(minutes: i * 3)),
          sequenceNumber: i + 1,
          perceivedStrength: MovementStrength.moderate,
        )),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      ));

      final (historyAnalytics, sessionAnalytics) = 
          useCase.calculateAllWithRollingWindow(sessions);

      expect(historyAnalytics.validSessionCount, 10);
      
      // The 4th session (index 3) should be flagged as outlier
      // even though it only has 3 sessions before it
      // because we use a hybrid window (sessions before + after)
      expect(sessionAnalytics[3].hasMinimumKicks, isTrue);
      expect(sessionAnalytics[3].isOutlier, isTrue);
    });
  });

  group('[UseCase] calculateForGraph', () {
    test('should return empty analytics when < 7 valid sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final sessions = List.generate(5, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });

      final (graphAnalytics, sessionAnalytics) = 
          useCase.calculateForGraph(sessions.take(5).toList(), sessions);

      expect(graphAnalytics.validSessionCount, 0);
      expect(graphAnalytics.hasEnoughDataForAnalytics, isFalse);
    });

    test('should use one safe range for all graph sessions', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      // Create 20 sessions
      final allSessions = List.generate(20, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });
      
      // Take last 7 sessions for display
      final graphSessions = allSessions.sublist(13, 20);

      final (graphAnalytics, sessionAnalytics) = 
          useCase.calculateForGraph(graphSessions, allSessions);

      expect(sessionAnalytics.length, 7);
      
      // All 7 graph sessions are evaluated against the same safe range
      // calculated from sessions 0-19 (before session 19, the newest)
      expect(graphAnalytics.hasEnoughDataForAnalytics, isTrue);
    });

    test('should calculate safe range from 14 sessions before newest graph session', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      // Create 25 sessions
      final allSessions = List.generate(25, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });
      
      // Take last 7 sessions for graph (sessions 18-24)
      final graphSessions = allSessions.sublist(18, 25);

      final (graphAnalytics, sessionAnalytics) = 
          useCase.calculateForGraph(graphSessions, allSessions);

      expect(sessionAnalytics.length, 7);
      
      // Safe range should be calculated from sessions 10-23 (14 before session 24)
      // All graph sessions evaluated against this single safe range
      expect(graphAnalytics.hasEnoughDataForAnalytics, isTrue);
    });

    test('should apply IQR filtering to safe range calculation', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      // Create 10 normal sessions
      final allSessions = List.generate(10, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });
      
      // Add extreme outlier
      final extremeTime = baseTime.add(Duration(hours: 10));
      allSessions.add(KickSession(
        id: 'extreme',
        startTime: extremeTime,
        endTime: null,
        isActive: false,
        kicks: List.generate(10, (i) => Kick(
          id: 'kick-$i-extreme',
          sessionId: 'extreme',
          timestamp: extremeTime.add(Duration(hours: i)),
          sequenceNumber: i + 1,
          perceivedStrength: MovementStrength.moderate,
        )),
        totalPausedDuration: Duration.zero,
        pauseCount: 0,
      ));
      
      // Add 7 more normal sessions for graph
      final moreSessions = List.generate(7, (i) {
        final startTime = baseTime.add(Duration(hours: i + 11));
        return KickSession(
          id: 'session-${i + 11}',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-${i + 11}'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });
      allSessions.addAll(moreSessions);
      
      final graphSessions = allSessions.sublist(11, 18); // Last 7 sessions

      final (graphAnalytics, sessionAnalytics) = 
          useCase.calculateForGraph(graphSessions, allSessions);

      // The extreme outlier should be filtered out by IQR
      // so the normal graph sessions should not be flagged
      expect(sessionAnalytics.every((s) => !s.isOutlier), isTrue);
    });

    test('should handle graph sessions not in chronological order', () {
      final baseTime = DateTime(2024, 12, 1, 10, 0);
      final allSessions = List.generate(15, (i) {
        final startTime = baseTime.add(Duration(hours: i));
        return KickSession(
          id: 'session-$i',
          startTime: startTime,
          endTime: null,
          isActive: false,
          kicks: generateKicks(10, startTime, 'session-$i'),
          totalPausedDuration: Duration.zero,
          pauseCount: 0,
        );
      });
      
      // Provide graph sessions in random order
      final graphSessions = [
        allSessions[14],
        allSessions[10],
        allSessions[12],
        allSessions[11],
        allSessions[13],
        allSessions[9],
        allSessions[8],
      ];

      final (graphAnalytics, sessionAnalytics) = 
          useCase.calculateForGraph(graphSessions, allSessions);

      // Should still work correctly by finding the newest session
      expect(sessionAnalytics.length, 7);
      expect(graphAnalytics.hasEnoughDataForAnalytics, isTrue);
    });
  });
}

