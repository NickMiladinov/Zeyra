import 'package:uuid/uuid.dart';

import '../../entities/user_profile/gender.dart';
import '../../entities/user_profile/user_profile.dart';
import '../../exceptions/user_profile_exception.dart';
import '../../repositories/user_profile_repository.dart';

/// Use case for creating a user profile.
class CreateUserProfileUseCase {
  final UserProfileRepository _repository;
  final Uuid _uuid;

  const CreateUserProfileUseCase({
    required UserProfileRepository repository,
    Uuid? uuid,
  })  : _repository = repository,
        _uuid = uuid ?? const Uuid();

  /// Create a new user profile.
  ///
  /// [authId] - Supabase auth user ID
  /// [email] - User's email
  /// [firstName] - User's first name
  /// [lastName] - User's last name
  /// [dateOfBirth] - User's date of birth
  /// [gender] - User's gender
  /// [schemaVersion] - Current database schema version
  ///
  /// Validates inputs and creates database file path naming.
  Future<UserProfile> execute({
    required String authId,
    required String email,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required Gender gender,
    required int schemaVersion,
  }) async {
    // Validate inputs
    _validateInputs(email, firstName, lastName, dateOfBirth);

    final now = DateTime.now();
    final profile = UserProfile(
      id: _uuid.v4(),
      authId: authId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      databasePath: 'zeyra_$authId.db',
      encryptionKeyId: 'zeyra_db_key_$authId',
      lastAccessedAt: now,
      schemaVersion: schemaVersion,
    );

    return await _repository.createUserProfile(profile);
  }

  void _validateInputs(
    String email,
    String firstName,
    String lastName,
    DateTime dateOfBirth,
  ) {
    // Validate email format (basic check)
    if (!email.contains('@') || !email.contains('.')) {
      throw const UserProfileException(
        'Invalid email format.',
        UserProfileErrorType.invalidEmail,
      );
    }

    // Validate names - firstName is required, lastName is optional (collected later)
    if (firstName.trim().isEmpty) {
      throw const UserProfileException(
        'First name cannot be empty.',
        UserProfileErrorType.invalidName,
      );
    }

    // Validate date of birth
    if (dateOfBirth.isAfter(DateTime.now())) {
      throw const UserProfileException(
        'Date of birth cannot be in the future.',
        UserProfileErrorType.invalidDateOfBirth,
      );
    }
  }
}
