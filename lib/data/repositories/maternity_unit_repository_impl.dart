import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/monitoring/logging_service.dart';
import '../../domain/entities/hospital/hospital_filter_criteria.dart';
import '../../domain/entities/hospital/maternity_unit.dart';
import '../../domain/entities/hospital/sync_metadata.dart';
import '../../domain/repositories/maternity_unit_repository.dart';
import '../local/app_database.dart';
import '../local/daos/maternity_unit_dao.dart';
import '../local/daos/sync_metadata_dao.dart';
import '../mappers/maternity_unit_mapper.dart';
import '../mappers/sync_metadata_mapper.dart';
import '../remote/maternity_unit_remote_source.dart';

/// Implementation of MaternityUnitRepository.
///
/// Combines local Drift database with remote Supabase data source.
/// Uses bounding box + Haversine algorithm for efficient geospatial queries.
class MaternityUnitRepositoryImpl implements MaternityUnitRepository {
  final MaternityUnitDao _dao;
  final SyncMetadataDao _syncMetadataDao;
  final MaternityUnitRemoteSource _remoteSource;
  final LoggingService _logger;

  /// Sync metadata ID for maternity units.
  static const String syncMetadataId = 'maternity_units';

  /// Path to pre-packaged JSON asset.
  static const String assetPath = 'assets/data/maternity_units.json';

  MaternityUnitRepositoryImpl({
    required MaternityUnitDao dao,
    required SyncMetadataDao syncMetadataDao,
    required MaternityUnitRemoteSource remoteSource,
    required LoggingService logger,
  })  : _dao = dao,
        _syncMetadataDao = syncMetadataDao,
        _remoteSource = remoteSource,
        _logger = logger;

  // ---------------------------------------------------------------------------
  // Query Operations
  // ---------------------------------------------------------------------------

