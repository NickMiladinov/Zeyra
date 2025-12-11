import '../../entities/pregnancy/pregnancy.dart';
import '../../exceptions/pregnancy_exception.dart';
import '../../repositories/pregnancy_repository.dart';

/// Use case for updating pregnancy start date with automatic due date calculation.
class UpdatePregnancyStartDateUseCase {
  final PregnancyRepository _repository;

  const UpdatePregnancyStartDateUseCase({
    required PregnancyRepository repository,
  }) : _repository = repository;

  /// Update start date and auto-calculate due date.
  ///
  /// [pregnancyId] - ID of the pregnancy to update
  /// [newStartDate] - New start date
  ///
  /// Automatically calculates due date as startDate + 280 days.
  Future<Pregnancy> execute(String pregnancyId, DateTime newStartDate) async {
    // Get current pregnancy
    final pregnancy = await _repository.getPregnancyById(pregnancyId);
    if (pregnancy == null) {
      throw const PregnancyException(
        'Pregnancy not found.',
        PregnancyErrorType.notFound,
      );
    }

    // Calculate new due date (280 days from start date)
    final newDueDate =
        newStartDate.add(const Duration(days: Pregnancy.standardDurationDays));

    // Update pregnancy with new dates
    final updatedPregnancy = pregnancy.copyWith(
      startDate: newStartDate,
      dueDate: newDueDate,
    );

    return await _repository.updatePregnancy(updatedPregnancy);
  }
}
