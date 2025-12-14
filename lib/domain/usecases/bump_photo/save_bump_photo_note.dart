import '../../entities/bump_photo/bump_photo.dart';
import '../../entities/bump_photo/bump_photo_constants.dart';
import '../../exceptions/bump_photo_exception.dart';
import '../../repositories/bump_photo_repository.dart';

/// Use case for saving a bump photo note without requiring a photo.
///
/// Validates the week number and delegates to repository for saving
/// the note metadata.
class SaveBumpPhotoNote {
  final BumpPhotoRepository _repository;

  SaveBumpPhotoNote(this._repository);

  /// Execute the use case.
  ///
  /// [pregnancyId] - ID of the pregnancy
  /// [weekNumber] - Pregnancy week (1-42)
  /// [note] - Note text (null to clear the note)
  ///
  /// Returns the saved BumpPhoto entity.
  ///
  /// Throws [InvalidWeekException] if week is out of range.
  Future<BumpPhoto> call({
    required String pregnancyId,
    required int weekNumber,
    required String? note,
  }) async {
    // Validate week number
    if (!BumpPhotoConstants.isValidWeek(weekNumber)) {
      throw InvalidWeekException(
        weekNumber,
        BumpPhotoConstants.getInvalidWeekMessage(weekNumber),
      );
    }

    // Delegate to repository
    return await _repository.saveNoteOnly(
      pregnancyId: pregnancyId,
      weekNumber: weekNumber,
      note: note,
    );
  }
}
