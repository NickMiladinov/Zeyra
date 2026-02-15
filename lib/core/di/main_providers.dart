import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/app_database.dart';
import '../../data/remote/maternity_unit_remote_source.dart';
import '../../data/repositories/hospital_shortlist_repository_impl.dart';
import '../../data/repositories/maternity_unit_repository_impl.dart';
import '../../data/repositories/pregnancy_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/hospital_shortlist_repository.dart';
import '../../domain/repositories/maternity_unit_repository.dart';
import '../../domain/repositories/pregnancy_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/usecases/pregnancy/create_pregnancy_usecase.dart';
import '../../domain/usecases/pregnancy/delete_pregnancy_usecase.dart';
import '../../domain/usecases/pregnancy/get_active_pregnancy_usecase.dart';
import '../../domain/usecases/pregnancy/get_all_pregnancies_usecase.dart';
import '../../domain/usecases/pregnancy/update_pregnancy_due_date_usecase.dart';
import '../../domain/usecases/pregnancy/update_pregnancy_start_date_usecase.dart';
import '../../domain/usecases/pregnancy/update_pregnancy_usecase.dart';
import '../../domain/usecases/hospital/filter_units_usecase.dart';
import '../../domain/usecases/hospital/get_nearby_units_usecase.dart';
import '../../domain/usecases/hospital/get_unit_detail_usecase.dart';
import '../../domain/usecases/hospital/manage_shortlist_usecase.dart';
import '../../domain/usecases/hospital/select_final_hospital_usecase.dart';
import '../../domain/usecases/user_profile/create_user_profile_usecase.dart';
import '../../domain/usecases/user_profile/get_user_profile_usecase.dart';
import '../../domain/usecases/user_profile/update_user_profile_usecase.dart';
import '../services/database_encryption_service.dart';
import '../services/account_service.dart';
import '../services/drive_time_service.dart';
import '../services/location_service.dart';
import '../services/maternity_unit_sync_service.dart';
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
final databaseEncryptionServiceProvider = Provider<DatabaseEncryptionService>((
  ref,
) {
  return DIGraph.databaseEncryptionService;
});

/// Provider for account operations service.
final accountServiceProvider = Provider<AccountService>((ref) {
  final logging = ref.watch(loggingServiceProvider);
  final encryption = ref.watch(databaseEncryptionServiceProvider);

  return AccountService(
    logger: logging,
    databaseEncryptionService: encryption,
    clearDatabaseCache: clearDatabaseCache,
  );
});

/// Provider for the tooltip preferences service.
///
/// Singleton instance for managing tooltip display state.
/// Initialized in DIGraph.initialize() during app startup.
final tooltipPreferencesServiceProvider = Provider<TooltipPreferencesService>((
  ref,
) {
  return DIGraph.tooltipPreferencesService;
});

/// Cache for database instances by user ID.
///
/// Ensures only one database instance exists per user, preventing the
/// "created database multiple times" warning from Drift.
final Map<String, AppDatabase> _databaseCache = {};

/// Opens the per-user encrypted database and validates SQLCipher.
Future<AppDatabase> _openValidatedDatabase({
  required String userId,
  required String encryptionKey,
}) async {
  final db = AppDatabase.encrypted(
    userId: userId,
    encryptionKey: encryptionKey,
  );
  await db.requireSqlCipherActive();
  return db;
}

/// Returns true when the error indicates an invalid/corrupt SQLite file.
bool _isInvalidDatabaseFileError(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains('file is not a database') ||
      message.contains('code 26');
}

/// Provider for the app database.
///
/// Returns an encrypted SQLCipher database for the current authenticated user.
/// Database file: `zeyra_<userId>.db`
///
/// Uses a static cache to ensure only one database instance per user exists,
/// even if the provider is rebuilt due to dependency changes.
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

  // Return cached instance if it exists for this user.
  // Note: We don't register onDispose here because the cache is the owner of
  // the database lifecycle. Database cleanup happens in clearDatabaseCache()
  // which is called during logout.
  if (_databaseCache.containsKey(user.id)) {
    logger.debug('Returning cached database for user');
    return _databaseCache[user.id]!;
  }

  // Get encryption service and retrieve/create key for this user
  final dbEncryption = ref.watch(databaseEncryptionServiceProvider);
  final encryptionKey = await dbEncryption.getKeyForUser(user.id);

  AppDatabase db;
  try {
    db = await _openValidatedDatabase(
      userId: user.id,
      encryptionKey: encryptionKey,
    );
  } catch (error, stackTrace) {
    if (!_isInvalidDatabaseFileError(error)) {
      rethrow;
    }

    logger.warning(
      'Invalid encrypted database file detected. Recreating local database.',
      error: error,
      stackTrace: stackTrace,
    );

    await deleteDatabaseFileForUser(user.id);
    db = await _openValidatedDatabase(
      userId: user.id,
      encryptionKey: encryptionKey,
    );
  }

  // Cache the database instance
  _databaseCache[user.id] = db;

  logger.debug('SQLCipher active for user database');

  // Note: We intentionally do NOT register ref.onDispose() here.
  // Problem: When the provider hits the cache (early return above), onDispose
  // is never registered for that execution. If the provider is later invalidated,
  // the previous execution's onDispose would close the database while consumers
  // from the cached execution are still using it, causing crashes.
  // Solution: Database cleanup is handled by clearDatabaseCache() which is called
  // explicitly during logout. This ensures consistent cleanup regardless of
  // provider caching behavior.

  return db;
});