  @override
  Future<List<MaternityUnit>> getNearbyUnits(
    double lat,
    double lng, {
    double radiusMiles = 15.0,
  }) async {
    _logger.debug('Getting nearby units', data: {
      'lat': lat,
      'lng': lng,
      'radius': radiusMiles,
    });

    try {
      // Step 1: Calculate bounding box
      final box = MaternityUnitDao.calculateBoundingBox(lat, lng, radiusMiles);

      // Step 2: Query units in bounding box
      final dtos = await _dao.getUnitsInBoundingBox(
        minLat: box.minLat,
        maxLat: box.maxLat,
        minLng: box.minLng,
        maxLng: box.maxLng,
        activeOnly: true,
      );

      // Step 3: Convert to domain entities
      final units = MaternityUnitMapper.toDomainList(dtos);

      // Step 4: Apply precise Haversine filtering and sort by distance
      final nearbyUnits = units
          .where((unit) {
            final distance = unit.distanceFrom(lat, lng);
            return distance != null && distance <= radiusMiles;
          })
          .toList()
        ..sort((a, b) {
          final distA = a.distanceFrom(lat, lng) ?? double.infinity;
          final distB = b.distanceFrom(lat, lng) ?? double.infinity;
          return distA.compareTo(distB);
        });

      _logger.debug('Found ${nearbyUnits.length} nearby units');
      return nearbyUnits;
    } catch (e, stackTrace) {
      _logger.error('Error getting nearby units', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<MaternityUnit>> getFilteredUnits(
    HospitalFilterCriteria criteria,
    double userLat,
    double userLng,
  ) async {
    _logger.debug('Getting filtered units', data: {
      'criteria': criteria.toString(),
    });

    try {
      // Get all units in bounding box first
      final box = MaternityUnitDao.calculateBoundingBox(
        userLat,
        userLng,
        criteria.maxDistanceMiles,
      );

      final dtos = await _dao.getUnitsInBoundingBox(
        minLat: box.minLat,
        maxLat: box.maxLat,
        minLng: box.minLng,
        maxLng: box.maxLng,
        activeOnly: true,
      );

      final units = MaternityUnitMapper.toDomainList(dtos);

      // Apply filter criteria (includes Haversine filtering and sorting)
      final filtered = criteria.apply(units, userLat, userLng);

      _logger.debug('Filtered to ${filtered.length} units');
      return filtered;
    } catch (e, stackTrace) {
      _logger.error('Error getting filtered units', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<MaternityUnit?> getUnitById(String id) async {
    final dto = await _dao.getById(id);
    if (dto == null) return null;
    return MaternityUnitMapper.toDomain(dto);
  }

  @override
  Future<MaternityUnit?> getUnitByCqcId(String cqcLocationId) async {
    final dto = await _dao.getByCqcId(cqcLocationId);
    if (dto == null) return null;
    return MaternityUnitMapper.toDomain(dto);
  }

  @override
  Future<int> getUnitCount() async {
    return _dao.getCount();
  }

  // ---------------------------------------------------------------------------
  // Sync Operations
  // ---------------------------------------------------------------------------

  @override
  Future<void> loadFromAssets(int jsonVersion, DateTime exportedAt) async {
    _logger.info('Loading maternity units from assets', data: {
      'version': jsonVersion,
      'exportedAt': exportedAt.toIso8601String(),
    });

    try {
      // Load JSON from assets
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Parse units
      final unitsList = jsonData['units'] as List<dynamic>;
      _logger.debug('Parsing ${unitsList.length} units from JSON');

      final dtos = <MaternityUnitDto>[];
      for (final unitJson in unitsList) {
        try {
          final dto = _parseJsonUnit(unitJson as Map<String, dynamic>);
          dtos.add(dto);
        } catch (e) {
          _logger.warning('Failed to parse unit from JSON', data: {'error': e.toString()});
        }
      }

      // Upsert all units
      await _dao.upsertAll(dtos);

      // Update sync metadata
      await _syncMetadataDao.updateDataVersion(
        id: syncMetadataId,
        dataVersionCode: jsonVersion,
        lastSyncAtMillis: exportedAt.millisecondsSinceEpoch,
        status: SyncStatus.preloadComplete.toDbString(),
        count: dtos.length,
      );

      _logger.info('Loaded ${dtos.length} maternity units from assets');
      _logger.logDatabaseOperation('PRELOAD', table: 'maternity_units', success: true);
    } catch (e, stackTrace) {
      _logger.error('Error loading from assets', error: e, stackTrace: stackTrace);
      _logger.logDatabaseOperation('PRELOAD', table: 'maternity_units', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> syncFromRemote() async {
    _logger.info('Starting incremental sync from remote');

    try {
      // Get last sync timestamp
      final metadata = await _syncMetadataDao.getById(syncMetadataId);
      final lastSyncAt = metadata?.lastSyncAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(metadata!.lastSyncAtMillis!)
          : DateTime.fromMillisecondsSinceEpoch(0);

      _logger.debug('Fetching updates since $lastSyncAt');

      // Fetch updated records from Supabase
      final updatedDtos = await _remoteSource.fetchUpdatedSince(lastSyncAt);

      if (updatedDtos.isEmpty) {
        _logger.debug('No updates found');
        // Update sync timestamp even if no changes
        await _syncMetadataDao.updateSyncSuccess(
          id: syncMetadataId,
          lastSyncAtMillis: DateTime.now().millisecondsSinceEpoch,
          status: SyncStatus.success.toDbString(),
          count: 0,
        );
        return;
      }

      // Upsert updated records
      await _dao.upsertAll(updatedDtos);

      // Update sync metadata
      await _syncMetadataDao.updateSyncSuccess(
        id: syncMetadataId,
        lastSyncAtMillis: DateTime.now().millisecondsSinceEpoch,
        status: SyncStatus.success.toDbString(),
        count: updatedDtos.length,
      );

      _logger.info('Synced ${updatedDtos.length} updated maternity units');
      _logger.logDatabaseOperation('SYNC', table: 'maternity_units', success: true);
    } catch (e, stackTrace) {
      _logger.error('Error syncing from remote', error: e, stackTrace: stackTrace);

      // Update sync metadata with error
      await _syncMetadataDao.updateSyncFailure(
        id: syncMetadataId,
        status: SyncStatus.failed.toDbString(),
        error: e.toString(),
      );

      _logger.logDatabaseOperation('SYNC', table: 'maternity_units', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<SyncMetadata?> getSyncMetadata() async {
    final dto = await _syncMetadataDao.getById(syncMetadataId);
    if (dto == null) return null;
    return SyncMetadataMapper.toDomain(dto);
  }

  @override
  Future<bool> needsInitialLoad(int currentJsonVersion) async {
    // Check if database is empty
    final count = await _dao.getCount();
    if (count == 0) {
      _logger.debug('Database is empty, needs initial load');
      return true;
    }

    // Check if pre-packaged data version is newer
    final metadata = await _syncMetadataDao.getById(syncMetadataId);
    if (metadata == null) {
      _logger.debug('No sync metadata found, needs initial load');
      return true;
    }

    if (metadata.dataVersionCode < currentJsonVersion) {
      _logger.debug('JSON version ($currentJsonVersion) is newer than local (${metadata.dataVersionCode})');
      return true;
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // JSON Parsing Helpers
  // ---------------------------------------------------------------------------

  /// Parse a unit from pre-packaged JSON format.
  MaternityUnitDto _parseJsonUnit(Map<String, dynamic> json) {
    // Parse latitude/longitude
    double? latitude;
    double? longitude;
    
    final latValue = json['latitude'];
    final lngValue = json['longitude'];
    
    if (latValue is String) {
      latitude = double.tryParse(latValue);
    } else if (latValue is num) {
      latitude = latValue.toDouble();
    }
    
    if (lngValue is String) {
      longitude = double.tryParse(lngValue);
    } else if (lngValue is num) {
      longitude = lngValue.toDouble();
    }

    // Parse timestamps
    final createdAt = _parseTimestamp(json['created_at'] ?? json['createdAt']);
    final updatedAt = _parseTimestamp(json['updated_at'] ?? json['updatedAt']);
    final cqcSyncedAt = _parseTimestamp(json['cqc_synced_at'] ?? json['cqcSyncedAt']);

    return MaternityUnitDto(
      id: json['id'] as String,
      cqcLocationId: json['cqc_location_id'] ?? json['cqcLocationId'] as String,
      cqcProviderId: json['cqc_provider_id'] ?? json['cqcProviderId'] as String?,
      odsCode: json['ods_code'] ?? json['odsCode'] as String?,
      name: json['name'] as String,
      providerName: json['provider_name'] ?? json['providerName'] as String?,
      unitType: (json['unit_type'] ?? json['unitType'] ?? 'nhs_hospital') as String,
      isNhs: (json['is_nhs'] ?? json['isNhs'] ?? true) as bool,
      addressLine1: json['address_line_1'] ?? json['addressLine1'] as String?,
      addressLine2: json['address_line_2'] ?? json['addressLine2'] as String?,
      townCity: json['town_city'] ?? json['townCity'] as String?,
      county: json['county'] as String?,
      postcode: json['postcode'] as String?,
      region: json['region'] as String?,
      localAuthority: json['local_authority'] ?? json['localAuthority'] as String?,
      latitude: latitude,
      longitude: longitude,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      overallRating: json['overall_rating'] ?? json['overallRating'] as String?,
      ratingSafe: json['rating_safe'] ?? json['ratingSafe'] as String?,
      ratingEffective: json['rating_effective'] ?? json['ratingEffective'] as String?,
      ratingCaring: json['rating_caring'] ?? json['ratingCaring'] as String?,
      ratingResponsive: json['rating_responsive'] ?? json['ratingResponsive'] as String?,
      ratingWellLed: json['rating_well_led'] ?? json['ratingWellLed'] as String?,
      maternityRating: json['maternity_rating'] ?? json['maternityRating'] as String?,
      maternityRatingDate: json['maternity_rating_date'] ?? json['maternityRatingDate'] as String?,
      lastInspectionDate: json['last_inspection_date'] ?? json['lastInspectionDate'] as String?,
      cqcReportUrl: json['cqc_report_url'] ?? json['cqcReportUrl'] as String?,
      registrationStatus: json['registration_status'] ?? json['registrationStatus'] as String?,
      birthingOptions: null,
      facilities: null,
      birthStatistics: null,
      notes: json['notes'] as String?,
      isActive: (json['is_active'] ?? json['isActive'] ?? true) as bool,
      createdAtMillis: createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      updatedAtMillis: updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      cqcSyncedAtMillis: cqcSyncedAt?.millisecondsSinceEpoch,
    );
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
