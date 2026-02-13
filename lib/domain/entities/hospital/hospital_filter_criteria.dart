import 'maternity_unit.dart';

/// Sort options for hospital list.
enum HospitalSortBy {
  distance,
  rating,
  name;

  String get displayName {
    switch (this) {
      case HospitalSortBy.distance:
        return 'Distance';
      case HospitalSortBy.rating:
        return 'Rating';
      case HospitalSortBy.name:
        return 'Name';
    }
  }
}

/// Filter criteria for searching hospitals.
class HospitalFilterCriteria {
  /// Maximum distance in miles from user's location.
  final double maxDistanceMiles;

  /// Set of allowed CQC ratings.
  /// If empty or contains all ratings, no rating filter is applied.
  final Set<CqcRating> allowedRatings;

  /// Include NHS hospitals.
  final bool includeNhs;

  /// Include independent/private hospitals.
  final bool includeIndependent;

  /// Sort order.
  final HospitalSortBy sortBy;

  /// All CQC ratings that can be filtered.
  static const Set<CqcRating> allRatings = {
    CqcRating.outstanding,
    CqcRating.good,
    CqcRating.requiresImprovement,
    CqcRating.inadequate,
  };

  const HospitalFilterCriteria({
    this.maxDistanceMiles = 15.0,
    this.allowedRatings = allRatings,
    this.includeNhs = true,
    this.includeIndependent = true,
    this.sortBy = HospitalSortBy.distance,
  });

  /// Default filter criteria.
  static const HospitalFilterCriteria defaults = HospitalFilterCriteria();

  /// Check if any rating filters are active.
  bool get hasRatingFilter => 
      allowedRatings.isNotEmpty && 
      !_setEquals(allowedRatings, allRatings);

  /// Check if any filters are active (non-default).
  bool get hasActiveFilters =>
      maxDistanceMiles != 15.0 ||
      hasRatingFilter ||
      !includeNhs ||
      !includeIndependent;
  
  /// Get display name for the active rating filter.
  String get ratingFilterDisplayName {
    if (!hasRatingFilter) return 'Any Rating';
    if (allowedRatings.length == 1) {
      return allowedRatings.first.displayName;
    }
    // Show the "best" rating in the selection
    if (allowedRatings.contains(CqcRating.outstanding) && 
        allowedRatings.contains(CqcRating.good) &&
        allowedRatings.length == 2) {
      return 'Good or better';
    }
    return '${allowedRatings.length} ratings';
  }
  
  /// Helper to compare sets for equality.
  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.every((element) => b.contains(element));
  }

  /// Apply filters to a list of units with distances.
  List<MaternityUnit> apply(
    List<MaternityUnit> units,
    double userLat,
    double userLng,
  ) {
    var filtered = units.where((unit) {
      // Check validity
      if (!unit.isValid) return false;

      // Check NHS/independent filter
      if (unit.isNhs && !includeNhs) return false;
      if (!unit.isNhs && !includeIndependent) return false;

      // Check distance
      final distance = unit.distanceFrom(userLat, userLng);
      if (distance == null || distance > maxDistanceMiles) return false;

      // Check rating filter
      if (hasRatingFilter && !allowedRatings.contains(unit.bestAvailableRating)) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    switch (sortBy) {
      case HospitalSortBy.distance:
        filtered.sort((a, b) {
          final distA = a.distanceFrom(userLat, userLng) ?? double.infinity;
          final distB = b.distanceFrom(userLat, userLng) ?? double.infinity;
          return distA.compareTo(distB);
        });
        break;
      case HospitalSortBy.rating:
        filtered.sort((a, b) {
          // Sort by rating descending (better ratings first)
          final ratingA = a.bestAvailableRating.sortValue;
          final ratingB = b.bestAvailableRating.sortValue;
          final ratingCompare = ratingB.compareTo(ratingA);
          if (ratingCompare != 0) return ratingCompare;
          // Secondary sort by distance
          final distA = a.distanceFrom(userLat, userLng) ?? double.infinity;
          final distB = b.distanceFrom(userLat, userLng) ?? double.infinity;
          return distA.compareTo(distB);
        });
        break;
      case HospitalSortBy.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  HospitalFilterCriteria copyWith({
    double? maxDistanceMiles,
    Set<CqcRating>? allowedRatings,
    bool? includeNhs,
    bool? includeIndependent,
    HospitalSortBy? sortBy,
  }) {
    return HospitalFilterCriteria(
      maxDistanceMiles: maxDistanceMiles ?? this.maxDistanceMiles,
      allowedRatings: allowedRatings ?? this.allowedRatings,
      includeNhs: includeNhs ?? this.includeNhs,
      includeIndependent: includeIndependent ?? this.includeIndependent,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalFilterCriteria &&
          runtimeType == other.runtimeType &&
          maxDistanceMiles == other.maxDistanceMiles &&
          _setEquals(allowedRatings, other.allowedRatings) &&
          includeNhs == other.includeNhs &&
          includeIndependent == other.includeIndependent &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      maxDistanceMiles.hashCode ^
      Object.hashAll(allowedRatings) ^
      includeNhs.hashCode ^
      includeIndependent.hashCode ^
      sortBy.hashCode;

  @override
  String toString() =>
      'HospitalFilterCriteria(maxDistance: $maxDistanceMiles mi, ratings: $allowedRatings, '
      'nhs: $includeNhs, independent: $includeIndependent, sortBy: $sortBy)';
}
