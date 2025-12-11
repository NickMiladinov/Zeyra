/// Exception thrown by user profile operations.
class UserProfileException implements Exception {
  final String message;
  final UserProfileErrorType type;

  const UserProfileException(this.message, this.type);

  @override
  String toString() => 'UserProfileException: $message (type: $type)';
}

/// Types of user profile errors
enum UserProfileErrorType {
  /// Profile not found for the authenticated user
  notFound,

  /// Profile already exists for this user
  alreadyExists,

  /// Invalid email format
  invalidEmail,

  /// Date of birth is in the future
  invalidDateOfBirth,

  /// First or last name is empty
  invalidName,

  /// Schema version mismatch
  schemaMismatch,
}
