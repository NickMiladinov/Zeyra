import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../main.dart' show logger;
import '../../features/auth/ui/auth_screen.dart';
import '../../features/dashboard/ui/screens/home_screen.dart';
import '../../features/baby/ui/screens/pregnancy_data_screen.dart';
import '../../features/tools/ui/screens/tools_screen.dart';
import '../../features/kick_counter/ui/screens/kick_counter_screen.dart';
import '../../features/kick_counter/ui/screens/kick_active_session_screen.dart';
import '../../features/kick_counter/ui/screens/kick_counter_info_screen.dart';
import '../../features/bump_photo/ui/screens/bump_diary_screen.dart';
import '../../features/bump_photo/ui/screens/bump_photo_edit_screen.dart';
import '../../features/contraction_timer/ui/screens/labour_overview_screen.dart';
import '../../features/contraction_timer/ui/screens/contraction_active_session_screen.dart';
import '../../features/contraction_timer/ui/screens/contraction_timer_info_screen.dart';
import '../../features/contraction_timer/ui/screens/contraction_session_detail_screen.dart';
import '../../domain/entities/contraction_timer/contraction_session.dart';
import '../../features/developer/ui/screens/developer_menu_screen.dart';
import '../../features/onboarding/ui/screens/onboarding_screens.dart';
import '../../shared/widgets/main_shell.dart';
import '../theme/app_effects.dart';
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
    initialLocation: MainRoutes.today,
    debugLogDiagnostics: true,
    observers: [TalkerRouteObserver(logger.talker)],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isAuthenticated;
      final hasCompletedOnboarding = authNotifier.hasCompletedOnboarding;
      final savedStep = authNotifier.savedOnboardingStep;
      final isAuthRoute = state.matchedLocation == AuthRoutes.auth;
      final isOnboardingRoute = state.matchedLocation.startsWith(OnboardingRoutes.base);

      // Helper to get the correct onboarding route based on saved progress
      String getOnboardingRoute() {
        if (savedStep > 0) {
          final route = OnboardingRoutes.getRouteForStep(savedStep);
          logger.debug('Router redirect: Resuming onboarding at step $savedStep ($route)');
          return route;
        }
        return OnboardingRoutes.welcome;
      }

      // Not logged in and not on onboarding → redirect to onboarding
      if (!isLoggedIn && !isOnboardingRoute && !isAuthRoute) {
        logger.debug('Router redirect: Not authenticated, redirecting to onboarding');
        return getOnboardingRoute();
      }

      // Logged in but onboarding not complete → redirect to onboarding
      if (isLoggedIn && !hasCompletedOnboarding && !isOnboardingRoute) {
        logger.debug('Router redirect: Onboarding not complete, redirecting to onboarding');
        return getOnboardingRoute();
      }

      // Logged in + onboarding complete + on onboarding route → go to main
      if (isLoggedIn && hasCompletedOnboarding && isOnboardingRoute) {
        logger.debug('Router redirect: Onboarding complete, redirecting to main');
        return MainRoutes.today;
      }

      // Logged in + onboarding complete + on auth route → go to main
      if (isLoggedIn && hasCompletedOnboarding && isAuthRoute) {
        logger.debug('Router redirect: Already authenticated, redirecting to main');
        return MainRoutes.today;
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

      // Onboarding routes (11 screens)
      GoRoute(
        path: OnboardingRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: OnboardingRoutes.name,
        builder: (context, state) => const NameInputScreen(),
      ),
      GoRoute(
        path: OnboardingRoutes.dueDate,
        builder: (context, state) => const DueDateScreen(),
      ),
      GoRoute(
        path: OnboardingRoutes.congratulations,
        builder: (context, state) => const CongratulationsScreen(),
      ),
      GoRoute(
        path: OnboardingRoutes.valueProp1,
        builder: (context, state) => const ValueProp1Screen(),
      ),
      GoRoute(
        path: OnboardingRoutes.valueProp2,
        builder: (context, state) => const ValueProp2Screen(),
      ),
      GoRoute(
        path: OnboardingRoutes.valueProp3,
        builder: (context, state) => const ValueProp3Screen(),
      ),
      GoRoute(
        path: OnboardingRoutes.birthDate,
        builder: (context, state) => const BirthDateScreen(),
      ),
      GoRoute(
        path: OnboardingRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: OnboardingRoutes.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: OnboardingRoutes.auth,
        builder: (context, state) => const AuthScreen(), // AuthScreen for final step
      ),

      // Full-screen active session routes (outside shell, no bottom nav)
      GoRoute(
        path: ToolRoutes.kickCounterActive,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideUpPage(
          const KickActiveSessionScreen(),
          state,
        ),
      ),
      GoRoute(
        path: ToolRoutes.contractionTimerActive,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideUpPage(
          const ContractionActiveSessionScreen(),
          state,
        ),
      ),

      // Main app shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(
          navigationShell: navigationShell,
        ),
        branches: [
          // Tab 0: Today/Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MainRoutes.today,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: My Health
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MainRoutes.myHealth,
                builder: (context, state) => const _PlaceholderScreen(title: 'My Health'),
              ),
            ],
          ),

          // Tab 2: Baby
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MainRoutes.baby,
                builder: (context, state) => const PregnancyDataScreen(),
              ),
            ],
          ),

          // Tab 3: Tools
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MainRoutes.tools,
                builder: (context, state) => const ToolsListScreen(),
                routes: [
                  // Kick Counter routes
                  GoRoute(
                    path: 'kick-counter',
                    builder: (context, state) => const KickCounterScreen(),
                    routes: [
                      GoRoute(
                        path: RouteSegments.info,
                        // Push to root navigator to avoid page key conflicts
                        // when navigating from active session
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => const KickCounterInfoScreen(),
                      ),
                    ],
                  ),

                  // Bump Diary routes
                  GoRoute(
                    path: 'bump-diary',
                    builder: (context, state) => const BumpDiaryScreen(),
                    routes: [
                      GoRoute(
                        path: RouteSegments.edit,
                        pageBuilder: (context, state) {
                          final weekStr = state.pathParameters['week'] ?? '0';
                          final week = int.tryParse(weekStr) ?? 0;
                          return _slideRightPage(
                            BumpPhotoEditScreen(weekNumber: week),
                            state,
                          );
                        },
                      ),
                    ],
                  ),

                  // Contraction Timer routes
                  GoRoute(
                    path: 'contraction-timer',
                    builder: (context, state) => const LabourOverviewScreen(),
                    routes: [
                      GoRoute(
                        path: RouteSegments.info,
                        // Push to root navigator to avoid page key conflicts
                        // when navigating from active session
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => const ContractionTimerInfoScreen(),
                      ),
                      GoRoute(
                        path: RouteSegments.session,
                        builder: (context, state) {
                          // Session is passed via extra parameter
                          final session = state.extra as ContractionSession?;
                          if (session == null) {
                            return const ErrorPage();
                          }
                          return ContractionSessionDetailScreen(session: session);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 4: More
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MainRoutes.more,
                builder: (context, state) => const _PlaceholderScreen(title: 'More'),
                routes: [
                  GoRoute(
                    path: RouteSegments.developer,
                    builder: (context, state) => const DeveloperMenuScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Creates a custom page with slide-up transition.
///
/// Used for active session screens (kick counter, contraction timer).
CustomTransitionPage<void> _slideUpPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppEffects.durationSlow,
    reverseTransitionDuration: AppEffects.durationSlow,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// Creates a custom page with slide-from-right transition.
///
/// Used for edit screens and detail views.
CustomTransitionPage<void> _slideRightPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// Placeholder screen for tabs not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tools list screen (extracted from ToolsScreen which had nested navigator).
///
/// This shows the grid of tool cards without the nested navigator - navigation
/// is now handled by go_router.
class ToolsListScreen extends StatelessWidget {
  const ToolsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget shows just the tools list - it used to be _ToolsListScreen
    // in tools_screen.dart. We keep ToolsScreen's card layout here.
    return const ToolsScreen();
  }
}
