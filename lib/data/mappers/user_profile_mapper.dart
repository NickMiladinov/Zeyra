import '../../domain/entities/user_profile/gender.dart';
import '../../domain/entities/user_profile/user_profile.dart';
import '../local/app_database.dart';

/// Mapper for UserProfile entity ↔ DTO conversion.
class UserProfileMapper {
  UserProfileMapper._();

  /// Convert DTO to domain entity.
  static UserProfile toDomain(UserProfileDto dto) {
    return UserProfile(
      id: dto.id,
      authId: dto.authId,
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(dto.dateOfBirthMillis),
      gender: Gender.fromString(dto.gender),
      createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(dto.updatedAtMillis),
      isSynced: dto.isSynced,
      databasePath: dto.databasePath,
      encryptionKeyId: dto.encryptionKeyId,
      lastAccessedAt:
          DateTime.fromMillisecondsSinceEpoch(dto.lastAccessedAtMillis),
      schemaVersion: dto.schemaVersion,
      postcode: dto.postcode,
    );
  }

  /// Convert domain entity to DTO.
  static UserProfileDto toDto(UserProfile domain) {
    return UserProfileDto(
      id: domain.id,
      authId: domain.authId,
      email: domain.email,
      firstName: domain.firstName,
      lastName: domain.lastName,
      dateOfBirthMillis: domain.dateOfBirth.millisecondsSinceEpoch,
      gender: domain.gender.name.toLowerCase(),
      createdAtMillis: domain.createdAt.millisecondsSinceEpoch,
      updatedAtMillis: domain.updatedAt.millisecondsSinceEpoch,
      isSynced: domain.isSynced,
      databasePath: domain.databasePath,
      encryptionKeyId: domain.encryptionKeyId,
      lastAccessedAtMillis: domain.lastAccessedAt.millisecondsSinceEpoch,
      schemaVersion: domain.schemaVersion,
      postcode: domain.postcode,
    );
  }
}
