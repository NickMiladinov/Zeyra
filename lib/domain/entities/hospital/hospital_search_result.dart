import 'maternity_unit.dart';

/// Tier indicating the source of a search result.
enum SearchTier {
  /// Nearby results from in-memory filtered list (instant).
  nearby,

  /// Global results from database search (all UK).
  allUk;

  /// Display name for the tier.
  String get displayName {
    switch (this) {
      case SearchTier.nearby:
        return 'Nearby';
      case SearchTier.allUk:
        return 'Other Locations';
    }
  }
}

/// A search result combining a maternity unit with search metadata.
///
/// Used to display grouped search results with relevance scoring
/// and tier information for UI grouping.
class HospitalSearchResult {
  /// The matched maternity unit.
  final MaternityUnit unit;

  /// Relevance score from fuzzy matching (0.0 to 1.0).
  /// Higher score = better match.
  final double score;

  /// Which tier this result came from.
  final SearchTier tier;

  /// Distance from user in miles (if location available).
  final double? distanceMiles;

  const HospitalSearchResult({
    required this.unit,
    required this.score,
    required this.tier,
    this.distanceMiles,
  });

  /// Create a copy with updated fields.
  HospitalSearchResult copyWith({
    MaternityUnit? unit,
    double? score,
    SearchTier? tier,
    double? distanceMiles,
  }) {
    return HospitalSearchResult(
      unit: unit ?? this.unit,
      score: score ?? this.score,
      tier: tier ?? this.tier,
      distanceMiles: distanceMiles ?? this.distanceMiles,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalSearchResult &&
          runtimeType == other.runtimeType &&
          unit.id == other.unit.id &&
          tier == other.tier;

  @override
  int get hashCode => unit.id.hashCode ^ tier.hashCode;

  @override
  String toString() =>
      'HospitalSearchResult(unit: ${unit.name}, score: $score, tier: $tier, distance: $distanceMiles)';
}
