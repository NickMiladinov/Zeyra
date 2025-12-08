import '../../domain/entities/kick_counter/pause_event.dart';
import '../local/app_database.dart';

/// Mapper for converting between PauseEvent DTOs and domain entities.
class PauseEventMapper {
  PauseEventMapper._(); // Prevent instantiation

  /// Convert PauseEventDto (database) to PauseEvent (domain entity).
  static PauseEvent toDomain(PauseEventDto dto) {
    return PauseEvent(
      id: dto.id,
      sessionId: dto.sessionId,
      pausedAt: DateTime.fromMillisecondsSinceEpoch(dto.pausedAtMillis),
      resumedAt: dto.resumedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(dto.resumedAtMillis!)
          : null,
      kickCountAtPause: dto.kickCountAtPause,
    );
  }

  /// Convert list of PauseEventDto to list of PauseEvent.
  static List<PauseEvent> toDomainList(List<PauseEventDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }
}

