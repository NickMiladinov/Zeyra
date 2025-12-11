import '../../entities/user_profile/user_profile.dart';
import '../../exceptions/user_profile_exception.dart';
import '../../repositories/user_profile_repository.dart';

/// Use case for updating the user profile.
class UpdateUserProfileUseCase {
  final UserProfileRepository _repository;

  const UpdateUserProfileUseCase({
    required UserProfileRepository repository,
  }) : _repository = repository;

  /// Update the user profile.
  ///
  /// Validates inputs before updating.
  Future<UserProfile> execute(UserProfile profile) async {
    // Validate inputs (similar to create)
    _validateInputs(profile);

    return await _repository.updateUserProfile(profile);
  }

  void _validateInputs(UserProfile profile) {
    // Validate email
    if (!profile.email.contains('@') || !profile.email.contains('.')) {
      throw const UserProfileException(
        'Invalid email format.',
        UserProfileErrorType.invalidEmail,
      );
    }

    // Validate names
    if (profile.firstName.trim().isEmpty || profile.lastName.trim().isEmpty) {
      throw const UserProfileException(
        'First name and last name cannot be empty.',
        UserProfileErrorType.invalidName,
      );
    }

    // Validate date of birth
    if (profile.dateOfBirth.isAfter(DateTime.now())) {
      throw const UserProfileException(
        'Date of birth cannot be in the future.',
        UserProfileErrorType.invalidDateOfBirth,
      );
    }
  }
}
