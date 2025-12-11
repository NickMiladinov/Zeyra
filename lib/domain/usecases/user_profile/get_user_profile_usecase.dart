import '../../entities/user_profile/user_profile.dart';
import '../../repositories/user_profile_repository.dart';

/// Use case for getting the user profile.
class GetUserProfileUseCase {
  final UserProfileRepository _repository;

  const GetUserProfileUseCase({
    required UserProfileRepository repository,
  }) : _repository = repository;

  /// Get the user profile.
  ///
  /// Returns null if no profile exists yet.
  Future<UserProfile?> execute() async {
    return await _repository.getUserProfile();
  }
}
