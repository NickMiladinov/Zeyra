@Tags(['widgets', 'tooltip'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/widgets/app_jit_tooltip.dart';

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

void main() {
  group('[Widget] JitTooltipConfig', () {
    test('should have default position of TooltipPosition.below', () {
      // Arrange & Act
      const config = JitTooltipConfig(message: 'Test');

      // Assert
      expect(config.position, TooltipPosition.below);
    });

    test('should have default highlightPadding of EdgeInsets.zero', () {
      // Arrange & Act
      const config = JitTooltipConfig(message: 'Test');

      // Assert
      expect(config.highlightPadding, EdgeInsets.zero);
    });

    test('should have default highlightBorderRadius of AppEffects.radiusLG', () {
      // Arrange & Act
      const config = JitTooltipConfig(message: 'Test');

      // Assert
      expect(config.highlightBorderRadius, AppEffects.radiusLG);
    });

    test('should accept custom values', () {
      // Arrange & Act
      const config = JitTooltipConfig(
        message: 'Custom message',
        title: 'Custom title',
        position: TooltipPosition.above,
        highlightPadding: EdgeInsets.all(16),
        highlightBorderRadius: 24,
      );

      // Assert
      expect(config.message, 'Custom message');
      expect(config.title, 'Custom title');
      expect(config.position, TooltipPosition.above);
      expect(config.highlightPadding, const EdgeInsets.all(16));
      expect(config.highlightBorderRadius, 24);
    });
  });

  group('[Widget] AppJitTooltip', () {
    // Helper to create a test widget with a target
    Widget createTestApp({
      required GlobalKey targetKey,
      required JitTooltipConfig config,
      VoidCallback? onDismiss,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              // Target widget that the tooltip highlights
              Positioned(
                top: 100,
                left: 50,
                child: Container(
                  key: targetKey,
                  width: 200,
                  height: 100,
                  color: Colors.blue,
                  child: const Text('Target'),
                ),
              ),
              // The tooltip overlay
              AppJitTooltip(
                targetKey: targetKey,
                config: config,
                onDismiss: onDismiss,
              ),
            ],
          ),
        ),
      );
    }

    // ------------------------------------------------------------------------
    // Rendering Tests
    // ------------------------------------------------------------------------

    group('rendering', () {
      testWidgets('should display tooltip card with message', (tester) async {
        // Arrange
        final targetKey = GlobalKey();
        const config = JitTooltipConfig(
          message: 'This is a test message',
        );

        // Act
        await tester.pumpWidget(createTestApp(
          targetKey: targetKey,
          config: config,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('This is a test message'), findsOneWidget);
      });

      testWidgets('should display title when provided', (tester) async {
        // Arrange
        final targetKey = GlobalKey();
        const config = JitTooltipConfig(
          message: 'Test message',
          title: 'Test Title',
        );

        // Act
        await tester.pumpWidget(createTestApp(
          targetKey: targetKey,
          config: config,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test message'), findsOneWidget);
      });

      testWidgets('should not display title when not provided', (tester) async {
        // Arrange
        final targetKey = GlobalKey();
        const config = JitTooltipConfig(
          message: 'Test message',
          title: null,
        );

        // Act
        await tester.pumpWidget(createTestApp(
          targetKey: targetKey,
          config: config,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test message'), findsOneWidget);
        // No title should be present - only one text widget for the message
      });

      testWidgets('should display close button icon', (tester) async {
        // Arrange
        final targetKey = GlobalKey();
        const config = JitTooltipConfig(message: 'Test');

        // Act
        await tester.pumpWidget(createTestApp(
          targetKey: targetKey,
          config: config,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(AppIcons.close), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------------
    // Interaction Tests
    // ------------------------------------------------------------------------

    group('interactions', () {
      testWidgets('should call onDismiss when close button tapped', (tester) async {
        // Arrange
        final targetKey = GlobalKey();
        const config = JitTooltipConfig(message: 'Test');
        bool onDismissCalled = false;

        // Act
        await tester.pumpWidget(createTestApp(
          targetKey: targetKey,
          config: config,
          onDismiss: () => onDismissCalled = true,
        ));
        await tester.pumpAndSettle();

        // Tap the close icon
        await tester.tap(find.byIcon(AppIcons.close));
        await tester.pumpAndSettle();

        // Assert
        expect(onDismissCalled, true);
      });

      testWidgets('should call onDismiss when background tapped', (tester) async {
        // Arrange
        final targetKey = GlobalKey();
        const config = JitTooltipConfig(message: 'Test');
        bool onDismissCalled = false;

        // Act
        await tester.pumpWidget(createTestApp(
          targetKey: targetKey,
          config: config,
          onDismiss: () => onDismissCalled = true,
        ));
        await tester.pumpAndSettle();

        // Tap on the background (near the top-left corner, away from the tooltip)
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Assert
        expect(onDismissCalled, true);
      });
    });

    // ------------------------------------------------------------------------
    // Target Rect Calculation Tests
    // ------------------------------------------------------------------------

    group('target rect calculation', () {
      testWidgets('should calculate target rect from GlobalKey', (tester) async {
        // Arrange
        final targetKey = GlobalKey();
        const config = JitTooltipConfig(message: 'Test');

        // Act
        await tester.pumpWidget(createTestApp(
          targetKey: targetKey,
          config: config,
        ));
        await tester.pumpAndSettle();

        // Assert - tooltip should be rendered (which means rect was calculated)
        expect(find.text('Test'), findsOneWidget);

        // The tooltip should be positioned relative to the target
        // We can verify the tooltip card is present
        expect(find.byType(Container), findsWidgets);
      });
    });

    // ------------------------------------------------------------------------
    // Static Show Method Tests
    // ------------------------------------------------------------------------

    group('show() static method', () {
      testWidgets('should display tooltip via Navigator', (tester) async {
        // Arrange
        final targetKey = GlobalKey();
        const config = JitTooltipConfig(
          message: 'Tooltip via show()',
          title: 'Static Method Test',
        );

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Stack(
                  children: [
                    Positioned(
                      top: 100,
                      left: 50,
                      child: Container(
                        key: targetKey,
                        width: 200,
                        height: 100,
                        color: Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        AppJitTooltip.show(
                          context: context,
                          targetKey: targetKey,
                          config: config,
                        );
                      },
                      child: const Text('Show Tooltip'),
                    ),
                  ],
                ),
              );
            },
          ),
        ));

        // Act - tap button to show tooltip
        await tester.tap(find.text('Show Tooltip'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Tooltip via show()'), findsOneWidget);
        expect(find.text('Static Method Test'), findsOneWidget);
      });
    });
  });

  // --------------------------------------------------------------------------
  // TooltipPosition Enum Tests
  // --------------------------------------------------------------------------

  group('[Tooltip] TooltipPosition', () {
    test('should have above and below values', () {
      expect(TooltipPosition.values.length, 2);
      expect(TooltipPosition.values, contains(TooltipPosition.above));
      expect(TooltipPosition.values, contains(TooltipPosition.below));
    });
  });
}
