/// Route path constants for the application.
///
/// Using constants ensures type safety and makes refactoring easier.
/// All route paths are defined here to avoid magic strings throughout the app.
library;

/// Route paths for authentication-related screens.
abstract class AuthRoutes {
  /// Standalone login screen (for "I already have an account" flow).
  static const String auth = '/auth';
}

/// Route paths for onboarding flow screens.
///
/// Onboarding follows this order:
/// 1. Welcome → 2. Name → 3. Due Date/LMP → 4. Congratulations
/// 5. Value Prop 1 → 6. Value Prop 2 → 7. Value Prop 3
/// 8. Birth Date → 9. Notifications → 10. Paywall → 11. Auth
abstract class OnboardingRoutes {
  /// Base path for all onboarding routes.
  static const String base = '/onboarding';

  /// Screen 1: Welcome screen with "I already have an account" option.
  static const String welcome = '/onboarding/welcome';

  /// Screen 2: Name input.
  static const String name = '/onboarding/name';

  /// Screen 3: Due date or last menstrual period input.
  static const String dueDate = '/onboarding/due-date';

  /// Screen 4: Congratulations with gestational week and insight.
  static const String congratulations = '/onboarding/congratulations';

  /// Screen 5: Value proposition 1.
  static const String valueProp1 = '/onboarding/value-1';

  /// Screen 6: Value proposition 2.
  static const String valueProp2 = '/onboarding/value-2';

  /// Screen 7: Value proposition 3.
  static const String valueProp3 = '/onboarding/value-3';

  /// Screen 8: User's birth date input.
  static const String birthDate = '/onboarding/birth-date';

  /// Screen 9: Notification permission request.
  static const String notifications = '/onboarding/notifications';

  /// Screen 10: Paywall (mandatory - cannot be skipped).
  static const String paywall = '/onboarding/paywall';

  /// Screen 11: OAuth authentication (final step).
  static const String auth = '/onboarding/auth';

  /// List of all onboarding routes in order.
  static const List<String> orderedRoutes = [
    welcome,
    name,
    dueDate,
    congratulations,
    valueProp1,
    valueProp2,
    valueProp3,
    birthDate,
    notifications,
    paywall,
    auth,
  ];

  /// Get the route for a specific step index (0-10).
  static String getRouteForStep(int step) {
    if (step < 0 || step >= orderedRoutes.length) {
      return welcome;
    }
    return orderedRoutes[step];
  }

  /// Get the step index for a route.
  static int getStepForRoute(String route) {
    final index = orderedRoutes.indexOf(route);
    return index >= 0 ? index : 0;
  }
}

/// Route paths for the main app shell and tab navigation.
abstract class MainRoutes {
  /// Root path for main shell with bottom navigation.
  static const String main = '/main';

  /// Today/Home tab (index 0).
  static const String today = '/main/today';

  /// My Health tab (index 1).
  static const String myHealth = '/main/my-health';

  /// Baby tab (index 2).
  static const String baby = '/main/baby';

  /// Tools tab (index 3).
  static const String tools = '/main/tools';

  /// More tab (index 4).
  static const String more = '/main/more';
}

/// Route paths for tools feature screens.
abstract class ToolRoutes {
  // Kick Counter
  /// Kick counter main screen (history).
  static const String kickCounter = '/main/tools/kick-counter';

  /// Active kick counting session (full-screen, pushed to root navigator).
  static const String kickCounterActive = '/kick-counter-active';

  /// Kick counter information/help screen (nested but pushed to root navigator).
  static const String kickCounterInfo = '/main/tools/kick-counter/info';

  // Bump Diary
  /// Bump diary main screen.
  static const String bumpDiary = '/main/tools/bump-diary';

  /// Bump photo edit screen with week parameter.
  /// Use [bumpDiaryEditPath] to generate the full path with week number.
  static const String bumpDiaryEdit = '/main/tools/bump-diary/edit/:week';

  /// Generate the bump diary edit path for a specific week.
  static String bumpDiaryEditPath(int week) =>
      '/main/tools/bump-diary/edit/$week';

  // Contraction Timer
  /// Contraction timer main screen (labour overview).
  static const String contractionTimer = '/main/tools/contraction-timer';

  /// Active contraction timing session (full-screen, pushed to root navigator).
  static const String contractionTimerActive = '/contraction-timer-active';

  /// Contraction timer information/help screen (nested but pushed to root navigator).
  static const String contractionTimerInfo = '/main/tools/contraction-timer/info';

  /// Contraction session detail screen with session ID parameter.
  /// Use [contractionSessionDetailPath] to generate the full path with ID.
  static const String contractionSessionDetail =
      '/main/tools/contraction-timer/session/:id';

  /// Generate the contraction session detail path for a specific session.
  static String contractionSessionDetailPath(String id) =>
      '/main/tools/contraction-timer/session/$id';
}

/// Route paths for the "More" tab screens.
abstract class MoreRoutes {
  /// Developer menu (debug builds only).
  static const String developer = '/main/more/developer';
}

/// Relative route segments for nested routes.
///
/// These are used when defining child routes within a parent route.
/// For example, 'info' is used under kick-counter to create
/// '/main/tools/kick-counter/info'.
abstract class RouteSegments {
  static const String info = 'info';
  static const String edit = 'edit/:week';
  static const String session = 'session/:id';
  static const String developer = 'developer';
}
