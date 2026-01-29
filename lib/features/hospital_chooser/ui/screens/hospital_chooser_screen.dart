import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/location_service.dart' as loc;
import '../../../../domain/entities/hospital/maternity_unit.dart';
import '../../../../main.dart' show logger;
import '../../logic/hospital_location_state.dart';
import '../../logic/hospital_map_state.dart';
import '../../logic/hospital_search_state.dart';
import '../widgets/hospital_detail_overlay.dart';
import '../widgets/hospital_filters_bottom_sheet.dart';
import '../widgets/hospital_list_content.dart';
import '../widgets/hospital_location_bar.dart';
import '../widgets/hospital_map_view.dart';
import '../widgets/postcode_bottom_sheet.dart';

/// Hospital Chooser screen with map view of nearby maternity units.
///
/// Flow:
/// 1. Check for saved postcode or request location permission
/// 2. If permission denied, show postcode input bottom sheet
/// 3. Load map with nearby maternity units as pins
/// 4. Auto-expand search radius if fewer than 5 units found
class HospitalChooserScreen extends ConsumerStatefulWidget {
  const HospitalChooserScreen({super.key});

  @override
  ConsumerState<HospitalChooserScreen> createState() =>
      _HospitalChooserScreenState();
}

class _HospitalChooserScreenState extends ConsumerState<HospitalChooserScreen> {
  GoogleMapController? _mapController;
  bool _hasRequestedPermission = false;
  bool _isLoadingUnits = false;
  bool _hasCompletedInitialLoad = false;

  /// Whether showing list view (false = map view).
  bool _isListView = false;

  /// Whether the list view has been initialized (auto-expanded distance once).
  /// Prevents re-expanding distance filter when switching back to list view.
  bool _listViewInitialized = false;

  /// Set of favorite hospital IDs.
  final Set<String> _favoriteIds = {};

  /// Debounce timer for camera movement.
  Timer? _cameraIdleTimer;

  /// Debounce timer for search input.
  Timer? _searchDebounceTimer;

  /// Search text controller.
  final _searchController = TextEditingController();

  /// Focus node for search bar.
  final _searchFocusNode = FocusNode();

  /// Last known camera position (preserved when switching views).
  CameraPosition? _lastCameraPosition;

  /// Radius expansion steps in miles.
  static const List<double> _radiusSteps = [1.0, 2.0, 3.0, 5.0, 10.0, 15.0, 25.0];

  /// Minimum number of units before auto-expanding radius.
  static const int _minUnitsThreshold = 5;

  /// Track the current search radius.
  double _currentSearchRadius = 1.0;

