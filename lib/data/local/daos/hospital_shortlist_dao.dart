import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/hospital_shortlist_table.dart';
import '../models/maternity_unit_table.dart';

part 'hospital_shortlist_dao.g.dart';

/// Data Access Object for hospital shortlist operations.
///
/// Provides type-safe database queries for managing the user's
/// shortlisted hospitals and their final selection.
@DriftAccessor(tables: [HospitalShortlists, MaternityUnits])
class HospitalShortlistDao extends DatabaseAccessor<AppDatabase>
    with _$HospitalShortlistDaoMixin {
  HospitalShortlistDao(super.db);

  // ---------------------------------------------------------------------------
  // Query Operations
  // ---------------------------------------------------------------------------

  /// Get all shortlist entries ordered by addedAt descending.
  Future<List<HospitalShortlistDto>> getAll() {
    return (select(hospitalShortlists)
          ..orderBy([(s) => OrderingTerm.desc(s.addedAtMillis)]))
        .get();
  }

  /// Get a shortlist entry by ID.
  Future<HospitalShortlistDto?> getById(String id) {
    return (select(hospitalShortlists)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get a shortlist entry by maternity unit ID.
  Future<HospitalShortlistDto?> getByMaternityUnitId(String maternityUnitId) {
    return (select(hospitalShortlists)
          ..where((s) => s.maternityUnitId.equals(maternityUnitId)))
        .getSingleOrNull();
  }

  /// Get the currently selected hospital entry.
  Future<HospitalShortlistDto?> getSelected() {
    return (select(hospitalShortlists)..where((s) => s.isSelected.equals(true)))
        .getSingleOrNull();
  }

  /// Check if a maternity unit is in the shortlist.
  Future<bool> isShortlisted(String maternityUnitId) async {
    final entry = await getByMaternityUnitId(maternityUnitId);
    return entry != null;
  }

  /// Get all shortlist entries with their associated maternity units.
  Future<List<ShortlistWithUnitDto>> getShortlistWithUnits() async {
    final query = select(hospitalShortlists).join([
      innerJoin(
        maternityUnits,
        maternityUnits.id.equalsExp(hospitalShortlists.maternityUnitId),
      ),
    ])
      ..orderBy([OrderingTerm.desc(hospitalShortlists.addedAtMillis)]);

    final results = await query.get();

    return results.map((row) {
      return ShortlistWithUnitDto(
        shortlist: row.readTable(hospitalShortlists),
        unit: row.readTable(maternityUnits),
      );
    }).toList();
  }

  /// Get the selected hospital with its maternity unit.
  Future<ShortlistWithUnitDto?> getSelectedWithUnit() async {
    final query = select(hospitalShortlists).join([
      innerJoin(
        maternityUnits,
        maternityUnits.id.equalsExp(hospitalShortlists.maternityUnitId),
      ),
    ])
      ..where(hospitalShortlists.isSelected.equals(true));

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    return ShortlistWithUnitDto(
      shortlist: result.readTable(hospitalShortlists),
      unit: result.readTable(maternityUnits),
    );
  }

  // ---------------------------------------------------------------------------
  // Mutation Operations
  // ---------------------------------------------------------------------------

  /// Insert a new shortlist entry.
  Future<HospitalShortlistDto> insertShortlist(HospitalShortlistDto shortlist) {
    return into(hospitalShortlists).insertReturning(shortlist);
  }

  /// Update a shortlist entry.
  Future<int> updateShortlist(HospitalShortlistDto shortlist) {
    return (update(hospitalShortlists)..where((s) => s.id.equals(shortlist.id)))
        .write(shortlist.toCompanion(false));
  }

  /// Update specific fields of a shortlist entry.
  Future<int> updateShortlistFields(
    String id,
    HospitalShortlistsCompanion companion,
  ) {
    return (update(hospitalShortlists)..where((s) => s.id.equals(id)))
        .write(companion);
  }

  /// Delete a shortlist entry by ID.
  Future<int> deleteShortlist(String id) {
    return (delete(hospitalShortlists)..where((s) => s.id.equals(id))).go();
  }

  /// Delete a shortlist entry by maternity unit ID.
  Future<int> deleteByMaternityUnitId(String maternityUnitId) {
    return (delete(hospitalShortlists)
          ..where((s) => s.maternityUnitId.equals(maternityUnitId)))
        .go();
  }

  /// Clear all selections (set isSelected = false for all entries).
  Future<int> clearAllSelections() {
    return (update(hospitalShortlists))
        .write(const HospitalShortlistsCompanion(isSelected: Value(false)));
  }

  /// Select a hospital as the final choice.
  ///
  /// Clears any existing selection first.
  Future<void> selectHospital(String shortlistId) async {
    await transaction(() async {
      // Clear existing selection
      await clearAllSelections();
      // Set new selection
      await updateShortlistFields(
        shortlistId,
        const HospitalShortlistsCompanion(isSelected: Value(true)),
      );
    });
  }
}

/// Combined DTO for a shortlist entry with its maternity unit.
class ShortlistWithUnitDto {
  final HospitalShortlistDto shortlist;
  final MaternityUnitDto unit;

  const ShortlistWithUnitDto({
    required this.shortlist,
    required this.unit,
  });
}
