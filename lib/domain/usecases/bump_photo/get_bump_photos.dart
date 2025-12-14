import '../../entities/bump_photo/bump_photo.dart';
import '../../repositories/bump_photo_repository.dart';

/// Use case for getting all bump photos for a pregnancy.
///
/// Returns photos sorted by week number in ascending order.
class GetBumpPhotos {
  final BumpPhotoRepository _repository;

  GetBumpPhotos(this._repository);

  /// Execute the use case.
  ///
  /// [pregnancyId] - ID of the pregnancy
  ///
  /// Returns list of bump photos ordered by weekNumber ascending.
  /// Returns empty list if no photos exist.
  Future<List<BumpPhoto>> call(String pregnancyId) async {
    return await _repository.getBumpPhotos(pregnancyId);
  }
}
