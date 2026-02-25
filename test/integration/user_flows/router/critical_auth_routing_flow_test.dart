@Tags(['router', 'integration', 'critical_path'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/app/router/app_router.dart' show resolveAppRedirect;
import 'package:zeyra/app/router/routes.dart';

void main() {
  group('[Router] Critical auth routing flow', () {
    test(
      'should redirect to onboarding when unauthenticated on a new device',
      () {
        final redirect = resolveAppRedirect(
          onboardingStepLoaded: true,
          deviceOnboardedLoaded: true,
          isLoggedIn: false,
          hasCompletedOnboarding: false,
          deviceOnboarded: false,
          savedStep: 0,
          matchedLocation: ToolRoutes.account,
          onInvalidateDatabase: () {},
          onDebugLog: (_) {},
        );

        expect(redirect, OnboardingRoutes.welcome);
      },
    );

    test(
      'should redirect to auth when unauthenticated on an onboarded device',
      () {
        final redirect = resolveAppRedirect(
          onboardingStepLoaded: true,
          deviceOnboardedLoaded: true,
          isLoggedIn: false,
          hasCompletedOnboarding: false,
          deviceOnboarded: true,
          savedStep: 0,
          matchedLocation: ToolRoutes.account,
          onInvalidateDatabase: () {},
          onDebugLog: (_) {},
        );

        expect(redirect, AuthRoutes.auth);
      },
    );

    test(
      'should redirect restricted routes to hospital explore when onboarding is complete',
      () {
        var invalidated = false;
        final redirect = resolveAppRedirect(
          onboardingStepLoaded: true,
          deviceOnboardedLoaded: true,
          isLoggedIn: true,
          hasCompletedOnboarding: true,
          deviceOnboarded: true,
          savedStep: 2,
          matchedLocation: OnboardingRoutes.welcome,
          onInvalidateDatabase: () => invalidated = true,
          onDebugLog: (_) {},
        );

        expect(redirect, ToolRoutes.hospitalChooserExplore);
        expect(invalidated, isTrue);
      },
    );

    test(
      'should allow legal and account routes when onboarding is complete',
      () {
        final legalRedirect = resolveAppRedirect(
          onboardingStepLoaded: true,
          deviceOnboardedLoaded: true,
          isLoggedIn: true,
          hasCompletedOnboarding: true,
          deviceOnboarded: true,
          savedStep: 2,
          matchedLocation: LegalRoutes.termsOfService,
          onInvalidateDatabase: () {},
          onDebugLog: (_) {},
        );
        final accountRedirect = resolveAppRedirect(
          onboardingStepLoaded: true,
          deviceOnboardedLoaded: true,
          isLoggedIn: true,
          hasCompletedOnboarding: true,
          deviceOnboarded: true,
          savedStep: 2,
          matchedLocation: ToolRoutes.account,
          onInvalidateDatabase: () {},
          onDebugLog: (_) {},
        );

        expect(legalRedirect, isNull);
        expect(accountRedirect, isNull);
      },
    );
  });
}

