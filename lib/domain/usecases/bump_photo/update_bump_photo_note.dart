import '../../entities/bump_photo/bump_photo.dart';
import '../../repositories/bump_photo_repository.dart';

/// Use case for updating a bump photo note.
///
/// Updates only the note field, leaving the photo unchanged.
class UpdateBumpPhotoNote {
  final BumpPhotoRepository _repository;

  UpdateBumpPhotoNote(this._repository);

  /// Execute the use case.
  ///
  /// [id] - ID of the bump photo
  /// [note] - New note text (null to clear the note)
  ///
  /// Returns the updated BumpPhoto entity.
  ///
  /// Throws [PhotoNotFoundException] if photo doesn't exist.
  Future<BumpPhoto> call(String id, String? note) async {
    return await _repository.updateNote(id, note);
  }
}
