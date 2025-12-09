import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing SQLCipher database encryption keys per user.
///
/// Handles key generation, storage, and retrieval for per-user encrypted databases.
/// Keys are stored in platform secure storage (Android Keystore / iOS Keychain).
///
/// **Key Storage Pattern:** `zeyra_db_key_<authId>`
///
/// **Security Properties:**
/// - 256-bit keys generated using cryptographically secure random
/// - Keys stored in hardware-backed secure storage
/// - Keys cached in memory during active session
/// - Cache cleared on logout to prevent unauthorized access
///
/// **Initialization:** This service is initialized in `DIGraph.initialize()` during app startup.
/// Access via `databaseEncryptionServiceProvider` or `DIGraph.databaseEncryptionService`.
class DatabaseEncryptionService {
  static const String _keyPrefix = 'zeyra_db_key_';
  static const int _keyLengthBytes = 32; // 256 bits

  final FlutterSecureStorage _secureStorage;
  final Random _secureRandom;

  // In-memory cache for the current user's key
  String? _cachedKey;
  String? _currentUserId;

  DatabaseEncryptionService({
    FlutterSecureStorage? secureStorage,
    Random? secureRandom,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            ),
        _secureRandom = secureRandom ?? Random.secure();

  /// Get or create the encryption key for a user.
  ///
  /// If a key exists in secure storage, it is retrieved and cached.
  /// If no key exists, a new 256-bit key is generated and stored.
  ///
  /// [userId] - The Supabase auth ID of the user
  ///
  /// Returns the hex-encoded encryption key for SQLCipher.
  ///
  /// Throws [DatabaseEncryptionException] if key operations fail.
  Future<String> getKeyForUser(String userId) async {
    // Return cached key if available for the same user
    if (_cachedKey != null && _currentUserId == userId) {
      return _cachedKey!;
    }

    try {
      final storageKey = '$_keyPrefix$userId';

      // Try to read existing key
      String? keyHex = await _secureStorage.read(key: storageKey);

      if (keyHex == null) {
        // Generate new key
        keyHex = _generateKey();
        await _secureStorage.write(key: storageKey, value: keyHex);
      }

      // Cache for current session
      _cachedKey = keyHex;
      _currentUserId = userId;

      return keyHex;
    } catch (e) {
      throw DatabaseEncryptionException(
        'Failed to get encryption key for user: $e',
      );
    }
  }

  /// Check if a key exists for a user without loading it.
  ///
  /// [userId] - The Supabase auth ID of the user
  ///
  /// Returns true if a key exists in secure storage.
  Future<bool> hasKeyForUser(String userId) async {
    try {
      final storageKey = '$_keyPrefix$userId';
      final key = await _secureStorage.read(key: storageKey);
      return key != null;
    } catch (e) {
      return false;
    }
  }

  /// Clear the cached key from memory.
  ///
  /// Call this on logout or session lock to prevent unauthorized access.
  /// The key remains in secure storage for future sessions.
  void clearCache() {
    _cachedKey = null;
    _currentUserId = null;
  }

  /// Delete the encryption key for a user.
  ///
  /// **WARNING:** This makes all data in the user's encrypted database
  /// permanently unrecoverable. Only use during account deletion.
  ///
  /// [userId] - The Supabase auth ID of the user
  ///
  /// Throws [DatabaseEncryptionException] if deletion fails.
  Future<void> deleteKeyForUser(String userId) async {
    try {
      final storageKey = '$_keyPrefix$userId';
      await _secureStorage.delete(key: storageKey);

      // Clear cache if this was the current user
      if (_currentUserId == userId) {
        clearCache();
      }
    } catch (e) {
      throw DatabaseEncryptionException(
        'Failed to delete encryption key for user: $e',
      );
    }
  }

  /// Generate a cryptographically secure 256-bit key.
  ///
  /// Returns the key as a hex-encoded string.
  String _generateKey() {
    final bytes = List<int>.generate(
      _keyLengthBytes,
      (_) => _secureRandom.nextInt(256),
    );
    return _bytesToHex(bytes);
  }

  /// Convert bytes to hex string.
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Get the current cached user ID (for debugging/verification).
  ///
  /// Returns null if no key is currently cached.
  String? get currentUserId => _currentUserId;

  /// Check if a key is currently cached in memory.
  bool get hasCachedKey => _cachedKey != null;
}

/// Exception thrown by database encryption operations.
class DatabaseEncryptionException implements Exception {
  final String message;

  const DatabaseEncryptionException(this.message);

  @override
  String toString() => 'DatabaseEncryptionException: $message';
}
