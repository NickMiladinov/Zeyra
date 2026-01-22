import 'gender.dart';

/// Domain entity representing a user's profile.
///
/// Contains personal information and system metadata for database
/// isolation and security. Each user has a dedicated encrypted database
/// file identified by their authId.
class UserProfile {
  /// Local record ID (UUID)
  final String id;

  /// Supabase Auth user ID (used for database file naming)
  final String authId;

  /// User's email address
  final String email;

  /// User's first name
  final String firstName;

  /// User's last name
  final String lastName;

  /// Date of birth
  final DateTime dateOfBirth;

  /// Gender (for personalization)
  final Gender gender;

  /// When record was created
  final DateTime createdAt;

  /// When record was last updated
  final DateTime updatedAt;

  /// Whether synced to cloud (for future sync feature)
  final bool isSynced;

  /// Path to user's database file (e.g., "zeyra_`<authId>`.db")
  final String databasePath;

  /// Encryption key ID in secure storage (e.g., "zeyra_db_key_`<authId>`")
  final String encryptionKeyId;

  /// Last time user accessed the app
  final DateTime lastAccessedAt;

  /// Database schema version for migrations
  final int schemaVersion;

  /// User's postcode for hospital search (optional)
  final String? postcode;

  const UserProfile({
    required this.id,
    required this.authId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.databasePath,
    required this.encryptionKeyId,
    required this.lastAccessedAt,
    required this.schemaVersion,
    this.postcode,
  });

  /// Calculate user's current age
  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;

    // Adjust if birthday hasn't occurred this year
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Create a copy with updated fields
  UserProfile copyWith({
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
    String? postcode,
  }) {
    return UserProfile(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      databasePath: databasePath ?? this.databasePath,
      encryptionKeyId: encryptionKeyId ?? this.encryptionKeyId,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      postcode: postcode ?? this.postcode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          authId == other.authId &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ authId.hashCode ^ email.hashCode;

  @override
  String toString() =>
      'UserProfile(id: $id, authId: $authId, email: $email, fullName: $fullName)';
}
