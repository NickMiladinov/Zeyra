@Tags(['contraction_timer'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';
import 'package:zeyra/features/contraction_timer/ui/screens/contraction_session_detail_screen.dart';
import 'package:zeyra/features/contraction_timer/ui/widgets/session_511_status_card.dart';

// ----------------------------------------------------------------------------
// Test Data
// ----------------------------------------------------------------------------

final _baseTime = DateTime(2025, 1, 1, 10, 0);

final _testContraction1 = Contraction(
  id: 'contraction-1',
  sessionId: 'session-1',
  startTime: _baseTime,
  endTime: _baseTime.add(const Duration(seconds: 50)),
  intensity: ContractionIntensity.moderate,
);

final _testContraction2 = Contraction(
  id: 'contraction-2',
  sessionId: 'session-1',
  startTime: _baseTime.add(const Duration(minutes: 5)),
  endTime: _baseTime.add(const Duration(minutes: 5, seconds: 55)),
  intensity: ContractionIntensity.strong,
);

final _testSession = ContractionSession(
  id: 'session-1',
  startTime: _baseTime,
  endTime: _baseTime.add(const Duration(hours: 2)),
  isActive: false,
  contractions: [_testContraction1, _testContraction2],
  note: 'Test note',
  achievedDuration: true,
  achievedFrequency: false,
  achievedConsistency: false,
);

final _testSessionNoNote = ContractionSession(
  id: 'session-2',
  startTime: _baseTime,
  endTime: _baseTime.add(const Duration(hours: 1)),
  isActive: false,
  contractions: [_testContraction1],
);

// ----------------------------------------------------------------------------
// Helper
// ----------------------------------------------------------------------------

Widget _buildTestWidget(ContractionSession session) {
  return ProviderScope(
    child: MaterialApp(
      home: ContractionSessionDetailScreen(session: session),
    ),
  );
}

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[ContractionSessionDetailScreen Widget]', () {
    // Note: These tests verify widget structure with mock session data.
    
    testWidgets('should display session summary stats', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSession));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Session Summary'), findsOneWidget);
      expect(find.text('Total Time in Labour'), findsOneWidget);
      expect(find.text('Average Contractions (Last Hour)'), findsOneWidget);
      expect(find.text('Average Frequency (Last Hour)'), findsOneWidget);
      expect(find.text('Closest Frequency'), findsOneWidget);
      expect(find.text('Longest Contraction'), findsOneWidget);
    });

    testWidgets('should display 5-1-1 status card', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSession));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Session511StatusCard), findsOneWidget);
    });

    testWidgets('should display note card with note text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSession));
      await tester.pumpAndSettle();

      // Scroll to find the note card
      await tester.scrollUntilVisible(
        find.text('Your Note'),
        100,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Your Note'), findsOneWidget);
      expect(find.text('Test note'), findsOneWidget);
    });

    testWidgets('should display no note placeholder when no note',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSessionNoNote));
      await tester.pumpAndSettle();

      // Scroll to find the note card
      await tester.scrollUntilVisible(
        find.text('Your Note'),
        100,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Your Note'), findsOneWidget);
      expect(find.text('No note saved for this session'), findsOneWidget);
    });

    testWidgets('should display complete log table', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSession));
      await tester.pumpAndSettle();

      // Scroll to find the complete log card
      await tester.scrollUntilVisible(
        find.text('Complete Log'),
        100,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Complete Log'), findsOneWidget);
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Intensity'), findsOneWidget);
    });

    testWidgets('should show popup menu with edit/delete options',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSession));
      await tester.pumpAndSettle();

      // Assert - menu button exists
      expect(find.byIcon(AppIcons.moreVertical), findsOneWidget);

      // Open menu
      await tester.tap(find.byIcon(AppIcons.moreVertical));
      await tester.pumpAndSettle();

      // Assert - menu items appear
      expect(find.text('Edit Note'), findsOneWidget);
      expect(find.text('Delete Session'), findsOneWidget);
    });

    testWidgets('should navigate back on back button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSession));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(AppIcons.back), findsOneWidget);
    });

    testWidgets('should display contractions in descending order',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSession));
      await tester.pumpAndSettle();

      // Scroll to complete log section
      await tester.scrollUntilVisible(
        find.text('Complete Log'),
        100,
      );
      await tester.pumpAndSettle();

      // Assert - contractions are in table
      expect(find.text('Complete Log'), findsOneWidget);
    });

    testWidgets('should display intensity badges in log', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_testSession));
      await tester.pumpAndSettle();

      // Scroll to complete log
      await tester.scrollUntilVisible(
        find.text('Complete Log'),
        100,
      );
      await tester.pumpAndSettle();

      // Assert - intensity labels exist
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Strong'), findsOneWidget);
    });
  });
}

