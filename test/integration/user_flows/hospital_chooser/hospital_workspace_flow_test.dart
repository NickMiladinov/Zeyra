@Tags(['hospital_chooser', 'integration', 'critical_path'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/app/router/routes.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/domain/repositories/hospital_shortlist_repository.dart';
import 'package:zeyra/features/hospital_chooser/ui/screens/hospital_shortlist_screen.dart';

import '../../../harness/integration_test_helpers.dart';
import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

GoRouter _createWorkspaceRouter() {
  return GoRouter(
    initialLocation: ToolRoutes.hospitalChooser,
    routes: [
      GoRoute(
        path: ToolRoutes.hospitalChooser,
        builder: (context, state) => const HospitalShortlistScreen(),
      ),
      GoRoute(
        path: ToolRoutes.account,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Account landing'))),
      ),
      GoRoute(
        path: ToolRoutes.hospitalChooserExplore,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Hospital explore landing'))),
      ),
    ],
  );
}

void main() {
  group('[HospitalChooser] Hospital workspace flow', () {
    late MockManageShortlistUseCase manageShortlist;
    late MockSelectFinalHospitalUseCase selectFinal;
    late ShortlistWithUnit selectedHospital;

    setUp(() {
      manageShortlist = MockManageShortlistUseCase();
      selectFinal = MockSelectFinalHospitalUseCase();

      final unit = FakeMaternityUnit.simple(name: 'St Mary Hospital');
      selectedHospital = FakeShortlistWithUnit.selected(unit: unit);

      when(
        () => manageShortlist.getShortlist(),
      ).thenAnswer((_) async => [selectedHospital]);
      when(
        () => selectFinal.getSelected(),
      ).thenAnswer((_) async => selectedHospital);
      when(() => selectFinal.clearSelection()).thenAnswer((_) async {});
    });

    testWidgets(
      'should render workspace data from mocked shortlist use cases',
      (tester) async {
        final router = _createWorkspaceRouter();
        addTearDown(router.dispose);

        await pumpRouterTestApp(
          tester,
          router: router,
          overrides: [
            manageShortlistUseCaseProvider.overrideWith(
              (ref) async => manageShortlist,
            ),
            selectFinalHospitalUseCaseProvider.overrideWith(
              (ref) async => selectFinal,
            ),
          ],
        );

        expect(find.text('My Hospital Workspace'), findsOneWidget);
        expect(find.text('St Mary Hospital'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('should open account route from app bar action', (tester) async {
      final router = _createWorkspaceRouter();
      addTearDown(router.dispose);

      await pumpRouterTestApp(
        tester,
        router: router,
        overrides: [
          manageShortlistUseCaseProvider.overrideWith(
            (ref) async => manageShortlist,
          ),
          selectFinalHospitalUseCaseProvider.overrideWith(
            (ref) async => selectFinal,
          ),
        ],
      );

      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Account landing'), findsOneWidget);
    });

    testWidgets('should push explore route from explore CTA', (tester) async {
      final router = _createWorkspaceRouter();
      addTearDown(router.dispose);

      await pumpRouterTestApp(
        tester,
        router: router,
        overrides: [
          manageShortlistUseCaseProvider.overrideWith(
            (ref) async => manageShortlist,
          ),
          selectFinalHospitalUseCaseProvider.overrideWith(
            (ref) async => selectFinal,
          ),
        ],
      );

      await tester.tap(find.text('Explore Hospitals'));
      await tester.pumpAndSettle();

      expect(find.text('Hospital explore landing'), findsOneWidget);
    });

    testWidgets(
      'should show snackbar when clear final choice fails',
      (tester) async {
        when(
          () => selectFinal.clearSelection(),
        ).thenThrow(Exception('clear failed'));

        final router = _createWorkspaceRouter();
        addTearDown(router.dispose);

        await pumpRouterTestApp(
          tester,
          router: router,
          overrides: [
            manageShortlistUseCaseProvider.overrideWith(
              (ref) async => manageShortlist,
            ),
            selectFinalHospitalUseCaseProvider.overrideWith(
              (ref) async => selectFinal,
            ),
          ],
        );

        await tester.tap(find.text('Clear final choice'));
        await tester.pumpAndSettle();

        expect(
          find.text('Unable to clear final choice. Please try again.'),
          findsOneWidget,
        );
      },
    );
  });
}

