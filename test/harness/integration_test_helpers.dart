import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zeyra/app/router/auth_notifier.dart';

/// Lightweight test double for router/auth integration tests.
///
/// This avoids hitting SharedPreferences/Supabase from [AuthNotifier]'s
/// production constructor while still satisfying go_router's refreshListenable.
class TestAuthNotifier extends ChangeNotifier implements AuthNotifier {
  TestAuthNotifier({
    bool isAuthenticated = false,
    bool hasCompletedOnboarding = false,
    int savedOnboardingStep = 0,
    bool onboardingStepLoaded = true,
    bool deviceOnboarded = false,
    bool deviceOnboardedLoaded = true,
    bool isCheckingOnboarding = false,
  }) : _isAuthenticated = isAuthenticated,
       _hasCompletedOnboarding = hasCompletedOnboarding,
       _savedOnboardingStep = savedOnboardingStep,
       _onboardingStepLoaded = onboardingStepLoaded,
       _deviceOnboarded = deviceOnboarded,
       _deviceOnboardedLoaded = deviceOnboardedLoaded,
       _isCheckingOnboarding = isCheckingOnboarding;

  bool _isAuthenticated;
  bool _hasCompletedOnboarding;
  bool _isCheckingOnboarding;
  int _savedOnboardingStep;
  bool _onboardingStepLoaded;
  bool _deviceOnboarded;
  bool _deviceOnboardedLoaded;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  @override
  bool get isCheckingOnboarding => _isCheckingOnboarding;

  @override
  int get savedOnboardingStep => _savedOnboardingStep;

  @override
  bool get onboardingStepLoaded => _onboardingStepLoaded;

  @override
  bool get deviceOnboarded => _deviceOnboarded;

  @override
  bool get deviceOnboardedLoaded => _deviceOnboardedLoaded;

  void setState({
    bool? isAuthenticated,
    bool? hasCompletedOnboarding,
    int? savedOnboardingStep,
    bool? onboardingStepLoaded,
    bool? deviceOnboarded,
    bool? deviceOnboardedLoaded,
    bool? isCheckingOnboarding,
    bool notify = true,
  }) {
    _isAuthenticated = isAuthenticated ?? _isAuthenticated;
    _hasCompletedOnboarding =
        hasCompletedOnboarding ?? _hasCompletedOnboarding;
    _savedOnboardingStep = savedOnboardingStep ?? _savedOnboardingStep;
    _onboardingStepLoaded = onboardingStepLoaded ?? _onboardingStepLoaded;
    _deviceOnboarded = deviceOnboarded ?? _deviceOnboarded;
    _deviceOnboardedLoaded = deviceOnboardedLoaded ?? _deviceOnboardedLoaded;
    _isCheckingOnboarding = isCheckingOnboarding ?? _isCheckingOnboarding;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  Future<bool> checkOnboardingStatus() async {
    return _hasCompletedOnboarding;
  }

  @override
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  @override
  bool isNewAccount() {
    return !_hasCompletedOnboarding;
  }

  @override
  Future<void> markDeviceOnboarded() async {
    _deviceOnboarded = true;
    _deviceOnboardedLoaded = true;
    notifyListeners();
  }

  @override
  void updateSavedOnboardingStep(int step) {
    _savedOnboardingStep = step;
  }

  @override
  void clearSavedOnboardingStep() {
    _savedOnboardingStep = 0;
  }
}

Widget createRouterTestApp({
  required GoRouter router,
  List overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> pumpRouterTestApp(
  WidgetTester tester, {
  required GoRouter router,
  List overrides = const [],
}) async {
  await tester.pumpWidget(
    createRouterTestApp(router: router, overrides: overrides),
  );
  await tester.pumpAndSettle();
}

