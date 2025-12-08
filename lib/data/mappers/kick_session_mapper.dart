import '../../domain/entities/kick_counter/kick.dart';
import '../../domain/entities/kick_counter/kick_session.dart';
import '../local/app_database.dart';
import '../local/daos/kick_counter_dao.dart';
import 'pause_event_mapper.dart';

/// Mapper for converting between domain entities and DTOs.
/// 
/// Handles bidirectional mapping of KickSession and Kick entities,
/// including Duration ↔ milliseconds conversion for pause tracking.
class KickSessionMapper {
  KickSessionMapper._(); // Prevent instantiation

  // --------------------------------------------------------------------------
  // Session Mapping
  // --------------------------------------------------------------------------

  /// Convert DTO with kicks to domain KickSession entity.
  /// 
  /// [dto] - Database representation with kicks
  /// [decryptStrength] - Function to decrypt perceived strength values
  /// [decryptNote] - Function to decrypt note (if present)
  /// 
  /// Returns fully hydrated domain entity with decrypted kicks.
  static KickSession toDomain(
    KickSessionWithKicks dto,
    String Function(String) decryptStrength, {
    String Function(String)? decryptNote,
  }) {
    String? note;
    if (dto.session.note != null && decryptNote != null) {
      note = decryptNote(dto.session.note!);
    }

    return KickSession(
      id: dto.session.id,
      startTime: DateTime.fromMillisecondsSinceEpoch(dto.session.startTimeMillis),
      endTime: dto.session.endTimeMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(dto.session.endTimeMillis!)
          : null,
      isActive: dto.session.isActive,
      kicks: dto.kicks
          .map((k) => kickToDomain(k, decryptStrength(k.perceivedStrength)))
          .toList(),
      pausedAt: dto.session.pausedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(dto.session.pausedAtMillis!)
          : null,
      totalPausedDuration: Duration(
        milliseconds: dto.session.totalPausedMillis,
      ),
      pauseCount: dto.session.pauseCount,
      note: note,
      pauseEvents: PauseEventMapper.toDomainList(dto.pauseEvents),
    );
  }

  /// Convert domain KickSession to DTO.
  /// 
  /// [domain] - Domain entity
  /// [encryptStrength] - Function to encrypt perceived strength values
  /// [encryptNote] - Function to encrypt note (if present)
  /// 
  /// Returns database representation. Kicks must be saved separately.
  static KickSessionDto toDto(
    KickSession domain,
    String Function(MovementStrength) encryptStrength, {
    String Function(String)? encryptNote,
  }) {
    final now = DateTime.now();
    String? encryptedNote;
    if (domain.note != null && encryptNote != null) {
      encryptedNote = encryptNote(domain.note!);
    }

    return KickSessionDto(
      id: domain.id,
      startTimeMillis: domain.startTime.millisecondsSinceEpoch,
      endTimeMillis: domain.endTime?.millisecondsSinceEpoch,
      isActive: domain.isActive,
      pausedAtMillis: domain.pausedAt?.millisecondsSinceEpoch,
      totalPausedMillis: domain.totalPausedDuration.inMilliseconds,
      pauseCount: domain.pauseCount,
      note: encryptedNote,
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
  /// [decryptedStrength] - Already decrypted strength value
  /// 
  /// Returns domain entity with parsed strength enum.
  static Kick kickToDomain(KickDto dto, String decryptedStrength) {
    return Kick(
      id: dto.id,
      sessionId: dto.sessionId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(dto.timestampMillis),
      sequenceNumber: dto.sequenceNumber,
      perceivedStrength: _parseMovementStrength(decryptedStrength),
    );
  }

  /// Convert domain Kick to DTO.
  /// 
  /// [domain] - Domain entity
  /// [encryptedStrength] - Already encrypted strength value
  /// 
  /// Returns database representation.
  static KickDto kickToDto(Kick domain, String encryptedStrength) {
    return KickDto(
      id: domain.id,
      sessionId: domain.sessionId,
      timestampMillis: domain.timestamp.millisecondsSinceEpoch,
      sequenceNumber: domain.sequenceNumber,
      perceivedStrength: encryptedStrength,
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

  /// Convert MovementStrength enum to string for encryption.
  static String movementStrengthToString(MovementStrength strength) {
    return strength.name;
  }
}

