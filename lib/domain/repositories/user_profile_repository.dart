import '../entities/user_profile/user_profile.dart';

/// Repository interface for user profile operations.
///
/// Manages the single user profile record for the authenticated user.
/// Each user has exactly one profile in their encrypted database.
abstract class UserProfileRepository {
  /// Get the user profile for the current authenticated user.
  ///
  /// Returns null if no profile exists yet (first-time user).
  Future<UserProfile?> getUserProfile();

  /// Create a new user profile.
  ///
  /// [profile] - The profile to create
  ///
  /// Throws [UserProfileException] with type [alreadyExists]
  /// if a profile already exists for this user.
  Future<UserProfile> createUserProfile(UserProfile profile);

  /// Update the user profile.
  ///
  /// [profile] - The updated profile
  ///
  /// Returns the updated profile.
  /// Updates the updatedAt timestamp automatically.
  Future<UserProfile> updateUserProfile(UserProfile profile);

  /// Update the last accessed timestamp.
  ///
  /// Called when user opens the app to track usage.
  Future<void> updateLastAccessed();

  /// Delete the user profile.
  ///
  /// This is a destructive operation that should only be used
  /// when user is deleting their account.
  Future<void> deleteUserProfile();
}
