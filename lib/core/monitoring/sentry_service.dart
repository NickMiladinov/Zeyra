import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'log_level.dart' as app_log;
import 'pii_scrubber.dart';

/// Sentry service for remote error tracking and monitoring.
/// 
/// Wraps Sentry Flutter SDK with:
/// - PII scrubbing before transmission
/// - Environment-aware configuration
/// - Breadcrumb management
/// - Custom context tagging
/// 
/// **Initialization:** This service is initialized in `DIGraph.initialize()` during app startup.
/// Access via `sentryServiceProvider` or `DIGraph.sentryService`.
class SentryService {
  static SentryService? _instance;
  bool _isInitialized = false;

  /// Singleton instance.
  factory SentryService() {
    _instance ??= SentryService._internal();
    return _instance!;
  }

  SentryService._internal();

  /// Returns whether Sentry has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes Sentry with the provided DSN.
  /// 
  /// Should be called in main() before runApp().
  /// 
  /// [dsn] - Sentry project DSN from environment variables
  /// [environment] - 'development', 'staging', or 'production'
  /// [release] - App version for release tracking
  /// 
  /// Returns true if initialization succeeded.
  Future<bool> initialize({
    required String dsn,
    String environment = kDebugMode ? 'development' : 'production',
    String? release,
  }) async {
    // Skip initialization if DSN is empty (Sentry disabled)
    if (dsn.isEmpty) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠️ Sentry DSN not provided - remote error tracking disabled');
      }
      return false;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.environment = environment;
          options.release = release;
          
          // Performance monitoring
          options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
          
          // Enable automatic breadcrumbs
          options.enableAutoSessionTracking = true;
          
          // Attach screenshots on errors (useful for UI issues)
          options.attachScreenshot = true;
          options.screenshotQuality = SentryScreenshotQuality.medium;
          
          // Attach view hierarchy
          options.attachViewHierarchy = true;
          
          // Debug output in development
          options.debug = kDebugMode;
          
          // Sample rate for error events
          options.sampleRate = 1.0; // Send all errors
          
          // Before send callback - scrub PII
          options.beforeSend = (event, hint) => _beforeSend(event, hint: hint);
          
          // Before breadcrumb callback - scrub PII
          // Note: Using inline function to match Sentry's expected signature
          options.beforeBreadcrumb = (breadcrumb, hint) {
            if (!_isInitialized || breadcrumb == null) return breadcrumb;
            
            // Scrub message
            final scrubbedMessage = breadcrumb.message != null
                ? PiiScrubber.scrubMessage(breadcrumb.message!)
                : null;

            // Scrub data
            final scrubbedData = breadcrumb.data != null
                ? PiiScrubber.scrubData(Map<String, dynamic>.from(breadcrumb.data!))
                : null;

            return breadcrumb.copyWith(
              message: scrubbedMessage,
              data: scrubbedData,
            );
          };
        },
      );

      _isInitialized = true;
      
      if (kDebugMode) {
        // ignore: avoid_print
        print('✅ Sentry initialized successfully');
      }
      
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ Failed to initialize Sentry: $e\n$stackTrace');
      }
      return false;
    }
  }

  /// Before send callback - scrubs PII from events before transmission.
  SentryEvent? _beforeSend(SentryEvent event, {Hint? hint}) {
    if (!_isInitialized) return null;

    // Scrub PII from exception message
    if (event.exceptions != null && event.exceptions!.isNotEmpty) {
      final scrubbedExceptions = event.exceptions!.map((exception) {
        return exception.copyWith(
          value: PiiScrubber.scrubMessage(exception.value ?? ''),
        );
      }).toList();
      
      event = event.copyWith(exceptions: scrubbedExceptions);
    }

    // Scrub PII from message
    if (event.message != null) {
      final formatted = event.message?.formatted;
      if (formatted != null) {
        event = event.copyWith(
          message: SentryMessage(
            PiiScrubber.scrubMessage(formatted),
          ),
        );
      }
    }

    // Scrub PII from contexts (modern approach - replaces deprecated 'extra')
    // Iterate through all contexts and scrub any that contain user data
    final contexts = Map<String, dynamic>.from(event.contexts.toJson());
    bool contextsChanged = false;

    // Scrub all context entries that might contain sensitive data
    contexts.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        contexts[key] = PiiScrubber.scrubData(Map<String, dynamic>.from(value));
        contextsChanged = true;
      }
    });

    if (contextsChanged) {
      event = event.copyWith(contexts: Contexts.fromJson(contexts));
    }

    return event;
  }

  /// Logs a message to Sentry as a breadcrumb.
  void addBreadcrumb({
    required String message,
    required app_log.LogLevel level,
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: PiiScrubber.scrubMessage(message),
        level: _mapLogLevelToSentryLevel(level),
        category: category,
        data: data != null ? PiiScrubber.scrubData(data) : null,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  /// Captures an exception and sends it to Sentry.
  Future<void> captureException({
    required dynamic exception,
    StackTrace? stackTrace,
    String? hint,
    Map<String, dynamic>? extra,
  }) async {
    if (!_isInitialized) return;

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint != null ? Hint.withMap({'hint': hint}) : null,
      withScope: (scope) {
        if (extra != null) {
          scope.setContexts('data', PiiScrubber.scrubData(extra));
        }
      },
    );
  }

  /// Captures a message and sends it to Sentry.
  Future<void> captureMessage({
    required String message,
    required app_log.LogLevel level,
    Map<String, dynamic>? extra,
  }) async {
    if (!_isInitialized) return;

    await Sentry.captureMessage(
      PiiScrubber.scrubMessage(message),
      level: _mapLogLevelToSentryLevel(level),
      withScope: (scope) {
        if (extra != null) {
          scope.setContexts('data', PiiScrubber.scrubData(extra));
        }
      },
    );
  }

  /// Sets user context (use with caution - no PII).
  /// 
  /// Only use anonymized user identifiers, never email/name.
  void setUser({
    String? id,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id != null ? PiiScrubber.scrubMessage(id) : null,
        data: data != null ? PiiScrubber.scrubData(data) : null,
      ));
    });
  }

  /// Sets a tag for filtering in Sentry dashboard.
  void setTag(String key, String value) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setTag(key, PiiScrubber.scrubMessage(value));
    });
  }

  /// Sets custom context for the current scope.
  void setContext(String key, Map<String, dynamic> value) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setContexts(key, PiiScrubber.scrubData(value));
    });
  }

  /// Clears user context.
  void clearUser() {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Maps LogLevel to Sentry's SentryLevel.
  SentryLevel _mapLogLevelToSentryLevel(app_log.LogLevel level) {
    switch (level) {
      case app_log.LogLevel.verbose:
      case app_log.LogLevel.debug:
        return SentryLevel.debug;
      case app_log.LogLevel.info:
        return SentryLevel.info;
      case app_log.LogLevel.warning:
        return SentryLevel.warning;
      case app_log.LogLevel.error:
        return SentryLevel.error;
      case app_log.LogLevel.critical:
        return SentryLevel.fatal;
    }
  }

  /// Closes Sentry client.
  /// 
  /// Should be called on app termination.
  Future<void> close() async {
    if (!_isInitialized) return;
    await Sentry.close();
    _isInitialized = false;
  }
}

