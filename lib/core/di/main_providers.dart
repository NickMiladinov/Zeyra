import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/repositories/kick_counter_repository_impl.dart';
import '../../domain/repositories/kick_counter_repository.dart';
import '../../domain/usecases/kick_counter/calculate_analytics_usecase.dart';
import '../../domain/usecases/kick_counter/manage_session_usecase.dart';
import '../services/encryption_service.dart';

/// Main DI providers registration file.
/// 
/// All top-level Riverpod providers should be registered here.
/// This file serves as the central dependency injection registry for the application.

// ----------------------------------------------------------------------------
// Core Services
// ----------------------------------------------------------------------------

/// Provider for the encryption service.
/// 
/// Singleton instance used for encrypting/decrypting sensitive medical data.
/// Must call initialize() before using encrypt/decrypt methods.
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// Provider for the app database.
/// 
/// Singleton Drift database instance for all local data storage.
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
  
  return KickCounterRepositoryImpl(
    dao: db.kickCounterDao,
    encryptionService: encryption,
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
