/// Domain entity representing sync metadata for tracking data synchronization state.
///
/// Used to track when data was last synced from Supabase, the status of the sync,
/// and the version of pre-packaged data loaded from assets.
class SyncMetadata {
  /// Unique identifier for the sync target (e.g., "maternity_units").
  final String id;

  /// When data was last successfully synced from remote.
  final DateTime? lastSyncAt;

  /// Status of the last sync attempt.
  final SyncStatus lastSyncStatus;

  /// Number of records processed in the last sync.
  final int lastSyncCount;

  /// Error message from the last failed sync attempt.
  final String? lastError;

  /// Version code of the pre-packaged JSON data.
  final int dataVersionCode;

  /// When this metadata record was created.
  final DateTime createdAt;

  /// When this metadata record was last updated.
  final DateTime updatedAt;

  const SyncMetadata({
    required this.id,
    this.lastSyncAt,
    this.lastSyncStatus = SyncStatus.never,
    this.lastSyncCount = 0,
    this.lastError,
    this.dataVersionCode = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether a sync has ever been performed.
  bool get hasEverSynced => lastSyncAt != null;

  /// Whether the last sync was successful.
  bool get wasLastSyncSuccessful =>
      lastSyncStatus == SyncStatus.success ||
      lastSyncStatus == SyncStatus.preloadComplete;

  SyncMetadata copyWith({
    String? id,
    DateTime? lastSyncAt,
    SyncStatus? lastSyncStatus,
    int? lastSyncCount,
    String? lastError,
    int? dataVersionCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncMetadata(
      id: id ?? this.id,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncCount: lastSyncCount ?? this.lastSyncCount,
      lastError: lastError ?? this.lastError,
      dataVersionCode: dataVersionCode ?? this.dataVersionCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncMetadata &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SyncMetadata(id: $id, lastSyncAt: $lastSyncAt, status: $lastSyncStatus)';
}

/// Status of a sync operation.
enum SyncStatus {
  /// Never synced.
  never,

  /// Pre-packaged data loaded successfully.
  preloadComplete,

  /// Remote sync completed successfully.
  success,

  /// Sync failed.
  failed,

  /// Sync completed with some errors.
  partial,

  /// Sync in progress.
  inProgress;

  /// Parse from string stored in database.
  static SyncStatus fromString(String? value) {
    if (value == null) return SyncStatus.never;
    switch (value.toLowerCase()) {
      case 'preload_complete':
        return SyncStatus.preloadComplete;
      case 'success':
        return SyncStatus.success;
      case 'failed':
        return SyncStatus.failed;
      case 'partial':
        return SyncStatus.partial;
      case 'in_progress':
        return SyncStatus.inProgress;
      default:
        return SyncStatus.never;
    }
  }

  /// Convert to string for database storage.
  String toDbString() {
    switch (this) {
      case SyncStatus.never:
        return 'never';
      case SyncStatus.preloadComplete:
        return 'preload_complete';
      case SyncStatus.success:
        return 'success';
      case SyncStatus.failed:
        return 'failed';
      case SyncStatus.partial:
        return 'partial';
      case SyncStatus.inProgress:
        return 'in_progress';
    }
  }
}
