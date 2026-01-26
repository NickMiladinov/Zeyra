import 'package:mocktail/mocktail.dart';

import 'package:zeyra/core/services/location_service.dart';
import 'package:zeyra/data/local/daos/hospital_shortlist_dao.dart';
import 'package:zeyra/data/local/daos/maternity_unit_dao.dart';
import 'package:zeyra/data/local/daos/sync_metadata_dao.dart';
import 'package:zeyra/data/remote/maternity_unit_remote_source.dart';
import 'package:zeyra/domain/entities/hospital/hospital_filter_criteria.dart';
import 'package:zeyra/domain/entities/hospital/hospital_shortlist.dart';
import 'package:zeyra/domain/entities/hospital/maternity_unit.dart';
import 'package:zeyra/domain/entities/hospital/sync_metadata.dart';
import 'package:zeyra/domain/repositories/hospital_shortlist_repository.dart';
import 'package:zeyra/domain/repositories/maternity_unit_repository.dart';
import 'package:zeyra/domain/usecases/hospital/filter_units_usecase.dart';
import 'package:zeyra/domain/usecases/hospital/get_nearby_units_usecase.dart';
import 'package:zeyra/domain/usecases/hospital/get_unit_detail_usecase.dart';
import 'package:zeyra/domain/usecases/hospital/manage_shortlist_usecase.dart';
import 'package:zeyra/domain/usecases/hospital/select_final_hospital_usecase.dart';
import 'package:zeyra/domain/usecases/user_profile/get_user_profile_usecase.dart';
import 'package:zeyra/domain/usecases/user_profile/update_user_profile_usecase.dart';

// =============================================================================
// Mock Classes
// =============================================================================

/// Mock for MaternityUnitRepository.
class MockMaternityUnitRepository extends Mock
    implements MaternityUnitRepository {}

/// Mock for HospitalShortlistRepository.
class MockHospitalShortlistRepository extends Mock
    implements HospitalShortlistRepository {}

/// Mock for MaternityUnitDao.
class MockMaternityUnitDao extends Mock implements MaternityUnitDao {}

/// Mock for HospitalShortlistDao.
class MockHospitalShortlistDao extends Mock implements HospitalShortlistDao {}

/// Mock for SyncMetadataDao.
class MockSyncMetadataDao extends Mock implements SyncMetadataDao {}

/// Mock for MaternityUnitRemoteSource.
class MockMaternityUnitRemoteSource extends Mock
    implements MaternityUnitRemoteSource {}

/// Mock for LocationService.
class MockLocationService extends Mock implements LocationService {}

// Note: MockLoggingService is defined in onboarding_fakes.dart

/// Mock for GetNearbyUnitsUseCase.
class MockGetNearbyUnitsUseCase extends Mock implements GetNearbyUnitsUseCase {}

/// Mock for FilterUnitsUseCase.
class MockFilterUnitsUseCase extends Mock implements FilterUnitsUseCase {}

/// Mock for GetUnitDetailUseCase.
class MockGetUnitDetailUseCase extends Mock implements GetUnitDetailUseCase {}

/// Mock for ManageShortlistUseCase.
class MockManageShortlistUseCase extends Mock implements ManageShortlistUseCase {}

/// Mock for SelectFinalHospitalUseCase.
class MockSelectFinalHospitalUseCase extends Mock
    implements SelectFinalHospitalUseCase {}

/// Mock for GetUserProfileUseCase.
class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}

/// Mock for UpdateUserProfileUseCase.
class MockUpdateUserProfileUseCase extends Mock
    implements UpdateUserProfileUseCase {}

// =============================================================================
// Fake Data Builders - MaternityUnit
// =============================================================================

/// Factory for creating fake MaternityUnit entities for testing.
class FakeMaternityUnit {
  FakeMaternityUnit._();

