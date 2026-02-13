import 'dart:math';

/// CQC rating levels for hospitals.
enum CqcRating {
  outstanding,
  good,
  requiresImprovement,
  inadequate,
  notRated;

  /// Parse CQC rating from string.
  static CqcRating fromString(String? value) {
    if (value == null) return CqcRating.notRated;
    switch (value.toLowerCase()) {
      case 'outstanding':
        return CqcRating.outstanding;
      case 'good':
        return CqcRating.good;
      case 'requires improvement':
        return CqcRating.requiresImprovement;
      case 'inadequate':
        return CqcRating.inadequate;
      default:
        return CqcRating.notRated;
    }
  }

  /// Convert to display string.
  String get displayName {
    switch (this) {
      case CqcRating.outstanding:
        return 'Outstanding';
      case CqcRating.good:
        return 'Good';
      case CqcRating.requiresImprovement:
        return 'Requires Improvement';
      case CqcRating.inadequate:
        return 'Inadequate';
      case CqcRating.notRated:
        return 'Not Rated';
    }
  }

  /// Numeric value for sorting (higher is better).
  int get sortValue {
    switch (this) {
      case CqcRating.outstanding:
        return 4;
      case CqcRating.good:
        return 3;
      case CqcRating.requiresImprovement:
        return 2;
      case CqcRating.inadequate:
        return 1;
      case CqcRating.notRated:
        return 0;
    }
  }
}

/// Domain entity representing a maternity unit from the CQC database.
///
/// Contains all information about a hospital/clinic that provides maternity
/// and midwifery services, including location, ratings, and contact details.
class MaternityUnit {
  /// UUID primary key (local).
  final String id;

  /// CQC unique location identifier.
  final String cqcLocationId;

  /// CQC provider ID.
  final String? cqcProviderId;

  /// NHS ODS code.
  final String? odsCode;

  /// Name of the maternity unit.
  final String name;

  /// Provider/Trust name.
  final String? providerName;

  /// Type: "nhs_hospital" or "independent_hospital".
  final String unitType;

  /// Whether this is an NHS facility.
  final bool isNhs;

  // Address fields
  final String? addressLine1;
  final String? addressLine2;
  final String? townCity;
  final String? county;
  final String? postcode;
  final String? region;
  final String? localAuthority;

  // Geolocation
  final double? latitude;
  final double? longitude;

  // Contact
  final String? phone;
  final String? website;

  // CQC Ratings
  final String? overallRating;
  final String? ratingSafe;
  final String? ratingEffective;
  final String? ratingCaring;
  final String? ratingResponsive;
  final String? ratingWellLed;
  final String? maternityRating;
  final String? maternityRatingDate;

  // CQC Metadata
  final String? lastInspectionDate;
  final String? cqcReportUrl;
  final String? registrationStatus;

  // PLACE Ratings (Patient-Led Assessments of the Care Environment)
  // Values are percentages (0-100), null if no PLACE data available
  final double? placeCleanliness;
  final double? placeFood;
  final double? placePrivacyDignityWellbeing;
  final double? placeConditionAppearance;
  final DateTime? placeSyncedAt;

  // Manual curation fields (empty for now)
  final List<String>? birthingOptions;
  final Map<String, dynamic>? facilities;
  final Map<String, dynamic>? birthStatistics;
  final String? notes;

  // Status
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cqcSyncedAt;

  const MaternityUnit({
    required this.id,
    required this.cqcLocationId,
    this.cqcProviderId,
    this.odsCode,
    required this.name,
    this.providerName,
    required this.unitType,
    required this.isNhs,
    this.addressLine1,
    this.addressLine2,
    this.townCity,
    this.county,
    this.postcode,
    this.region,
    this.localAuthority,
    this.latitude,
    this.longitude,
    this.phone,
    this.website,
    this.overallRating,
    this.ratingSafe,
    this.ratingEffective,
    this.ratingCaring,
    this.ratingResponsive,
    this.ratingWellLed,
    this.maternityRating,
    this.maternityRatingDate,
    this.lastInspectionDate,
    this.cqcReportUrl,
    this.registrationStatus,
    this.placeCleanliness,
    this.placeFood,
    this.placePrivacyDignityWellbeing,
    this.placeConditionAppearance,
    this.placeSyncedAt,
    this.birthingOptions,
    this.facilities,
    this.birthStatistics,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.cqcSyncedAt,
  });

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Whether this unit is valid for display (active, registered, has location).
  bool get isValid =>
      isActive &&
      registrationStatus == 'Registered' &&
      latitude != null &&
      longitude != null;

  /// Whether this unit has a complete address.
  bool get hasAddress => postcode != null || townCity != null;

  /// Get the overall rating as an enum.
  CqcRating get overallRatingEnum => CqcRating.fromString(overallRating);

  /// Get the maternity-specific rating as an enum.
  CqcRating get maternityRatingEnum => CqcRating.fromString(maternityRating);

  /// Best available rating (maternity-specific if available, otherwise overall).
  CqcRating get bestAvailableRating {
    if (maternityRating != null) {
      return maternityRatingEnum;
    }
    return overallRatingEnum;
  }

