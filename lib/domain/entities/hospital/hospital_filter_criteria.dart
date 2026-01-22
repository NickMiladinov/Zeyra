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

/// Minimum rating filter options.
enum MinRatingFilter {
  any,
  good,
  outstanding;

  String get displayName {
    switch (this) {
      case MinRatingFilter.any:
        return 'Any Rating';
      case MinRatingFilter.good:
        return 'Good or better';
      case MinRatingFilter.outstanding:
        return 'Outstanding only';
    }
  }

  /// Check if a rating meets this minimum.
  bool meetsMinimum(CqcRating rating) {
    switch (this) {
      case MinRatingFilter.any:
        return true;
      case MinRatingFilter.good:
        return rating == CqcRating.good || rating == CqcRating.outstanding;
      case MinRatingFilter.outstanding:
        return rating == CqcRating.outstanding;
    }
  }
}

/// Filter criteria for searching hospitals.
class HospitalFilterCriteria {
  /// Maximum distance in miles from user's location.
  final double maxDistanceMiles;

  /// Minimum rating filter.
  final MinRatingFilter minRating;

  /// Include NHS hospitals.
  final bool includeNhs;

  /// Include independent/private hospitals.
  final bool includeIndependent;

  /// Sort order.
  final HospitalSortBy sortBy;

  const HospitalFilterCriteria({
    this.maxDistanceMiles = 15.0,
    this.minRating = MinRatingFilter.any,
    this.includeNhs = true,
    this.includeIndependent = true,
    this.sortBy = HospitalSortBy.distance,
  });

  /// Default filter criteria.
  static const HospitalFilterCriteria defaults = HospitalFilterCriteria();

  /// Check if any filters are active (non-default).
  bool get hasActiveFilters =>
      maxDistanceMiles != 15.0 ||
      minRating != MinRatingFilter.any ||
      !includeNhs ||
      !includeIndependent;

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

      // Check rating
      if (!minRating.meetsMinimum(unit.bestAvailableRating)) return false;

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
    MinRatingFilter? minRating,
    bool? includeNhs,
    bool? includeIndependent,
    HospitalSortBy? sortBy,
  }) {
    return HospitalFilterCriteria(
      maxDistanceMiles: maxDistanceMiles ?? this.maxDistanceMiles,
      minRating: minRating ?? this.minRating,
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
          minRating == other.minRating &&
          includeNhs == other.includeNhs &&
          includeIndependent == other.includeIndependent &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      maxDistanceMiles.hashCode ^
      minRating.hashCode ^
      includeNhs.hashCode ^
      includeIndependent.hashCode ^
      sortBy.hashCode;

  @override
  String toString() =>
      'HospitalFilterCriteria(maxDistance: $maxDistanceMiles mi, minRating: $minRating, '
      'nhs: $includeNhs, independent: $includeIndependent, sortBy: $sortBy)';
}
