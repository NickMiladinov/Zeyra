import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/main_providers.dart';
import '../../../core/services/hospital_search_service.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/hospital/hospital_search_result.dart';
import '../../../domain/entities/hospital/maternity_unit.dart';

// ----------------------------------------------------------------------------
// State Classes
// ----------------------------------------------------------------------------

/// State for hospital search functionality.
class HospitalSearchState {
  /// Current search query.
  final String query;

  /// Nearby search results (Tier 1 - in-memory fuzzy search).
  final List<HospitalSearchResult> nearbyResults;

  /// Global search results (Tier 2 - database search).
  final List<HospitalSearchResult> globalResults;

  /// Whether a search is currently in progress.
  final bool isSearching;

  /// Whether the search overlay is active/visible.
  final bool isActive;

  /// Error message if search failed.
  final String? error;

  const HospitalSearchState({
    this.query = '',
    this.nearbyResults = const [],
    this.globalResults = const [],
    this.isSearching = false,
    this.isActive = false,
    this.error,
  });

  /// Whether there are any search results.
  bool get hasResults => nearbyResults.isNotEmpty || globalResults.isNotEmpty;

  /// Whether the search has been performed but found no results.
  bool get hasNoResults =>
      query.isNotEmpty && !isSearching && !hasResults;

  /// Total number of results across both tiers.
  int get totalResultCount => nearbyResults.length + globalResults.length;

  HospitalSearchState copyWith({
    String? query,
    List<HospitalSearchResult>? nearbyResults,
    List<HospitalSearchResult>? globalResults,
    bool? isSearching,
    bool? isActive,
    String? error,
  }) {
    return HospitalSearchState(
      query: query ?? this.query,
      nearbyResults: nearbyResults ?? this.nearbyResults,
      globalResults: globalResults ?? this.globalResults,
      isSearching: isSearching ?? this.isSearching,
      isActive: isActive ?? this.isActive,
      error: error,
    );
  }

  /// Create a cleared state (but keep isActive).
  HospitalSearchState clear() {
    return HospitalSearchState(
      isActive: isActive,
    );
  }
}

// ----------------------------------------------------------------------------
// Notifier
// ----------------------------------------------------------------------------

/// Notifier for managing hospital search state.
///
/// Orchestrates tiered search using HospitalSearchService and manages
/// the search overlay UI state.
class HospitalSearchNotifier extends StateNotifier<HospitalSearchState> {
  final HospitalSearchService? _searchService;
  final bool _isLoading;

  HospitalSearchNotifier({
    required HospitalSearchService searchService,
  })  : _searchService = searchService,
        _isLoading = false,
        super(const HospitalSearchState());

  /// Creates a loading-only notifier used while dependencies are initializing.
  HospitalSearchNotifier._loading()
      : _searchService = null,
        _isLoading = true,
        super(const HospitalSearchState());

  /// Execute tiered search.
  ///
  /// [query] - Search string
  /// [nearbyUnits] - List of nearby units already loaded in memory
  /// [userLocation] - User's current location for distance calculation
  Future<void> search({
    required String query,
    required List<MaternityUnit> nearbyUnits,
    required LatLng userLocation,
  }) async {
    final searchService = _searchService;
    if (_isLoading || searchService == null) return;

    // If query is empty, clear results but keep overlay active
    if (query.trim().isEmpty) {
      state = state.copyWith(
        query: '',
        nearbyResults: [],
        globalResults: [],
        isSearching: false,
      );
      return;
    }

    // Start search
    state = state.copyWith(
      query: query,
      isSearching: true,
      isActive: true,
      error: null,
    );

    try {
      final results = await searchService.search(
        query: query,
        nearbyUnits: nearbyUnits,
        userLat: userLocation.latitude,
        userLng: userLocation.longitude,
      );

      // Only update if query hasn't changed during async operation
      if (state.query == query) {
        state = state.copyWith(
          nearbyResults: results.nearby,
          globalResults: results.global,
          isSearching: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  /// Clear search and hide overlay.
  void clearSearch() {
    state = const HospitalSearchState();
  }

  /// Set whether the search overlay is active.
  /// When deactivating, keeps the query and results so they can be shown again.
  void setActive(bool active) {
    state = state.copyWith(isActive: active);
  }

  /// Update query without triggering search (for controlled input).
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }
}

// ----------------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------------

/// Provider for HospitalSearchService.
final hospitalSearchServiceProvider =
    FutureProvider<HospitalSearchService>((ref) async {
  final repository = await ref.watch(maternityUnitRepositoryProvider.future);
  return HospitalSearchService(repository: repository);
});

/// Provider that indicates whether hospital search dependencies are ready.
final hospitalSearchReadyProvider = Provider<bool>((ref) {
  final searchServiceAsync = ref.watch(hospitalSearchServiceProvider);
  return searchServiceAsync.hasValue;
});

/// Provider for hospital search state.
final hospitalSearchProvider =
    StateNotifierProvider<HospitalSearchNotifier, HospitalSearchState>((ref) {
  final searchServiceAsync = ref.watch(hospitalSearchServiceProvider);

  // If dependencies aren't ready, return a loading notifier
  if (!searchServiceAsync.hasValue) {
    return HospitalSearchNotifier._loading();
  }

  return HospitalSearchNotifier(
    searchService: searchServiceAsync.requireValue,
  );
});
