import '../../domain/entities/pregnancy/pregnancy.dart';
import '../local/app_database.dart';

/// Mapper for Pregnancy entity ↔ DTO conversion.
class PregnancyMapper {
  PregnancyMapper._();

  /// Convert DTO to domain entity.
  static Pregnancy toDomain(PregnancyDto dto) {
    return Pregnancy(
      id: dto.id,
      userId: dto.userId,
      startDate: DateTime.fromMillisecondsSinceEpoch(dto.startDateMillis),
      dueDate: DateTime.fromMillisecondsSinceEpoch(dto.dueDateMillis),
      selectedHospitalId: dto.selectedHospitalId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(dto.updatedAtMillis),
    );
  }

  /// Convert domain entity to DTO.
  static PregnancyDto toDto(Pregnancy domain) {
    return PregnancyDto(
      id: domain.id,
      userId: domain.userId,
      startDateMillis: domain.startDate.millisecondsSinceEpoch,
      dueDateMillis: domain.dueDate.millisecondsSinceEpoch,
      selectedHospitalId: domain.selectedHospitalId,
      createdAtMillis: domain.createdAt.millisecondsSinceEpoch,
      updatedAtMillis: domain.updatedAt.millisecondsSinceEpoch,
    );
  }
}
