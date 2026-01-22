import '../local/app_database.dart';
import '../../domain/entities/hospital/sync_metadata.dart';

/// Mapper for converting between SyncMetadata domain entity and Drift DTO.
class SyncMetadataMapper {
  /// Convert Drift DTO to domain entity.
  static SyncMetadata toDomain(SyncMetadataDto dto) {
    return SyncMetadata(
      id: dto.id,
      lastSyncAt: dto.lastSyncAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(dto.lastSyncAtMillis!)
          : null,
      lastSyncStatus: SyncStatus.fromString(dto.lastSyncStatus),
      lastSyncCount: dto.lastSyncCount,
      lastError: dto.lastError,
      dataVersionCode: dto.dataVersionCode,
      createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(dto.updatedAtMillis),
    );
  }

  /// Convert domain entity to Drift DTO.
  static SyncMetadataDto toDto(SyncMetadata entity) {
    return SyncMetadataDto(
      id: entity.id,
      lastSyncAtMillis: entity.lastSyncAt?.millisecondsSinceEpoch,
      lastSyncStatus: entity.lastSyncStatus.toDbString(),
      lastSyncCount: entity.lastSyncCount,
      lastError: entity.lastError,
      dataVersionCode: entity.dataVersionCode,
      createdAtMillis: entity.createdAt.millisecondsSinceEpoch,
      updatedAtMillis: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Convert a list of DTOs to domain entities.
  static List<SyncMetadata> toDomainList(List<SyncMetadataDto> dtos) {
    return dtos.map(toDomain).toList();
  }
}
