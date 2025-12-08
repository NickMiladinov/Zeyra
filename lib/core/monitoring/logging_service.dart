import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

import 'log_level.dart' as app_log;
import 'sentry_service.dart';

/// Centralized logging service for the Zeyra application.
/// 
/// Provides a unified API for logging that routes to:
/// - Talker (local console + in-app viewer)
/// - Sentry (remote error tracking)
/// 
/// Features:
/// - Automatic PII scrubbing before remote transmission
/// - Environment-aware logging (debug vs release)
/// - Structured logging with context
/// - Breadcrumb management
/// 
/// **Initialization:** This service is initialized in `DIGraph.initialize()` during app startup.
/// Access via the global `logger` instance or `loggingServiceProvider`.
class LoggingService {
  final Talker _talker;
  final SentryService _sentryService;
  final bool _isReleaseMode;

  /// Creates a logging service with the provided dependencies.
  LoggingService({
    Talker? talker,
    SentryService? sentryService,
  })  : _talker = talker ?? Talker(),
        _sentryService = sentryService ?? SentryService(),
        _isReleaseMode = kReleaseMode;

  /// Returns the Talker instance for accessing logs UI.
  Talker get talker => _talker;

  /// Logs a verbose message (most detailed).
  /// 
  /// Only logged locally in debug builds.
  /// Use for tracing through complex operations.
  void verbose(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (_isReleaseMode) return;

    _talker.verbose(message);
    if (error != null) {
      _talker.verbose('Error: $error');
    }
    if (data != null) {
      _talker.verbose('Data: $data');
    }
  }

  /// Logs a debug message.
  /// 
  /// Only logged locally in debug builds.
  /// Use for development debugging information.
  void debug(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (_isReleaseMode) return;

    _talker.debug(message);
    if (error != null) {
      _talker.debug('Error: $error');
    }
    if (data != null) {
      _talker.debug('Data: $data');
    }
  }

  /// Logs an informational message.
  /// 
  /// Logged locally and sent to Sentry as a breadcrumb.
  /// Use for significant app events.
  void info(
    String message, {
    Map<String, dynamic>? data,
  }) {
    // Log locally
    _talker.info(message);
    if (data != null && !_isReleaseMode) {
      _talker.info('Data: $data');
    }

    // Send to Sentry as breadcrumb (with PII scrubbing)
    _sentryService.addBreadcrumb(
      message: message,
      level: app_log.LogLevel.info,
      data: data,
    );
  }

  /// Logs a warning message.
  /// 
  /// Logged locally and sent to Sentry as a breadcrumb.
  /// Use for recoverable issues or unexpected situations.
  void warning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // Log locally
    _talker.warning(message);
    if (error != null) {
      _talker.warning('Error: $error');
    }
    if (stackTrace != null && !_isReleaseMode) {
      _talker.warning('StackTrace: $stackTrace');
    }
    if (data != null && !_isReleaseMode) {
      _talker.warning('Data: $data');
    }

