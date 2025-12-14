import '../../domain/entities/bump_photo/bump_photo.dart';
import '../local/app_database.dart';

/// Mapper for converting between database DTOs and domain entities for bump photos.
///
/// Handles conversions between BumpPhotoDto (database layer) and BumpPhoto (domain layer).
/// All timestamp conversions use milliseconds since epoch for precision.
class BumpPhotoMapper {
  /// Convert database DTO to domain entity.
  static BumpPhoto toDomain(BumpPhotoDto dto) {
    return BumpPhoto(
      id: dto.id,
      pregnancyId: dto.pregnancyId,
      weekNumber: dto.weekNumber,
      filePath: dto.filePath,
      note: dto.note,
      photoDate: DateTime.fromMillisecondsSinceEpoch(dto.photoDateMillis),
      createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(dto.updatedAtMillis),
    );
  }

  /// Convert domain entity to database DTO.
  static BumpPhotoDto toDto(BumpPhoto entity) {
    return BumpPhotoDto(
      id: entity.id,
      pregnancyId: entity.pregnancyId,
      weekNumber: entity.weekNumber,
      filePath: entity.filePath,
      note: entity.note,
      photoDateMillis: entity.photoDate.millisecondsSinceEpoch,
      createdAtMillis: entity.createdAt.millisecondsSinceEpoch,
      updatedAtMillis: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Convert list of DTOs to list of domain entities.
  static List<BumpPhoto> toDomainList(List<BumpPhotoDto> dtos) {
    return dtos.map(toDomain).toList();
  }

  /// Convert list of domain entities to list of DTOs.
  static List<BumpPhotoDto> toDtoList(List<BumpPhoto> entities) {
    return entities.map(toDto).toList();
  }
}
