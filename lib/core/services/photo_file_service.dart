import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/bump_photo/bump_photo_constants.dart';
import '../../domain/exceptions/bump_photo_exception.dart';
import '../monitoring/logging_service.dart';
import '../utils/image_format_utils.dart';

/// Service for managing bump photo files on the file system.
///
/// Handles file operations including:
/// - User-isolated storage in per-user directories
/// - Image compression and resizing
/// - File cleanup and deletion
///
/// **Storage structure:**
/// ```
/// {appDocuments}/users/{userId}/bump_photos/{pregnancyId}/{weekNumber}.jpg
/// ```
class PhotoFileService {
  final LoggingService _logger;

  PhotoFileService({required LoggingService logger}) : _logger = logger;

  /// Save a photo to the file system with compression and resizing.
  /// All images are converted to JPEG with controlled quality.
  ///
  /// [imageBytes] - Raw image data (any supported format)
  /// [userId] - User ID for directory isolation
  /// [pregnancyId] - Pregnancy ID
  /// [weekNumber] - Week number (used in filename)
  ///
  /// Returns the absolute file path where the photo was saved.
  ///
  /// Throws [ImageProcessingException] if image processing or format validation fails.
  /// Throws [PhotoFileException] if file operations fail.
  Future<String> savePhoto({
    required List<int> imageBytes,
    required String userId,
    required String pregnancyId,
    required int weekNumber,
  }) async {
    try {
      final bytes = Uint8List.fromList(imageBytes);
      
      _logger.debug('Processing image for save', data: {
        'user_id': userId,
        'pregnancy_id': pregnancyId,
        'week_number': weekNumber,
        'original_size': bytes.length,
      });

      // Validate image format
      final detectedFormat = ImageFormatUtils.detectFormatFromBytes(bytes);
      if (detectedFormat == null || !ImageFormatUtils.isFormatSupported(detectedFormat)) {
        throw ImageProcessingException(
          ImageFormatUtils.getUnsupportedFormatMessage(detectedFormat),
        );
      }

      _logger.debug('Image format validated', data: {
        'format': detectedFormat,
      });

      // Decode image (this supports all validated formats)
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw const ImageProcessingException('Failed to decode image');
      }

      // Resize if needed
      img.Image processedImage = image;
      if (image.width > BumpPhotoConstants.maxImageWidth) {
        _logger.debug('Resizing image', data: {
          'original_width': image.width,
          'target_width': BumpPhotoConstants.maxImageWidth,
        });
        processedImage = img.copyResize(
          image,
          width: BumpPhotoConstants.maxImageWidth,
        );
      }

      // Encode to JPEG with compression
      final compressedBytes = img.encodeJpg(
        processedImage,
        quality: BumpPhotoConstants.jpegQuality,
      );

      _logger.debug('Image processed', data: {
        'compressed_size': compressedBytes.length,
        'compression_ratio': '${(compressedBytes.length / imageBytes.length * 100).toStringAsFixed(1)}%',
      });

      // Check file size
      if (compressedBytes.length > BumpPhotoConstants.maxFileSizeBytes) {
        throw ImageTooLargeException(
          compressedBytes.length,
          BumpPhotoConstants.maxFileSizeBytes,
          'Image is too large after compression',
        );
      }

      // Get file path and ensure directory exists
      final filePath = await getPhotoPath(
        userId: userId,
        pregnancyId: pregnancyId,
        weekNumber: weekNumber,
      );
      final file = File(filePath);
      await file.parent.create(recursive: true);

      // Write file
      await file.writeAsBytes(compressedBytes);

      _logger.info('Photo saved successfully', data: {
        'file_path': filePath,
        'final_size': compressedBytes.length,
      });

      return filePath;
    } on BumpPhotoException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to save photo',
        error: e,
        stackTrace: stackTrace,
      );
      throw PhotoFileException(
        'unknown',
        'Failed to save photo: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete a photo file.
  ///
  /// [filePath] - Absolute path to the photo file
  ///
  /// Does nothing if file doesn't exist.
  ///
  /// Throws [PhotoFileException] if deletion fails.
  Future<void> deletePhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.debug('Photo file deleted', data: {'file_path': filePath});
      } else {
        _logger.debug('Photo file not found, skipping deletion', data: {'file_path': filePath});
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete photo file',
        error: e,
        stackTrace: stackTrace,
        data: {'file_path': filePath},
      );
      throw PhotoFileException(
        filePath,
        'Failed to delete photo: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get the expected file path for a photo.
  ///
  /// [userId] - User ID for directory isolation
  /// [pregnancyId] - Pregnancy ID
  /// [weekNumber] - Week number
  ///
  /// Returns the absolute file path (file may not exist yet).
  Future<String> getPhotoPath({
    required String userId,
    required String pregnancyId,
    required int weekNumber,
  }) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileName = '$weekNumber.${BumpPhotoConstants.imageExtension}';
    return p.join(
      appDocDir.path,
      'users',
      userId,
      'bump_photos',
      pregnancyId,
      fileName,
    );
  }

  /// Delete all photos for a specific pregnancy.
  ///
  /// [userId] - User ID
  /// [pregnancyId] - Pregnancy ID
  ///
  /// Returns the number of files deleted.
  Future<int> deleteAllPhotosForPregnancy({
    required String userId,
    required String pregnancyId,
  }) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final pregnancyDir = Directory(p.join(
        appDocDir.path,
        'users',
        userId,
        'bump_photos',
        pregnancyId,
      ));

      if (!await pregnancyDir.exists()) {
        _logger.debug('Pregnancy directory not found, nothing to delete', data: {
          'pregnancy_id': pregnancyId,
        });
        return 0;
      }

      int deletedCount = 0;
      await for (final entity in pregnancyDir.list()) {
        if (entity is File) {
          await entity.delete();
          deletedCount++;
        }
      }

      // Delete the directory if empty
      if (deletedCount > 0) {
        await pregnancyDir.delete();
      }

      _logger.info('Deleted photos for pregnancy', data: {
        'pregnancy_id': pregnancyId,
        'count': deletedCount,
      });

      return deletedCount;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete photos for pregnancy',
        error: e,
        stackTrace: stackTrace,
        data: {'pregnancy_id': pregnancyId},
      );
      rethrow;
    }
  }

  /// Delete all photos for a user.
  ///
  /// [userId] - User ID
  ///
  /// Used during account deletion or logout cleanup.
  /// Returns the number of files deleted.
  Future<int> deleteAllPhotosForUser(String userId) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final userPhotosDir = Directory(p.join(
        appDocDir.path,
        'users',
        userId,
        'bump_photos',
      ));

      if (!await userPhotosDir.exists()) {
        _logger.debug('User photos directory not found, nothing to delete', data: {
          'user_id': userId,
        });
        return 0;
      }

      int deletedCount = 0;
      await for (final entity in userPhotosDir.list(recursive: true)) {
        if (entity is File) {
          await entity.delete();
          deletedCount++;
        }
      }

      // Delete the directory
      await userPhotosDir.delete(recursive: true);

      _logger.info('Deleted all photos for user', data: {
        'user_id': userId,
        'count': deletedCount,
      });

      return deletedCount;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete all photos for user',
        error: e,
        stackTrace: stackTrace,
        data: {'user_id': userId},
      );
      rethrow;
    }
  }

  /// Check if a photo file exists.
  ///
  /// [filePath] - Absolute path to the photo file
  ///
  /// Returns true if the file exists, false otherwise.
  Future<bool> photoExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      _logger.warning('Failed to check if photo exists', data: {
        'file_path': filePath,
        'error': e.toString(),
      });
      return false;
    }
  }
}
