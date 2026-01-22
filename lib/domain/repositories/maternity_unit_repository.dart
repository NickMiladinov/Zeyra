import '../entities/hospital/hospital_filter_criteria.dart';
import '../entities/hospital/maternity_unit.dart';
import '../entities/hospital/sync_metadata.dart';

/// Repository interface for maternity unit data operations.
///
/// Provides access to maternity unit data with support for local caching,
/// remote sync, and geospatial queries.
abstract class MaternityUnitRepository {
  // ---------------------------------------------------------------------------
  // Query Operations
  // ---------------------------------------------------------------------------

  /// Get all valid maternity units within a radius of the given coordinates.
  ///
  /// Uses bounding box pre-filtering for efficiency, then applies Haversine
  /// distance calculation for accurate results.
  ///
  /// [lat] - User's latitude
  /// [lng] - User's longitude
  /// [radiusMiles] - Search radius in miles (default: 15)
  ///
  /// Returns units sorted by distance (nearest first).
  Future<List<MaternityUnit>> getNearbyUnits(
    double lat,
    double lng, {
    double radiusMiles = 15.0,
  });

  /// Get maternity units matching the given filter criteria.
  ///
  /// [criteria] - Filter and sort options
  /// [userLat] - User's latitude for distance calculation
  /// [userLng] - User's longitude for distance calculation
  ///
  /// Returns filtered and sorted list of units.
  Future<List<MaternityUnit>> getFilteredUnits(
    HospitalFilterCriteria criteria,
    double userLat,
    double userLng,
  );

  /// Get a single maternity unit by its ID.
  ///
  /// Returns null if not found.
  Future<MaternityUnit?> getUnitById(String id);

  /// Get a single maternity unit by its CQC location ID.
  ///
  /// Returns null if not found.
  Future<MaternityUnit?> getUnitByCqcId(String cqcLocationId);

  /// Get the total count of maternity units in the local database.
  Future<int> getUnitCount();

  // ---------------------------------------------------------------------------
  // Sync Operations
  // ---------------------------------------------------------------------------

  /// Load pre-packaged maternity unit data from app assets.
  ///
  /// Called on first app launch to populate the local database with
  /// bundled JSON data. Sets the sync timestamp to the JSON export date.
  ///
  /// [jsonVersion] - Version code from the JSON file
  /// [exportedAt] - When the JSON was exported from Supabase
  Future<void> loadFromAssets(int jsonVersion, DateTime exportedAt);

  /// Perform incremental sync from Supabase.
  ///
  /// Fetches records updated since the last sync and upserts them locally.
  Future<void> syncFromRemote();

  /// Get sync metadata for maternity units.
  Future<SyncMetadata?> getSyncMetadata();

  /// Check if initial data load is needed.
  ///
  /// Returns true if the database is empty or has outdated pre-packaged data.
  Future<bool> needsInitialLoad(int currentJsonVersion);
}