/// Clears the database cache for a specific user or all users.
///
/// Closes any open database connections before removing from cache.
/// Call this on logout to ensure a fresh database instance on next login.
///
/// This is the proper cleanup point for database connections since the
/// provider's onDispose cannot be used reliably with caching.
Future<void> clearDatabaseCache([String? userId]) async {
  if (userId != null) {
    final db = _databaseCache.remove(userId);
    if (db != null) {
      await db.close();
      logger.debug('Database closed and cache cleared for user');
    }
  } else {
    // Close all databases before clearing
    for (final db in _databaseCache.values) {
      await db.close();
    }
    _databaseCache.clear();
    logger.debug('All databases closed and cache cleared');
  }
}

// ----------------------------------------------------------------------------
// User Profile Feature
// ----------------------------------------------------------------------------

/// Provider for the user profile repository.
///
/// Implements user profile data operations with SQLCipher-encrypted Drift persistence.
final userProfileRepositoryProvider = FutureProvider<UserProfileRepository>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final logging = ref.watch(loggingServiceProvider);

  return UserProfileRepositoryImpl(
    dao: db.userProfileDao,
    pregnancyDao: db.pregnancyDao,
    logger: logging,
  );
});

/// Provider for the create user profile use case.
final createUserProfileUseCaseProvider =
    FutureProvider<CreateUserProfileUseCase>((ref) async {
      final repository = await ref.watch(userProfileRepositoryProvider.future);
      return CreateUserProfileUseCase(repository: repository);
    });

/// Provider for the get user profile use case.
final getUserProfileUseCaseProvider = FutureProvider<GetUserProfileUseCase>((
  ref,
) async {
  final repository = await ref.watch(userProfileRepositoryProvider.future);
  return GetUserProfileUseCase(repository: repository);
});

/// Provider for the update user profile use case.
final updateUserProfileUseCaseProvider =
    FutureProvider<UpdateUserProfileUseCase>((ref) async {
      final repository = await ref.watch(userProfileRepositoryProvider.future);
      return UpdateUserProfileUseCase(repository: repository);
    });

// ----------------------------------------------------------------------------
// Pregnancy Feature
// ----------------------------------------------------------------------------

/// Provider for the pregnancy repository.
///
/// Implements pregnancy data operations with SQLCipher-encrypted Drift persistence.
final pregnancyRepositoryProvider = FutureProvider<PregnancyRepository>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final logging = ref.watch(loggingServiceProvider);

  return PregnancyRepositoryImpl(dao: db.pregnancyDao, logger: logging);
});

/// Provider for the create pregnancy use case.
final createPregnancyUseCaseProvider = FutureProvider<CreatePregnancyUseCase>((
  ref,
) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return CreatePregnancyUseCase(repository: repository);
});

/// Provider for the get active pregnancy use case.
final getActivePregnancyUseCaseProvider =
    FutureProvider<GetActivePregnancyUseCase>((ref) async {
      final repository = await ref.watch(pregnancyRepositoryProvider.future);
      return GetActivePregnancyUseCase(repository: repository);
    });

/// Provider for the get all pregnancies use case.
final getAllPregnanciesUseCaseProvider =
    FutureProvider<GetAllPregnanciesUseCase>((ref) async {
      final repository = await ref.watch(pregnancyRepositoryProvider.future);
      return GetAllPregnanciesUseCase(repository: repository);
    });

/// Provider for the update pregnancy use case.
final updatePregnancyUseCaseProvider = FutureProvider<UpdatePregnancyUseCase>((
  ref,
) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return UpdatePregnancyUseCase(repository: repository);
});

/// Provider for the delete pregnancy use case.
final deletePregnancyUseCaseProvider = FutureProvider<DeletePregnancyUseCase>((
  ref,
) async {
  final repository = await ref.watch(pregnancyRepositoryProvider.future);
  return DeletePregnancyUseCase(repository: repository);
});

/// Provider for the update pregnancy start date use case.
final updatePregnancyStartDateUseCaseProvider =
    FutureProvider<UpdatePregnancyStartDateUseCase>((ref) async {
      final repository = await ref.watch(pregnancyRepositoryProvider.future);
      return UpdatePregnancyStartDateUseCase(repository: repository);
    });

