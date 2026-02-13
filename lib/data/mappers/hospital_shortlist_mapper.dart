import '../local/app_database.dart';
import '../local/daos/hospital_shortlist_dao.dart';
import '../../domain/entities/hospital/hospital_shortlist.dart';
import '../../domain/repositories/hospital_shortlist_repository.dart';
import 'maternity_unit_mapper.dart';

/// Mapper for converting between HospitalShortlist domain entity and Drift DTO.
class HospitalShortlistMapper {
  /// Convert Drift DTO to domain entity.
  static HospitalShortlist toDomain(HospitalShortlistDto dto) {
    return HospitalShortlist(
      id: dto.id,
      maternityUnitId: dto.maternityUnitId,
      addedAt: DateTime.fromMillisecondsSinceEpoch(dto.addedAtMillis),
      isSelected: dto.isSelected,
      notes: dto.notes,
    );
  }

  /// Convert domain entity to Drift DTO.
  static HospitalShortlistDto toDto(HospitalShortlist entity) {
    return HospitalShortlistDto(
      id: entity.id,
      maternityUnitId: entity.maternityUnitId,
      addedAtMillis: entity.addedAt.millisecondsSinceEpoch,
      isSelected: entity.isSelected,
      notes: entity.notes,
    );
  }

  /// Convert a list of DTOs to domain entities.
  static List<HospitalShortlist> toDomainList(List<HospitalShortlistDto> dtos) {
    return dtos.map(toDomain).toList();
  }

  /// Convert ShortlistWithUnitDto to domain ShortlistWithUnit.
  static ShortlistWithUnit toShortlistWithUnit(ShortlistWithUnitDto dto) {
    return ShortlistWithUnit(
      shortlist: toDomain(dto.shortlist),
      unit: MaternityUnitMapper.toDomain(dto.unit),
    );
  }

  /// Convert a list of ShortlistWithUnitDto to domain ShortlistWithUnit.
  static List<ShortlistWithUnit> toShortlistWithUnitList(
    List<ShortlistWithUnitDto> dtos,
  ) {
    return dtos.map(toShortlistWithUnit).toList();
  }
}