    // Send to Sentry as breadcrumb (with PII scrubbing)
    _sentryService.addBreadcrumb(
      message: message,
      level: app_log.LogLevel.warning,
      data: data,
    );
  }

  /// Logs an error message.
  /// 
  /// Logged locally and sent to Sentry as an event.
  /// Use for caught exceptions that affect functionality.
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // Log locally
    _talker.error(message);
    if (error != null) {
      _talker.error('Error: $error');
    }
    if (stackTrace != null) {
      _talker.error('StackTrace: $stackTrace');
    }
    if (data != null && !_isReleaseMode) {
      _talker.error('Data: $data');
    }

    // Send to Sentry (with PII scrubbing)
    if (error != null) {
      _sentryService.captureException(
        exception: error,
        stackTrace: stackTrace,
        hint: message,
        extra: data,
      );
    } else {
      _sentryService.captureMessage(
        message: message,
        level: app_log.LogLevel.error,
        extra: data,
      );
    }
  }

  /// Logs a critical error message.
  /// 
  /// Logged locally and immediately sent to Sentry.
  /// Use for fatal errors and app crashes.
  void critical(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // Log locally
    _talker.critical(message);
    if (error != null) {
      _talker.critical('Error: $error');
    }
    if (stackTrace != null) {
      _talker.critical('StackTrace: $stackTrace');
    }
    if (data != null) {
      _talker.critical('Data: $data');
    }

    // Send to Sentry immediately (with PII scrubbing)
    if (error != null) {
      _sentryService.captureException(
        exception: error,
        stackTrace: stackTrace,
        hint: message,
        extra: data,
      );
    } else {
      _sentryService.captureMessage(
        message: message,
        level: app_log.LogLevel.critical,
        extra: data,
      );
    }
  }

  /// Logs a feature usage event.
  /// 
  /// Use to track when users interact with features.
  /// Only logged locally - requires user consent for analytics.
  void logFeatureUsage(
    String feature, {
    String? action,
    Map<String, dynamic>? data,
  }) {
    if (_isReleaseMode) return;

    final message = action != null
        ? 'Feature: $feature - Action: $action'
        : 'Feature: $feature';

    _talker.info(message);
    if (data != null) {
      _talker.info('Data: $data');
    }

    // TODO: If user has consented to analytics, send to analytics service
    // For now, only log locally
  }

  /// Logs a navigation event.
  /// 
  /// Automatically called by TalkerRouteObserver.
  /// Logged locally and sent to Sentry as breadcrumb.
  void logNavigation(
    String route, {
    String? action,
    Map<String, dynamic>? data,
  }) {
    final message = action != null
        ? 'Navigation: $route ($action)'
        : 'Navigation: $route';

    if (!_isReleaseMode) {
      _talker.info(message);
    }

    _sentryService.addBreadcrumb(
      message: message,
      level: app_log.LogLevel.info,
      category: 'navigation',
      data: data,
    );
  }

  /// Logs a database operation.
  /// 
  /// Use for tracking DB operations (create, read, update, delete).
  void logDatabaseOperation(
    String operation, {
    String? table,
    bool success = true,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final message = table != null
        ? 'DB $operation on $table: ${success ? "success" : "failed"}'
        : 'DB $operation: ${success ? "success" : "failed"}';

    if (success) {
      debug(message);
    } else {
      this.error(
        message,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Logs a state change in a provider.
  /// 
  /// Use for tracking state transitions in Riverpod providers.
  void logStateChange(
    String provider,
    String oldState,
    String newState, {
    Map<String, dynamic>? data,
  }) {
    if (_isReleaseMode) return;

    debug('State change in $provider: $oldState → $newState', data: data);
  }

  /// Logs an HTTP request/response.
  /// 
  /// Automatically called by TalkerDioLogger.
  /// PII is scrubbed before logging.
  void logHttp(
    String method,
    String url, {
    int? statusCode,
    Duration? duration,
    dynamic error,
    Map<String, dynamic>? data,
  }) {
    final message = statusCode != null
        ? '$method $url - $statusCode (${duration?.inMilliseconds}ms)'
        : '$method $url';

    if (error != null) {
      this.error(
        'HTTP Error: $message',
        error: error,
        data: data,
      );
    } else if (!_isReleaseMode) {
      debug(message, data: data);
    }
  }

  /// Sets user context for Sentry.
  /// 
  /// Only use with anonymized identifiers, never PII.
  void setUser({
    String? id,
    Map<String, dynamic>? data,
  }) {
    _sentryService.setUser(id: id, data: data);
  }

  /// Clears user context from Sentry.
  void clearUser() {
    _sentryService.clearUser();
  }

  /// Sets a tag for filtering in Sentry.
  void setTag(String key, String value) {
    _sentryService.setTag(key, value);
  }

  /// Sets custom context for the current scope.
  void setContext(String key, Map<String, dynamic> value) {
    _sentryService.setContext(key, value);
  }

  /// Returns the current logs for display in debug UI.
  List<TalkerData> getLogs() {
    return _talker.history.toList();
  }

  /// Clears all logs.
  void clearLogs() {
    _talker.cleanHistory();
  }

  /// Exports logs to a string (for saving/sharing).
  String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('Zeyra Logs Export');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final log in _talker.history) {
      buffer.writeln('[${log.displayTime}] ${log.displayMessage}');
      if (log.exception != null) {
        buffer.writeln('  Exception: ${log.exception}');
      }
      if (log.stackTrace != null) {
        buffer.writeln('  Stack Trace: ${log.stackTrace}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Disposes resources.
  void dispose() {
    _sentryService.close();
  }
}

