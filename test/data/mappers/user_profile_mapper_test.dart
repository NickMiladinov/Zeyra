@Tags(['user_profile'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/mappers/user_profile_mapper.dart';
import 'package:zeyra/domain/entities/user_profile/gender.dart';

import '../../mocks/fake_data/user_profile_fakes.dart';

void main() {
  group('[UserProfile] UserProfileMapper', () {
    test('should map UserProfileDto to UserProfile domain entity', () {
      // Arrange
      final dto = UserProfileDto(
        id: 'profile-1',
        authId: 'auth-123',
        email: 'test@example.com',
        firstName: 'Jane',
        lastName: 'Doe',
        dateOfBirthMillis: DateTime(1990, 5, 15).millisecondsSinceEpoch,
        gender: 'female',
        createdAtMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMillis: DateTime(2024, 1, 2).millisecondsSinceEpoch,
        isSynced: false,
        databasePath: '/path/to/db.sqlite',
        encryptionKeyId: 'key-123',
        lastAccessedAtMillis: DateTime(2024, 1, 3).millisecondsSinceEpoch,
        schemaVersion: 2,
      );

      // Act
      final domain = UserProfileMapper.toDomain(dto);

      // Assert
      expect(domain.id, equals('profile-1'));
      expect(domain.authId, equals('auth-123'));
      expect(domain.email, equals('test@example.com'));
      expect(domain.firstName, equals('Jane'));
      expect(domain.lastName, equals('Doe'));
      expect(domain.dateOfBirth, equals(DateTime(1990, 5, 15)));
      expect(domain.gender, equals(Gender.female));
      expect(domain.createdAt, equals(DateTime(2024, 1, 1)));
      expect(domain.updatedAt, equals(DateTime(2024, 1, 2)));
      expect(domain.isSynced, isFalse);
      expect(domain.databasePath, equals('/path/to/db.sqlite'));
      expect(domain.encryptionKeyId, equals('key-123'));
      expect(domain.lastAccessedAt, equals(DateTime(2024, 1, 3)));
      expect(domain.schemaVersion, equals(2));
    });

    test('should map UserProfile domain entity to UserProfileDto', () {
      // Arrange
      final domain = FakeUserProfile.simple();

      // Act
      final dto = UserProfileMapper.toDto(domain);

      // Assert
      expect(dto.id, equals(domain.id));
      expect(dto.authId, equals(domain.authId));
      expect(dto.email, equals(domain.email));
      expect(dto.firstName, equals(domain.firstName));
      expect(dto.lastName, equals(domain.lastName));
      expect(
        dto.dateOfBirthMillis,
        equals(domain.dateOfBirth.millisecondsSinceEpoch),
      );
      expect(dto.gender, equals('female'));
      expect(
        dto.createdAtMillis,
        equals(domain.createdAt.millisecondsSinceEpoch),
      );
      expect(
        dto.updatedAtMillis,
        equals(domain.updatedAt.millisecondsSinceEpoch),
      );
      expect(dto.isSynced, equals(domain.isSynced));
      expect(dto.databasePath, equals(domain.databasePath));
      expect(dto.encryptionKeyId, equals(domain.encryptionKeyId));
      expect(
        dto.lastAccessedAtMillis,
        equals(domain.lastAccessedAt.millisecondsSinceEpoch),
      );
      expect(dto.schemaVersion, equals(domain.schemaVersion));
    });

    test('should correctly map all Gender enum values to strings', () {
      // Female
      final female = FakeUserProfile.simple(gender: Gender.female);
      expect(UserProfileMapper.toDto(female).gender, equals('female'));

      // Male
      final male = FakeUserProfile.simple(gender: Gender.male);
      expect(UserProfileMapper.toDto(male).gender, equals('male'));

      // Non-binary (enum value is nonBinary, stored as lowercase)
      final nonBinary = FakeUserProfile.simple(gender: Gender.nonBinary);
      expect(UserProfileMapper.toDto(nonBinary).gender, equals('nonbinary'));

      // Prefer not to say (enum value is preferNotToSay, stored as lowercase)
      final preferNotToSay = FakeUserProfile.simple(gender: Gender.preferNotToSay);
      expect(UserProfileMapper.toDto(preferNotToSay).gender, equals('prefernottosay'));
    });

    test('should correctly map all string values to Gender enum', () {
      // Female
      final femaleDto = UserProfileDto(
        id: 'id',
        authId: 'auth',
        email: 'email',
        firstName: 'first',
        lastName: 'last',
        dateOfBirthMillis: DateTime.now().millisecondsSinceEpoch,
        gender: 'female',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        isSynced: false,
        databasePath: 'path',
        encryptionKeyId: 'key',
        lastAccessedAtMillis: DateTime.now().millisecondsSinceEpoch,
        schemaVersion: 2,
      );
      expect(UserProfileMapper.toDomain(femaleDto).gender, equals(Gender.female));

      // Male
      final maleDto = femaleDto.copyWith(gender: 'male');
      expect(UserProfileMapper.toDomain(maleDto).gender, equals(Gender.male));

      // Non-binary (stored as lowercase, but fromString should handle it)
      final nonBinaryDto = femaleDto.copyWith(gender: 'nonbinary');
      expect(UserProfileMapper.toDomain(nonBinaryDto).gender, equals(Gender.nonBinary));

      // Prefer not to say (stored as lowercase, but fromString should handle it)
      final preferNotToSayDto = femaleDto.copyWith(gender: 'prefernottosay');
      expect(UserProfileMapper.toDomain(preferNotToSayDto).gender, equals(Gender.preferNotToSay));
    });

    test('should handle DateTime to milliseconds conversion correctly', () {
      // Arrange - specific timestamps
      final dob = DateTime(1990, 5, 15, 10, 30, 45, 123);
      final created = DateTime(2024, 1, 1, 12, 0, 0);
      final updated = DateTime(2024, 1, 2, 14, 30, 0);
      final accessed = DateTime(2024, 1, 3, 16, 45, 30);

      final domain = FakeUserProfile.simple(
        dateOfBirth: dob,
        createdAt: created,
        updatedAt: updated,
        lastAccessedAt: accessed,
      );

      // Act
      final dto = UserProfileMapper.toDto(domain);

      // Assert - exact millisecond precision
      expect(dto.dateOfBirthMillis, equals(dob.millisecondsSinceEpoch));
      expect(dto.createdAtMillis, equals(created.millisecondsSinceEpoch));
      expect(dto.updatedAtMillis, equals(updated.millisecondsSinceEpoch));
      expect(dto.lastAccessedAtMillis, equals(accessed.millisecondsSinceEpoch));
    });

    test('should handle milliseconds to DateTime conversion correctly', () {
      // Arrange - specific millisecond timestamps
      final dobMillis = DateTime(1990, 5, 15, 10, 30, 45, 123).millisecondsSinceEpoch;
      final createdMillis = DateTime(2024, 1, 1, 12, 0, 0).millisecondsSinceEpoch;
      final updatedMillis = DateTime(2024, 1, 2, 14, 30, 0).millisecondsSinceEpoch;
      final accessedMillis = DateTime(2024, 1, 3, 16, 45, 30).millisecondsSinceEpoch;

      final dto = UserProfileDto(
        id: 'id',
        authId: 'auth',
        email: 'email',
        firstName: 'first',
        lastName: 'last',
        dateOfBirthMillis: dobMillis,
        gender: 'female',
        createdAtMillis: createdMillis,
        updatedAtMillis: updatedMillis,
        isSynced: false,
        databasePath: 'path',
        encryptionKeyId: 'key',
        lastAccessedAtMillis: accessedMillis,
        schemaVersion: 2,
      );

      // Act
      final domain = UserProfileMapper.toDomain(dto);

      // Assert - exact millisecond precision
      expect(domain.dateOfBirth.millisecondsSinceEpoch, equals(dobMillis));
      expect(domain.createdAt.millisecondsSinceEpoch, equals(createdMillis));
      expect(domain.updatedAt.millisecondsSinceEpoch, equals(updatedMillis));
      expect(domain.lastAccessedAt.millisecondsSinceEpoch, equals(accessedMillis));
    });

    test('should preserve all data in round-trip conversion (domain -> dto -> domain)', () {
      // Arrange
      final original = FakeUserProfile.simple(
        id: 'test-123',
        authId: 'auth-456',
        email: 'roundtrip@test.com',
        firstName: 'Round',
        lastName: 'Trip',
        gender: Gender.nonBinary,
        isSynced: true,
        schemaVersion: 3,
      );

      // Act - convert to DTO and back to domain
      final dto = UserProfileMapper.toDto(original);
      final roundTrip = UserProfileMapper.toDomain(dto);

      // Assert - all fields match
      expect(roundTrip.id, equals(original.id));
      expect(roundTrip.authId, equals(original.authId));
      expect(roundTrip.email, equals(original.email));
      expect(roundTrip.firstName, equals(original.firstName));
      expect(roundTrip.lastName, equals(original.lastName));
      expect(roundTrip.dateOfBirth.millisecondsSinceEpoch,
          equals(original.dateOfBirth.millisecondsSinceEpoch));
      expect(roundTrip.gender, equals(original.gender));
      expect(roundTrip.createdAt.millisecondsSinceEpoch,
          equals(original.createdAt.millisecondsSinceEpoch));
      expect(roundTrip.updatedAt.millisecondsSinceEpoch,
          equals(original.updatedAt.millisecondsSinceEpoch));
      expect(roundTrip.isSynced, equals(original.isSynced));
      expect(roundTrip.databasePath, equals(original.databasePath));
      expect(roundTrip.encryptionKeyId, equals(original.encryptionKeyId));
      expect(roundTrip.lastAccessedAt.millisecondsSinceEpoch,
          equals(original.lastAccessedAt.millisecondsSinceEpoch));
      expect(roundTrip.schemaVersion, equals(original.schemaVersion));
    });

    test('should correctly map isSynced boolean values', () {
      // Test synced
      final synced = FakeUserProfile.simple(isSynced: true);
      final syncedDto = UserProfileMapper.toDto(synced);
      expect(syncedDto.isSynced, isTrue);
      expect(UserProfileMapper.toDomain(syncedDto).isSynced, isTrue);

      // Test not synced
      final notSynced = FakeUserProfile.simple(isSynced: false);
      final notSyncedDto = UserProfileMapper.toDto(notSynced);
      expect(notSyncedDto.isSynced, isFalse);
      expect(UserProfileMapper.toDomain(notSyncedDto).isSynced, isFalse);
    });

    test('should handle schema version correctly', () {
      // Test different schema versions
      for (final version in [1, 2, 3, 10, 100]) {
        final domain = FakeUserProfile.simple(schemaVersion: version);
        final dto = UserProfileMapper.toDto(domain);
        expect(dto.schemaVersion, equals(version));
        expect(UserProfileMapper.toDomain(dto).schemaVersion, equals(version));
      }
    });
  });
}
