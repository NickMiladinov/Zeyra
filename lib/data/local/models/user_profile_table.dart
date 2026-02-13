import 'package:drift/drift.dart';

/// Drift table for user profiles.
///
/// Stores per-user profile information and system metadata.
/// Each database has exactly one user profile record.
@DataClassName('UserProfileDto')
class UserProfiles extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Supabase Auth user ID
  TextColumn get authId => text()();

  /// User's email
  TextColumn get email => text()();

  /// User's first name
  TextColumn get firstName => text()();

  /// User's last name
  TextColumn get lastName => text()();

  /// Date of birth (stored as millis since epoch)
  IntColumn get dateOfBirthMillis => integer()();

  /// Gender (stored as lowercase string)
  TextColumn get gender => text()();

  /// When record was created (millis since epoch)
  IntColumn get createdAtMillis => integer()();

  /// When record was last updated (millis since epoch)
  IntColumn get updatedAtMillis => integer()();

  /// Whether synced to cloud
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Path to database file
  TextColumn get databasePath => text()();

  /// Encryption key ID in secure storage
  TextColumn get encryptionKeyId => text()();

  /// Last access timestamp (millis since epoch)
  IntColumn get lastAccessedAtMillis => integer()();

  /// Database schema version
  IntColumn get schemaVersion => integer()();

  /// User's postcode for hospital search (optional)
  TextColumn get postcode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
