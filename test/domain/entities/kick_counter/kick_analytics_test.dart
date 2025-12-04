@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_analytics.dart';

void main() {
  group('[Domain] KickSessionAnalytics', () {
    test('should create session analytics with all fields', () {
      const analytics = KickSessionAnalytics(
        durationToTen: Duration(minutes: 15),
        hasMinimumKicks: true,
        isOutlier: true,
      );

      expect(analytics.durationToTen, const Duration(minutes: 15));
      expect(analytics.hasMinimumKicks, isTrue);
      expect(analytics.isOutlier, isTrue);
    });

    test('should support equality comparison', () {
      const analytics1 = KickSessionAnalytics(
        durationToTen: Duration(minutes: 15),
        hasMinimumKicks: true,
        isOutlier: false,
      );

      const analytics2 = KickSessionAnalytics(
        durationToTen: Duration(minutes: 15),
        hasMinimumKicks: true,
        isOutlier: false,
      );

      expect(analytics1, equals(analytics2));
      expect(analytics1.hashCode, equals(analytics2.hashCode));
    });

    test('should have correct toString format', () {
      const analytics = KickSessionAnalytics(
        durationToTen: Duration(minutes: 15),
        hasMinimumKicks: true,
        isOutlier: true,
      );

      final string = analytics.toString();
      expect(string, contains('KickSessionAnalytics'));
      expect(string, contains('hasMinimumKicks: true'));
      expect(string, contains('isOutlier: true'));
    });
  });

  group('[Domain] KickHistoryAnalytics', () {
    test('should create history analytics with valid session count', () {
      const analytics = KickHistoryAnalytics(
        validSessionCount: 10,
        averageDurationToTen: Duration(minutes: 20),
        standardDeviation: Duration(minutes: 5),
        upperThreshold: Duration(minutes: 30),
      );

      expect(analytics.validSessionCount, 10);
      expect(analytics.averageDurationToTen, const Duration(minutes: 20));
      expect(analytics.standardDeviation, const Duration(minutes: 5));
      expect(analytics.upperThreshold, const Duration(minutes: 30));
    });

    test('should calculate hasEnoughDataForAnalytics correctly when >= 7', () {
      const analytics = KickHistoryAnalytics(
        validSessionCount: 7,
      );

      expect(analytics.hasEnoughDataForAnalytics, isTrue);
    });

    test('should calculate hasEnoughDataForAnalytics correctly when < 7', () {
      const analytics = KickHistoryAnalytics(
        validSessionCount: 6,
      );

      expect(analytics.hasEnoughDataForAnalytics, isFalse);
    });

    test('should have correct minSessionsForAnalytics constant', () {
      expect(KickHistoryAnalytics.minSessionsForAnalytics, 7);
    });

    test('should support equality comparison', () {
      const analytics1 = KickHistoryAnalytics(
        validSessionCount: 10,
        averageDurationToTen: Duration(minutes: 20),
        standardDeviation: Duration(minutes: 5),
        upperThreshold: Duration(minutes: 30),
      );

      const analytics2 = KickHistoryAnalytics(
        validSessionCount: 10,
        averageDurationToTen: Duration(minutes: 20),
        standardDeviation: Duration(minutes: 5),
        upperThreshold: Duration(minutes: 30),
      );

      expect(analytics1, equals(analytics2));
      expect(analytics1.hashCode, equals(analytics2.hashCode));
    });

    test('should have correct toString format', () {
      const analytics = KickHistoryAnalytics(
        validSessionCount: 10,
        averageDurationToTen: Duration(minutes: 20),
        standardDeviation: Duration(minutes: 5),
        upperThreshold: Duration(minutes: 30),
      );

      final string = analytics.toString();
      expect(string, contains('KickHistoryAnalytics'));
      expect(string, contains('validSessionCount: 10'));
      expect(string, contains('hasEnoughDataForAnalytics: true'));
    });
  });
}

