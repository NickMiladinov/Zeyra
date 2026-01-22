import 'dart:convert';

import '../local/app_database.dart';
import '../../domain/entities/hospital/maternity_unit.dart';

/// Mapper for converting between MaternityUnit domain entity and Drift DTO.
class MaternityUnitMapper {
  /// Convert Drift DTO to domain entity.
  static MaternityUnit toDomain(MaternityUnitDto dto) {
    return MaternityUnit(
      id: dto.id,
      cqcLocationId: dto.cqcLocationId,
      cqcProviderId: dto.cqcProviderId,
      odsCode: dto.odsCode,
      name: dto.name,
      providerName: dto.providerName,
      unitType: dto.unitType,
      isNhs: dto.isNhs,
      addressLine1: dto.addressLine1,
      addressLine2: dto.addressLine2,
      townCity: dto.townCity,
      county: dto.county,
      postcode: dto.postcode,
      region: dto.region,
      localAuthority: dto.localAuthority,
      latitude: dto.latitude,
      longitude: dto.longitude,
      phone: dto.phone,
      website: dto.website,
      overallRating: dto.overallRating,
      ratingSafe: dto.ratingSafe,
      ratingEffective: dto.ratingEffective,
      ratingCaring: dto.ratingCaring,
      ratingResponsive: dto.ratingResponsive,
      ratingWellLed: dto.ratingWellLed,
      maternityRating: dto.maternityRating,
      maternityRatingDate: dto.maternityRatingDate,
      lastInspectionDate: dto.lastInspectionDate,
      cqcReportUrl: dto.cqcReportUrl,
      registrationStatus: dto.registrationStatus,
      birthingOptions: _parseJsonList(dto.birthingOptions),
      facilities: _parseJsonMap(dto.facilities),
      birthStatistics: _parseJsonMap(dto.birthStatistics),
      notes: dto.notes,
      isActive: dto.isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(dto.updatedAtMillis),
      cqcSyncedAt: dto.cqcSyncedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(dto.cqcSyncedAtMillis!)
          : null,
    );
  }

  /// Convert domain entity to Drift DTO.
  static MaternityUnitDto toDto(MaternityUnit entity) {
    return MaternityUnitDto(
      id: entity.id,
      cqcLocationId: entity.cqcLocationId,
      cqcProviderId: entity.cqcProviderId,
      odsCode: entity.odsCode,
      name: entity.name,
      providerName: entity.providerName,
      unitType: entity.unitType,
      isNhs: entity.isNhs,
      addressLine1: entity.addressLine1,
      addressLine2: entity.addressLine2,
      townCity: entity.townCity,
      county: entity.county,
      postcode: entity.postcode,
      region: entity.region,
      localAuthority: entity.localAuthority,
      latitude: entity.latitude,
      longitude: entity.longitude,
      phone: entity.phone,
      website: entity.website,
      overallRating: entity.overallRating,
      ratingSafe: entity.ratingSafe,
      ratingEffective: entity.ratingEffective,
      ratingCaring: entity.ratingCaring,
      ratingResponsive: entity.ratingResponsive,
      ratingWellLed: entity.ratingWellLed,
      maternityRating: entity.maternityRating,
      maternityRatingDate: entity.maternityRatingDate,
      lastInspectionDate: entity.lastInspectionDate,
      cqcReportUrl: entity.cqcReportUrl,
      registrationStatus: entity.registrationStatus,
      birthingOptions: _encodeJsonList(entity.birthingOptions),
      facilities: _encodeJsonMap(entity.facilities),
      birthStatistics: _encodeJsonMap(entity.birthStatistics),
      notes: entity.notes,
      isActive: entity.isActive,
      createdAtMillis: entity.createdAt.millisecondsSinceEpoch,
      updatedAtMillis: entity.updatedAt.millisecondsSinceEpoch,
      cqcSyncedAtMillis: entity.cqcSyncedAt?.millisecondsSinceEpoch,
    );
  }

  /// Convert a list of DTOs to domain entities.
  static List<MaternityUnit> toDomainList(List<MaternityUnitDto> dtos) {
    return dtos.map(toDomain).toList();
  }

  /// Convert a list of domain entities to DTOs.
  static List<MaternityUnitDto> toDtoList(List<MaternityUnit> entities) {
    return entities.map(toDto).toList();
  }

  // ---------------------------------------------------------------------------
  // JSON Helpers
  // ---------------------------------------------------------------------------

  static List<String>? _parseJsonList(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _parseJsonMap(String? json) {
    if (json == null || json.isEmpty || json == '{}') return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _encodeJsonList(List<String>? list) {
    if (list == null || list.isEmpty) return null;
    return jsonEncode(list);
  }

  static String? _encodeJsonMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    return jsonEncode(map);
  }
}
