/// Base exception for bump photo operations.
///
/// All bump photo-related errors should extend this class for consistent
/// error handling across the feature.
class BumpPhotoException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const BumpPhotoException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'BumpPhotoException: $message';
}

/// Exception thrown when week number is invalid.
class InvalidWeekException extends BumpPhotoException {
  final int weekNumber;

  const InvalidWeekException(
    this.weekNumber,
    super.message,
  );

  @override
  String toString() => 'InvalidWeekException: $message (week: $weekNumber)';
}

/// Exception thrown when file operations fail.
class PhotoFileException extends BumpPhotoException {
  final String filePath;

  const PhotoFileException(
    this.filePath,
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'PhotoFileException: $message (file: $filePath)';
}

/// Exception thrown when photo not found.
class PhotoNotFoundException extends BumpPhotoException {
  final String? pregnancyId;
  final int? weekNumber;

  const PhotoNotFoundException(
    super.message, {
    this.pregnancyId,
    this.weekNumber,
  });

  @override
  String toString() {
    final details = [
      if (pregnancyId != null) 'pregnancyId: $pregnancyId',
      if (weekNumber != null) 'week: $weekNumber',
    ].join(', ');
    return 'PhotoNotFoundException: $message${details.isNotEmpty ? ' ($details)' : ''}';
  }
}

/// Exception thrown when image is too large.
class ImageTooLargeException extends BumpPhotoException {
  final int actualSize;
  final int maxSize;

  const ImageTooLargeException(
    this.actualSize,
    this.maxSize,
    super.message,
  );

  @override
  String toString() =>
      'ImageTooLargeException: $message (size: $actualSize bytes, max: $maxSize bytes)';
}

/// Exception thrown when image processing fails.
class ImageProcessingException extends BumpPhotoException {
  const ImageProcessingException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ImageProcessingException: $message';
}