/// Provider for the update pregnancy due date use case.
final updatePregnancyDueDateUseCaseProvider =
    FutureProvider<UpdatePregnancyDueDateUseCase>((ref) async {
      final repository = await ref.watch(pregnancyRepositoryProvider.future);
      return UpdatePregnancyDueDateUseCase(repository: repository);
    });

/// Provider for the active pregnancy entity.
///
/// Returns the current active pregnancy or null if none exists.
final activePregnancyProvider = FutureProvider((ref) async {
  final useCase = await ref.watch(getActivePregnancyUseCaseProvider.future);
  return await useCase.execute();
});

// ----------------------------------------------------------------------------
// Hospital Chooser Feature
// ----------------------------------------------------------------------------

/// Provider for the location service.
///
/// Handles device location and UK postcode lookup via postcodes.io.
/// Properly disposes the HTTP client when the provider is disposed.
final locationServiceProvider = Provider<LocationService>((ref) {
  final logging = ref.watch(loggingServiceProvider);
  final service = LocationService(logger: logging);

  // Clean up HTTP client when provider is disposed
  ref.onDispose(() {
    service.close();
  });

  return service;
});

/// Provider for the drive time service.
///
/// Calculates drive times using Google Distance Matrix API.
/// Uses the same API key as Google Maps (requires Distance Matrix API enabled).
final driveTimeServiceProvider = Provider<DriveTimeService>((ref) {
  final logging = ref.watch(loggingServiceProvider);
  final service = DriveTimeService(logger: logging);

  // Clean up HTTP client when provider is disposed
  ref.onDispose(() {
    service.close();
  });

  return service;
});

/// Provider for the maternity unit remote source.
///
/// Fetches maternity units from Supabase.
final maternityUnitRemoteSourceProvider = Provider<MaternityUnitRemoteSource>((
  ref,
) {
  return MaternityUnitRemoteSource();
});

/// Provider for the maternity unit repository.
///
/// Handles maternity unit data operations with local caching and remote sync.
final maternityUnitRepositoryProvider = FutureProvider<MaternityUnitRepository>(
  (ref) async {
    final db = await ref.watch(appDatabaseProvider.future);
    final logging = ref.watch(loggingServiceProvider);
    final remoteSource = ref.watch(maternityUnitRemoteSourceProvider);

    return MaternityUnitRepositoryImpl(
      dao: db.maternityUnitDao,
      syncMetadataDao: db.syncMetadataDao,
      remoteSource: remoteSource,
      logger: logging,
    );
  },
);

/// Provider for maternity unit sync orchestration.
///
/// Call `initialize()` from the first hospital screen after auth to ensure
/// local data is preloaded from assets and then incrementally synced.
final maternityUnitSyncServiceProvider =
    FutureProvider<MaternityUnitSyncService>((ref) async {
      final repository = await ref.watch(
        maternityUnitRepositoryProvider.future,
      );
      final logging = ref.watch(loggingServiceProvider);

      return MaternityUnitSyncService(repository: repository, logger: logging);
    });

/// Provider for the hospital shortlist repository.
///
/// Manages user's shortlisted hospitals.
final hospitalShortlistRepositoryProvider =
    FutureProvider<HospitalShortlistRepository>((ref) async {
      final db = await ref.watch(appDatabaseProvider.future);
      final logging = ref.watch(loggingServiceProvider);

      return HospitalShortlistRepositoryImpl(
        dao: db.hospitalShortlistDao,
        logger: logging,
      );
    });

/// Provider for the get nearby units use case.
final getNearbyUnitsUseCaseProvider = FutureProvider<GetNearbyUnitsUseCase>((
  ref,
) async {
  final repository = await ref.watch(maternityUnitRepositoryProvider.future);
  return GetNearbyUnitsUseCase(repository: repository);
});

/// Provider for the filter units use case.
final filterUnitsUseCaseProvider = FutureProvider<FilterUnitsUseCase>((
  ref,
) async {
  final repository = await ref.watch(maternityUnitRepositoryProvider.future);
  return FilterUnitsUseCase(repository: repository);
});

/// Provider for the get unit detail use case.
final getUnitDetailUseCaseProvider = FutureProvider<GetUnitDetailUseCase>((
  ref,
) async {
  final repository = await ref.watch(maternityUnitRepositoryProvider.future);
  return GetUnitDetailUseCase(repository: repository);
});

/// Provider for the manage shortlist use case.
final manageShortlistUseCaseProvider = FutureProvider<ManageShortlistUseCase>((
  ref,
) async {
  final repository = await ref.watch(
    hospitalShortlistRepositoryProvider.future,
  );
  return ManageShortlistUseCase(repository: repository);
});

/// Provider for the select final hospital use case.
final selectFinalHospitalUseCaseProvider =
    FutureProvider<SelectFinalHospitalUseCase>((ref) async {
      final repository = await ref.watch(
        hospitalShortlistRepositoryProvider.future,
      );
      return SelectFinalHospitalUseCase(repository: repository);
    });
