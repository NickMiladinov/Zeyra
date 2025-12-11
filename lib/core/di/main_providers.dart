import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/app_database.dart';
import '../../data/repositories/kick_counter_repository_impl.dart';
import '../../data/repositories/pregnancy_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/kick_counter_repository.dart';
import '../../domain/repositories/pregnancy_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/usecases/kick_counter/calculate_analytics_usecase.dart';
import '../../domain/usecases/kick_counter/manage_session_usecase.dart';
import '../../domain/usecases/pregnancy/create_pregnancy_usecase.dart';
import '../../domain/usecases/pregnancy/delete_pregnancy_usecase.dart';
import '../../domain/usecases/pregnancy/get_active_pregnancy_usecase.dart';
import '../../domain/usecases/pregnancy/get_all_pregnancies_usecase.dart';
import '../../domain/usecases/pregnancy/update_pregnancy_due_date_usecase.dart';
import '../../domain/usecases/pregnancy/update_pregnancy_start_date_usecase.dart';
import '../../domain/usecases/pregnancy/update_pregnancy_usecase.dart';
import '../../domain/usecases/user_profile/create_user_profile_usecase.dart';
import '../../domain/usecases/user_profile/get_user_profile_usecase.dart';
import '../../domain/usecases/user_profile/update_user_profile_usecase.dart';
import '../services/database_encryption_service.dart';
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
/// **Note:** Core services (Sentry, Logging, DatabaseEncryption, Supabase, TooltipPreferences)
/// are initialized in DIGraph.initialize() and accessed via singleton getters.
///
/// **Database Access:** The database requires an authenticated user. Use
/// `appDatabaseProvider` which returns an `AsyncValue<AppDatabase>`.

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

/// Provider for the database encryption service.
///
/// Manages SQLCipher encryption keys per user.
/// Initialized in DIGraph.initialize() during app startup.
final databaseEncryptionServiceProvider = Provider<DatabaseEncryptionService>((ref) {
  return DIGraph.databaseEncryptionService;
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
/// Returns an encrypted SQLCipher database for the current authenticated user.
/// Database file: `zeyra_<userId>.db`
///
/// **Requires:** Authenticated Supabase user
///
/// **Usage:**
/// ```dart
/// final dbAsync = ref.watch(appDatabaseProvider);
/// dbAsync.when(
///   data: (db) => /* use database */,
///   loading: () => /* show loading */,
///   error: (e, st) => /* handle error */,
/// );
/// ```
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  // Get current authenticated user
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    throw StateError(
      'Cannot access database without authenticated user. '
      'Ensure user is logged in before accessing appDatabaseProvider.',
    );
  }

  // Get encryption service and retrieve/create key for this user
  final dbEncryption = ref.watch(databaseEncryptionServiceProvider);
  final encryptionKey = await dbEncryption.getKeyForUser(user.id);

  // Create encrypted database for this user
  final db = AppDatabase.encrypted(
    userId: user.id,
    encryptionKey: encryptionKey,
  );

  // Verify SQLCipher is active (optional - for debugging)
  final cipherVersion = await db.verifySqlCipherActive();
  if (cipherVersion != null) {
    logger.debug('SQLCipher active: $cipherVersion');
  } else {
    logger.warning('SQLCipher verification failed - database may not be encrypted');
  }

  // Register cleanup when provider is disposed
  ref.onDispose(() async {
    await db.close();
    logger.debug('Database closed for user');
  });

  return db;
});

// ----------------------------------------------------------------------------
// Kick Counter Feature
// ----------------------------------------------------------------------------

/// Provider for the kick counter repository.
///
/// Implements kick counter data operations with SQLCipher-encrypted Drift persistence.
final kickCounterRepositoryProvider = FutureProvider<KickCounterRepository>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final logging = ref.watch(loggingServiceProvider);

  return KickCounterRepositoryImpl(
    dao: db.kickCounterDao,
    logger: logging,
  );
});

