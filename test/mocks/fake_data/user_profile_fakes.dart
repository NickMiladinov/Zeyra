import 'package:zeyra/domain/entities/user_profile/gender.dart';
import 'package:zeyra/domain/entities/user_profile/user_profile.dart';

// ----------------------------------------------------------------------------
// Fake Data Builders for UserProfile
// ----------------------------------------------------------------------------

/// Fake data builders for UserProfile entities.
class FakeUserProfile {
  /// Create a simple user profile with default or custom values.
  static UserProfile simple({
    String? id,
    String? authId,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    Gender? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? databasePath,
    String? encryptionKeyId,
    DateTime? lastAccessedAt,
    int? schemaVersion,
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: id ?? 'user-profile-1',
      authId: authId ?? 'auth-123',
      email: email ?? 'test@example.com',
      firstName: firstName ?? 'Jane',
      lastName: lastName ?? 'Doe',
      dateOfBirth: dateOfBirth ?? DateTime(1990, 5, 15),
      gender: gender ?? Gender.female,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      isSynced: isSynced ?? false,
      databasePath: databasePath ?? '/path/to/db.sqlite',
      encryptionKeyId: encryptionKeyId ?? 'key-123',
      lastAccessedAt: lastAccessedAt ?? now,
      schemaVersion: schemaVersion ?? 2,
    );
  }

  /// Create a user profile for a specific age.
  static UserProfile withAge(int age) {
    final now = DateTime.now();
    final dob = DateTime(now.year - age, now.month, now.day);
    return simple(dateOfBirth: dob);
  }

  /// Create a male user profile.
  static UserProfile male() {
    return simple(
      firstName: 'John',
      gender: Gender.male,
    );
  }

  /// Create a non-binary user profile.
  static UserProfile nonBinary() {
    return simple(
      firstName: 'Alex',
      gender: Gender.nonBinary,
    );
  }

  /// Create a user profile with custom email format.
  static UserProfile withEmail(String email) {
    return simple(email: email);
  }

  /// Create a user profile that's synced.
  static UserProfile synced() {
    return simple(isSynced: true);
  }
}
