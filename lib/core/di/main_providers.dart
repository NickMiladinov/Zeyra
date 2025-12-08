import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/repositories/kick_counter_repository_impl.dart';
import '../../domain/repositories/kick_counter_repository.dart';
import '../../domain/usecases/kick_counter/calculate_analytics_usecase.dart';
import '../../domain/usecases/kick_counter/manage_session_usecase.dart';
import '../services/encryption_service.dart';
import '../services/tooltip_preferences_service.dart';
import '../monitoring/logging_service.dart';
import '../monitoring/sentry_service.dart';
import '../../main.dart' show logger;
import 'di_graph.dart';

/// Main DI providers registration file.
/// 
/// All top-level Riverpod providers should be registered here.
/// This file serves as the central dependency injection registry for the application.
/// 
/// **Note:** Core services (Sentry, Logging, Encryption, Supabase, TooltipPreferences)
/// are initialized in DIGraph.initialize() and accessed via singleton getters.

// ----------------------------------------------------------------------------
// Monitoring Services
// ----------------------------------------------------------------------------

/// Provider for the Sentry service.
/// 
/// Singleton instance for remote error tracking and monitoring.
/// Initialized in DIGraph.initialize() during app startup.
final sentryServiceProvider = Provider<SentryService>((ref) {
  return DIGraph.sentryService;
});

/// Provider for the logging service.
/// 
/// Singleton instance for centralized logging (Talker + Sentry).
/// Initialized in DIGraph.initialize() during app startup.
final loggingServiceProvider = Provider<LoggingService>((ref) {
  return logger;
});

// ----------------------------------------------------------------------------
// Core Services
// ----------------------------------------------------------------------------

/// Provider for the encryption service.
/// 
/// Singleton instance used for encrypting/decrypting sensitive medical data.
/// Initialized in DIGraph.initialize() during app startup.
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return DIGraph.encryptionService;
});

/// Provider for the tooltip preferences service.
/// 
/// Singleton instance for managing tooltip display state.
/// Initialized in DIGraph.initialize() during app startup.
final tooltipPreferencesServiceProvider = Provider<TooltipPreferencesService>((ref) {
  return DIGraph.tooltipPreferencesService;
});

/// Provider for the app database.
/// 
/// Singleton Drift database instance for all local data storage.
/// Uses LazyDatabase - auto-initializes on first query (no manual init required).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// ----------------------------------------------------------------------------
// Kick Counter Feature
// ----------------------------------------------------------------------------

/// Provider for the kick counter repository.
/// 
/// Implements kick counter data operations with encryption and Drift persistence.
final kickCounterRepositoryProvider = Provider<KickCounterRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final encryption = ref.watch(encryptionServiceProvider);
  final logging = ref.watch(loggingServiceProvider);
  
  return KickCounterRepositoryImpl(
    dao: db.kickCounterDao,
    encryptionService: encryption,
    logger: logging,
  );
});

/// Provider for the manage session use case.
/// 
/// Orchestrates kick counting session operations with validation.
final manageSessionUseCaseProvider = Provider<ManageSessionUseCase>((ref) {
  final repository = ref.watch(kickCounterRepositoryProvider);
  
  return ManageSessionUseCase(repository: repository);
});

/// Provider for the calculate analytics use case.
/// 
/// Handles statistical calculations for kick counter analytics.
final calculateAnalyticsUseCaseProvider = Provider<CalculateAnalyticsUseCase>((ref) {
  return CalculateAnalyticsUseCase();
});
