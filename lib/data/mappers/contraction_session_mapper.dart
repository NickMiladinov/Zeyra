import '../../domain/entities/contraction_timer/contraction_session.dart';
import '../local/app_database.dart';
import '../local/daos/contraction_timer_dao.dart';
import 'contraction_mapper.dart';

/// Mapper for converting between ContractionSession domain entity and database models.
class ContractionSessionMapper {
  /// Convert database composite (session + contractions) to domain entity
  static ContractionSession toDomain(ContractionSessionWithContractions composite) {
    final session = composite.session;
    final contractions = composite.contractions
        .map((dto) => ContractionMapper.toDomain(dto))
        .toList();

    return ContractionSession(
      id: session.id,
      startTime: DateTime.fromMillisecondsSinceEpoch(session.startTimeMillis),
      endTime: session.endTimeMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(session.endTimeMillis!)
          : null,
      isActive: session.isActive,
      contractions: contractions,
      note: session.note,
      achievedDuration: session.achievedDuration,
      durationAchievedAt: session.durationAchievedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(session.durationAchievedAtMillis!)
          : null,
      achievedFrequency: session.achievedFrequency,
      frequencyAchievedAt: session.frequencyAchievedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(session.frequencyAchievedAtMillis!)
          : null,
      achievedConsistency: session.achievedConsistency,
      consistencyAchievedAt: session.consistencyAchievedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(session.consistencyAchievedAtMillis!)
          : null,
    );
  }

  /// Convert domain entity to database DTO (session only, without contractions)
  static ContractionSessionDto toDto(ContractionSession entity) {
    final now = DateTime.now().millisecondsSinceEpoch;

    return ContractionSessionDto(
      id: entity.id,
      startTimeMillis: entity.startTime.millisecondsSinceEpoch,
      endTimeMillis: entity.endTime?.millisecondsSinceEpoch,
      isActive: entity.isActive,
      achievedDuration: entity.achievedDuration,
      durationAchievedAtMillis: entity.durationAchievedAt?.millisecondsSinceEpoch,
      achievedFrequency: entity.achievedFrequency,
      frequencyAchievedAtMillis: entity.frequencyAchievedAt?.millisecondsSinceEpoch,
      achievedConsistency: entity.achievedConsistency,
      consistencyAchievedAtMillis: entity.consistencyAchievedAt?.millisecondsSinceEpoch,
      note: entity.note,
      createdAtMillis: now,
      updatedAtMillis: now,
    );
  }

  /// Convert list of sessions to domain entities
  static List<ContractionSession> toDomainList(
    List<ContractionSessionWithContractions> composites,
  ) {
    return composites.map((composite) => toDomain(composite)).toList();
  }
}

