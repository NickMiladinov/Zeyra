import '../../domain/entities/contraction_timer/contraction.dart';
import '../../domain/entities/contraction_timer/contraction_intensity.dart';
import '../local/app_database.dart';

/// Mapper for converting between Contraction domain entity and ContractionDto (database model).
class ContractionMapper {
  /// Convert database DTO to domain entity
  static Contraction toDomain(ContractionDto dto) {
    return Contraction(
      id: dto.id,
      sessionId: dto.sessionId,
      startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTimeMillis),
      endTime: dto.endTimeMillis != null 
          ? DateTime.fromMillisecondsSinceEpoch(dto.endTimeMillis!)
          : null,
      intensity: _intensityFromInt(dto.intensity),
    );
  }

  /// Convert domain entity to database DTO
  static ContractionDto toDto(Contraction entity) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return ContractionDto(
      id: entity.id,
      sessionId: entity.sessionId,
      startTimeMillis: entity.startTime.millisecondsSinceEpoch,
      endTimeMillis: entity.endTime?.millisecondsSinceEpoch,
      intensity: _intensityToInt(entity.intensity),
      createdAtMillis: now,
      updatedAtMillis: now,
    );
  }

  /// Convert intensity enum to integer for database storage
  static int _intensityToInt(ContractionIntensity intensity) {
    switch (intensity) {
      case ContractionIntensity.mild:
        return 0;
      case ContractionIntensity.moderate:
        return 1;
      case ContractionIntensity.strong:
        return 2;
    }
  }

  /// Convert integer from database to intensity enum
  static ContractionIntensity _intensityFromInt(int value) {
    switch (value) {
      case 0:
        return ContractionIntensity.mild;
      case 1:
        return ContractionIntensity.moderate;
      case 2:
        return ContractionIntensity.strong;
      default:
        return ContractionIntensity.moderate; // Default fallback
    }
  }
}

