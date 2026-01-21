import '../../core/monitoring/logging_service.dart';
import '../../domain/entities/user_profile/user_profile.dart';
import '../../domain/exceptions/user_profile_exception.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../local/daos/pregnancy_dao.dart';
import '../local/daos/user_profile_dao.dart';
import '../mappers/user_profile_mapper.dart';

/// Implementation of UserProfileRepository using Drift.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileDao _dao;
  final PregnancyDao _pregnancyDao;
  final LoggingService _logger;

  UserProfileRepositoryImpl({
    required UserProfileDao dao,
    required PregnancyDao pregnancyDao,
    required LoggingService logger,
  })  : _dao = dao,
        _pregnancyDao = pregnancyDao,
        _logger = logger;

  @override
  Future<UserProfile?> getUserProfile() async {
    final dto = await _dao.getUserProfile();
    if (dto == null) return null;

    return UserProfileMapper.toDomain(dto);
  }

  @override
  Future<UserProfile> createUserProfile(UserProfile profile) async {
    _logger.debug('Creating user profile');

    try {
      // Check if profile already exists
      final existing = await _dao.getUserProfile();
      if (existing != null) {
        // Check if existing profile belongs to same user (authId match)
        if (existing.authId == profile.authId) {
          throw const UserProfileException(
            'User profile already exists.',
            UserProfileErrorType.alreadyExists,
          );
        }
        
        // Existing profile has different authId - this is stale data
        // from a previously deleted user. Delete all their data first.
        _logger.info(
          'Found stale user profile with different authId, cleaning up stale data',
        );
        
        // Explicitly delete pregnancies first (cascade delete may not work reliably)
        final deletedPregnancies = await _pregnancyDao.deletePregnanciesByUserId(existing.id);
        _logger.debug('Deleted $deletedPregnancies stale pregnancies');
        _logger.logDatabaseOperation('DELETE',
            table: 'pregnancies', success: true);
        
        // Now delete the user profile
        await _dao.deleteUserProfile(existing.id);
        _logger.logDatabaseOperation('DELETE',
            table: 'user_profiles', success: true);
      }

      final dto = UserProfileMapper.toDto(profile);
      final insertedDto = await _dao.insertUserProfile(dto);

      _logger.info('User profile created successfully');
      _logger.logDatabaseOperation('INSERT',
          table: 'user_profiles', success: true);

      // Return the inserted DTO mapped back to domain entity
      // to ensure database-generated fields are included
      return UserProfileMapper.toDomain(insertedDto);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to create user profile',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('INSERT',
          table: 'user_profiles', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    _logger.debug('Updating user profile');

    try {
      // Update updatedAt timestamp
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );

      final dto = UserProfileMapper.toDto(updatedProfile);
      await _dao.updateUserProfile(dto);

      _logger.info('User profile updated successfully');
      _logger.logDatabaseOperation('UPDATE',
          table: 'user_profiles', success: true);

      return updatedProfile;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update user profile',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('UPDATE',
          table: 'user_profiles', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateLastAccessed() async {
    final profile = await getUserProfile();
    if (profile == null) return;

    final now = DateTime.now();
    await _dao.updateLastAccessed(profile.id, now.millisecondsSinceEpoch);
  }

  @override
  Future<void> deleteUserProfile() async {
    _logger.debug('Deleting user profile');

    try {
      final profile = await getUserProfile();
      if (profile == null) return;

      await _dao.deleteUserProfile(profile.id);

      _logger.info('User profile deleted successfully');
      _logger.logDatabaseOperation('DELETE',
          table: 'user_profiles', success: true);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete user profile',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('DELETE',
          table: 'user_profiles', success: false, error: e);
      rethrow;
    }
  }
}
