import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for encrypting and decrypting sensitive data using AES-256-GCM.
/// 
/// Uses AES-256-GCM encryption with authentication for secure data protection.
/// Encryption keys are stored in platform secure storage (Android Keystore / iOS Keychain).
/// Each encryption uses a random nonce for additional security.
///
/// AES-GCM provides:
/// - Confidentiality (encryption)
/// - Authentication (tamper detection via auth tag)
/// - Performance (hardware acceleration via cryptography_flutter)
/// 
/// **Initialization:** This service is initialized in `DIGraph.initialize()` during app startup.
/// Access via `encryptionServiceProvider` or `DIGraph.encryptionService`.
class EncryptionService {
  static const String _keyStorageKey = 'zeyra_encryption_key';

  final FlutterSecureStorage _secureStorage;
  final AesGcm _algorithm;

  EncryptionService({
    FlutterSecureStorage? secureStorage,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            ),
        _algorithm = AesGcm.with256bits();

  SecretKey? _cachedKey;

  /// Initialize the encryption service.
  /// 
  /// Generates and stores encryption key if it doesn't exist.
  /// Must be called before using encrypt/decrypt methods.
  Future<void> initialize() async {
    try {
      // Check if key exists, generate if not
      String? keyString = await _secureStorage.read(key: _keyStorageKey);
      
      if (keyString == null) {
        // Generate new secret key
        final newKey = await _algorithm.newSecretKey();
        final keyBytes = await newKey.extractBytes();
        keyString = base64.encode(keyBytes);
        await _secureStorage.write(key: _keyStorageKey, value: keyString);
      }
      
      // Create SecretKey from stored bytes
      final keyBytes = base64.decode(keyString);
      _cachedKey = SecretKey(keyBytes);
    } catch (e) {
      throw EncryptionException(
        'Failed to initialize encryption service: $e',
      );
    }
  }

  /// Encrypt plaintext string to base64-encoded ciphertext.
  /// 
  /// [plaintext] - The data to encrypt
  /// 
  /// Returns base64-encoded string containing nonce + ciphertext + auth tag.
  /// Format: [12 bytes nonce][encrypted data][16 bytes auth tag]
  /// 
  /// Each encryption uses a new random nonce for security.
  /// The authentication tag enables tamper detection.
  Future<String> encrypt(String plaintext) async {
    try {
      if (_cachedKey == null) {
        await initialize();
      }

      // Convert plaintext to bytes
      final plaintextBytes = utf8.encode(plaintext);

      // Encrypt using AES-256-GCM
      final secretBox = await _algorithm.encrypt(
        plaintextBytes,
        secretKey: _cachedKey!,
      );

      // Combine nonce + ciphertext + mac (auth tag) and encode to base64
      final combined = Uint8List.fromList([
        ...secretBox.nonce,
        ...secretBox.cipherText,
        ...secretBox.mac.bytes,
      ]);
      
      return base64.encode(combined);
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypt base64-encoded ciphertext to plaintext string.
  /// 
  /// [ciphertext] - Base64-encoded string containing nonce + encrypted data + auth tag
  /// 
  /// Returns the original plaintext.
  /// 
  /// Throws [EncryptionException] if:
  /// - Ciphertext is invalid or corrupted
  /// - Authentication tag verification fails (tamper detection)
  Future<String> decrypt(String ciphertext) async {
    try {
      if (_cachedKey == null) {
        await initialize();
      }

      // Decode from base64
      final combined = base64.decode(ciphertext);

      // Extract nonce (12 bytes), ciphertext, and MAC (16 bytes)
      const nonceLength = 12; // Standard for GCM
      const macLength = 16; // 128 bits

      if (combined.length < nonceLength + macLength) {
        throw EncryptionException('Invalid ciphertext: too short');
      }

      final nonce = combined.sublist(0, nonceLength);
      final mac = combined.sublist(combined.length - macLength);
      final encryptedData = combined.sublist(
        nonceLength,
        combined.length - macLength,
      );

      // Create SecretBox with all components
      final secretBox = SecretBox(
        encryptedData,
        nonce: nonce,
        mac: Mac(mac),
      );

      // Decrypt using AES-256-GCM (will throw if auth tag is invalid)
      final plaintextBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: _cachedKey!,
      );

      // Convert back to string
      return utf8.decode(plaintextBytes);
    } on SecretBoxAuthenticationError {
      throw EncryptionException(
        'Authentication failed: data has been tampered with or corrupted',
      );
    } catch (e) {
      if (e is EncryptionException) rethrow;
      throw EncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Clear the encryption key from memory and secure storage.
  /// 
  /// WARNING: This will make all encrypted data unrecoverable.
  /// Only use during app reset/uninstall flows.
  Future<void> clearKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
    _cachedKey = null;
  }
}

/// Exception thrown by encryption operations.
class EncryptionException implements Exception {
  final String message;

  const EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
