import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';

/// Remote data source for fetching maternity units from Supabase.
///
/// Handles communication with the Supabase `maternity_units` table,
/// including fetching all records and incremental sync.
class MaternityUnitRemoteSource {
  final SupabaseClient _client;
  final Uuid _uuid;

  MaternityUnitRemoteSource({
    SupabaseClient? client,
    Uuid? uuid,
  })  : _client = client ?? Supabase.instance.client,
        _uuid = uuid ?? const Uuid();

  /// Table name in Supabase.
  static const String tableName = 'maternity_units';

  /// Fetch all maternity units from Supabase.
  ///
  /// Used for full sync or when local database is empty.
  /// Returns a list of DTOs ready for insertion into local database.
  Future<List<MaternityUnitDto>> fetchAll() async {
    final response = await _client
        .from(tableName)
        .select()
        .order('name', ascending: true);

    return _parseResponse(response);
  }

  /// Fetch maternity units updated since the given timestamp.
  ///
  /// Used for incremental sync to get only changed records.
  /// [since] - Fetch records with updated_at > this timestamp.
  Future<List<MaternityUnitDto>> fetchUpdatedSince(DateTime since) async {
    final response = await _client
        .from(tableName)
        .select()
        .gt('updated_at', since.toUtc().toIso8601String())
        .order('updated_at', ascending: true);

    return _parseResponse(response);
  }

  /// Fetch a single maternity unit by ID.
  Future<MaternityUnitDto?> fetchById(String id) async {
    final response = await _client
        .from(tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _parseRow(response);
  }

  /// Parse Supabase response into list of DTOs.
  List<MaternityUnitDto> _parseResponse(List<Map<String, dynamic>> data) {
    return data.map(_parseRow).toList();
  }

  /// Parse a single row from Supabase into a DTO.
  ///
  /// Handles the conversion of Supabase's snake_case fields and
  /// string timestamps to Drift's expected format.
  MaternityUnitDto _parseRow(Map<String, dynamic> row) {
    // Parse latitude/longitude - Supabase returns numeric columns as double
    final latitude = _parseDouble(row['latitude']);
    final longitude = _parseDouble(row['longitude']);

    // Parse timestamps
    final createdAt = _parseTimestamp(row['created_at'] as String?);
    final updatedAt = _parseTimestamp(row['updated_at'] as String?);
    final cqcSyncedAt = _parseTimestamp(row['cqc_synced_at'] as String?);
    final placeSyncedAt = _parseTimestamp(row['place_synced_at'] as String?);

    // Parse PLACE ratings (stored as DECIMAL in Supabase)
    final placeCleanliness = _parseDouble(row['place_cleanliness']);
    final placeFood = _parseDouble(row['place_food']);
    final placePrivacyDignityWellbeing =
        _parseDouble(row['place_privacy_dignity_wellbeing']);
    final placeConditionAppearance =
        _parseDouble(row['place_condition_appearance']);

    // Parse facilities and birth_statistics (stored as JSONB in Supabase)
    String? facilitiesJson;
    String? birthStatisticsJson;
    
    if (row['facilities'] != null) {
      final facilities = row['facilities'];
      if (facilities is Map && facilities.isNotEmpty) {
        facilitiesJson = facilities.toString();
      }
    }
    
    if (row['birth_statistics'] != null) {
      final birthStats = row['birth_statistics'];
      if (birthStats is Map && birthStats.isNotEmpty) {
        birthStatisticsJson = birthStats.toString();
      }
    }

    // Parse birthing_options (stored as TEXT[] in Supabase)
    String? birthingOptionsJson;
    if (row['birthing_options'] != null) {
      final options = row['birthing_options'];
      if (options is List && options.isNotEmpty) {
        birthingOptionsJson = options.toString();
      }
    }

    return MaternityUnitDto(
      // Use Supabase ID if available, otherwise generate one
      id: row['id'] as String? ?? _uuid.v4(),
      cqcLocationId: row['cqc_location_id'] as String,
      cqcProviderId: row['cqc_provider_id'] as String?,
      odsCode: row['ods_code'] as String?,
      name: row['name'] as String,
      providerName: row['provider_name'] as String?,
      unitType: row['unit_type'] as String? ?? 'nhs_hospital',
      isNhs: row['is_nhs'] as bool? ?? true,
      addressLine1: row['address_line_1'] as String?,
      addressLine2: row['address_line_2'] as String?,
      townCity: row['town_city'] as String?,
      county: row['county'] as String?,
      postcode: row['postcode'] as String?,
      region: row['region'] as String?,
      localAuthority: row['local_authority'] as String?,
      latitude: latitude,
      longitude: longitude,
      phone: row['phone'] as String?,
      website: row['website'] as String?,
      overallRating: row['overall_rating'] as String?,
      ratingSafe: row['rating_safe'] as String?,
      ratingEffective: row['rating_effective'] as String?,
      ratingCaring: row['rating_caring'] as String?,
      ratingResponsive: row['rating_responsive'] as String?,
      ratingWellLed: row['rating_well_led'] as String?,
      maternityRating: row['maternity_rating'] as String?,
      maternityRatingDate: row['maternity_rating_date'] as String?,
      lastInspectionDate: row['last_inspection_date'] as String?,
      cqcReportUrl: row['cqc_report_url'] as String?,
      registrationStatus: row['registration_status'] as String?,
      birthingOptions: birthingOptionsJson,
      facilities: facilitiesJson,
      birthStatistics: birthStatisticsJson,
      notes: row['notes'] as String?,
      isActive: row['is_active'] as bool? ?? true,
      createdAtMillis: createdAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      updatedAtMillis: updatedAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      cqcSyncedAtMillis: cqcSyncedAt?.millisecondsSinceEpoch,
      placeCleanliness: placeCleanliness,
      placeFood: placeFood,
      placePrivacyDignityWellbeing: placePrivacyDignityWellbeing,
      placeConditionAppearance: placeConditionAppearance,
      placeSyncedAtMillis: placeSyncedAt?.millisecondsSinceEpoch,
    );
  }

  /// Parse ISO 8601 timestamp string to DateTime.
  DateTime? _parseTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return null;
    try {
      return DateTime.parse(timestamp);
    } catch (_) {
      return null;
    }
  }

  /// Parse a value to double, handling both String and numeric types.
  ///
  /// Supabase returns numeric columns as double, but older data
  /// may have been stored as strings.
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