  /// Whether this unit has PLACE assessment data.
  bool get hasPlaceData =>
      placeCleanliness != null ||
      placeFood != null ||
      placePrivacyDignityWellbeing != null ||
      placeConditionAppearance != null;

  /// Format address as a single line.
  String get formattedAddress {
    final parts = <String>[];
    if (addressLine1 != null && addressLine1!.isNotEmpty) {
      parts.add(addressLine1!);
    }
    if (townCity != null && townCity!.isNotEmpty) {
      parts.add(townCity!);
    }
    if (postcode != null && postcode!.isNotEmpty) {
      parts.add(postcode!);
    }
    return parts.join(', ');
  }

  /// Format address as multiple lines.
  List<String> get addressLines {
    final lines = <String>[];
    if (addressLine1 != null && addressLine1!.isNotEmpty) {
      lines.add(addressLine1!);
    }
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      lines.add(addressLine2!);
    }
    if (townCity != null && townCity!.isNotEmpty) {
      lines.add(townCity!);
    }
    if (county != null && county!.isNotEmpty) {
      lines.add(county!);
    }
    if (postcode != null && postcode!.isNotEmpty) {
      lines.add(postcode!);
    }
    return lines;
  }

  // ---------------------------------------------------------------------------
  // Distance Calculation
  // ---------------------------------------------------------------------------

  /// Calculate distance from given coordinates using Haversine formula.
  ///
  /// Returns distance in miles, or null if this unit has no coordinates.
  double? distanceFrom(double lat, double lng) {
    if (latitude == null || longitude == null) return null;

    const earthRadiusMiles = 3958.8;
    final dLat = _toRadians(latitude! - lat);
    final dLng = _toRadians(longitude! - lng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat)) *
            cos(_toRadians(latitude!)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMiles * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------

  MaternityUnit copyWith({
    String? id,
    String? cqcLocationId,
    String? cqcProviderId,
    String? odsCode,
    String? name,
    String? providerName,
    String? unitType,
    bool? isNhs,
    String? addressLine1,
    String? addressLine2,
    String? townCity,
    String? county,
    String? postcode,
    String? region,
    String? localAuthority,
    double? latitude,
    double? longitude,
    String? phone,
    String? website,
    String? overallRating,
    String? ratingSafe,
    String? ratingEffective,
    String? ratingCaring,
    String? ratingResponsive,
    String? ratingWellLed,
    String? maternityRating,
    String? maternityRatingDate,
    String? lastInspectionDate,
    String? cqcReportUrl,
    String? registrationStatus,
    double? placeCleanliness,
    double? placeFood,
    double? placePrivacyDignityWellbeing,
    double? placeConditionAppearance,
    DateTime? placeSyncedAt,
    List<String>? birthingOptions,
    Map<String, dynamic>? facilities,
    Map<String, dynamic>? birthStatistics,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cqcSyncedAt,
  }) {
    return MaternityUnit(
      id: id ?? this.id,
      cqcLocationId: cqcLocationId ?? this.cqcLocationId,
      cqcProviderId: cqcProviderId ?? this.cqcProviderId,
      odsCode: odsCode ?? this.odsCode,
      name: name ?? this.name,
      providerName: providerName ?? this.providerName,
      unitType: unitType ?? this.unitType,
      isNhs: isNhs ?? this.isNhs,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      townCity: townCity ?? this.townCity,
      county: county ?? this.county,
      postcode: postcode ?? this.postcode,
      region: region ?? this.region,
      localAuthority: localAuthority ?? this.localAuthority,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      overallRating: overallRating ?? this.overallRating,
      ratingSafe: ratingSafe ?? this.ratingSafe,
      ratingEffective: ratingEffective ?? this.ratingEffective,
      ratingCaring: ratingCaring ?? this.ratingCaring,
      ratingResponsive: ratingResponsive ?? this.ratingResponsive,
      ratingWellLed: ratingWellLed ?? this.ratingWellLed,
      maternityRating: maternityRating ?? this.maternityRating,
      maternityRatingDate: maternityRatingDate ?? this.maternityRatingDate,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
      cqcReportUrl: cqcReportUrl ?? this.cqcReportUrl,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      placeCleanliness: placeCleanliness ?? this.placeCleanliness,
      placeFood: placeFood ?? this.placeFood,
      placePrivacyDignityWellbeing:
          placePrivacyDignityWellbeing ?? this.placePrivacyDignityWellbeing,
      placeConditionAppearance:
          placeConditionAppearance ?? this.placeConditionAppearance,
      placeSyncedAt: placeSyncedAt ?? this.placeSyncedAt,
      birthingOptions: birthingOptions ?? this.birthingOptions,
      facilities: facilities ?? this.facilities,
      birthStatistics: birthStatistics ?? this.birthStatistics,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cqcSyncedAt: cqcSyncedAt ?? this.cqcSyncedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaternityUnit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cqcLocationId == other.cqcLocationId;

  @override
  int get hashCode => id.hashCode ^ cqcLocationId.hashCode;

  @override
  String toString() => 'MaternityUnit(id: $id, name: $name, postcode: $postcode)';
}