  @override
  void initState() {
    super.initState();
    _setupSearchListener();

    // Check permission status after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPermissionState();
    });
  }

  /// Set up listener for search text changes with debouncing.
  void _setupSearchListener() {
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  /// Handle search text changes with debouncing.
  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // If query becomes empty, clear search immediately
    if (query.isEmpty) {
      _searchDebounceTimer?.cancel();
      ref.read(hospitalSearchProvider.notifier).clearSearch();
      return;
    }

    // Set active immediately when typing
    ref.read(hospitalSearchProvider.notifier).setActive(true);

    // Debounce the actual search
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final locationState = ref.read(hospitalLocationProvider);
      final mapState = ref.read(hospitalMapProvider);

      if (!locationState.hasLocation || locationState.userLocation == null) {
        return;
      }

      ref.read(hospitalSearchProvider.notifier).search(
            query: query,
            nearbyUnits: mapState.nearbyUnits,
            userLocation: locationState.userLocation!,
          );
    });
  }

  /// Handle search focus changes.
  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      ref.read(hospitalSearchProvider.notifier).setActive(true);
    } else if (!_searchFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_searchFocusNode.hasFocus) {
          ref.read(hospitalSearchProvider.notifier).setActive(false);
        }
      });
    }
  }

  /// Check if we should request permission on initial load.
  void _checkInitialPermissionState() {
    final locationReady = ref.read(hospitalLocationReadyProvider);
    if (!locationReady) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _checkInitialPermissionState();
      });
      return;
    }

    final locationState = ref.read(hospitalLocationProvider);

    if (!locationState.hasLocation &&
        locationState.canRequestPermission &&
        !_hasRequestedPermission &&
        locationState.isInitialized &&
        !locationState.isLoading) {
      logger.debug('Auto-requesting location permission on first visit');
      _requestLocationPermission();
    }
  }

  @override
  void dispose() {
    _cameraIdleTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _mapController?.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Clear search and hide overlay.
  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(hospitalSearchProvider.notifier).clearSearch();
  }

  /// Dismiss the search overlay without clearing the text.
  void _dismissSearchOverlay() {
    _searchFocusNode.unfocus();
    ref.read(hospitalSearchProvider.notifier).setActive(false);
  }

  /// Handle when a search result is selected.
  void _onSearchResultSelected(MaternityUnit unit) {
    _clearSearch();
    ref.read(hospitalMapProvider.notifier).selectUnit(unit);

    // If in map view, animate to the unit
    if (!_isListView &&
        _mapController != null &&
        unit.latitude != null &&
        unit.longitude != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(unit.latitude!, unit.longitude!),
          14.0,
        ),
      );
    }

    // Show the detail overlay for the selected unit
    final locationState = ref.read(hospitalLocationProvider);
    final distanceMiles = locationState.userLocation != null
        ? unit.distanceFrom(
            locationState.userLocation!.latitude,
            locationState.userLocation!.longitude,
          )
        : null;

    showHospitalDetailOverlay(
      context: context,
      unit: unit,
      distanceMiles: distanceMiles,
      userLat: locationState.userLocation?.latitude,
      userLng: locationState.userLocation?.longitude,
    );
  }

  /// Show the filters bottom sheet.
  void _showFiltersSheet({
    bool showDistanceFilter = false,
    loc.LatLng? sortLocation,
  }) {
    final currentFilters = ref.read(hospitalMapProvider).filters;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HospitalFiltersBottomSheet(
        currentFilters: currentFilters,
        showDistanceFilter: showDistanceFilter,
        onApply: (newFilters) async {
          final mapNotifier = ref.read(hospitalMapProvider.notifier);
          await mapNotifier.applyFilters(newFilters, sortLocation: sortLocation);
        },
      ),
    );
  }

  /// Switch to list view with auto-expanding distance.
  /// 
  /// On first visit: auto-expands distance to find at least 10 results.
  /// On subsequent visits: reloads units from user's location using current filters.
  Future<void> _switchToListView() async {
    final locationState = ref.read(hospitalLocationProvider);
    if (!locationState.hasLocation || locationState.userLocation == null) {
      setState(() => _isListView = true);
      return;
    }

    final userLocation = loc.LatLng(
      locationState.userLocation!.latitude,
      locationState.userLocation!.longitude,
    );

    if (!_listViewInitialized) {
      // First visit: auto-expand distance to find enough results
      await ref.read(hospitalMapProvider.notifier).autoExpandDistance(
            location: userLocation,
            minResults: 10,
          );
      _listViewInitialized = true;
    } else {
      // Subsequent visits: reload units from user's location with current filters
      await ref.read(hospitalMapProvider.notifier).loadNearbyUnits(userLocation);
    }

    setState(() => _isListView = true);
  }

  /// Handle location state changes and load units when ready.
  void _onLocationStateChanged(HospitalLocationState locationState) {
    if (!locationState.isInitialized || locationState.isLoading) return;

    if (locationState.hasLocation && !_isLoadingUnits) {
      _loadUnitsWithAutoExpand(locationState.userLocation!);
    } else if (locationState.wasPermissionPermanentlyDenied &&
        !locationState.hasLocation) {
      _showPostcodeSheet();
    } else if (locationState.wasPermissionDenied &&
        !locationState.hasLocation &&
        _hasRequestedPermission) {
      _showPostcodeSheet();
    }
  }

  /// Request location permission and handle the result.
  Future<void> _requestLocationPermission() async {
    setState(() => _hasRequestedPermission = true);

    final notifier = ref.read(hospitalLocationProvider.notifier);
    final granted = await notifier.requestPermission();

    if (!granted && mounted) {
      _showPostcodeSheet();
    }
  }

  /// Show the postcode input bottom sheet.
  void _showPostcodeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostcodeBottomSheet(
        onPostcodeSubmitted: (postcode) async {
          Navigator.pop(context);
          final notifier = ref.read(hospitalLocationProvider.notifier);
          final success = await notifier.setPostcode(postcode);
          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid postcode. Please try again.')),
            );
          }
        },
      ),
    );
  }

  /// Calculate appropriate zoom level for a given radius in miles.
  double _zoomForRadius(double radiusMiles) {
    if (radiusMiles <= 0.5) return 15.0;
    if (radiusMiles <= 1.0) return 14.0;
    if (radiusMiles <= 2.0) return 13.0;
    if (radiusMiles <= 3.0) return 12.5;
    if (radiusMiles <= 5.0) return 12.0;
    if (radiusMiles <= 10.0) return 11.0;
    if (radiusMiles <= 15.0) return 10.5;
    if (radiusMiles <= 25.0) return 10.0;
    return 9.0;
  }

  /// Calculate radius in miles from visible map bounds.
  double _radiusFromBounds(LatLngBounds bounds) {
    final latDiff = (bounds.northeast.latitude - bounds.southwest.latitude).abs();
    final lngDiff = (bounds.northeast.longitude - bounds.southwest.longitude).abs();

    final centerLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    final cosLat = math.cos(centerLat * math.pi / 180);

    final latMiles = latDiff * 69.0;
    final lngMiles = lngDiff * 69.0 * cosLat;

    final diagonal = math.sqrt(latMiles * latMiles + lngMiles * lngMiles);
    return (diagonal / 2) * 1.2;
  }

  /// Load units with auto-expanding radius until we have enough.
  Future<void> _loadUnitsWithAutoExpand(loc.LatLng location) async {
    if (_isLoadingUnits) return;
    setState(() => _isLoadingUnits = true);

    final mapNotifier = ref.read(hospitalMapProvider.notifier);
    double finalRadius = _radiusSteps.first;

    try {
      for (final radius in _radiusSteps) {
        logger.debug('Loading units within $radius miles');
        finalRadius = radius;

        await mapNotifier.loadNearbyUnitsWithRadius(
          location,
          radiusMiles: radius,
        );

        final state = ref.read(hospitalMapProvider);

        if (state.nearbyUnits.length >= _minUnitsThreshold) {
          logger.info('Found ${state.nearbyUnits.length} units within $radius miles');
          break;
        }

        if (radius == _radiusSteps.last) {
          logger.info('Max radius reached, found ${state.nearbyUnits.length} units');
        }
      }

      _currentSearchRadius = finalRadius;
      _animateToLocation(location, radiusMiles: finalRadius);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUnits = false;
          _hasCompletedInitialLoad = true;
        });
      }
    }
  }

  /// Handle camera movement - reload units when user pans/zooms.
  void _onCameraIdle() {
    if (!_hasCompletedInitialLoad) return;
    if (_isLoadingUnits) return;

    _cameraIdleTimer?.cancel();
    _cameraIdleTimer = Timer(const Duration(milliseconds: 500), () {
      _loadUnitsForVisibleArea();
    });
  }

  /// Load units for the current visible map area.
  /// 
  /// Uses [loadUnitsForMapViewport] to preserve user's distance filter preference.
  Future<void> _loadUnitsForVisibleArea() async {
    if (_isLoadingUnits) return;
    if (_mapController == null) return;

    setState(() => _isLoadingUnits = true);

    final mapNotifier = ref.read(hospitalMapProvider.notifier);

    try {
      final bounds = await _mapController!.getVisibleRegion();

      final center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );

      final radiusMiles = _radiusFromBounds(bounds);
      _currentSearchRadius = radiusMiles;

      final location = loc.LatLng(center.latitude, center.longitude);

      // Use viewport loading to preserve user's filter preferences
      await mapNotifier.loadUnitsForMapViewport(
        location,
        viewportRadiusMiles: radiusMiles,
      );

      logger.debug(
        'Reloaded units for visible area: center=${center.latitude}, ${center.longitude}, '
        'radius=${_currentSearchRadius.toStringAsFixed(1)} miles',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingUnits = false);
      }
    }
  }

  /// Animate map camera to the given location.
  void _animateToLocation(loc.LatLng location, {double? radiusMiles}) {
    final zoom = radiusMiles != null ? _zoomForRadius(radiusMiles) : 12.0;

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        zoom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if providers are ready
    final locationReady = ref.watch(hospitalLocationReadyProvider);
    final mapReady = ref.watch(hospitalMapReadyProvider);

    // Show loading screen while dependencies are initializing
    if (!locationReady || !mapReady) {
      return _buildLoadingScreen();
    }

    final locationState = ref.watch(hospitalLocationProvider);
    final mapState = ref.watch(hospitalMapProvider);
    final searchState = ref.watch(hospitalSearchProvider);

    // Listen for location state changes
    ref.listen<HospitalLocationState>(hospitalLocationProvider, (prev, next) {
      _onLocationStateChanged(next);
    });

    // Check if search is active (overlay visible or input focused)
    final isSearchActive = searchState.isActive || _searchFocusNode.hasFocus;

    return PopScope(
      // Allow pop only if search is not active
      canPop: !isSearchActive,
      onPopInvokedWithResult: (didPop, result) {
        // If we didn't pop (search was active), dismiss the search overlay
        if (!didPop) {
          _dismissSearchOverlay();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Location bar
            HospitalLocationBar(
              postcode: locationState.userPostcode,
              isLoading: locationState.isLoading,
              onChangeTap: _showPostcodeSheet,
            ),

            // Main content
            Expanded(
              child: _buildContent(locationState, mapState),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the loading screen while providers initialize.
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.gapLG),
            Text('Initializing...'),
          ],
        ),
      ),
    );
  }

  /// Build the app bar.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(AppIcons.back, color: AppColors.iconDefault, size: AppSpacing.iconMD,),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Find a Hospital',
        style: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build the main content (map or list view).
  Widget _buildContent(
    HospitalLocationState locationState,
    HospitalMapState mapState,
  ) {
    // Determine overlay states
    final showPermissionPrompt = !locationState.hasLocation &&
        locationState.canRequestPermission &&
        !_hasRequestedPermission &&
        !locationState.isLoading &&
        locationState.isInitialized;

    final isWaitingForLocation = !locationState.hasLocation &&
        locationState.isInitialized &&
        !locationState.isLoading;

    // Show list view if toggled and we have location
    if (_isListView && locationState.hasLocation) {
      return HospitalListContent(
        locationState: locationState,
        mapState: mapState,
        isLoadingUnits: _isLoadingUnits,
        favoriteIds: _favoriteIds,
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onFilterTap: () => _showFiltersSheet(
          showDistanceFilter: true,
          sortLocation: locationState.userLocation,
        ),
        onClearSearch: _clearSearch,
        onDismissSearch: _dismissSearchOverlay,
        onSearchResultSelected: _onSearchResultSelected,
        onHospitalTap: (unit) {
          // Calculate distance for the unit
          final distanceMiles = locationState.userLocation != null
              ? unit.distanceFrom(
                  locationState.userLocation!.latitude,
                  locationState.userLocation!.longitude,
                )
              : null;

          // Show the detail overlay directly
          showHospitalDetailOverlay(
            context: context,
            unit: unit,
            distanceMiles: distanceMiles,
            userLat: locationState.userLocation?.latitude,
            userLng: locationState.userLocation?.longitude,
          );
        },
        onFavoriteTap: (unit) {
          setState(() {
            if (_favoriteIds.contains(unit.id)) {
              _favoriteIds.remove(unit.id);
            } else {
              _favoriteIds.add(unit.id);
            }
          });
        },
        onMapViewTap: () {
          setState(() => _isListView = false);
        },
      );
    }

    // Otherwise show map view
    return HospitalMapView(
      locationState: locationState,
      mapState: mapState,
      showPermissionPrompt: showPermissionPrompt,
      isWaitingForLocation: isWaitingForLocation,
      isLoadingUnits: _isLoadingUnits,
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      lastCameraPosition: _lastCameraPosition,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onCameraMove: (position) {
        _lastCameraPosition = position;
      },
      onCameraIdle: _onCameraIdle,
      onFilterTap: _showFiltersSheet,
      onClearSearch: _clearSearch,
      onDismissSearch: _dismissSearchOverlay,
      onSearchResultSelected: _onSearchResultSelected,
      onListViewTap: _switchToListView,
      onRequestPermission: _requestLocationPermission,
      onShowPostcodeSheet: _showPostcodeSheet,
      onCenterLocation: _centerOnUserLocation,
    );
  }

  /// Center the map on the user's postcode/location.
  void _centerOnUserLocation() {
    final locationState = ref.read(hospitalLocationProvider);
    if (!locationState.hasLocation || locationState.userLocation == null) return;
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          locationState.userLocation!.latitude,
          locationState.userLocation!.longitude,
        ),
        _zoomForRadius(_currentSearchRadius),
      ),
    );
  }
}
