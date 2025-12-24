@Tags(['contraction_timer'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';
import 'package:zeyra/features/contraction_timer/ui/widgets/session_511_status_card.dart';

// ----------------------------------------------------------------------------
// Test Data
// ----------------------------------------------------------------------------

final _baseTime = DateTime(2025, 1, 1, 10, 0);

// Dummy contraction for sessions that need contractionCount > 0
final _dummyContraction = Contraction(
  id: 'contraction-1',
  sessionId: 'session-1',
  startTime: _baseTime.add(const Duration(minutes: 5)),
  endTime: _baseTime.add(const Duration(minutes: 6)),
  intensity: ContractionIntensity.moderate,
);

final _sessionNoAchievement = ContractionSession(
  id: 'session-1',
  startTime: _baseTime,
  endTime: _baseTime.add(const Duration(hours: 1)),
  isActive: false,
  contractions: [_dummyContraction], // Need at least 1 to show "useful tracking data" message
  achievedDuration: false,
  achievedFrequency: false,
  achievedConsistency: false,
);

final _sessionFullAlert = ContractionSession(
  id: 'session-2',
  startTime: _baseTime,
  endTime: _baseTime.add(const Duration(hours: 2)),
  isActive: false,
  contractions: [],
  achievedDuration: true,
  durationAchievedAt: _baseTime.add(const Duration(minutes: 10)),
  achievedFrequency: true,
  frequencyAchievedAt: _baseTime.add(const Duration(minutes: 10)),
  achievedConsistency: true,
  consistencyAchievedAt: _baseTime.add(const Duration(hours: 1)),
);

final _sessionPartialDurationFrequency = ContractionSession(
  id: 'session-3',
  startTime: _baseTime,
  endTime: _baseTime.add(const Duration(hours: 1)),
  isActive: false,
  contractions: [],
  achievedDuration: true,
  durationAchievedAt: _baseTime.add(const Duration(minutes: 10)),
  achievedFrequency: true,
  frequencyAchievedAt: _baseTime.add(const Duration(minutes: 10)),
  achievedConsistency: false,
);

final _sessionOnlyFrequency = ContractionSession(
  id: 'session-4',
  startTime: _baseTime,
  endTime: _baseTime.add(const Duration(hours: 1)),
  isActive: false,
  contractions: [],
  achievedDuration: false,
  achievedFrequency: true,
  frequencyAchievedAt: _baseTime.add(const Duration(minutes: 10)),
  achievedConsistency: false,
);

// ----------------------------------------------------------------------------
// Helper
// ----------------------------------------------------------------------------

Widget _buildTestWidget(ContractionSession session) {
  return MaterialApp(
    home: Scaffold(
      body: Session511StatusCard(session: session),
    ),
  );
}

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[Session511StatusCard Widget]', () {
    testWidgets('should display 5-1-1 Rule Progress header', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_sessionNoAchievement));

      // Assert
      expect(find.text('5-1-1 Rule Progress'), findsOneWidget);
    });

    testWidgets('should show all three checklist items', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_sessionNoAchievement));

      // Assert
      expect(find.text('Contractions every 5 minutes'), findsOneWidget);
      expect(find.text('Lasting 1 minute each'), findsOneWidget);
      expect(find.text('For 1 hour consistently'), findsOneWidget);
    });

    testWidgets('should check items when criteria achieved', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_sessionFullAlert));

      // Assert - all three checkboxes should have check icons
      expect(find.byIcon(AppIcons.checkIcon), findsNWidgets(3));
    });

    testWidgets('should not check items when criteria not achieved',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_sessionNoAchievement));

      // Assert - no check icons should be present
      expect(find.byIcon(AppIcons.checkIcon), findsNothing);
    });

    testWidgets('should show alert message when all criteria met',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_sessionFullAlert));

      // Assert
      expect(
        find.textContaining('This session met all 5-1-1 rule criteria'),
        findsOneWidget,
      );
    });

    testWidgets('should show partial progress message for two criteria',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        _buildTestWidget(_sessionPartialDurationFrequency),
      );

      // Assert
      expect(
        find.textContaining('Contractions were regular and strong'),
        findsOneWidget,
      );
    });

    testWidgets('should show single criterion message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_sessionOnlyFrequency));

      // Assert
      expect(
        find.textContaining('Contractions came regularly'),
        findsOneWidget,
      );
    });

    testWidgets('should show no criteria message when none achieved',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_sessionNoAchievement));

      // Assert
      expect(
        find.textContaining('This session provided useful tracking data'),
        findsOneWidget,
      );
    });

    testWidgets('should apply alert styling when achieved511Alert',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_sessionFullAlert));

      // Assert - find container with error-themed decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Session511StatusCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('should check exactly two items for partial achievement',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        _buildTestWidget(_sessionPartialDurationFrequency),
      );

      // Assert - exactly two check icons
      expect(find.byIcon(AppIcons.checkIcon), findsNWidgets(2));
    });
  });
}

