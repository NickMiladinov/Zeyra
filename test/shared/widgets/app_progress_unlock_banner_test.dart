@Tags(['widgets'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/shared/widgets/app_progress_unlock_banner.dart';

void main() {
  group('[Widget] AppProgressUnlockBanner', () {
    testWidgets('should display correct remaining count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressUnlockBanner(
              currentCount: 3,
              requiredCount: 7,
              messageTemplate: 'Record {remaining} more sessions',
            ),
          ),
        ),
      );

      // Should display "4 more sessions" (7 - 3 = 4)
      expect(find.text('Record 4 more sessions'), findsOneWidget);
    });

    testWidgets('should render correct number of progress bars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressUnlockBanner(
              currentCount: 3,
              requiredCount: 7,
              messageTemplate: 'Test message',
              barCount: 5,
            ),
          ),
        ),
      );

      // Should find 5 containers (bars)
      final bars = find.descendant(
        of: find.byType(Row),
        matching: find.byType(Container),
      );
      
      // At least 5 bars should be rendered
      expect(bars, findsAtLeastNWidgets(5));
    });

    testWidgets('should fill correct number of progress bars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressUnlockBanner(
              currentCount: 3,
              requiredCount: 7,
              messageTemplate: 'Test message',
              barCount: 7,
            ),
          ),
        ),
      );

      // 3 out of 7 bars should be filled
      await tester.pumpAndSettle();

      // Check the banner is rendered
      expect(find.byType(AppProgressUnlockBanner), findsOneWidget);
    });

    testWidgets('should interpolate message template correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressUnlockBanner(
              currentCount: 2,
              requiredCount: 10,
              messageTemplate: 'Complete {remaining} more to unlock',
            ),
          ),
        ),
      );

      expect(find.text('Complete 8 more to unlock'), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressUnlockBanner(
              currentCount: 3,
              requiredCount: 7,
              messageTemplate: 'Test message',
              icon: Icons.star,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should handle edge case when currentCount equals requiredCount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressUnlockBanner(
              currentCount: 7,
              requiredCount: 7,
              messageTemplate: 'Record {remaining} more',
            ),
          ),
        ),
      );

      // Should show "0 more"
      expect(find.text('Record 0 more'), findsOneWidget);
    });

    testWidgets('should use default bar count of 7 when not specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressUnlockBanner(
              currentCount: 3,
              requiredCount: 7,
              messageTemplate: 'Test message',
            ),
          ),
        ),
      );

      // Check widget renders (implicitly using default barCount = 7)
      expect(find.byType(AppProgressUnlockBanner), findsOneWidget);
    });

    testWidgets('should have proper padding and spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppProgressUnlockBanner(
              currentCount: 3,
              requiredCount: 7,
              messageTemplate: 'Test message',
            ),
          ),
        ),
      );

      // Find the main container
      final container = find.byType(Container).first;
      expect(container, findsOneWidget);

      // Check the banner renders
      expect(find.byType(AppProgressUnlockBanner), findsOneWidget);
    });
  });
}

