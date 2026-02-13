import '../../domain/entities/hospital/hospital_search_result.dart';
import '../../domain/entities/hospital/maternity_unit.dart';
import '../../domain/repositories/maternity_unit_repository.dart';
import '../utils/fuzzy_search.dart';

/// Service that orchestrates tiered hospital search.
///
/// Implements a two-tier search strategy:
/// - Tier 1 (Nearby): Fuzzy search on in-memory nearby units (instant)
/// - Tier 2 (All UK): Database search for global results (async)
///
/// Results are deduplicated and grouped by tier.
class HospitalSearchService {
  final MaternityUnitRepository _repository;

  /// Maximum results to return from nearby (Tier 1) search.
  static const int maxNearbyResults = 5;

  /// Maximum results to return from global (Tier 2) search.
  static const int maxGlobalResults = 10;

  HospitalSearchService({
    required MaternityUnitRepository repository,
  }) : _repository = repository;

  /// Execute tiered search.
  ///
  /// [query] - Search string
  /// [nearbyUnits] - List of nearby units already loaded in memory
  /// [userLat] - User's latitude for distance calculation
  /// [userLng] - User's longitude for distance calculation
  ///
  /// Returns a record containing nearby and global results separately.
  Future<({List<HospitalSearchResult> nearby, List<HospitalSearchResult> global})> search({
    required String query,
    required List<MaternityUnit> nearbyUnits,
    required double userLat,
    required double userLng,
  }) async {
    if (query.trim().isEmpty) {
      return (nearby: <HospitalSearchResult>[], global: <HospitalSearchResult>[]);
    }

    final nearbyIds = <String>{};

    // ─────────────────────────────────────────────────────────────────────────
    // TIER 1: Search nearby units (in-memory, instant)
    // ─────────────────────────────────────────────────────────────────────────
    final nearbyResults = _searchNearby(
      query: query,
      nearbyUnits: nearbyUnits,
      userLat: userLat,
      userLng: userLng,
    );

    // Track nearby IDs for deduplication
    for (final result in nearbyResults) {
      nearbyIds.add(result.unit.id);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TIER 2: Search global database (async)
    // ─────────────────────────────────────────────────────────────────────────
    final globalResults = await _searchGlobal(
      query: query,
      excludeIds: nearbyIds,
      userLat: userLat,
      userLng: userLng,
    );

    return (nearby: nearbyResults, global: globalResults);
  }

  /// Search nearby units using fuzzy matching (Tier 1).
  List<HospitalSearchResult> _searchNearby({
    required String query,
    required List<MaternityUnit> nearbyUnits,
    required double userLat,
    required double userLng,
  }) {
    // Use fuzzy search with scores
    final matches = FuzzySearch.searchWithScores(
      items: nearbyUnits,
      query: query,
      getText: (unit) => _getSearchableText(unit),
    );

    // Convert to HospitalSearchResult with distance
    final results = matches.map((match) {
      return HospitalSearchResult(
        unit: match.item,
        score: match.score,
        tier: SearchTier.nearby,
        distanceMiles: match.item.distanceFrom(userLat, userLng),
      );
    }).toList();

    // Sort by score first, then by distance as tiebreaker
    results.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      
      final distA = a.distanceMiles ?? double.infinity;
      final distB = b.distanceMiles ?? double.infinity;
      return distA.compareTo(distB);
    });

    // Return top results
    return results.take(maxNearbyResults).toList();
  }

  /// Search global database (Tier 2).
  Future<List<HospitalSearchResult>> _searchGlobal({
    required String query,
    required Set<String> excludeIds,
    required double userLat,
    required double userLng,
  }) async {
    // Over-fetch to account for deduplication and sorting
    final fetchLimit = (maxGlobalResults + excludeIds.length) * 3;

    final units = await _repository.searchByName(query, limit: fetchLimit);

    final results = <HospitalSearchResult>[];

    for (final unit in units) {
      // Skip if already in nearby results
      if (excludeIds.contains(unit.id)) continue;

      // Calculate a score for database results using fuzzy matching
      final score = _calculateDatabaseScore(query, unit);
      
      // Skip if score is too low
      if (score < FuzzySearch.minScoreThreshold) continue;

      results.add(HospitalSearchResult(
        unit: unit,
        score: score,
        tier: SearchTier.allUk,
        distanceMiles: unit.distanceFrom(userLat, userLng),
      ));
    }

    // Sort by score (descending) first, then by distance (ascending) as tiebreaker
    results.sort((a, b) {
      // Primary sort: score (higher is better)
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      
      // Secondary sort: distance (closer is better)
      final distA = a.distanceMiles ?? double.infinity;
      final distB = b.distanceMiles ?? double.infinity;
      return distA.compareTo(distB);
    });

    // Return top results
    return results.take(maxGlobalResults).toList();
  }

  /// Get searchable text for a maternity unit.
  ///
  /// Combines name, town/city, and postcode for comprehensive matching.
  String _getSearchableText(MaternityUnit unit) {
    final parts = <String>[unit.name];
    if (unit.townCity != null) parts.add(unit.townCity!);
    if (unit.postcode != null) parts.add(unit.postcode!);
    return parts.join(' ');
  }

  /// Calculate a score for database results.
  ///
  /// Since these don't go through fuzzy search, we compute a simple score
  /// based on how well the query matches the name.
  double _calculateDatabaseScore(String query, MaternityUnit unit) {
    final normalizedQuery = FuzzySearch.normalize(query);
    final normalizedName = FuzzySearch.normalize(unit.name);

    return FuzzySearch.calculateScore(normalizedQuery, normalizedName);
  }
}
