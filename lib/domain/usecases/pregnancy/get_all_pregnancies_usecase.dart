import '../../entities/pregnancy/pregnancy.dart';
import '../../repositories/pregnancy_repository.dart';

/// Use case for getting all pregnancies.
class GetAllPregnanciesUseCase {
  final PregnancyRepository _repository;

  const GetAllPregnanciesUseCase({
    required PregnancyRepository repository,
  }) : _repository = repository;

  /// Get all pregnancies ordered by start date descending.
  Future<List<Pregnancy>> execute() async {
    return await _repository.getAllPregnancies();
  }
}
