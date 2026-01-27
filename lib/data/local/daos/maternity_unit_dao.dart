import 'dart:math';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/maternity_unit_table.dart';

part 'maternity_unit_dao.g.dart';

/// Data Access Object for maternity unit operations.
///
/// Provides type-safe database queries for maternity units,
/// including geospatial queries using bounding box pre-filtering.
@DriftAccessor(tables: [MaternityUnits])
class MaternityUnitDao extends DatabaseAccessor<AppDatabase>
    with _$MaternityUnitDaoMixin {
  MaternityUnitDao(super.db);

  // ---------------------------------------------------------------------------
  // Query Operations
  // ---------------------------------------------------------------------------

  /// Get all maternity units.
  Future<List<MaternityUnitDto>> getAll() {
    return select(maternityUnits).get();
  }

  /// Get a single unit by ID.
  Future<MaternityUnitDto?> getById(String id) {
    return (select(maternityUnits)..where((u) => u.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get a single unit by CQC location ID.
  Future<MaternityUnitDto?> getByCqcId(String cqcLocationId) {
    return (select(maternityUnits)
          ..where((u) => u.cqcLocationId.equals(cqcLocationId)))
        .getSingleOrNull();
  }

  /// Get total count of units.
  Future<int> getCount() async {
    final countQuery = selectOnly(maternityUnits)
      ..addColumns([maternityUnits.id.count()]);
    final result = await countQuery.getSingleOrNull();
    return result?.read(maternityUnits.id.count()) ?? 0;
  }

  /// Get units within a bounding box (for efficient geospatial queries).
  ///
  /// This is the first step of the bounding box + Haversine algorithm.
  /// The caller should then apply precise Haversine distance filtering.
  Future<List<MaternityUnitDto>> getUnitsInBoundingBox({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    bool activeOnly = true,
  }) {
    final query = select(maternityUnits)
      ..where((u) => u.latitude.isBetweenValues(minLat, maxLat))
      ..where((u) => u.longitude.isBetweenValues(minLng, maxLng))
      ..where((u) => u.latitude.isNotNull())
      ..where((u) => u.longitude.isNotNull());

    if (activeOnly) {
      query.where((u) => u.isActive.equals(true));
      query.where((u) => u.registrationStatus.equals('Registered'));
    }

    return query.get();
  }

  /// Calculate bounding box coordinates for a given center and radius.
  ///
  /// Returns (minLat, maxLat, minLng, maxLng).
  /// Uses approximation: 1 degree latitude ≈ 69 miles.
  static ({double minLat, double maxLat, double minLng, double maxLng})
      calculateBoundingBox(double centerLat, double centerLng, double radiusMiles) {
    const milesPerDegreeLat = 69.0;
    final milesPerDegreeLng = 69.0 * cos(centerLat * pi / 180);

    final latDelta = radiusMiles / milesPerDegreeLat;
    final lngDelta = radiusMiles / milesPerDegreeLng;

    return (
      minLat: centerLat - latDelta,
      maxLat: centerLat + latDelta,
      minLng: centerLng - lngDelta,
      maxLng: centerLng + lngDelta,
    );
  }

  /// Get the maximum updatedAt timestamp for incremental sync.
  Future<int?> getMaxUpdatedAt() async {
    final query = selectOnly(maternityUnits)
      ..addColumns([maternityUnits.updatedAtMillis.max()]);
    final result = await query.getSingleOrNull();
    return result?.read(maternityUnits.updatedAtMillis.max());
  }

  /// Search units by name using case-insensitive LIKE query.
  ///
  /// Returns matching units ordered by name, limited to [limit] results.
  /// Only returns active, registered units.
  ///
  /// [query] - Search string to match against unit names
  /// [limit] - Maximum number of results to return (default: 20)
  Future<List<MaternityUnitDto>> searchByName(
    String query, {
    int limit = 20,
  }) {
    final normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) return Future.value([]);

    // Use LIKE with wildcards for substring matching
    // Drift's .like() is case-insensitive on SQLite by default
    final searchPattern = '%$normalizedQuery%';

    return (select(maternityUnits)
          ..where((u) => u.name.lower().like(searchPattern))
          ..where((u) => u.isActive.equals(true))
          ..where((u) => u.registrationStatus.equals('Registered'))
          ..orderBy([(u) => OrderingTerm.asc(u.name)])
          ..limit(limit))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Mutation Operations
  // ---------------------------------------------------------------------------

  /// Insert a single unit.
  Future<MaternityUnitDto> insertUnit(MaternityUnitDto unit) {
    return into(maternityUnits).insertReturning(unit);
  }

  /// Upsert a single unit (insert or update on conflict).
  Future<void> upsertUnit(MaternityUnitDto unit) {
    return into(maternityUnits).insertOnConflictUpdate(unit);
  }

  /// Upsert multiple units in a batch.
  Future<void> upsertAll(List<MaternityUnitDto> units) async {
    await batch((batch) {
      for (final unit in units) {
        batch.insert(
          maternityUnits,
          unit,
          onConflict: DoUpdate(
            (old) => MaternityUnitsCompanion(
              // Update all fields except id and cqcLocationId
              cqcProviderId: Value(unit.cqcProviderId),
              odsCode: Value(unit.odsCode),
              name: Value(unit.name),
              providerName: Value(unit.providerName),
              unitType: Value(unit.unitType),
              isNhs: Value(unit.isNhs),
              addressLine1: Value(unit.addressLine1),
              addressLine2: Value(unit.addressLine2),
              townCity: Value(unit.townCity),
              county: Value(unit.county),
              postcode: Value(unit.postcode),
              region: Value(unit.region),
              localAuthority: Value(unit.localAuthority),
              latitude: Value(unit.latitude),
              longitude: Value(unit.longitude),
              phone: Value(unit.phone),
              website: Value(unit.website),
              overallRating: Value(unit.overallRating),
              ratingSafe: Value(unit.ratingSafe),
              ratingEffective: Value(unit.ratingEffective),
              ratingCaring: Value(unit.ratingCaring),
              ratingResponsive: Value(unit.ratingResponsive),
              ratingWellLed: Value(unit.ratingWellLed),
              maternityRating: Value(unit.maternityRating),
              maternityRatingDate: Value(unit.maternityRatingDate),
              lastInspectionDate: Value(unit.lastInspectionDate),
              cqcReportUrl: Value(unit.cqcReportUrl),
              registrationStatus: Value(unit.registrationStatus),
              birthingOptions: Value(unit.birthingOptions),
              facilities: Value(unit.facilities),
              birthStatistics: Value(unit.birthStatistics),
              notes: Value(unit.notes),
              isActive: Value(unit.isActive),
              updatedAtMillis: Value(unit.updatedAtMillis),
              cqcSyncedAtMillis: Value(unit.cqcSyncedAtMillis),
            ),
          ),
        );
      }
    });
  }

  /// Delete a unit by ID.
  Future<int> deleteUnit(String id) {
    return (delete(maternityUnits)..where((u) => u.id.equals(id))).go();
  }

  /// Delete all units (for testing/reset).
  Future<int> deleteAll() {
    return delete(maternityUnits).go();
  }
}
