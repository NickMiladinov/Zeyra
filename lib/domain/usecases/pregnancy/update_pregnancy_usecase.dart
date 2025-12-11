import '../../entities/pregnancy/pregnancy.dart';
import '../../repositories/pregnancy_repository.dart';

/// Use case for updating a pregnancy.
class UpdatePregnancyUseCase {
  final PregnancyRepository _repository;

  const UpdatePregnancyUseCase({
    required PregnancyRepository repository,
  }) : _repository = repository;

  /// Update an existing pregnancy.
  ///
  /// Validates date ranges before update.
  Future<Pregnancy> execute(Pregnancy pregnancy) async {
    // Repository will validate dates
    return await _repository.updatePregnancy(pregnancy);
  }
}
