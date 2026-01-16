@Tags(['router', 'routes'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/app/router/routes.dart';

void main() {
  group('[Router] AuthRoutes', () {
    test('should have correct auth path', () {
      expect(AuthRoutes.auth, equals('/auth'));
    });
  });

  group('[Router] OnboardingRoutes', () {
    test('should have correct base path', () {
      expect(OnboardingRoutes.base, equals('/onboarding'));
    });

    test('should have correct welcome path', () {
      expect(OnboardingRoutes.welcome, equals('/onboarding/welcome'));
    });

    test('should have correct screen paths', () {
      expect(OnboardingRoutes.name, equals('/onboarding/name'));
      expect(OnboardingRoutes.dueDate, equals('/onboarding/due-date'));
      expect(OnboardingRoutes.congratulations, equals('/onboarding/congratulations'));
      expect(OnboardingRoutes.valueProp1, equals('/onboarding/value-1'));
      expect(OnboardingRoutes.valueProp2, equals('/onboarding/value-2'));
      expect(OnboardingRoutes.valueProp3, equals('/onboarding/value-3'));
      expect(OnboardingRoutes.birthDate, equals('/onboarding/birth-date'));
      expect(OnboardingRoutes.notifications, equals('/onboarding/notifications'));
      expect(OnboardingRoutes.paywall, equals('/onboarding/paywall'));
      expect(OnboardingRoutes.auth, equals('/onboarding/auth'));
    });

    test('orderedRoutes should have 11 routes', () {
      expect(OnboardingRoutes.orderedRoutes.length, equals(11));
    });

    test('getRouteForStep should return correct route', () {
      expect(OnboardingRoutes.getRouteForStep(0), equals(OnboardingRoutes.welcome));
      expect(OnboardingRoutes.getRouteForStep(3), equals(OnboardingRoutes.congratulations));
      expect(OnboardingRoutes.getRouteForStep(10), equals(OnboardingRoutes.auth));
    });

    test('getRouteForStep should return welcome for invalid step', () {
      expect(OnboardingRoutes.getRouteForStep(-1), equals(OnboardingRoutes.welcome));
      expect(OnboardingRoutes.getRouteForStep(100), equals(OnboardingRoutes.welcome));
    });

    test('getStepForRoute should return correct step index', () {
      expect(OnboardingRoutes.getStepForRoute(OnboardingRoutes.welcome), equals(0));
      expect(OnboardingRoutes.getStepForRoute(OnboardingRoutes.paywall), equals(9));
      expect(OnboardingRoutes.getStepForRoute(OnboardingRoutes.auth), equals(10));
    });
  });

  group('[Router] MainRoutes', () {
    test('should have correct main path', () {
      expect(MainRoutes.main, equals('/main'));
    });

    test('should have correct today path', () {
      expect(MainRoutes.today, equals('/main/today'));
    });

    test('should have correct myHealth path', () {
      expect(MainRoutes.myHealth, equals('/main/my-health'));
    });

    test('should have correct baby path', () {
      expect(MainRoutes.baby, equals('/main/baby'));
    });

    test('should have correct tools path', () {
      expect(MainRoutes.tools, equals('/main/tools'));
    });

    test('should have correct more path', () {
      expect(MainRoutes.more, equals('/main/more'));
    });
  });

  group('[Router] ToolRoutes', () {
    test('should have correct kick counter paths', () {
      expect(ToolRoutes.kickCounter, equals('/main/tools/kick-counter'));
      // Active session is outside shell, info is nested but pushed to root
      expect(ToolRoutes.kickCounterActive, equals('/kick-counter-active'));
      expect(ToolRoutes.kickCounterInfo, equals('/main/tools/kick-counter/info'));
    });

    test('should have correct bump diary paths', () {
      expect(ToolRoutes.bumpDiary, equals('/main/tools/bump-diary'));
      expect(ToolRoutes.bumpDiaryEdit, equals('/main/tools/bump-diary/edit/:week'));
    });

    test('should have correct contraction timer paths', () {
      expect(ToolRoutes.contractionTimer, equals('/main/tools/contraction-timer'));
      // Active session is outside shell, info is nested but pushed to root
      expect(ToolRoutes.contractionTimerActive, equals('/contraction-timer-active'));
      expect(ToolRoutes.contractionTimerInfo, equals('/main/tools/contraction-timer/info'));
      expect(ToolRoutes.contractionSessionDetail, equals('/main/tools/contraction-timer/session/:id'));
    });

    test('bumpDiaryEditPath should generate correct path with week number', () {
      expect(ToolRoutes.bumpDiaryEditPath(20), equals('/main/tools/bump-diary/edit/20'));
      expect(ToolRoutes.bumpDiaryEditPath(1), equals('/main/tools/bump-diary/edit/1'));
      expect(ToolRoutes.bumpDiaryEditPath(40), equals('/main/tools/bump-diary/edit/40'));
    });

    test('contractionSessionDetailPath should generate correct path with session ID', () {
      expect(
        ToolRoutes.contractionSessionDetailPath('abc-123'),
        equals('/main/tools/contraction-timer/session/abc-123'),
      );
      expect(
        ToolRoutes.contractionSessionDetailPath('session-uuid-here'),
        equals('/main/tools/contraction-timer/session/session-uuid-here'),
      );
    });
  });

  group('[Router] MoreRoutes', () {
    test('should have correct developer path', () {
      expect(MoreRoutes.developer, equals('/main/more/developer'));
    });
  });

  group('[Router] RouteSegments', () {
    test('should have correct segment values', () {
      expect(RouteSegments.info, equals('info'));
      expect(RouteSegments.edit, equals('edit/:week'));
      expect(RouteSegments.session, equals('session/:id'));
      expect(RouteSegments.developer, equals('developer'));
    });
  });
}
