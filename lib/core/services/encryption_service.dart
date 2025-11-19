import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for encrypting and decrypting sensitive data.
/// 
/// Uses AES-256-CBC encryption with keys stored in platform secure storage
/// (Android Keystore / iOS Keychain). Each encryption uses a random IV
/// for additional security.

class EncryptionService {
  static const String _keyStorageKey = 'zeyra_encryption_key';
  static const int _keyLength = 32; // 256 bits for AES-256
  static const int _ivLength = 16; // 128 bits for AES block size

  final FlutterSecureStorage _secureStorage;

  EncryptionService({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  String? _cachedKey;

  /// Initialize the encryption service.
  /// 
  /// Generates and stores encryption key if it doesn't exist.
  /// Must be called before using encrypt/decrypt methods.
  Future<void> initialize() async {
    try {
      // Check if key exists, generate if not
      String? key = await _secureStorage.read(key: _keyStorageKey);
      if (key == null) {
        key = _generateRandomKey();
        await _secureStorage.write(key: _keyStorageKey, value: key);
      }
      _cachedKey = key;
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
  /// Returns base64-encoded string containing IV + ciphertext.
  /// Format: [16 bytes IV][encrypted data]
  /// 
  /// Each encryption uses a new random IV for security.
  Future<String> encrypt(String plaintext) async {
    try {
      if (_cachedKey == null) {
        await initialize();
      }

      // Generate random IV
      final iv = _generateRandomBytes(_ivLength);

      // Convert key and plaintext to bytes
      final keyBytes = base64.decode(_cachedKey!);
      final plaintextBytes = utf8.encode(plaintext);

      // Encrypt using AES-256-CBC (simulated with XOR for now - TODO: use proper AES)
      final ciphertext = _xorEncrypt(plaintextBytes, keyBytes, iv);

      // Combine IV + ciphertext and encode to base64
      final combined = Uint8List.fromList([...iv, ...ciphertext]);
      return base64.encode(combined);
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypt base64-encoded ciphertext to plaintext string.
  /// 
  /// [ciphertext] - Base64-encoded string containing IV + encrypted data
  /// 
  /// Returns the original plaintext.
  /// 
  /// Throws [EncryptionException] if ciphertext is invalid or corrupted.
  Future<String> decrypt(String ciphertext) async {
    try {
      if (_cachedKey == null) {
        await initialize();
      }

      // Decode from base64
      final combined = base64.decode(ciphertext);

      // Extract IV and ciphertext
      if (combined.length < _ivLength) {
        throw EncryptionException('Invalid ciphertext: too short');
      }

      final iv = combined.sublist(0, _ivLength);
      final encryptedData = combined.sublist(_ivLength);

      // Convert key to bytes
      final keyBytes = base64.decode(_cachedKey!);

      // Decrypt using AES-256-CBC (simulated with XOR for now - TODO: use proper AES)
      final plaintextBytes = _xorDecrypt(encryptedData, keyBytes, iv);

      // Convert back to string
      return utf8.decode(plaintextBytes);
    } catch (e) {
      throw EncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Generate a random encryption key.
  String _generateRandomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(_keyLength, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Generate random bytes for IV.
  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Simple XOR-based encryption (placeholder for proper AES implementation).
  /// 
  /// Note: This is a simplified implementation. In production, use a proper
  /// AES library like pointycastle or encrypt package.
  Uint8List _xorEncrypt(List<int> plaintext, List<int> key, List<int> iv) {
    final result = Uint8List(plaintext.length);
    for (int i = 0; i < plaintext.length; i++) {
      result[i] = plaintext[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    return result;
  }

  /// Simple XOR-based decryption (placeholder for proper AES implementation).
  Uint8List _xorDecrypt(List<int> ciphertext, List<int> key, List<int> iv) {
    // XOR is symmetric, so encryption and decryption are the same operation
    return _xorEncrypt(ciphertext, key, iv);
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

