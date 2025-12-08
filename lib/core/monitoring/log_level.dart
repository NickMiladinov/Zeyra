/// Log level enum for the Zeyra logging system.
/// 
/// Defines the severity levels for logging messages, from most verbose
/// to most critical. Used to control what gets logged locally vs remotely.
enum LogLevel {
  /// Extremely detailed diagnostic information.
  /// 
  /// Used for tracing through complex operations step-by-step.
  /// Only logged locally in debug builds.
  /// 
  /// Example: "Calculating average: values=[1, 2, 3]"
  verbose,

  /// Detailed information for debugging.
  /// 
  /// Useful for developers to understand what the app is doing.
  /// Only logged locally in debug builds.
  /// 
  /// Example: "Session created with ID: xxx"
  debug,

  /// Informational messages about significant app events.
  /// 
  /// Highlights important milestones in app operation.
  /// Logged locally and sent to Sentry as breadcrumbs.
  /// 
  /// Example: "User started kick counting session"
  info,

  /// Warning messages for recoverable issues.
  /// 
  /// Indicates something unexpected happened but the app can continue.
  /// Logged locally and sent to Sentry as breadcrumbs.
  /// 
  /// Example: "Encryption key regenerated"
  warning,

  /// Error messages for caught exceptions.
  /// 
  /// Indicates an operation failed but the app is still functional.
  /// Sent to Sentry with full context and stack trace.
  /// 
  /// Example: "Failed to save session: DB error"
  error,

  /// Critical errors and app crashes.
  /// 
  /// Indicates the app is in an unstable state or crashed.
  /// Immediately sent to Sentry with highest priority.
  /// 
  /// Example: Uncaught exceptions, fatal errors
  critical,
}

/// Extension methods for LogLevel.
extension LogLevelExtension on LogLevel {
  /// Returns the string representation of the log level.
  String get name {
    switch (this) {
      case LogLevel.verbose:
        return 'VERBOSE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.critical:
        return 'CRITICAL';
    }
  }

  /// Returns whether this log level should be sent to Sentry.
  bool get shouldSendToSentry {
    switch (this) {
      case LogLevel.verbose:
      case LogLevel.debug:
        return false;
      case LogLevel.info:
      case LogLevel.warning:
        return true; // Sent as breadcrumbs
      case LogLevel.error:
      case LogLevel.critical:
        return true; // Sent as events
    }
  }

  /// Returns whether this log level is for debugging only.
  bool get isDebugOnly {
    return this == LogLevel.verbose || this == LogLevel.debug;
  }

  /// Returns the emoji representation for console output.
  String get emoji {
    switch (this) {
      case LogLevel.verbose:
        return '📝';
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🔥';
    }
  }

  /// Returns the numeric priority (higher = more severe).
  int get priority {
    switch (this) {
      case LogLevel.verbose:
        return 0;
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
      case LogLevel.critical:
        return 5;
    }
  }

  /// Returns whether this level should be shown in release builds.
  bool get shouldShowInRelease {
    return this == LogLevel.error || this == LogLevel.critical;
  }
}

