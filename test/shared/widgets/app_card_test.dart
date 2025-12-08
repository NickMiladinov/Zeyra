import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/shared/widgets/app_card.dart';

void main() {
  testWidgets('AppCard renders child and respects styling', (WidgetTester tester) async {
    const childText = 'Card Content';
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            child: Text(childText),
          ),
        ),
      ),
    );

    expect(find.text(childText), findsOneWidget);

    final container = tester.widget<Container>(find.descendant(
      of: find.byType(AppCard),
      matching: find.byType(Container).first,
    ));

    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.white); // AppColors.white is white
    expect(decoration.borderRadius, AppEffects.roundedXL);
    expect(decoration.boxShadow, AppEffects.shadowSM);
  });

  testWidgets('AppCard handles tap', (WidgetTester tester) async {
    bool tapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppCard(
            child: const Text('Tap me'),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppCard));
    expect(tapped, isTrue);
  });

  testWidgets('AppCard uses custom padding if provided', (WidgetTester tester) async {
    const customPadding = EdgeInsets.all(20.0);
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            padding: customPadding,
            child: Text('Padding'),
          ),
        ),
      ),
    );

    final paddingWidget = tester.widget<Padding>(find.descendant(
      of: find.byType(InkWell),
      matching: find.byType(Padding),
    ));

    expect(paddingWidget.padding, customPadding);
  });
}

