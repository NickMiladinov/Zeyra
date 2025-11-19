import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/encryption_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late EncryptionService encryptionService;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    encryptionService = EncryptionService(secureStorage: mockStorage);

    // Register fallback values
    registerFallbackValue('key');
    registerFallbackValue('value');
  });

  group('[Core] EncryptionService', () {
    test('should initialize without error', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'existing-key');

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
          .thenAnswer((_) async => 'dGVzdC1rZXk='); // base64 test key
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
          .thenAnswer((_) async => 'dGVzdC1rZXk='); // base64 test key
      await encryptionService.initialize();

      const plaintext = 'sensitive medical data';

      // Act
      final ciphertext = await encryptionService.encrypt(plaintext);
      final decrypted = await encryptionService.decrypt(ciphertext);

      // Assert
      expect(decrypted, equals(plaintext));
    });

    test('should produce different ciphertext for same plaintext (IV randomness)',
        () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'dGVzdC1rZXk='); // base64 test key
      await encryptionService.initialize();

      const plaintext = 'test';

      // Act
      final ciphertext1 = await encryptionService.encrypt(plaintext);
      final ciphertext2 = await encryptionService.encrypt(plaintext);

      // Assert - Different due to random IV
      expect(ciphertext1, isNot(equals(ciphertext2)));
      
      // But both decrypt to same plaintext
      final decrypted1 = await encryptionService.decrypt(ciphertext1);
      final decrypted2 = await encryptionService.decrypt(ciphertext2);
      expect(decrypted1, equals(plaintext));
      expect(decrypted2, equals(plaintext));
    });

    test('should throw exception when decrypting invalid ciphertext', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'dGVzdC1rZXk='); // base64 test key
      await encryptionService.initialize();

      const invalidCiphertext = 'invalid-base64-data';

      // Act & Assert
      expect(
        () => encryptionService.decrypt(invalidCiphertext),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('should clear key from storage', () async {
      // Arrange
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'test-key');
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

