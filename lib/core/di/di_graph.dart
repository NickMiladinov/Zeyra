/// Explicit DI graph visualizer/initializer.
///
/// This file provides visibility into the dependency injection graph
/// and handles initialization of all async services during app startup.
///
/// **Initialization Order (CRITICAL - DO NOT CHANGE):**
/// 1. Environment variables (required by other services)
/// 2. Sentry (to catch errors from subsequent initializations)
/// 3. Logging (depends on Sentry)
/// 4. Database encryption service (for SQLCipher key management)
/// 5. Supabase (backend & auth)
/// 6. SharedPreferences → TooltipPreferencesService
/// 7. RevenueCat (payments) - depends on logging
///
/// **Note:** The encrypted database is initialized lazily when a user logs in,
/// not during app startup. See `main_providers.dart` for database provider.
///
library;

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../monitoring/logging_service.dart';
import '../monitoring/sentry_service.dart';
import '../services/database_encryption_service.dart';
import '../services/payment_service.dart';
import '../services/tooltip_preferences_service.dart';
import '../../main.dart' show logger;

class DIGraph {
  // Singleton instances of initialized services
  static SentryService? _sentryService;
  static DatabaseEncryptionService? _databaseEncryptionService;
  static TooltipPreferencesService? _tooltipPreferencesService;
  static PaymentService? _paymentService;

  /// Get the initialized Sentry service.
  static SentryService get sentryService {
    if (_sentryService == null) {
      throw StateError('DIGraph not initialized. Call DIGraph.initialize() first.');
    }
    return _sentryService!;
  }

  /// Get the initialized database encryption service.
  ///
  /// Manages SQLCipher encryption keys per user.
  static DatabaseEncryptionService get databaseEncryptionService {
    if (_databaseEncryptionService == null) {
      throw StateError('DIGraph not initialized. Call DIGraph.initialize() first.');
    }
    return _databaseEncryptionService!;
  }

  /// Get the initialized tooltip preferences service.
  static TooltipPreferencesService get tooltipPreferencesService {
    if (_tooltipPreferencesService == null) {
      throw StateError('DIGraph not initialized. Call DIGraph.initialize() first.');
    }
    return _tooltipPreferencesService!;
  }

  /// Get the initialized payment service.
  ///
  /// Wraps RevenueCat SDK for subscription and payment management.
  static PaymentService get paymentService {
    if (_paymentService == null) {
      throw StateError('DIGraph not initialized. Call DIGraph.initialize() first.');
    }
    return _paymentService!;
  }

  /// Check if Supabase is properly initialized and available.
  static bool get isSupabaseAvailable {
    try {
      // Try to access Supabase instance to verify it's initialized
      // This will throw if Supabase.initialize() hasn't been called
      final _ = Supabase.instance.client.auth;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Initialize the dependency injection graph.
  ///
  /// **Must be called in main() before runApp().**
  ///
  /// Initializes all async services in the correct dependency order.
  /// Auth state is managed by [AuthNotifier] with go_router, not here.
  static Future<void> initialize() async {
    // 1. Load environment variables (required by Sentry and Supabase)
    await AppConstants.loadEnv();

    // 2. Get app version for Sentry release tracking
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    // 3. Initialize Sentry for remote error tracking (FIRST - catches all errors)
    _sentryService = SentryService();
    await _sentryService!.initialize(
      dsn: AppConstants.sentryDsn,
      release: appVersion,
    );

    // 4. Initialize logging service (depends on Sentry)
    logger = LoggingService(sentryService: _sentryService!);
    logger.info('App starting - DIGraph initialization');

    // 5. Initialize database encryption service (for SQLCipher key management)
    // Note: This service doesn't load keys at startup - keys are loaded
    // lazily when a user authenticates and their database is opened.
    _databaseEncryptionService = DatabaseEncryptionService();
    logger.info('Database encryption service initialized');

    // 6. Initialize Supabase (backend & auth)
    // Note: Auth state is managed by AuthNotifier with go_router
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          // Auto-refresh tokens before they expire
          autoRefreshToken: true,
        ),
        // Configure realtime client options for better resilience
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 2,
        ),
      );
      logger.info('Supabase initialized');
    } catch (e, stackTrace) {
      logger.error(
        'Failed to initialize Supabase - auth will be unavailable',
        error: e,
        stackTrace: stackTrace,
      );
      // Continue app startup even if Supabase fails
      // User will be shown login screen but won't be able to authenticate
    }

    // 7. Initialize SharedPreferences for tooltip preferences
    // Note: Auth state is now managed by AuthNotifier with go_router
    try {
      final prefs = await SharedPreferences.getInstance();
      _tooltipPreferencesService = TooltipPreferencesService(prefs);
      logger.info('Tooltip preferences service initialized');
    } catch (e, stackTrace) {
      logger.error(
        'Failed to initialize tooltip preferences',
        error: e,
        stackTrace: stackTrace,
      );
      // Non-critical - app can continue without tooltip tracking
    }

    // 8. Initialize RevenueCat for payments
    // Note: RevenueCat handles its own customer state management
    try {
      _paymentService = PaymentService(logger);
      await _paymentService!.initialize(
        iosApiKey: AppConstants.revenueCatApiKeyIOS,
        androidApiKey: AppConstants.revenueCatApiKeyAndroid,
      );
      logger.info('Payment service initialized');
    } catch (e, stackTrace) {
      logger.error(
        'Failed to initialize payment service',
        error: e,
        stackTrace: stackTrace,
      );
      // Non-critical - app can continue without payments
      // PaymentService handles graceful degradation internally
    }

    logger.info('DIGraph initialization complete');
  }

  /// Clear all cached encryption keys from memory.
  ///
  /// Call this on logout to ensure keys are not accessible.
  static void clearEncryptionCache() {
    _databaseEncryptionService?.clearCache();
  }
}
