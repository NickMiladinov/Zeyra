import '../../entities/hospital/maternity_unit.dart';
import '../../repositories/maternity_unit_repository.dart';

/// Use case for getting nearby maternity units.
///
/// Fetches maternity units within a specified radius of the user's location,
/// returning only valid units sorted by distance.
class GetNearbyUnitsUseCase {
  final MaternityUnitRepository _repository;

  GetNearbyUnitsUseCase({
    required MaternityUnitRepository repository,
  }) : _repository = repository;

  /// Execute the use case.
  ///
  /// [lat] - User's latitude
  /// [lng] - User's longitude
  /// [radiusMiles] - Search radius in miles (default: 15)
  ///
  /// Returns list of nearby maternity units sorted by distance.
  Future<List<MaternityUnit>> execute({
    required double lat,
    required double lng,
    double radiusMiles = 15.0,
  }) async {
    return _repository.getNearbyUnits(lat, lng, radiusMiles: radiusMiles);
  }
}
