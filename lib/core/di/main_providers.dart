import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/app_database.dart';
import '../../data/repositories/bump_photo_repository_impl.dart';
import '../../data/repositories/contraction_timer_repository_impl.dart';
import '../../data/repositories/kick_counter_repository_impl.dart';
import '../../data/repositories/pregnancy_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/bump_photo_repository.dart';
import '../../domain/repositories/contraction_timer_repository.dart';
import '../../domain/repositories/kick_counter_repository.dart';
import '../../domain/repositories/pregnancy_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/usecases/bump_photo/delete_bump_photo.dart';
import '../../domain/usecases/bump_photo/get_bump_photos.dart';
import '../../domain/usecases/bump_photo/save_bump_photo.dart';
import '../../domain/usecases/bump_photo/save_bump_photo_note.dart';
import '../../domain/usecases/bump_photo/update_bump_photo_note.dart';
import '../../domain/usecases/contraction_timer/calculate_511_rule_usecase.dart';
import '../../domain/usecases/contraction_timer/manage_contraction_session_usecase.dart';
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
import '../services/notification_permission_service.dart';
import '../services/payment_service.dart';
import '../services/photo_file_service.dart';
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

/// Provider for the payment service.
///
/// Wraps RevenueCat SDK for subscription management.
/// Initialized in DIGraph.initialize() during app startup.
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return DIGraph.paymentService;
});

/// Provider for Zeyra entitlement status.
///
/// Returns true if user has an active Zeyra subscription.
/// Use this for gating premium features.
final hasZeyraEntitlementProvider = FutureProvider<bool>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  if (!paymentService.isInitialized) {
    return false;
  }
  return await paymentService.hasZeyraEntitlement();
});

/// Provider for customer info stream.
///
/// Use this for reactive UI updates when subscription status changes.
final customerInfoStreamProvider = StreamProvider<CustomerInfo?>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  if (!paymentService.isInitialized) {
    return const Stream.empty();
  }
  return paymentService.customerInfoStream;
});

/// Provider for the notification permission service.
///
/// Handles notification permission requests and status checks.
final notificationPermissionServiceProvider = Provider<NotificationPermissionService>((ref) {
  final logging = ref.watch(loggingServiceProvider);
  return NotificationPermissionService(logging);
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
  final pregnancyRepo = await ref.watch(pregnancyRepositoryProvider.future);

  return KickCounterRepositoryImpl(
    dao: db.kickCounterDao,
    pregnancyRepository: pregnancyRepo,
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
// Contraction Timer Feature
// ----------------------------------------------------------------------------

/// Provider for the contraction timer repository.
///
/// Implements contraction timer data operations with SQLCipher-encrypted Drift persistence.
final contractionTimerRepositoryProvider = FutureProvider<ContractionTimerRepository>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final logging = ref.watch(loggingServiceProvider);
  final pregnancyRepo = await ref.watch(pregnancyRepositoryProvider.future);

  return ContractionTimerRepositoryImpl(
    dao: db.contractionTimerDao,
    pregnancyRepository: pregnancyRepo,
    logger: logging,
  );
});

/// Provider for the manage contraction session use case.
///
/// Orchestrates contraction timing session operations with validation.
final manageContractionSessionUseCaseProvider = FutureProvider<ManageContractionSessionUseCase>((ref) async {
  final repository = await ref.watch(contractionTimerRepositoryProvider.future);

  return ManageContractionSessionUseCase(repository: repository);
});

/// Provider for the calculate 5-1-1 rule use case.
///
/// Handles 5-1-1 rule calculations with rolling window and tolerances.
final calculate511RuleUseCaseProvider = FutureProvider<Calculate511RuleUseCase>((ref) async {
  return Calculate511RuleUseCase();
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

/// Provider for the active pregnancy entity.
///
/// Returns the current active pregnancy or null if none exists.
final activePregnancyProvider = FutureProvider((ref) async {
  final useCase = await ref.watch(getActivePregnancyUseCaseProvider.future);
  return await useCase.execute();
});

// ----------------------------------------------------------------------------
// Bump Photo Feature
// ----------------------------------------------------------------------------

/// Provider for the photo file service.
///
/// Handles file operations for bump photos including compression and user-isolated storage.
final photoFileServiceProvider = Provider<PhotoFileService>((ref) {
  final logging = ref.watch(loggingServiceProvider);
  return PhotoFileService(logger: logging);
});

/// Provider for the bump photo repository.
///
/// Implements bump photo data operations with SQLCipher-encrypted Drift persistence
/// and file system storage for photos.
final bumpPhotoRepositoryProvider = FutureProvider<BumpPhotoRepository>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final fileService = ref.watch(photoFileServiceProvider);
  final logging = ref.watch(loggingServiceProvider);

  // Get current user ID for file operations
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    throw StateError('Cannot access bump photo repository without authenticated user.');
  }

  return BumpPhotoRepositoryImpl(
    dao: db.bumpPhotoDao,
    fileService: fileService,
    logger: logging,
    userId: user.id,
  );
});

/// Provider for the get bump photos use case.
final getBumpPhotosUseCaseProvider = FutureProvider<GetBumpPhotos>((ref) async {
  final repository = await ref.watch(bumpPhotoRepositoryProvider.future);
  return GetBumpPhotos(repository);
});

/// Provider for the save bump photo use case.
final saveBumpPhotoUseCaseProvider = FutureProvider<SaveBumpPhoto>((ref) async {
  final repository = await ref.watch(bumpPhotoRepositoryProvider.future);
  return SaveBumpPhoto(repository);
});

/// Provider for the save bump photo note use case (without photo).
final saveBumpPhotoNoteUseCaseProvider = FutureProvider<SaveBumpPhotoNote>((ref) async {
  final repository = await ref.watch(bumpPhotoRepositoryProvider.future);
  return SaveBumpPhotoNote(repository);
});

/// Provider for the update bump photo note use case.
final updateBumpPhotoNoteUseCaseProvider = FutureProvider<UpdateBumpPhotoNote>((ref) async {
  final repository = await ref.watch(bumpPhotoRepositoryProvider.future);
  return UpdateBumpPhotoNote(repository);
});

/// Provider for the delete bump photo use case.
final deleteBumpPhotoUseCaseProvider = FutureProvider<DeleteBumpPhoto>((ref) async {
  final repository = await ref.watch(bumpPhotoRepositoryProvider.future);
  return DeleteBumpPhoto(repository);
});
