import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../main.dart' show logger;
import '../../core/di/main_providers.dart';
import '../../features/auth/ui/auth_screen.dart';
import '../../features/auth/ui/screens/legal_document_screen.dart';
import '../../features/account/ui/screens/account_details_screen.dart';
import '../../features/account/ui/screens/account_screen.dart';
import '../../features/account/ui/screens/account_support_screen.dart';
import '../../features/account/ui/screens/data_source_disclaimer_screen.dart';
import '../../features/hospital_chooser/ui/screens/hospital_chooser_screen.dart';
import '../../features/hospital_chooser/ui/screens/hospital_shortlist_screen.dart';
import '../../features/onboarding/ui/screens/onboarding_screens.dart';
import 'auth_notifier.dart';
import 'error_page.dart';
import 'routes.dart';

/// Key for the root navigator, used to push routes outside the shell.
///
/// Routes that use `parentNavigatorKey: _rootNavigatorKey` will be pushed
/// onto the root navigator instead of the shell's branch navigator.
/// This allows routes to be logically nested but rendered full-screen.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Provider for the [GoRouter] instance.
///
/// This router handles all navigation in the app, including:
/// - Authentication redirects
/// - Deep link handling for OAuth callbacks
/// - Tab navigation with state preservation
/// - Custom page transitions
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authNotifier,
    initialLocation: ToolRoutes.hospitalChooserExplore,
    debugLogDiagnostics: true,
    observers: [TalkerRouteObserver(logger.talker)],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: (context, state) {
      // Wait for async SharedPreferences data to load before making routing decisions.
      // The notifyListeners() calls in the async load methods will re-trigger
      // redirect evaluation once the data is ready.
      if (!authNotifier.onboardingStepLoaded ||
          !authNotifier.deviceOnboardedLoaded) {
        logger.debug(
          'Router redirect: Waiting for async initialization to complete',
        );
        return null; // Defer redirect until data is loaded
      }

      final isLoggedIn = authNotifier.isAuthenticated;
      final hasCompletedOnboarding = authNotifier.hasCompletedOnboarding;
      final deviceOnboarded = authNotifier.deviceOnboarded;
      final savedStep = authNotifier.savedOnboardingStep;
      final isAuthRoute =
          state.matchedLocation == AuthRoutes.auth ||
          state.matchedLocation == OnboardingRoutes.auth;
      final isOnboardingRoute = state.matchedLocation.startsWith(
        OnboardingRoutes.base,
      );
      final isLegalRoute =
          state.matchedLocation == LegalRoutes.termsOfService ||
          state.matchedLocation == LegalRoutes.privacyPolicy;
      final isAccountRoute =
          state.matchedLocation == ToolRoutes.account ||
          state.matchedLocation == ToolRoutes.accountDetails ||
          state.matchedLocation == ToolRoutes.accountSupport ||
          state.matchedLocation == ToolRoutes.dataSourceDisclaimer;
      final isHospitalRoute =
          state.matchedLocation == ToolRoutes.hospitalChooser ||
          state.matchedLocation == ToolRoutes.hospitalChooserExplore;

      // Helper to get the correct onboarding route based on saved progress
      String getOnboardingRoute() {
        if (savedStep > 0) {
          final route = OnboardingRoutes.getRouteForStep(savedStep);
          logger.debug(
            'Router redirect: Resuming onboarding at step $savedStep ($route)',
          );
          return route;
        }
        return OnboardingRoutes.welcome;
      }

      // Not logged in - check if device has been onboarded before
      if (!isLoggedIn && !isOnboardingRoute && !isAuthRoute && !isLegalRoute) {
        if (deviceOnboarded) {
          // Device was onboarded before - go to auth screen
          logger.debug(
            'Router redirect: Not authenticated, device onboarded, redirecting to auth',
          );
          return AuthRoutes.auth;
        } else {
          // Fresh device - go to onboarding
          logger.debug(
            'Router redirect: Not authenticated, new device, redirecting to onboarding',
          );
          return getOnboardingRoute();
        }
      }

      // Logged in but onboarding not complete → redirect to onboarding
      if (isLoggedIn && !hasCompletedOnboarding && !isOnboardingRoute) {
        logger.debug(
          'Router redirect: Onboarding not complete, redirecting to onboarding',
        );
        return getOnboardingRoute();
      }

      // Logged in + onboarding complete should stay on hospital flow only.
      if (isLoggedIn &&
          hasCompletedOnboarding &&
          !isHospitalRoute &&
          !isAccountRoute &&
          !isLegalRoute) {
        // Invalidate database provider BEFORE redirecting to avoid stale instances.
        ref.invalidate(appDatabaseProvider);
        logger.debug(
          'Router redirect: Onboarding complete, redirecting to hospital map',
        );
        return ToolRoutes.hospitalChooserExplore;
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth route (OAuth only - Apple + Google)
      // Used for "I already have an account" flow
      GoRoute(
        path: AuthRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),

      // Onboarding routes (3 screens)
      GoRoute(
        path: OnboardingRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: OnboardingRoutes.valueProp3,
        builder: (context, state) => const ValueProp3Screen(),
      ),
      GoRoute(
        path: OnboardingRoutes.auth,
        builder: (context, state) =>
            const AuthScreen(), // AuthScreen for final step
      ),
      GoRoute(
        path: LegalRoutes.termsOfService,
        pageBuilder: (context, state) => _cupertinoPage(
          state: state,
          child: const LegalDocumentScreen(
            documentType: LegalDocumentType.termsOfService,
          ),
        ),
      ),
      GoRoute(
        path: LegalRoutes.privacyPolicy,
        pageBuilder: (context, state) => _cupertinoPage(
          state: state,
          child: const LegalDocumentScreen(
            documentType: LegalDocumentType.privacyPolicy,
          ),
        ),
      ),
      GoRoute(
        path: ToolRoutes.hospitalChooser,
        builder: (context, state) => const HospitalShortlistScreen(),
      ),
      GoRoute(
        path: ToolRoutes.hospitalChooserExplore,
        builder: (context, state) => const HospitalChooserScreen(),
      ),
      GoRoute(
        path: ToolRoutes.account,
        pageBuilder: (context, state) =>
            _cupertinoPage(state: state, child: const AccountScreen()),
      ),
      GoRoute(
        path: ToolRoutes.accountDetails,
        pageBuilder: (context, state) =>
            _cupertinoPage(state: state, child: const AccountDetailsScreen()),
      ),
      GoRoute(
        path: ToolRoutes.accountSupport,
        pageBuilder: (context, state) =>
            _cupertinoPage(state: state, child: const AccountSupportScreen()),
      ),
      GoRoute(
        path: ToolRoutes.dataSourceDisclaimer,
        pageBuilder: (context, state) => _cupertinoPage(
          state: state,
          child: const DataSourceDisclaimerScreen(),
        ),
      ),
    ],
  );
});

Page<void> _cupertinoPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CupertinoPage<void>(key: state.pageKey, child: child);
}
