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

/// Public route paths for legal documents.
abstract class LegalRoutes {
  static const String termsOfService = '/legal/terms';
  static const String privacyPolicy = '/legal/privacy';
}

/// Route paths for onboarding flow screens.
///
/// Onboarding follows this order:
/// 1. Welcome -> 2. Value Prop -> 3. Auth
abstract class OnboardingRoutes {
  /// Base path for all onboarding routes.
  static const String base = '/onboarding';

  /// Screen 1: Welcome screen with "I already have an account" option.
  static const String welcome = '/onboarding/welcome';

  /// Screen 2: Value proposition.
  static const String valueProp3 = '/onboarding/value-3';

  /// Screen 3: OAuth authentication (final step).
  static const String auth = '/onboarding/auth';

  /// List of all onboarding routes in order.
  static const List<String> orderedRoutes = [welcome, valueProp3, auth];

  /// Get the route for a specific step index (0-2).
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
  static const String contractionTimerInfo =
      '/main/tools/contraction-timer/info';

  /// Contraction session detail screen with session ID parameter.
  /// Use [contractionSessionDetailPath] to generate the full path with ID.
  static const String contractionSessionDetail =
      '/main/tools/contraction-timer/session/:id';

  /// Generate the contraction session detail path for a specific session.
  static String contractionSessionDetailPath(String id) =>
      '/main/tools/contraction-timer/session/$id';

  // Hospital Chooser
  /// Hospital chooser workspace screen (shortlist + final choice).
  static const String hospitalChooser = '/main/tools/hospital-chooser';

  /// Hospital chooser explore screen (map/list browser).
  static const String hospitalChooserExplore =
      '/main/tools/hospital-chooser/explore';

  /// Account hub screen.
  static const String account = '/main/tools/account';

  /// Account details screen.
  static const String accountDetails = '/main/tools/account/details';

  /// Account support screen.
  static const String accountSupport = '/main/tools/account/support';

  /// Data source disclaimer screen.
  static const String dataSourceDisclaimer =
      '/main/tools/account/data-source-disclaimer';
}
