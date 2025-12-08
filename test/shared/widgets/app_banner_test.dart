import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/shared/widgets/app_banner.dart';

void main() {
  testWidgets('AppBanner renders title correctly', (WidgetTester tester) async {
    const testTitle = 'Test Title';
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBanner(
            title: testTitle,
          ),
        ),
      ),
    );

    expect(find.text(testTitle), findsOneWidget);
    // Should have spacing for icons even if not provided
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('AppBanner renders icons and triggers callbacks', (WidgetTester tester) async {
    bool leadingPressed = false;
    bool trailingPressed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppBanner(
            title: 'Title',
            leadingIcon: Icons.menu,
            onLeadingPressed: () => leadingPressed = true,
            trailingIcon: Icons.settings,
            onTrailingPressed: () => trailingPressed = true,
          ),
        ),
      ),
    );

    // Find icons
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Tap leading
    await tester.tap(find.byIcon(Icons.menu));
    expect(leadingPressed, isTrue);

    // Tap trailing
    await tester.tap(find.byIcon(Icons.settings));
    expect(trailingPressed, isTrue);
  });

  testWidgets('AppBanner respects padding requirements', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBanner(title: 'Padding Test'),
        ),
      ),
    );

    // Find the inner container (which has color white)
    final container = tester.widget<Container>(find.descendant(
      of: find.byType(AppBanner),
      matching: find.byType(Container),
    ));

    // Padding should include top padding (which is dynamic with MediaQuery, 
    // but standard EdgeInsets.only structure)
    final padding = container.padding as EdgeInsets;
    expect(padding.left, AppSpacing.paddingLG);
    expect(padding.right, AppSpacing.paddingLG);
    expect(padding.bottom, AppSpacing.paddingLG);
    // Top padding depends on MediaQuery, assuming 0 in test environment usually, 
    // but logic adds AppSpacing.paddingLG
    expect(padding.top, greaterThanOrEqualTo(AppSpacing.paddingLG));
  });

  testWidgets('AppBanner has default bottom spacing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBanner(title: 'Spacing Test'),
        ),
      ),
    );

    final paddingWidget = tester.widget<Padding>(find.descendant(
      of: find.byType(AppBanner),
      matching: find.byType(Padding).first,
    ));

    final padding = paddingWidget.padding as EdgeInsets;
    expect(padding.bottom, AppSpacing.paddingXL);
  });

  testWidgets('AppBanner allows custom bottom spacing', (WidgetTester tester) async {
    const customSpacing = 50.0;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBanner(
            title: 'Custom Spacing',
            bottomSpacing: customSpacing,
          ),
        ),
      ),
    );

    final paddingWidget = tester.widget<Padding>(find.descendant(
      of: find.byType(AppBanner),
      matching: find.byType(Padding).first,
    ));

    final padding = paddingWidget.padding as EdgeInsets;
    expect(padding.bottom, customSpacing);
  });
}
