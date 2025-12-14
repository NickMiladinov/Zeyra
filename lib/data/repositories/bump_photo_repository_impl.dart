import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/monitoring/logging_service.dart';
import '../../core/services/photo_file_service.dart';
import '../../domain/entities/bump_photo/bump_photo.dart';
import '../../domain/entities/bump_photo/bump_photo_constants.dart';
import '../../domain/exceptions/bump_photo_exception.dart';
import '../../domain/repositories/bump_photo_repository.dart';
import '../local/app_database.dart';
import '../local/daos/bump_photo_dao.dart';
import '../mappers/bump_photo_mapper.dart';

/// Implementation of BumpPhotoRepository using Drift with SQLCipher encryption.
///
/// Handles both database operations (via DAO) and file operations (via PhotoFileService).
/// Data is protected by SQLCipher full database encryption.
///
/// **Security:** The entire database is encrypted with AES-256 via SQLCipher.
/// See [AppDatabase.encrypted] for encryption configuration details.
class BumpPhotoRepositoryImpl implements BumpPhotoRepository {
  final BumpPhotoDao _dao;
  final PhotoFileService _fileService;
  final LoggingService _logger;
  final Uuid _uuid;
  final String _userId; // Current user ID for file operations

  BumpPhotoRepositoryImpl({
    required BumpPhotoDao dao,
    required PhotoFileService fileService,
    required LoggingService logger,
    required String userId,
    Uuid? uuid,
  })  : _dao = dao,
        _fileService = fileService,
        _logger = logger,
        _userId = userId,
        _uuid = uuid ?? const Uuid();

  @override
  Future<BumpPhoto> saveBumpPhoto({
    required String pregnancyId,
    required int weekNumber,
    required List<int> imageBytes,
    String? note,
  }) async {
    _logger.debug('Saving bump photo', data: {
      'pregnancy_id': pregnancyId,
      'week_number': weekNumber,
    });

    // Validate week number
    if (!BumpPhotoConstants.isValidWeek(weekNumber)) {
      throw InvalidWeekException(
        weekNumber,
        BumpPhotoConstants.getInvalidWeekMessage(weekNumber),
      );
    }

    try {
      // Check if photo already exists for this week
      final existingPhoto = await _dao.getBumpPhotoByWeek(pregnancyId, weekNumber);

      // Save photo to file system
      final filePath = await _fileService.savePhoto(
        imageBytes: imageBytes,
        userId: _userId,
        pregnancyId: pregnancyId,
        weekNumber: weekNumber,
      );

      final now = DateTime.now();
      final photoDto = BumpPhotoDto(
        id: existingPhoto?.id ?? _uuid.v4(),
        pregnancyId: pregnancyId,
        weekNumber: weekNumber,
        filePath: filePath,
        note: note,
        photoDateMillis: now.millisecondsSinceEpoch,
        createdAtMillis: existingPhoto?.createdAtMillis ?? now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      // If existing photo, delete old file if path changed
      if (existingPhoto != null && existingPhoto.filePath != null &&
          existingPhoto.filePath != filePath) {
        try {
          await _fileService.deletePhoto(existingPhoto.filePath!);
        } catch (e) {
          _logger.warning('Failed to delete old photo file', data: {
            'file_path': existingPhoto.filePath,
            'error': e.toString(),
          });
        }
      }

      // Upsert to database (insert or replace)
      await _dao.upsertBumpPhoto(photoDto);

      _logger.info('Bump photo saved successfully', data: {
        'photo_id': photoDto.id,
        'is_update': existingPhoto != null,
      });
      _logger.logDatabaseOperation('UPSERT', table: 'bump_photos', success: true);

      return BumpPhotoMapper.toDomain(photoDto);
    } on BumpPhotoException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to save bump photo',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('UPSERT', table: 'bump_photos', success: false, error: e);
      throw BumpPhotoException(
        'Failed to save bump photo: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<BumpPhoto>> getBumpPhotos(String pregnancyId) async {
    try {
      final dtos = await _dao.getBumpPhotosForPregnancy(pregnancyId);
      return BumpPhotoMapper.toDomainList(dtos);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get bump photos',
        error: e,
        stackTrace: stackTrace,
        data: {'pregnancy_id': pregnancyId},
      );
      rethrow;
    }
  }

  @override
  Future<BumpPhoto?> getBumpPhoto(String pregnancyId, int weekNumber) async {
    try {
      final dto = await _dao.getBumpPhotoByWeek(pregnancyId, weekNumber);
      return dto != null ? BumpPhotoMapper.toDomain(dto) : null;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get bump photo',
        error: e,
        stackTrace: stackTrace,
        data: {
          'pregnancy_id': pregnancyId,
          'week_number': weekNumber,
        },
      );
      rethrow;
    }
  }

