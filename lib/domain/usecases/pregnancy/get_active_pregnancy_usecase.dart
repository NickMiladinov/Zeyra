import '../../entities/pregnancy/pregnancy.dart';
import '../../repositories/pregnancy_repository.dart';

/// Use case for getting the active pregnancy.
class GetActivePregnancyUseCase {
  final PregnancyRepository _repository;

  const GetActivePregnancyUseCase({
    required PregnancyRepository repository,
  }) : _repository = repository;

  /// Get the currently active pregnancy.
  ///
  /// Returns null if no pregnancies exist.
  Future<Pregnancy?> execute() async {
    return await _repository.getActivePregnancy();
  }
}
