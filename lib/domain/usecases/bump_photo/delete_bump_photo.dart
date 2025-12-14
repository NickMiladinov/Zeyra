import '../../repositories/bump_photo_repository.dart';

/// Use case for deleting a bump photo.
///
/// Removes both the database record and the physical file.
class DeleteBumpPhoto {
  final BumpPhotoRepository _repository;

  DeleteBumpPhoto(this._repository);

  /// Execute the use case.
  ///
  /// [id] - ID of the bump photo to delete
  ///
  /// Removes both the database record and the physical file.
  /// Does nothing if photo doesn't exist.
  Future<void> call(String id) async {
    return await _repository.deleteBumpPhoto(id);
  }
}
