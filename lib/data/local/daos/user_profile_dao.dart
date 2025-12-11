import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/user_profile_table.dart';

part 'user_profile_dao.g.dart';

/// Data Access Object for user profile operations.
@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  /// Get the single user profile (if exists).
  Future<UserProfileDto?> getUserProfile() {
    return (select(userProfiles)..limit(1)).getSingleOrNull();
  }

  /// Insert a new user profile.
  Future<UserProfileDto> insertUserProfile(UserProfileDto profile) {
    return into(userProfiles).insertReturning(profile);
  }

  /// Update an existing user profile.
  Future<int> updateUserProfile(UserProfileDto profile) {
    return (update(userProfiles)..where((p) => p.id.equals(profile.id)))
        .write(profile.toCompanion(false));
  }

  /// Update specific fields using a Companion.
  Future<int> updateUserProfileFields(
      String id, UserProfilesCompanion companion) {
    return (update(userProfiles)..where((p) => p.id.equals(id)))
        .write(companion);
  }

  /// Delete the user profile.
  Future<int> deleteUserProfile(String id) {
    return (delete(userProfiles)..where((p) => p.id.equals(id))).go();
  }

  /// Update last accessed timestamp.
  Future<int> updateLastAccessed(String id, int lastAccessedMillis) {
    return (update(userProfiles)..where((p) => p.id.equals(id))).write(
      UserProfilesCompanion(
        lastAccessedAtMillis: Value(lastAccessedMillis),
      ),
    );
  }
}
