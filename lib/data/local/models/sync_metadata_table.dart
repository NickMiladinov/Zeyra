import 'package:drift/drift.dart';

/// Drift table for tracking sync state.
///
/// Stores metadata about data synchronization, including last sync time,
/// status, and version of pre-packaged data.
@DataClassName('SyncMetadataDto')
class SyncMetadatas extends Table {
  /// Unique identifier for the sync target (e.g., "maternity_units").
  TextColumn get id => text()();

  /// When data was last successfully synced (millis since epoch).
  IntColumn get lastSyncAtMillis => integer().nullable()();

  /// Status of the last sync attempt.
  TextColumn get lastSyncStatus => text().nullable()();

  /// Number of records processed in the last sync.
  IntColumn get lastSyncCount => integer().withDefault(const Constant(0))();

  /// Error message from the last failed sync attempt.
  TextColumn get lastError => text().nullable()();

  /// Version code of the pre-packaged JSON data.
  IntColumn get dataVersionCode => integer().withDefault(const Constant(0))();

  /// When this metadata record was created (millis since epoch).
  IntColumn get createdAtMillis => integer()();

  /// When this metadata record was last updated (millis since epoch).
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
