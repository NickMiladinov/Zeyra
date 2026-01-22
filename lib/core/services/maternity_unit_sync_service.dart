import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/repositories/maternity_unit_repository.dart';
import '../monitoring/logging_service.dart';

/// Service for syncing maternity unit data.
///
/// Handles initial data loading from assets and incremental
/// sync from Supabase.
class MaternityUnitSyncService {
  final MaternityUnitRepository _repository;
  final LoggingService _logger;

  /// Path to pre-packaged JSON asset.
  static const String assetPath = 'assets/data/maternity_units.json';

  MaternityUnitSyncService({
    required MaternityUnitRepository repository,
    required LoggingService logger,
  })  : _repository = repository,
        _logger = logger;

  /// Initialize data on app start.
  ///
  /// Checks if initial load is needed (empty database or newer JSON version)
  /// and loads pre-packaged data if required. Then performs incremental sync.
  Future<void> initialize() async {
    _logger.info('Initializing maternity unit sync');

    try {
      // Load JSON metadata to check version
      final jsonMetadata = await _loadJsonMetadata();
      if (jsonMetadata == null) {
        _logger.warning('Could not load JSON metadata, skipping initial load');
        return;
      }

      // Check if initial load is needed
      final needsLoad = await _repository.needsInitialLoad(jsonMetadata.version);

      if (needsLoad) {
        _logger.info('Initial data load required');
        await _repository.loadFromAssets(
          jsonMetadata.version,
          jsonMetadata.exportedAt,
        );
      } else {
        _logger.debug('Initial data already loaded');
      }

      // Perform incremental sync
      await performIncrementalSync();
    } catch (e, stackTrace) {
      _logger.error(
        'Error initializing maternity unit sync',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - the app should still work with cached data
    }
  }

  /// Perform initial data load from assets.
  ///
  /// Call this if you want to force a reload from assets.
  Future<void> loadFromAssets() async {
    _logger.info('Loading maternity units from assets');

    try {
      final jsonMetadata = await _loadJsonMetadata();
      if (jsonMetadata == null) {
        throw Exception('Could not load JSON metadata');
      }

      await _repository.loadFromAssets(
        jsonMetadata.version,
        jsonMetadata.exportedAt,
      );
    } catch (e, stackTrace) {
      _logger.error('Error loading from assets', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Perform incremental sync from Supabase.
  ///
  /// Fetches records updated since the last sync.
  Future<void> performIncrementalSync() async {
    _logger.info('Performing incremental sync');

    try {
      await _repository.syncFromRemote();
    } catch (e, stackTrace) {
      _logger.error('Error during incremental sync', error: e, stackTrace: stackTrace);
      // Don't rethrow - the app should still work with cached data
    }
  }

  /// Get sync status information.
  Future<SyncStatusInfo> getSyncStatus() async {
    final metadata = await _repository.getSyncMetadata();
    final unitCount = await _repository.getUnitCount();

    return SyncStatusInfo(
      lastSyncAt: metadata?.lastSyncAt,
      lastSyncStatus: metadata?.lastSyncStatus.name,
      lastSyncCount: metadata?.lastSyncCount ?? 0,
      totalUnits: unitCount,
      dataVersionCode: metadata?.dataVersionCode ?? 0,
      lastError: metadata?.lastError,
    );
  }

  /// Load JSON metadata from assets.
  Future<_JsonMetadata?> _loadJsonMetadata() async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final version = jsonData['version'] as int? ?? 1;
      final exportedAtStr = jsonData['exportedAt'] as String?;
      final exportedAt = exportedAtStr != null
          ? DateTime.parse(exportedAtStr)
          : DateTime.now();

      return _JsonMetadata(version: version, exportedAt: exportedAt);
    } catch (e) {
      _logger.warning('Error loading JSON metadata: $e');
      return null;
    }
  }
}

/// Metadata from the pre-packaged JSON file.
class _JsonMetadata {
  final int version;
  final DateTime exportedAt;

  const _JsonMetadata({
    required this.version,
    required this.exportedAt,
  });
}

/// Information about the current sync status.
class SyncStatusInfo {
  final DateTime? lastSyncAt;
  final String? lastSyncStatus;
  final int lastSyncCount;
  final int totalUnits;
  final int dataVersionCode;
  final String? lastError;

  const SyncStatusInfo({
    this.lastSyncAt,
    this.lastSyncStatus,
    this.lastSyncCount = 0,
    this.totalUnits = 0,
    this.dataVersionCode = 0,
    this.lastError,
  });

  bool get hasData => totalUnits > 0;
  bool get hasSynced => lastSyncAt != null;
  bool get hasError => lastError != null;

  @override
  String toString() =>
      'SyncStatusInfo(lastSync: $lastSyncAt, status: $lastSyncStatus, '
      'units: $totalUnits, version: $dataVersionCode)';
}
