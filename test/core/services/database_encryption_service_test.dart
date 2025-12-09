import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/database_encryption_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late DatabaseEncryptionService encryptionService;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    encryptionService = DatabaseEncryptionService(secureStorage: mockStorage);

    // Register fallback values
    registerFallbackValue('key');
    registerFallbackValue('value');
  });

  group('[Core] DatabaseEncryptionService - SQLCipher Key Management', () {
    const testUserId = 'test-user-123';
    const testKeyId = 'zeyra_db_key_test-user-123';
    
    // Valid 64-character hex string (256 bits)
    const validHexKey = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

    test('should generate new 256-bit hex key if none exists', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      // Act
      final key = await encryptionService.getKeyForUser(testUserId);

      // Assert
      expect(key, isNotEmpty);
      expect(key.length, equals(64)); // 32 bytes * 2 (hex encoding)
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(key), isTrue);
      
      verify(() => mockStorage.read(key: testKeyId)).called(1);
      verify(() => mockStorage.write(
        key: testKeyId,
        value: any(named: 'value'),
      )).called(1);
    });

    test('should return existing key if already stored', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => validHexKey);

      // Act
      final key = await encryptionService.getKeyForUser(testUserId);

      // Assert
      expect(key, equals(validHexKey));
      verify(() => mockStorage.read(key: testKeyId)).called(1);
      verifyNever(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ));
    });

    test('should cache key after first retrieval', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => validHexKey);

      // Act
      final key1 = await encryptionService.getKeyForUser(testUserId);
      final key2 = await encryptionService.getKeyForUser(testUserId);

      // Assert
      expect(key1, equals(key2));
      // Should only read from storage once due to caching
      verify(() => mockStorage.read(key: testKeyId)).called(1);
    });

    test('should not cache keys for different users', () async {
      // Arrange
      const userId1 = 'user1';
      const userId2 = 'user2';
      const keyId1 = 'zeyra_db_key_user1';
      const keyId2 = 'zeyra_db_key_user2';
      const key1 = '0000000000000000000000000000000000000000000000000000000000000001';
      const key2 = '0000000000000000000000000000000000000000000000000000000000000002';

      when(() => mockStorage.read(key: keyId1))
          .thenAnswer((_) async => key1);
      when(() => mockStorage.read(key: keyId2))
          .thenAnswer((_) async => key2);

      // Act
      final retrievedKey1 = await encryptionService.getKeyForUser(userId1);
      final retrievedKey2 = await encryptionService.getKeyForUser(userId2);

      // Assert
      expect(retrievedKey1, equals(key1));
      expect(retrievedKey2, equals(key2));
      verify(() => mockStorage.read(key: keyId1)).called(1);
      verify(() => mockStorage.read(key: keyId2)).called(1);
    });

    test('should check if key exists for user', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => validHexKey);

      // Act
      final exists = await encryptionService.hasKeyForUser(testUserId);

      // Assert
      expect(exists, isTrue);
      verify(() => mockStorage.read(key: testKeyId)).called(1);
    });

    test('should return false if no key exists for user', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => null);

      // Act
      final exists = await encryptionService.hasKeyForUser(testUserId);

      // Assert
      expect(exists, isFalse);
      verify(() => mockStorage.read(key: testKeyId)).called(1);
    });

    test('should clear cache on clearCache()', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => validHexKey);

      await encryptionService.getKeyForUser(testUserId);
      
      // Act
      encryptionService.clearCache();
      
      // Request key again - should read from storage again
      await encryptionService.getKeyForUser(testUserId);

      // Assert - Should have read from storage twice (once before clear, once after)
      verify(() => mockStorage.read(key: testKeyId)).called(2);
    });

    test('should delete key for user', () async {
      // Arrange
      when(() => mockStorage.delete(key: testKeyId))
          .thenAnswer((_) async {});

      // Act
      await encryptionService.deleteKeyForUser(testUserId);

      // Assert
      verify(() => mockStorage.delete(key: testKeyId)).called(1);
    });

    test('should clear cache after deleting key', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => validHexKey);
      when(() => mockStorage.delete(key: testKeyId))
          .thenAnswer((_) async {});
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      // Cache a key
      await encryptionService.getKeyForUser(testUserId);
      
      // Act
      await encryptionService.deleteKeyForUser(testUserId);
      
      // Try to get key again - should generate new one since deleted
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => null);
      await encryptionService.getKeyForUser(testUserId);

      // Assert
      verify(() => mockStorage.delete(key: testKeyId)).called(1);
      // Should have read twice (once before delete, once after)
      verify(() => mockStorage.read(key: testKeyId)).called(2);
      // Should write new key after deletion
      verify(() => mockStorage.write(
        key: testKeyId,
        value: any(named: 'value'),
      )).called(1);
    });

    test('should use correct key prefix pattern', () async {
      // Arrange
      const userId = 'auth-id-456';
      const expectedKeyId = 'zeyra_db_key_auth-id-456';
      
      when(() => mockStorage.read(key: expectedKeyId))
          .thenAnswer((_) async => validHexKey);

      // Act
      await encryptionService.getKeyForUser(userId);

      // Assert
      verify(() => mockStorage.read(key: expectedKeyId)).called(1);
    });

    test('should generate unique keys on consecutive calls for new users', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      // Act
      final key1 = await encryptionService.getKeyForUser(testUserId);
      
      // Clear cache to force regeneration
      encryptionService.clearCache();
      
      final key2 = await encryptionService.getKeyForUser(testUserId);

      // Assert - Keys should be different due to random generation
      expect(key1, isNot(equals(key2)));
      expect(key1.length, equals(64));
      expect(key2.length, equals(64));
    });

    test('should handle multiple user contexts independently', () async {
      // Arrange
      const user1 = 'user-alpha';
      const user2 = 'user-beta';
      const key1Id = 'zeyra_db_key_user-alpha';
      const key2Id = 'zeyra_db_key_user-beta';
      const key1 = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      const key2 = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

      when(() => mockStorage.read(key: key1Id))
          .thenAnswer((_) async => key1);
      when(() => mockStorage.read(key: key2Id))
          .thenAnswer((_) async => key2);

      // Act
      final retrievedKey1a = await encryptionService.getKeyForUser(user1);
      final retrievedKey2 = await encryptionService.getKeyForUser(user2);
      final retrievedKey1b = await encryptionService.getKeyForUser(user1);

      // Assert
      expect(retrievedKey1a, equals(key1));
      expect(retrievedKey2, equals(key2));
      expect(retrievedKey1b, equals(key1));

      // user1's key is read twice because cache is cleared when switching to user2
      // Cache only holds one user at a time (single-user cache, not multi-user)
      verify(() => mockStorage.read(key: key1Id)).called(2);
      verify(() => mockStorage.read(key: key2Id)).called(1);
    });

    test('should throw error if key generation fails', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenThrow(Exception('Storage write failed'));

      // Act & Assert
      expect(
        () => encryptionService.getKeyForUser(testUserId),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle secure storage read errors gracefully', () async {
      // Arrange
      when(() => mockStorage.read(key: testKeyId))
          .thenThrow(Exception('Storage read failed'));

      // Act & Assert
      expect(
        () => encryptionService.getKeyForUser(testUserId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
