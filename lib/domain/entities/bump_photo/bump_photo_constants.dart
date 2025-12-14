/// Constants for the Bump Photo feature.
///
/// Defines constraints and limits for bump photos including valid week ranges
/// and image specifications.
class BumpPhotoConstants {
  /// Minimum pregnancy week for bump photos
  static const int minWeek = 1;

  /// Maximum pregnancy week for bump photos (typical full-term + post-term)
  static const int maxWeek = 44;

  /// Maximum width for saved images (pixels)
  /// Images are resized to this width to optimize storage and future video generation
  static const int maxImageWidth = 1920;

  /// JPEG compression quality (0-100)
  /// 85% provides good balance between quality and file size
  static const int jpegQuality = 85;

  /// Maximum file size in bytes (~5MB)
  /// Reasonable limit for mobile device storage
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Image file extension
  static const String imageExtension = 'jpg';

  /// Check if week number is valid
  static bool isValidWeek(int week) {
    return week >= minWeek && week <= maxWeek;
  }

  /// Get error message for invalid week
  static String getInvalidWeekMessage(int week) {
    return 'Week number must be between $minWeek and $maxWeek, got $week';
  }
}
