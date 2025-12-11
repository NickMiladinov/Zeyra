import 'package:uuid/uuid.dart';

import '../../entities/pregnancy/pregnancy.dart';
import '../../repositories/pregnancy_repository.dart';

/// Use case for creating a pregnancy.
class CreatePregnancyUseCase {
  final PregnancyRepository _repository;
  final Uuid _uuid;

  const CreatePregnancyUseCase({
    required PregnancyRepository repository,
    Uuid? uuid,
  })  : _repository = repository,
        _uuid = uuid ?? const Uuid();

  /// Create a new pregnancy.
  ///
  /// [userId] - User profile ID
  /// [startDate] - Last Menstrual Period date
  /// [dueDate] - Expected due date (will be validated)
  /// [selectedHospitalId] - Optional hospital ID
  ///
  /// Validates date ranges before creation.
  Future<Pregnancy> execute({
    required String userId,
    required DateTime startDate,
    required DateTime dueDate,
    String? selectedHospitalId,
  }) async {
    final now = DateTime.now();
    final pregnancy = Pregnancy(
      id: _uuid.v4(),
      userId: userId,
      startDate: startDate,
      dueDate: dueDate,
      selectedHospitalId: selectedHospitalId,
      createdAt: now,
      updatedAt: now,
    );

    // Repository will validate dates
    return await _repository.createPregnancy(pregnancy);
  }
}
