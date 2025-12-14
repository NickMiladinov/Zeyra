import '../../entities/bump_photo/bump_photo.dart';
import '../../entities/bump_photo/bump_photo_constants.dart';
import '../../exceptions/bump_photo_exception.dart';
import '../../repositories/bump_photo_repository.dart';

/// Use case for saving a bump photo.
///
/// Validates the week number and delegates to repository for saving
/// the photo with metadata.
class SaveBumpPhoto {
  final BumpPhotoRepository _repository;

  SaveBumpPhoto(this._repository);

  /// Execute the use case.
  ///
  /// [pregnancyId] - ID of the pregnancy
  /// [weekNumber] - Pregnancy week (1-42)
  /// [imageBytes] - Raw image data to save
  /// [note] - Optional user note about this week
  ///
  /// Returns the saved BumpPhoto entity.
  ///
  /// Throws [InvalidWeekException] if week is out of range.
  /// Throws [ImageTooLargeException] if image exceeds size limit.
  /// Throws [ImageProcessingException] if image processing fails.
  Future<BumpPhoto> call({
    required String pregnancyId,
    required int weekNumber,
    required List<int> imageBytes,
    String? note,
  }) async {
    // Validate week number
    if (!BumpPhotoConstants.isValidWeek(weekNumber)) {
      throw InvalidWeekException(
        weekNumber,
        BumpPhotoConstants.getInvalidWeekMessage(weekNumber),
      );
    }

    // Delegate to repository
    return await _repository.saveBumpPhoto(
      pregnancyId: pregnancyId,
      weekNumber: weekNumber,
      imageBytes: imageBytes,
      note: note,
    );
  }
}
