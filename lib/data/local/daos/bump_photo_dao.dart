import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/bump_photo_table.dart';

part 'bump_photo_dao.g.dart';

/// DAO for bump photo operations.
///
/// Handles all database operations for bump photos using Drift.
/// Data is encrypted by SQLCipher at the database level.
@DriftAccessor(tables: [BumpPhotos])
class BumpPhotoDao extends DatabaseAccessor<AppDatabase> with _$BumpPhotoDaoMixin {
  BumpPhotoDao(super.db);

  // --------------------------------------------------------------------------
  // Create & Update
  // --------------------------------------------------------------------------

  /// Insert a new bump photo.
  Future<void> insertBumpPhoto(BumpPhotoDto photo) async {
    await into(bumpPhotos).insert(photo);
  }

  /// Update an existing bump photo.
  Future<void> updateBumpPhoto(BumpPhotoDto photo) async {
    await update(bumpPhotos).replace(photo);
  }

  /// Upsert a bump photo (insert or replace if exists).
  ///
  /// Uses ON CONFLICT REPLACE strategy for the unique constraint on
  /// (pregnancyId, weekNumber).
  Future<void> upsertBumpPhoto(BumpPhotoDto photo) async {
    await into(bumpPhotos).insertOnConflictUpdate(photo);
  }

  /// Update specific fields of a bump photo.
  Future<void> updateBumpPhotoFields(
    String id,
    BumpPhotosCompanion companion,
  ) async {
    await (update(bumpPhotos)..where((t) => t.id.equals(id))).write(companion);
  }

  // --------------------------------------------------------------------------
  // Read
  // --------------------------------------------------------------------------

  /// Get a bump photo by ID.
  Future<BumpPhotoDto?> getBumpPhoto(String id) async {
    return (select(bumpPhotos)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Get a bump photo by pregnancy ID and week number.
  Future<BumpPhotoDto?> getBumpPhotoByWeek(
    String pregnancyId,
    int weekNumber,
  ) async {
    return (select(bumpPhotos)
          ..where((t) => t.pregnancyId.equals(pregnancyId))
          ..where((t) => t.weekNumber.equals(weekNumber)))
        .getSingleOrNull();
  }

  /// Get all bump photos for a pregnancy, ordered by week number.
  Future<List<BumpPhotoDto>> getBumpPhotosForPregnancy(String pregnancyId) async {
    return (select(bumpPhotos)
          ..where((t) => t.pregnancyId.equals(pregnancyId))
          ..orderBy([(t) => OrderingTerm.asc(t.weekNumber)]))
        .get();
  }

  /// Get count of bump photos for a pregnancy.
  Future<int> getBumpPhotoCount(String pregnancyId) async {
    final countExp = bumpPhotos.id.count();
    final query = selectOnly(bumpPhotos)
      ..addColumns([countExp])
      ..where(bumpPhotos.pregnancyId.equals(pregnancyId));

    final result = await query.getSingleOrNull();
    return result?.read(countExp) ?? 0;
  }

  // --------------------------------------------------------------------------
  // Delete
  // --------------------------------------------------------------------------

  /// Delete a bump photo by ID.
  Future<void> deleteBumpPhoto(String id) async {
    await (delete(bumpPhotos)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all bump photos for a pregnancy.
  ///
  /// Returns the number of photos deleted.
  Future<int> deleteAllForPregnancy(String pregnancyId) async {
    return await (delete(bumpPhotos)
          ..where((t) => t.pregnancyId.equals(pregnancyId)))
        .go();
  }

  /// Delete bump photos older than the specified date.
  ///
  /// Returns the number of photos deleted.
  Future<int> deleteBumpPhotosOlderThan(int cutoffMillis) async {
    return await (delete(bumpPhotos)
          ..where((t) => t.photoDateMillis.isSmallerThanValue(cutoffMillis)))
        .go();
  }
}
