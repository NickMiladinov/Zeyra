import '../../entities/pregnancy/pregnancy.dart';
import '../../exceptions/pregnancy_exception.dart';
import '../../repositories/pregnancy_repository.dart';

/// Use case for updating pregnancy due date with automatic start date calculation.
class UpdatePregnancyDueDateUseCase {
  final PregnancyRepository _repository;

  const UpdatePregnancyDueDateUseCase({
    required PregnancyRepository repository,
  }) : _repository = repository;

  /// Update due date and auto-calculate start date.
  ///
  /// [pregnancyId] - ID of the pregnancy to update
  /// [newDueDate] - New due date
  ///
  /// Automatically calculates start date as dueDate - 280 days.
  Future<Pregnancy> execute(String pregnancyId, DateTime newDueDate) async {
    // Get current pregnancy
    final pregnancy = await _repository.getPregnancyById(pregnancyId);
    if (pregnancy == null) {
      throw const PregnancyException(
        'Pregnancy not found.',
        PregnancyErrorType.notFound,
      );
    }

    // Calculate new start date (280 days before due date)
    final newStartDate = newDueDate
        .subtract(const Duration(days: Pregnancy.standardDurationDays));

    // Update pregnancy with new dates
    final updatedPregnancy = pregnancy.copyWith(
      startDate: newStartDate,
      dueDate: newDueDate,
    );

    return await _repository.updatePregnancy(updatedPregnancy);
  }
}
