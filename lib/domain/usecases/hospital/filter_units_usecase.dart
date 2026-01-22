import '../../entities/hospital/hospital_filter_criteria.dart';
import '../../entities/hospital/maternity_unit.dart';
import '../../repositories/maternity_unit_repository.dart';

/// Use case for filtering maternity units.
///
/// Applies filter criteria (distance, rating, NHS/independent) and
/// sorting options to the list of nearby maternity units.
class FilterUnitsUseCase {
  final MaternityUnitRepository _repository;

  FilterUnitsUseCase({
    required MaternityUnitRepository repository,
  }) : _repository = repository;

  /// Execute the use case.
  ///
  /// [criteria] - Filter and sort options
  /// [userLat] - User's latitude for distance calculation
  /// [userLng] - User's longitude for distance calculation
  ///
  /// Returns filtered and sorted list of maternity units.
  Future<List<MaternityUnit>> execute({
    required HospitalFilterCriteria criteria,
    required double userLat,
    required double userLng,
  }) async {
    return _repository.getFilteredUnits(criteria, userLat, userLng);
  }
}