  @override
  Future<BumpPhoto> updateNote(String id, String? note) async {
    _logger.debug('Updating bump photo note', data: {'photo_id': id});

    try {
      // Normalize note (empty string -> null)
      final normalizedNote = (note == null || note.isEmpty) ? null : note;

      final now = DateTime.now();
      await _dao.updateBumpPhotoFields(
        id,
        BumpPhotosCompanion(
          note: Value(normalizedNote),
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );

      // Fetch and return updated photo
      final updatedDto = await _dao.getBumpPhoto(id);
      if (updatedDto == null) {
        throw PhotoNotFoundException(
          'Bump photo not found after update',
          pregnancyId: null,
          weekNumber: null,
        );
      }

      _logger.info('Bump photo note updated successfully');
      _logger.logDatabaseOperation('UPDATE', table: 'bump_photos', success: true);

      return BumpPhotoMapper.toDomain(updatedDto);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update bump photo note',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('UPDATE', table: 'bump_photos', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteBumpPhoto(String id) async {
    _logger.debug('Deleting bump photo (preserving note)', data: {'photo_id': id});

    try {
      // Get photo to find file path and check if note exists
      final photoDto = await _dao.getBumpPhoto(id);
      if (photoDto == null) {
        _logger.debug('Bump photo not found, nothing to delete');
        return;
      }

      // Delete file first (if it exists)
      if (photoDto.filePath != null) {
        try {
          await _fileService.deletePhoto(photoDto.filePath!);
        } catch (e) {
          _logger.warning('Failed to delete photo file', data: {
            'file_path': photoDto.filePath,
            'error': e.toString(),
          });
        }
      }

      // If there's a note, preserve it by clearing only the filePath
      if (photoDto.note != null && photoDto.note!.isNotEmpty) {
        final now = DateTime.now();
        await _dao.updateBumpPhotoFields(
          id,
          BumpPhotosCompanion(
            filePath: Value(null),
            updatedAtMillis: Value(now.millisecondsSinceEpoch),
          ),
        );
        _logger.info('Bump photo deleted, note preserved');
      } else {
        // No note, delete the entire record
        await _dao.deleteBumpPhoto(id);
        _logger.info('Bump photo deleted completely');
      }

      _logger.logDatabaseOperation('DELETE/UPDATE', table: 'bump_photos', success: true);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete bump photo',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('DELETE', table: 'bump_photos', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<BumpPhoto> saveNoteOnly({
    required String pregnancyId,
    required int weekNumber,
    required String? note,
  }) async {
    _logger.debug('Saving note only', data: {
      'pregnancy_id': pregnancyId,
      'week_number': weekNumber,
    });

    // Validate week number
    if (!BumpPhotoConstants.isValidWeek(weekNumber)) {
      throw InvalidWeekException(
        weekNumber,
        BumpPhotoConstants.getInvalidWeekMessage(weekNumber),
      );
    }

    try {
      // Check if entry already exists for this week
      final existingPhoto = await _dao.getBumpPhotoByWeek(pregnancyId, weekNumber);

      // If clearing the note on a note-only entry (no filePath), delete the entry entirely
      if (note == null && existingPhoto != null && existingPhoto.filePath == null) {
        await _dao.deleteBumpPhoto(existingPhoto.id);
        _logger.info('Deleted note-only entry with cleared note', data: {
          'photo_id': existingPhoto.id,
        });
        _logger.logDatabaseOperation('DELETE', table: 'bump_photos', success: true);
        // Return a "tombstone" entry to indicate the entry was cleared
        return BumpPhotoMapper.toDomain(existingPhoto.copyWith(note: const Value(null)));
      }

      // If note is null and no existing entry, nothing to save
      if (note == null && existingPhoto == null) {
        final now = DateTime.now();
        // Return an empty entry (not persisted)
        return BumpPhoto(
          id: _uuid.v4(),
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: null,
          note: null,
          photoDate: now,
          createdAt: now,
          updatedAt: now,
        );
      }

      final now = DateTime.now();
      final photoDto = BumpPhotoDto(
        id: existingPhoto?.id ?? _uuid.v4(),
        pregnancyId: pregnancyId,
        weekNumber: weekNumber,
        filePath: existingPhoto?.filePath, // Preserve existing filePath if any
        note: note,
        photoDateMillis: existingPhoto?.photoDateMillis ?? now.millisecondsSinceEpoch,
        createdAtMillis: existingPhoto?.createdAtMillis ?? now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      // Upsert to database
      await _dao.upsertBumpPhoto(photoDto);

      _logger.info('Note saved successfully', data: {
        'photo_id': photoDto.id,
        'is_update': existingPhoto != null,
      });
      _logger.logDatabaseOperation('UPSERT', table: 'bump_photos', success: true);

      return BumpPhotoMapper.toDomain(photoDto);
    } on BumpPhotoException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to save note',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('UPSERT', table: 'bump_photos', success: false, error: e);
      throw BumpPhotoException(
        'Failed to save note: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> deleteAllForPregnancy(String pregnancyId) async {
    _logger.debug('Deleting all bump photos for pregnancy', data: {
      'pregnancy_id': pregnancyId,
    });

    try {
      // Delete files
      final fileCount = await _fileService.deleteAllPhotosForPregnancy(
        userId: _userId,
        pregnancyId: pregnancyId,
      );

      // Delete from database
      final dbCount = await _dao.deleteAllForPregnancy(pregnancyId);

      _logger.info('Deleted all bump photos for pregnancy', data: {
        'db_count': dbCount,
        'file_count': fileCount,
      });
      _logger.logDatabaseOperation('DELETE', table: 'bump_photos', success: true);

      return dbCount;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete all bump photos for pregnancy',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('DELETE', table: 'bump_photos', success: false, error: e);
      rethrow;
    }
  }
}
