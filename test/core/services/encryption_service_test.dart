import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/encryption_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late EncryptionService encryptionService;
  
  // Valid 32-byte key encoded in base64 (AES-256 requires exactly 32 bytes)
  // This is bytes 0x00 through 0x1F (32 bytes total)
  const validBase64Key = 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    encryptionService = EncryptionService(secureStorage: mockStorage);

    // Register fallback values
    registerFallbackValue('key');
    registerFallbackValue('value');
  });

  group('[Core] EncryptionService - AES-GCM', () {
    test('should initialize without error', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);

      // Act
      await encryptionService.initialize();
      
      // Assert
      verify(() => mockStorage.read(key: 'zeyra_encryption_key')).called(1);
    });

    test('should generate new key if none exists', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      // Act
      await encryptionService.initialize();

      // Assert
      verify(() => mockStorage.read(key: 'zeyra_encryption_key')).called(1);
      verify(() => mockStorage.write(
            key: 'zeyra_encryption_key',
            value: any(named: 'value'),
          )).called(1);
    });

    test('should encrypt plaintext to non-empty ciphertext', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      const plaintext = 'test data';

      // Act
      final ciphertext = await encryptionService.encrypt(plaintext);

      // Assert
      expect(ciphertext, isNotEmpty);
      expect(ciphertext, isNot(equals(plaintext)));
    });

    test('should decrypt ciphertext back to original plaintext', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      const plaintext = 'sensitive medical data';

      // Act
      final ciphertext = await encryptionService.encrypt(plaintext);
      final decrypted = await encryptionService.decrypt(ciphertext);

      // Assert
      expect(decrypted, equals(plaintext));
    });

    test('should produce different ciphertext for same plaintext (nonce randomness)',
        () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      const plaintext = 'test';

      // Act
      final ciphertext1 = await encryptionService.encrypt(plaintext);
      final ciphertext2 = await encryptionService.encrypt(plaintext);

      // Assert - Different due to random nonce
      expect(ciphertext1, isNot(equals(ciphertext2)));
      
      // But both decrypt to same plaintext
      final decrypted1 = await encryptionService.decrypt(ciphertext1);
      final decrypted2 = await encryptionService.decrypt(ciphertext2);
      expect(decrypted1, equals(plaintext));
      expect(decrypted2, equals(plaintext));
    });

    test('should throw exception when decrypting invalid base64', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      const invalidCiphertext = 'invalid-base64-data!!!';

      // Act & Assert
      expect(
        () => encryptionService.decrypt(invalidCiphertext),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('should throw exception when ciphertext is too short', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      // Too short - needs at least 12 (nonce) + 16 (mac) = 28 bytes
      const shortCiphertext = 'YWJjZA=='; // "abcd" in base64

      // Act & Assert
      expect(
        () => encryptionService.decrypt(shortCiphertext),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('should detect tampering with authentication tag', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      const plaintext = 'important medical data';

      // Act
      final ciphertext = await encryptionService.encrypt(plaintext);
      
      // Tamper with the ciphertext by flipping a bit
      final tamperedCiphertext = _tamperWithCiphertext(ciphertext);

      // Assert - Should throw authentication error
      expect(
        () => encryptionService.decrypt(tamperedCiphertext),
        throwsA(
          isA<EncryptionException>().having(
            (e) => e.message,
            'message',
            contains('Authentication failed'),
          ),
        ),
      );
    });

    test('should handle empty string encryption and decryption', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      const plaintext = '';

      // Act
      final ciphertext = await encryptionService.encrypt(plaintext);
      final decrypted = await encryptionService.decrypt(ciphertext);

      // Assert
      expect(decrypted, equals(plaintext));
    });

    test('should handle unicode characters', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      const plaintext = 'Hello 👶 测试 🤰';

      // Act
      final ciphertext = await encryptionService.encrypt(plaintext);
      final decrypted = await encryptionService.decrypt(ciphertext);

      // Assert
      expect(decrypted, equals(plaintext));
    });

    test('should handle long text encryption', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      await encryptionService.initialize();

      final plaintext = 'Long medical note: ${'A' * 1000}';

      // Act
      final ciphertext = await encryptionService.encrypt(plaintext);
      final decrypted = await encryptionService.decrypt(ciphertext);

      // Assert
      expect(decrypted, equals(plaintext));
    });

    test('should clear key from storage', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => validBase64Key);
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      await encryptionService.initialize();

      // Act
      await encryptionService.clearKey();

      // Assert
      verify(() => mockStorage.delete(key: 'zeyra_encryption_key')).called(1);
    });
  });
}

/// Helper function to tamper with ciphertext for testing authentication.
String _tamperWithCiphertext(String ciphertext) {
  final bytes = ciphertext.codeUnits.toList();
  // Flip a bit in the middle of the ciphertext
  if (bytes.length > 10) {
    bytes[bytes.length ~/ 2] = bytes[bytes.length ~/ 2] ^ 1;
  }
  return String.fromCharCodes(bytes);
}
