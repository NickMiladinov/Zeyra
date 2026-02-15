import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/app_database.dart';
import '../di/di_graph.dart';
import '../monitoring/logging_service.dart';
import 'database_encryption_service.dart';

typedef ClearDatabaseCache = Future<void> Function([String? userId]);

/// Lightweight account identity details for account UI.
class AccountIdentity {
  const AccountIdentity({
    required this.userId,
    required this.email,
    required this.provider,
  });

  final String userId;
  final String? email;
  final String? provider;

  String get providerLabel {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      default:
        return 'OAuth';
    }
  }
}

/// Account operations service for sign-out and account deletion.
class AccountService {
  AccountService({
    required LoggingService logger,
    required DatabaseEncryptionService databaseEncryptionService,
    required ClearDatabaseCache clearDatabaseCache,
    SupabaseClient? supabaseClient,
  })  : _logger = logger,
        _databaseEncryptionService = databaseEncryptionService,
        _clearDatabaseCache = clearDatabaseCache,
        _supabase = supabaseClient ?? Supabase.instance.client;

  final LoggingService _logger;
  final DatabaseEncryptionService _databaseEncryptionService;
  final ClearDatabaseCache _clearDatabaseCache;
  final SupabaseClient _supabase;

  AccountIdentity? getCurrentIdentity() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final provider = user.appMetadata['provider'] as String?;
    return AccountIdentity(
      userId: user.id,
      email: user.email,
      provider: provider,
    );
  }

  /// Signs the current user out while preserving account data for later login.
  Future<void> signOut() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId != null) {
      await _clearDatabaseCache(userId);
    }

    DIGraph.clearEncryptionCache();
    await _supabase.auth.signOut();
    _logger.info('AccountService: User signed out');
  }

  /// Deletes the current authenticated user account remotely and locally.
  Future<void> deleteCurrentAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AccountServiceException('No authenticated user found.');
    }

    final userId = user.id;
    _logger.warning('AccountService: Starting account deletion');

    // 1) Delete remote auth user via edge function.
    final response = await _supabase.functions.invoke(
      'delete-user-account',
      body: {'confirmDeletion': true},
    );

    if (response.status != 200) {
      throw AccountServiceException(
        'Account deletion failed with status ${response.status}.',
      );
    }

    final data = response.data;
    if (data is! Map<String, dynamic> || data['success'] != true) {
      throw const AccountServiceException(
        'Account deletion failed. Please try again.',
      );
    }

    // 2) Local secure cleanup.
    await _clearDatabaseCache(userId);
    await deleteDatabaseFileForUser(userId);
    await _databaseEncryptionService.deleteKeyForUser(userId);
    DIGraph.clearEncryptionCache();

    // 3) Ensure session cleanup on device.
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // User may already be invalidated after remote delete. Safe to ignore.
    }

    _logger.info('AccountService: Account deletion completed');
  }
}

class AccountServiceException implements Exception {
  const AccountServiceException(this.message);

  final String message;

  @override
  String toString() => 'AccountServiceException: $message';
}
