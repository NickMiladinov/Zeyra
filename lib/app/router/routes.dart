/// Route path constants for the application.
///
/// Using constants ensures type safety and makes refactoring easier.
/// All route paths are defined here to avoid magic strings throughout the app.
library;

/// Route paths for authentication-related screens.
abstract class AuthRoutes {
  /// Login screen with OAuth options (Apple + Google).
  static const String auth = '/auth';

  /// Onboarding flow for new users (future implementation).
  static const String onboarding = '/onboarding';
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
