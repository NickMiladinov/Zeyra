@Tags(['account', 'integration', 'critical_path'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/app/router/routes.dart';
import 'package:zeyra/core/services/account_service.dart';
import 'package:zeyra/features/account/logic/account_notifier.dart';
import 'package:zeyra/features/account/ui/screens/account_details_screen.dart';
import 'package:zeyra/features/account/ui/screens/account_screen.dart';

import '../../../harness/integration_test_helpers.dart';
import '../../../mocks/fake_data/account_fakes.dart';

GoRouter _createTestRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AuthRoutes.auth,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Auth landing'))),
      ),
      GoRoute(
        path: ToolRoutes.account,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: ToolRoutes.accountDetails,
        builder: (context, state) => const AccountDetailsScreen(),
      ),
      GoRoute(
        path: ToolRoutes.accountSupport,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Support landing'))),
      ),
      GoRoute(
        path: ToolRoutes.dataSourceDisclaimer,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Data source disclaimer landing')),
        ),
      ),
      GoRoute(
        path: LegalRoutes.termsOfService,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Terms landing'))),
      ),
      GoRoute(
        path: LegalRoutes.privacyPolicy,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Privacy landing'))),
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
  group('[Account] Account lifecycle flow', () {
    late MockAccountService accountService;

    setUp(() {
      accountService = MockAccountService();
      when(
        () => accountService.getCurrentIdentity(),
      ).thenReturn(FakeAccountIdentityBuilder.google());
    });

    testWidgets(
      'should navigate to auth when sign out succeeds from account hub',
      (tester) async {
        when(() => accountService.signOut()).thenAnswer((_) async {});
        final router = _createTestRouter(initialLocation: ToolRoutes.account);
        addTearDown(router.dispose);

        await pumpRouterTestApp(
          tester,
          router: router,
          overrides: [
            accountNotifierProvider.overrideWith(
              (ref) => AccountNotifier(accountService: accountService),
            ),
          ],
        );

        await tester.tap(find.text('Sign Out'));
        await tester.pumpAndSettle();

        expect(find.text('Auth landing'), findsOneWidget);
        verify(() => accountService.signOut()).called(1);
      },
    );

    testWidgets(
      'should not delete account when user cancels confirmation',
      (tester) async {
        when(() => accountService.deleteCurrentAccount()).thenAnswer((_) async {});
        final router = _createTestRouter(initialLocation: ToolRoutes.accountDetails);
        addTearDown(router.dispose);

        await pumpRouterTestApp(
          tester,
          router: router,
          overrides: [
            accountNotifierProvider.overrideWith(
              (ref) => AccountNotifier(accountService: accountService),
            ),
          ],
        );

        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();

        verifyNever(() => accountService.deleteCurrentAccount());
        expect(find.text('Account Details'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to auth when delete account succeeds after confirmation',
      (tester) async {
        when(() => accountService.deleteCurrentAccount()).thenAnswer((_) async {});
        final router = _createTestRouter(initialLocation: ToolRoutes.accountDetails);
        addTearDown(router.dispose);

        await pumpRouterTestApp(
          tester,
          router: router,
          overrides: [
            accountNotifierProvider.overrideWith(
              (ref) => AccountNotifier(accountService: accountService),
            ),
          ],
        );

        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();

        verify(() => accountService.deleteCurrentAccount()).called(1);
        expect(find.text('Auth landing'), findsOneWidget);
      },
    );

    testWidgets(
      'should show error and remain on details when delete account fails',
      (tester) async {
        when(
          () => accountService.deleteCurrentAccount(),
        ).thenThrow(const AccountServiceException('Delete failed'));
        final router = _createTestRouter(initialLocation: ToolRoutes.accountDetails);
        addTearDown(router.dispose);

        await pumpRouterTestApp(
          tester,
          router: router,
          overrides: [
            accountNotifierProvider.overrideWith(
              (ref) => AccountNotifier(accountService: accountService),
            ),
          ],
        );

        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();

        verify(() => accountService.deleteCurrentAccount()).called(1);
        expect(find.text('Delete failed'), findsOneWidget);
        expect(find.text('Account Details'), findsOneWidget);
      },
    );
  });
}