/// Provider for the manage session use case.
///
/// Orchestrates kick counting session operations with validation.
final manageSessionUseCaseProvider = FutureProvider<ManageSessionUseCase>((ref) async {
  final repository = await ref.watch(kickCounterRepositoryProvider.future);

  return ManageSessionUseCase(repository: repository);
});

/// Provider for the calculate analytics use case.
///
/// Handles statistical calculations for kick counter analytics.
final calculateAnalyticsUseCaseProvider = Provider<CalculateAnalyticsUseCase>((ref) {
  return CalculateAnalyticsUseCase();
});

// ----------------------------------------------------------------------------
// User Profile Feature
// ----------------------------------------------------------------------------

/// Provider for the user profile repository.
///
/// Implements user profile data operations with SQLCipher-encrypted Drift persistence.
final userProfileRepositoryProvider = FutureProvider<UserProfileRepository>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final logging = ref.watch(loggingServiceProvider);

  return UserProfileRepositoryImpl(
    dao: db.userProfileDao,
    logger: logging,
  );
});

/// Provider for the create user profile use case.
final createUserProfileUseCaseProvider = FutureProvider<CreateUserProfileUseCase>((ref) async {
  final repository = await ref.watch(userProfileRepositoryProvider.future);
  return CreateUserProfileUseCase(repository: repository);
});

/// Provider for the get user profile use case.
final getUserProfileUseCaseProvider = FutureProvider<GetUserProfileUseCase>((ref) async {
  final repository = await ref.watch(userProfileRepositoryProvider.future);
  return GetUserProfileUseCase(repository: repository);
});

/// Provider for the update user profile use case.
final updateUserProfileUseCaseProvider = FutureProvider<UpdateUserProfileUseCase>((ref) async {
  final repository = await ref.watch(userProfileRepositoryProvider.future);
  return UpdateUserProfileUseCase(repository: repository);
});

// ----------------------------------------------------------------------------
// Pregnancy Feature
// ----------------------------------------------------------------------------

/// Provider for the pregnancy repository.
///
/// Implements pregnancy data operations with SQLCipher-encrypted Drift persistence.
final pregnancyRepositoryProvider = FutureProvider<PregnancyRepository>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final logging = ref.watch(loggingServiceProvider);

  return PregnancyRepositoryImpl(
    dao: db.pregnancyDao,
    logger: logging,
  );
});

/// Provider for the create pregnancy use case.
final createPregnancyUseCaseProvider = FutureProvider<CreatePregnancyUseCase>((ref) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return CreatePregnancyUseCase(repository: repository);
});

/// Provider for the get active pregnancy use case.
final getActivePregnancyUseCaseProvider = FutureProvider<GetActivePregnancyUseCase>((ref) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return GetActivePregnancyUseCase(repository: repository);
});

/// Provider for the get all pregnancies use case.
final getAllPregnanciesUseCaseProvider = FutureProvider<GetAllPregnanciesUseCase>((ref) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return GetAllPregnanciesUseCase(repository: repository);
});

/// Provider for the update pregnancy use case.
final updatePregnancyUseCaseProvider = FutureProvider<UpdatePregnancyUseCase>((ref) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return UpdatePregnancyUseCase(repository: repository);
});

/// Provider for the delete pregnancy use case.
final deletePregnancyUseCaseProvider = FutureProvider<DeletePregnancyUseCase>((ref) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return DeletePregnancyUseCase(repository: repository);
});

/// Provider for the update pregnancy start date use case.
final updatePregnancyStartDateUseCaseProvider = FutureProvider<UpdatePregnancyStartDateUseCase>((ref) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return UpdatePregnancyStartDateUseCase(repository: repository);
});

/// Provider for the update pregnancy due date use case.
final updatePregnancyDueDateUseCaseProvider = FutureProvider<UpdatePregnancyDueDateUseCase>((ref) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return UpdatePregnancyDueDateUseCase(repository: repository);
});