  /// Creates a simple valid maternity unit with default values.
  static MaternityUnit simple({
    String? id,
    String? cqcLocationId,
    String? name,
    double? latitude,
    double? longitude,
    String? postcode,
    String? overallRating,
    bool isNhs = true,
    bool isActive = true,
    String registrationStatus = 'Registered',
    double? placeCleanliness,
    double? placeFood,
    double? placePrivacyDignityWellbeing,
    double? placeConditionAppearance,
  }) {
    final now = DateTime.now();
    return MaternityUnit(
      id: id ?? 'unit-${now.millisecondsSinceEpoch}',
      cqcLocationId: cqcLocationId ?? 'cqc-${now.millisecondsSinceEpoch}',
      name: name ?? 'Test Hospital',
      unitType: isNhs ? 'nhs_hospital' : 'independent_hospital',
      isNhs: isNhs,
      latitude: latitude ?? 51.5074, // London
      longitude: longitude ?? -0.1278,
      postcode: postcode ?? 'SW1A 1AA',
      townCity: 'London',
      overallRating: overallRating ?? 'Good',
      registrationStatus: registrationStatus,
      isActive: isActive,
      placeCleanliness: placeCleanliness,
      placeFood: placeFood,
      placePrivacyDignityWellbeing: placePrivacyDignityWellbeing,
      placeConditionAppearance: placeConditionAppearance,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a maternity unit with PLACE ratings.
  static MaternityUnit withPlaceRatings({
    String? id,
    String? name,
    double cleanliness = 95.0,
    double food = 90.0,
    double privacyDignityWellbeing = 85.0,
    double conditionAppearance = 92.0,
  }) {
    return simple(
      id: id,
      name: name ?? 'Hospital with PLACE ratings',
      placeCleanliness: cleanliness,
      placeFood: food,
      placePrivacyDignityWellbeing: privacyDignityWellbeing,
      placeConditionAppearance: conditionAppearance,
    );
  }

  /// Creates a maternity unit with a specific CQC rating.
  static MaternityUnit withRating({
    required String rating,
    String? id,
    String? name,
  }) {
    return simple(
      id: id,
      name: name ?? 'Hospital with $rating rating',
      overallRating: rating,
    );
  }

  /// Creates a maternity unit at specific coordinates.
  static MaternityUnit atLocation({
    required double latitude,
    required double longitude,
    String? id,
    String? name,
    String? postcode,
  }) {
    return simple(
      id: id,
      name: name ?? 'Hospital at $latitude, $longitude',
      latitude: latitude,
      longitude: longitude,
      postcode: postcode,
    );
  }

  /// Creates an NHS hospital.
  static MaternityUnit nhsHospital({
    String? id,
    String? name,
    String? rating,
  }) {
    return simple(
      id: id,
      name: name ?? 'NHS Hospital',
      overallRating: rating ?? 'Good',
      isNhs: true,
    );
  }

  /// Creates an independent (private) hospital.
  static MaternityUnit independentHospital({
    String? id,
    String? name,
    String? rating,
  }) {
    return simple(
      id: id,
      name: name ?? 'Independent Hospital',
      overallRating: rating ?? 'Good',
      isNhs: false,
    );
  }

  /// Creates an invalid unit (inactive or unregistered or missing coordinates).
  ///
  /// Unlike `simple()`, this does NOT apply default coordinates.
  static MaternityUnit invalid({
    String? id,
    bool isActive = false,
    String registrationStatus = 'Deregistered',
    double? latitude,
    double? longitude,
  }) {
    final now = DateTime.now();
    return MaternityUnit(
      id: id ?? 'invalid-${now.millisecondsSinceEpoch}',
      cqcLocationId: 'cqc-invalid-${now.millisecondsSinceEpoch}',
      name: 'Invalid Hospital',
      unitType: 'nhs_hospital',
      isNhs: true,
      latitude: latitude, // Explicitly null if not provided
      longitude: longitude, // Explicitly null if not provided
      postcode: null,
      townCity: null,
      overallRating: 'Good',
      registrationStatus: registrationStatus,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a batch of n maternity units with sequential IDs.
  static List<MaternityUnit> batch(int count, {double? baseLat, double? baseLng}) {
    final base = baseLat ?? 51.5074;
    final baseLon = baseLng ?? -0.1278;
    
    return List.generate(count, (index) {
      // Spread units slightly apart
      final lat = base + (index * 0.01);
      final lng = baseLon + (index * 0.01);
      
      return simple(
        id: 'unit-$index',
        cqcLocationId: 'cqc-$index',
        name: 'Hospital $index',
        latitude: lat,
        longitude: lng,
        postcode: 'SW${index}A ${index}AA',
      );
    });
  }

  /// Creates a batch of units at increasing distances from a center point.
  static List<MaternityUnit> atDistances({
    required double centerLat,
    required double centerLng,
    required List<double> distancesMiles,
  }) {
    return distancesMiles.asMap().entries.map((entry) {
      final index = entry.key;
      final distance = entry.value;
      
      // Approximate: 1 degree latitude ≈ 69 miles
      final latOffset = distance / 69.0;
      
      return simple(
        id: 'unit-distance-$index',
        name: 'Hospital at ${distance.toStringAsFixed(1)} miles',
        latitude: centerLat + latOffset,
        longitude: centerLng,
      );
    }).toList();
  }
}

// =============================================================================
// Fake Data Builders - HospitalShortlist
// =============================================================================

/// Factory for creating fake HospitalShortlist entities for testing.
class FakeHospitalShortlist {
  FakeHospitalShortlist._();

  /// Creates a simple shortlist entry.
  static HospitalShortlist simple({
    String? id,
    String? maternityUnitId,
    DateTime? addedAt,
    bool isSelected = false,
    String? notes,
  }) {
    return HospitalShortlist(
      id: id ?? 'shortlist-${DateTime.now().millisecondsSinceEpoch}',
      maternityUnitId: maternityUnitId ?? 'unit-1',
      addedAt: addedAt ?? DateTime.now(),
      isSelected: isSelected,
      notes: notes,
    );
  }

  /// Creates a selected shortlist entry.
  static HospitalShortlist selected({
    String? id,
    String? maternityUnitId,
    String? notes,
  }) {
    return simple(
      id: id,
      maternityUnitId: maternityUnitId,
      isSelected: true,
      notes: notes,
    );
  }

  /// Creates a shortlist entry with notes.
  static HospitalShortlist withNotes({
    required String notes,
    String? id,
    String? maternityUnitId,
  }) {
    return simple(
      id: id,
      maternityUnitId: maternityUnitId,
      notes: notes,
    );
  }

  /// Creates a batch of shortlist entries.
  static List<HospitalShortlist> batch(int count) {
    return List.generate(count, (index) {
      return simple(
        id: 'shortlist-$index',
        maternityUnitId: 'unit-$index',
      );
    });
  }
}

// =============================================================================
// Fake Data Builders - ShortlistWithUnit
// =============================================================================

/// Factory for creating fake ShortlistWithUnit entities for testing.
class FakeShortlistWithUnit {
  FakeShortlistWithUnit._();

  /// Creates a simple shortlist with unit.
  static ShortlistWithUnit simple({
    HospitalShortlist? shortlist,
    MaternityUnit? unit,
  }) {
    final unitToUse = unit ?? FakeMaternityUnit.simple();
    final shortlistToUse = shortlist ??
        FakeHospitalShortlist.simple(maternityUnitId: unitToUse.id);

    return ShortlistWithUnit(
      shortlist: shortlistToUse,
      unit: unitToUse,
    );
  }

  /// Creates a selected shortlist with unit.
  static ShortlistWithUnit selected({
    MaternityUnit? unit,
  }) {
    final unitToUse = unit ?? FakeMaternityUnit.simple();
    return ShortlistWithUnit(
      shortlist: FakeHospitalShortlist.selected(maternityUnitId: unitToUse.id),
      unit: unitToUse,
    );
  }

  /// Creates a batch of shortlist with units.
  static List<ShortlistWithUnit> batch(int count) {
    final units = FakeMaternityUnit.batch(count);
    return units.map((unit) {
      return ShortlistWithUnit(
        shortlist: FakeHospitalShortlist.simple(maternityUnitId: unit.id),
        unit: unit,
      );
    }).toList();
  }
}

// =============================================================================
// Fake Data Builders - SyncMetadata
// =============================================================================

/// Factory for creating fake SyncMetadata entities for testing.
class FakeSyncMetadata {
  FakeSyncMetadata._();

  /// Creates a simple sync metadata entry.
  static SyncMetadata simple({
    String id = 'maternity_units',
    DateTime? lastSyncAt,
    SyncStatus status = SyncStatus.success,
    int lastSyncCount = 100,
    int dataVersionCode = 1,
    String? lastError,
  }) {
    final now = DateTime.now();
    return SyncMetadata(
      id: id,
      lastSyncAt: lastSyncAt ?? now.subtract(const Duration(hours: 1)),
      lastSyncStatus: status,
      lastSyncCount: lastSyncCount,
      lastError: lastError,
      dataVersionCode: dataVersionCode,
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now,
    );
  }

  /// Creates metadata indicating never synced.
  static SyncMetadata neverSynced({String id = 'maternity_units'}) {
    final now = DateTime.now();
    return SyncMetadata(
      id: id,
      lastSyncAt: null,
      lastSyncStatus: SyncStatus.never,
      lastSyncCount: 0,
      dataVersionCode: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates metadata indicating preload complete.
  static SyncMetadata preloadComplete({
    String id = 'maternity_units',
    int count = 500,
    int version = 1,
  }) {
    final now = DateTime.now();
    return SyncMetadata(
      id: id,
      lastSyncAt: now,
      lastSyncStatus: SyncStatus.preloadComplete,
      lastSyncCount: count,
      dataVersionCode: version,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates metadata indicating failed sync.
  static SyncMetadata failed({
    String id = 'maternity_units',
    String error = 'Network error',
  }) {
    final now = DateTime.now();
    return SyncMetadata(
      id: id,
      lastSyncAt: now.subtract(const Duration(hours: 2)),
      lastSyncStatus: SyncStatus.failed,
      lastSyncCount: 0,
      lastError: error,
      dataVersionCode: 1,
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now,
    );
  }
}

// =============================================================================
// Fake Data Builders - HospitalFilterCriteria
// =============================================================================

/// Factory for creating fake filter criteria for testing.
class FakeFilterCriteria {
  FakeFilterCriteria._();

  /// Default filter criteria.
  static HospitalFilterCriteria defaults() {
    return HospitalFilterCriteria.defaults;
  }

  /// Filter with custom distance.
  static HospitalFilterCriteria withDistance(double miles) {
    return HospitalFilterCriteria(maxDistanceMiles: miles);
  }

  /// Filter for NHS only.
  static HospitalFilterCriteria nhsOnly() {
    return const HospitalFilterCriteria(
      includeNhs: true,
      includeIndependent: false,
    );
  }

  /// Filter for outstanding rating only.
  static HospitalFilterCriteria outstandingOnly() {
    return const HospitalFilterCriteria(
      allowedRatings: {CqcRating.outstanding},
    );
  }

  /// Filter sorted by rating.
  static HospitalFilterCriteria sortByRating() {
    return const HospitalFilterCriteria(
      sortBy: HospitalSortBy.rating,
    );
  }
}
