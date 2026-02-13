import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/sync_metadata_table.dart';

part 'sync_metadata_dao.g.dart';

/// Data Access Object for sync metadata operations.
///
/// Provides type-safe database queries for tracking data synchronization state.
@DriftAccessor(tables: [SyncMetadatas])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetadataDaoMixin {
  SyncMetadataDao(super.db);

  // ---------------------------------------------------------------------------
  // Query Operations
  // ---------------------------------------------------------------------------

  /// Get sync metadata by ID.
  Future<SyncMetadataDto?> getById(String id) {
    return (select(syncMetadatas)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all sync metadata entries.
  Future<List<SyncMetadataDto>> getAll() {
    return select(syncMetadatas).get();
  }

  // ---------------------------------------------------------------------------
  // Mutation Operations
  // ---------------------------------------------------------------------------

  /// Insert or update sync metadata.
  Future<void> upsert(SyncMetadataDto metadata) {
    return into(syncMetadatas).insertOnConflictUpdate(metadata);
  }

  /// Update sync status after a successful sync.
  Future<void> updateSyncSuccess({
    required String id,
    required int lastSyncAtMillis,
    required String status,
    required int count,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await (update(syncMetadatas)..where((s) => s.id.equals(id))).write(
      SyncMetadatasCompanion(
        lastSyncAtMillis: Value(lastSyncAtMillis),
        lastSyncStatus: Value(status),
        lastSyncCount: Value(count),
        lastError: const Value(null),
        updatedAtMillis: Value(now),
      ),
    );
  }

  /// Update sync status after a failed sync.
  Future<void> updateSyncFailure({
    required String id,
    required String status,
    required String error,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await (update(syncMetadatas)..where((s) => s.id.equals(id))).write(
      SyncMetadatasCompanion(
        lastSyncStatus: Value(status),
        lastError: Value(error),
        updatedAtMillis: Value(now),
      ),
    );
  }

  /// Update data version code after loading pre-packaged data.
  Future<void> updateDataVersion({
    required String id,
    required int dataVersionCode,
    required int lastSyncAtMillis,
    required String status,
    required int count,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await getById(id);
    if (existing == null) {
      // Insert new record
      await into(syncMetadatas).insert(
        SyncMetadataDto(
          id: id,
          lastSyncAtMillis: lastSyncAtMillis,
          lastSyncStatus: status,
          lastSyncCount: count,
          lastError: null,
          dataVersionCode: dataVersionCode,
          createdAtMillis: now,
          updatedAtMillis: now,
        ),
      );
    } else {
      // Update existing record
      await (update(syncMetadatas)..where((s) => s.id.equals(id))).write(
        SyncMetadatasCompanion(
          lastSyncAtMillis: Value(lastSyncAtMillis),
          lastSyncStatus: Value(status),
          lastSyncCount: Value(count),
          lastError: const Value(null),
          dataVersionCode: Value(dataVersionCode),
          updatedAtMillis: Value(now),
        ),
      );
    }
  }

  /// Delete sync metadata by ID.
  Future<int> deleteMetadata(String id) {
    return (delete(syncMetadatas)..where((s) => s.id.equals(id))).go();
  }
}
