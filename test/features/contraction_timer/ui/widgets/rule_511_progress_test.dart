@Tags(['contraction_timer'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/contraction_timer/rule_511_status.dart';
import 'package:zeyra/features/contraction_timer/ui/widgets/rule_511_progress.dart';

// ----------------------------------------------------------------------------
// Test Data
// ----------------------------------------------------------------------------

const _emptyStatus = Rule511Status(
  alertActive: false,
  contractionsInWindow: 0,
  validDurationCount: 0,
  validFrequencyCount: 0,
  validityPercentage: 0.0,
  durationProgress: 0.0,
  frequencyProgress: 0.0,
  consistencyProgress: 0.0,
);

const _alertStatus = Rule511Status(
  alertActive: true,
  contractionsInWindow: 8,
  validDurationCount: 7,
  validFrequencyCount: 7,
  validityPercentage: 0.85,
  durationProgress: 1.0,
  frequencyProgress: 1.0,
  consistencyProgress: 1.0,
);

const _durationAchievedStatus = Rule511Status(
  alertActive: false,
  contractionsInWindow: 4,
  validDurationCount: 4,
  validFrequencyCount: 1,
  validityPercentage: 0.5,
  durationProgress: 1.0,
  frequencyProgress: 0.4,
  consistencyProgress: 0.3,
);

const _frequencyAchievedStatus = Rule511Status(
  alertActive: false,
  contractionsInWindow: 4,
  validDurationCount: 1,
  validFrequencyCount: 3,
  validityPercentage: 0.5,
  durationProgress: 0.4,
  frequencyProgress: 1.0,
  consistencyProgress: 0.3,
);

// ----------------------------------------------------------------------------
// Helper
// ----------------------------------------------------------------------------

Widget _buildTestWidget(Rule511Status status, {int contractionCount = 0}) {
  return MaterialApp(
    home: Scaffold(
      body: Rule511Progress(
        status: status,
        contractionCount: contractionCount,
      ),
    ),
  );
}

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[Rule511Progress Widget]', () {
    testWidgets('should display progress tracking header', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_emptyStatus));

      // Assert
      expect(find.text('Progress Tracking'), findsOneWidget);
      expect(find.byIcon(AppIcons.infoIcon), findsOneWidget);
    });

    testWidgets('should show alert message when alertActive is true',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_alertStatus, contractionCount: 8));

      // Assert
      expect(
        find.textContaining('Call your midwife or maternity unit now'),
        findsOneWidget,
      );
      expect(find.byIcon(AppIcons.warningIcon), findsOneWidget);
    });

    testWidgets('should show duration/frequency achieved message',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(
        const Rule511Status(
          alertActive: false,
          contractionsInWindow: 4,
          validDurationCount: 4,
          validFrequencyCount: 3,
          validityPercentage: 0.7,
          durationProgress: 1.0,
          frequencyProgress: 1.0,
          consistencyProgress: 0.5,
        ),
        contractionCount: 4,
      ));

      // Assert
      expect(
        find.textContaining('Contractions are regular and strong'),
        findsOneWidget,
      );
    });

    testWidgets('should show frequency achieved message when only frequency met',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        _buildTestWidget(_frequencyAchievedStatus, contractionCount: 4),
      );

      // Assert
      expect(
        find.textContaining('Contractions are coming regularly'),
        findsOneWidget,
      );
    });

    testWidgets('should show duration achieved message when only duration met',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        _buildTestWidget(_durationAchievedStatus, contractionCount: 4),
      );

      // Assert
      expect(
        find.textContaining('Contractions are lasting long enough'),
        findsOneWidget,
      );
    });

    testWidgets('should show default message when no criteria met',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_emptyStatus));

      // Assert
      expect(
        find.textContaining('Start timing your contractions'),
        findsOneWidget,
      );
    });

    testWidgets('should display three progress indicators', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_emptyStatus));

      // Assert - find progress indicators by their labels
      expect(find.textContaining('Duration'), findsOneWidget);
      expect(find.textContaining('Frequency'), findsOneWidget);
      expect(find.textContaining('For over'), findsOneWidget);
      // Verify there are at least 3 CustomPaint widgets (for progress rings)
      expect(find.byType(CustomPaint), findsAtLeast(3));
    });

    testWidgets('should show check icon when progress is complete',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_alertStatus, contractionCount: 8));

      // Assert - all three indicators should show check icons
      expect(find.byIcon(AppIcons.checkIcon), findsNWidgets(3));
    });

    testWidgets('should apply alert styling when alertActive', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(_buildTestWidget(_alertStatus, contractionCount: 8));

      // Assert - find container with error-themed border
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Rule511Progress),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(find.byIcon(AppIcons.warningIcon), findsOneWidget);
    });
  });
}

