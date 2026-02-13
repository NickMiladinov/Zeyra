import '../../entities/hospital/maternity_unit.dart';
import '../../repositories/maternity_unit_repository.dart';

/// Use case for getting detailed information about a single maternity unit.
class GetUnitDetailUseCase {
  final MaternityUnitRepository _repository;

  GetUnitDetailUseCase({
    required MaternityUnitRepository repository,
  }) : _repository = repository;

  /// Execute the use case.
  ///
  /// [unitId] - ID of the maternity unit to retrieve
  ///
  /// Returns the maternity unit or null if not found.
  Future<MaternityUnit?> execute(String unitId) async {
    return _repository.getUnitById(unitId);
  }
}
