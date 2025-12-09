import '../../domain/entities/kick_counter/kick.dart';
import '../../domain/entities/kick_counter/kick_session.dart';
import '../local/app_database.dart';
import '../local/daos/kick_counter_dao.dart';
import 'pause_event_mapper.dart';

/// Mapper for converting between domain entities and DTOs.
///
/// Handles bidirectional mapping of KickSession and Kick entities,
/// including Duration ↔ milliseconds conversion for pause tracking.
///
/// **Note:** With SQLCipher full database encryption, no field-level
/// encryption/decryption is needed. Data is stored as plaintext in the
/// encrypted database.
class KickSessionMapper {
  KickSessionMapper._(); // Prevent instantiation

  // --------------------------------------------------------------------------
  // Session Mapping
  // --------------------------------------------------------------------------

  /// Convert DTO with kicks to domain KickSession entity.
  ///
  /// [dto] - Database representation with kicks
  ///
  /// Returns fully hydrated domain entity.
  static KickSession toDomain(KickSessionWithKicks dto) {
    return KickSession(
      id: dto.session.id,
      startTime: DateTime.fromMillisecondsSinceEpoch(dto.session.startTimeMillis),
      endTime: dto.session.endTimeMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(dto.session.endTimeMillis!)
          : null,
      isActive: dto.session.isActive,
      kicks: dto.kicks.map((k) => kickToDomain(k)).toList(),
      pausedAt: dto.session.pausedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(dto.session.pausedAtMillis!)
          : null,
      totalPausedDuration: Duration(
        milliseconds: dto.session.totalPausedMillis,
      ),
      pauseCount: dto.session.pauseCount,
      note: dto.session.note,
      pauseEvents: PauseEventMapper.toDomainList(dto.pauseEvents),
    );
  }

  /// Convert domain KickSession to DTO.
  ///
  /// [domain] - Domain entity
  ///
  /// Returns database representation. Kicks must be saved separately.
  static KickSessionDto toDto(KickSession domain) {
    final now = DateTime.now();

    return KickSessionDto(
      id: domain.id,
      startTimeMillis: domain.startTime.millisecondsSinceEpoch,
      endTimeMillis: domain.endTime?.millisecondsSinceEpoch,
      isActive: domain.isActive,
      pausedAtMillis: domain.pausedAt?.millisecondsSinceEpoch,
      totalPausedMillis: domain.totalPausedDuration.inMilliseconds,
      pauseCount: domain.pauseCount,
      note: domain.note,
      createdAtMillis: now.millisecondsSinceEpoch,
      updatedAtMillis: now.millisecondsSinceEpoch,
    );
  }

  // --------------------------------------------------------------------------
  // Kick Mapping
  // --------------------------------------------------------------------------

  /// Convert DTO kick to domain Kick entity.
  ///
  /// [dto] - Database representation
  ///
  /// Returns domain entity with parsed strength enum.
  static Kick kickToDomain(KickDto dto) {
    return Kick(
      id: dto.id,
      sessionId: dto.sessionId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(dto.timestampMillis),
      sequenceNumber: dto.sequenceNumber,
      perceivedStrength: _parseMovementStrength(dto.perceivedStrength),
    );
  }

  /// Convert domain Kick to DTO.
  ///
  /// [domain] - Domain entity
  ///
  /// Returns database representation.
  static KickDto kickToDto(Kick domain) {
    return KickDto(
      id: domain.id,
      sessionId: domain.sessionId,
      timestampMillis: domain.timestamp.millisecondsSinceEpoch,
      sequenceNumber: domain.sequenceNumber,
      perceivedStrength: movementStrengthToString(domain.perceivedStrength),
    );
  }

  // --------------------------------------------------------------------------
  // Helper Methods
  // --------------------------------------------------------------------------

  /// Parse string to MovementStrength enum.
  ///
  /// Handles case-insensitive parsing and defaults to moderate if invalid.
  static MovementStrength _parseMovementStrength(String value) {
    switch (value.toLowerCase()) {
      case 'weak':
        return MovementStrength.weak;
      case 'moderate':
        return MovementStrength.moderate;
      case 'strong':
        return MovementStrength.strong;
      default:
        // Throw exception for invalid values to detect data corruption
        throw const FormatException('Invalid movement strength value');
    }
  }

  /// Convert MovementStrength enum to string for storage.
  static String movementStrengthToString(MovementStrength strength) {
    return strength.name;
  }
}
