import '../../repositories/pregnancy_repository.dart';

/// Use case for deleting a pregnancy.
class DeletePregnancyUseCase {
  final PregnancyRepository _repository;

  const DeletePregnancyUseCase({
    required PregnancyRepository repository,
  }) : _repository = repository;

  /// Delete a pregnancy.
  ///
  /// [pregnancyId] - ID of the pregnancy to delete
  Future<void> execute(String pregnancyId) async {
    await _repository.deletePregnancy(pregnancyId);
  }
}
