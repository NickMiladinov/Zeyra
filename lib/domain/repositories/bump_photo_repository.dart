import '../entities/bump_photo/bump_photo.dart';

/// Repository interface for bump photo data operations.
///
/// Defines the contract for managing bump photos including CRUD operations
/// and file storage. Implementation handles both database persistence and
/// file system operations.
abstract class BumpPhotoRepository {
  // --------------------------------------------------------------------------
  // Photo Management
  // --------------------------------------------------------------------------

  /// Save a new bump photo or update an existing one for the same week.
  ///
  /// [pregnancyId] - ID of the pregnancy
  /// [weekNumber] - Pregnancy week (1-42)
  /// [imageBytes] - Raw image data to save
  /// [note] - Optional user note about this week
  ///
  /// If a photo already exists for this week, it will be replaced.
  /// Returns the saved BumpPhoto entity.
  ///
  /// Throws [InvalidWeekException] if week is out of range.
  /// Throws [ImageTooLargeException] if image exceeds size limit.
  /// Throws [ImageProcessingException] if image processing fails.
  Future<BumpPhoto> saveBumpPhoto({
    required String pregnancyId,
    required int weekNumber,
    required List<int> imageBytes,
    String? note,
  });

  /// Get all bump photos for a pregnancy.
  ///
  /// [pregnancyId] - ID of the pregnancy
  ///
  /// Returns list of bump photos ordered by weekNumber ascending.
  /// Returns empty list if no photos exist.
  Future<List<BumpPhoto>> getBumpPhotos(String pregnancyId);

  /// Get a single bump photo by week number.
  ///
  /// [pregnancyId] - ID of the pregnancy
  /// [weekNumber] - Pregnancy week
  ///
  /// Returns the bump photo if it exists, null otherwise.
  Future<BumpPhoto?> getBumpPhoto(String pregnancyId, int weekNumber);

  /// Update the note for an existing bump photo.
  ///
  /// [id] - ID of the bump photo
  /// [note] - New note text (null to clear the note)
  ///
  /// Returns the updated BumpPhoto entity.
  ///
  /// Throws [PhotoNotFoundException] if photo doesn't exist.
  Future<BumpPhoto> updateNote(String id, String? note);

  /// Save or update a note for a week (without requiring a photo).
  ///
  /// [pregnancyId] - ID of the pregnancy
  /// [weekNumber] - Pregnancy week (1-42)
  /// [note] - Note text (null to clear the note)
  ///
  /// If a photo entry already exists for this week, updates the note.
  /// Otherwise, creates a new entry with just the note.
  /// Returns the saved BumpPhoto entity.
  ///
  /// Throws [InvalidWeekException] if week is out of range.
  Future<BumpPhoto> saveNoteOnly({
    required String pregnancyId,
    required int weekNumber,
    required String? note,
  });

  /// Delete a bump photo.
  ///
  /// [id] - ID of the bump photo to delete
  ///
  /// Removes both the database record and the physical file.
  /// Does nothing if photo doesn't exist.
  Future<void> deleteBumpPhoto(String id);

  /// Delete all bump photos for a pregnancy.
  ///
  /// [pregnancyId] - ID of the pregnancy
  ///
  /// Removes all database records and physical files for the pregnancy.
  /// Returns the number of photos deleted.
  Future<int> deleteAllForPregnancy(String pregnancyId);
}
