import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/location_service.dart' as loc;
import '../../../../domain/entities/hospital/hospital_filter_criteria.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';
import '../../../../main.dart' show logger;
import '../../logic/hospital_location_state.dart';
import '../../logic/hospital_map_state.dart';
import '../widgets/custom_map_marker.dart';
import '../widgets/hospital_filters_bottom_sheet.dart';
import '../widgets/hospital_list_view.dart';
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
  ConsumerState<HospitalChooserScreen> createState() => _HospitalChooserScreenState();
}

class _HospitalChooserScreenState extends ConsumerState<HospitalChooserScreen> {
  GoogleMapController? _mapController;
  bool _hasRequestedPermission = false;
  bool _isLoadingUnits = false;
  bool _hasCompletedInitialLoad = false;
  
  /// Whether showing list view (false = map view).
  bool _isListView = false;
  
  /// Set of favorite hospital IDs.
  final Set<String> _favoriteIds = {};
  
  /// Debounce timer for camera movement
  Timer? _cameraIdleTimer;
  
  /// Custom marker icons
  BitmapDescriptor? _defaultMarkerIcon;
  BitmapDescriptor? _selectedMarkerIcon;
  
  /// Search text controller
  final _searchController = TextEditingController();
  
  /// Last known camera position (preserved when switching views).
  CameraPosition? _lastCameraPosition;

  /// Radius expansion steps in miles (start at 1 mile for dense city areas)
  static const List<double> _radiusSteps = [1.0, 2.0, 3.0, 5.0, 10.0, 15.0, 25.0];
  
  /// Minimum number of units before auto-expanding radius
  static const int _minUnitsThreshold = 5;
  
  /// Track the current search radius (updated after auto-expand)
  double _currentSearchRadius = 1.0;
  
  /// Default location (Central London - Trafalgar Square area)
  static const LatLng _defaultLondonLocation = LatLng(51.5074, -0.1278);
  
  /// Calculate appropriate zoom level for a given radius in miles.
  /// 
  /// Uses approximation: at zoom 15, ~0.5 mile visible width
  /// Each zoom level doubles/halves the visible area.
  double _zoomForRadius(double radiusMiles) {
    // Base: zoom 15 shows about 0.5 mile radius
    // Each zoom level change doubles/halves the visible area
    // zoom = 15 - log2(radius / 0.5)
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
    // Calculate the width/height of the visible area in degrees
    final latDiff = (bounds.northeast.latitude - bounds.southwest.latitude).abs();
    final lngDiff = (bounds.northeast.longitude - bounds.southwest.longitude).abs();
    
    // Convert to approximate miles (1 degree latitude ≈ 69 miles)
    // For longitude, adjust by cos(latitude)
    final centerLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    final cosLat = math.cos(centerLat * math.pi / 180);
    
    final latMiles = latDiff * 69.0;
    final lngMiles = lngDiff * 69.0 * cosLat;
    
    // Use half the diagonal as the effective radius, with some buffer
    final diagonal = math.sqrt(latMiles * latMiles + lngMiles * lngMiles);
    return (diagonal / 2) * 1.2; // 20% buffer to ensure coverage
  }

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    
    // Check permission status after first frame to handle initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPermissionState();
    });
  }
  
  /// Check if we should request permission on initial load.
  void _checkInitialPermissionState() {
    // Wait for providers to be ready
    final locationReady = ref.read(hospitalLocationReadyProvider);
    if (!locationReady) {
      // Try again after a short delay if not ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _checkInitialPermissionState();
      });
      return;
    }
    
    final locationState = ref.read(hospitalLocationProvider);
    
    // If no location and permission can be requested, request it
    if (!locationState.hasLocation && 
        locationState.canRequestPermission &&
        !_hasRequestedPermission &&
        locationState.isInitialized &&
        !locationState.isLoading) {
      logger.debug('Auto-requesting location permission on first visit');
      _requestLocationPermission();
    }
  }
  
  /// Load custom marker icons asynchronously.
  Future<void> _loadCustomMarkers() async {
    _defaultMarkerIcon = await CustomMapMarker.getDefaultMarker();
    _selectedMarkerIcon = await CustomMapMarker.getSelectedMarker();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraIdleTimer?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  /// Show the filters bottom sheet.
  /// 
  /// [showDistanceFilter] - Whether to show the distance filter (only for list view).
  /// [sortLocation] - Optional location to use for sorting (for list view).
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

  /// Handle location state changes and load units when ready.
  void _onLocationStateChanged(HospitalLocationState locationState) {
    if (!locationState.isInitialized || locationState.isLoading) return;

    // If we have a location, load units
    if (locationState.hasLocation && !_isLoadingUnits) {
      _loadUnitsWithAutoExpand(locationState.userLocation!);
    }
    // If permission was permanently denied (can't ask again), show postcode sheet
    else if (locationState.wasPermissionPermanentlyDenied && 
             !locationState.hasLocation) {
      _showPostcodeSheet();
    }
    // If permission was just denied (after we requested), show postcode sheet
    else if (locationState.wasPermissionDenied && 
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
        
        // Update filters with new radius and load
        await mapNotifier.loadNearbyUnitsWithRadius(
          location,
          radiusMiles: radius,
        );
        
        final state = ref.read(hospitalMapProvider);
        
        // If we have enough valid units, stop expanding
        if (state.nearbyUnits.length >= _minUnitsThreshold) {
          logger.info('Found ${state.nearbyUnits.length} units within $radius miles');
          break;
        }
        
        // If this is the last radius step, accept whatever we have
        if (radius == _radiusSteps.last) {
          logger.info('Max radius reached, found ${state.nearbyUnits.length} units');
        }
      }
      
      // Store the final radius used for subsequent camera movements
      _currentSearchRadius = finalRadius;
      
      // Center map on user location with appropriate zoom for the radius
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
    // Skip if initial load hasn't completed yet
    if (!_hasCompletedInitialLoad) return;
    
    // Skip if already loading
    if (_isLoadingUnits) return;
    
    // Debounce rapid camera movements
    _cameraIdleTimer?.cancel();
    _cameraIdleTimer = Timer(const Duration(milliseconds: 500), () {
      _loadUnitsForVisibleArea();
    });
  }

  /// Load units for the current visible map area (after pan/zoom).
  Future<void> _loadUnitsForVisibleArea() async {
    if (_isLoadingUnits) return;
    if (_mapController == null) return;
    
    setState(() => _isLoadingUnits = true);

    final mapNotifier = ref.read(hospitalMapProvider.notifier);
    
    try {
      // Get the visible region bounds
      final bounds = await _mapController!.getVisibleRegion();
      
      // Calculate center and radius from visible bounds
      final center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      
      // Calculate radius from bounds to cover the visible area
      final radiusMiles = _radiusFromBounds(bounds);
      _currentSearchRadius = radiusMiles;
      
      // Convert to loc.LatLng for the service
      final location = loc.LatLng(center.latitude, center.longitude);
      
      await mapNotifier.loadNearbyUnitsWithRadius(
        location,
        radiusMiles: radiusMiles,
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
  /// 
  /// [radiusMiles] - If provided, calculates appropriate zoom level for the radius.
  void _animateToLocation(loc.LatLng location, {double? radiusMiles}) {
    final zoom = radiusMiles != null ? _zoomForRadius(radiusMiles) : 12.0;
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        zoom,
      ),
    );
  }

  /// Maximum number of markers to show before clustering is required.
  /// This is the target for visible markers (clusters + individual pins).
  static const int _maxVisibleMarkers = 50;
  
  /// Cluster markers cache.
  final Map<String, BitmapDescriptor> _clusterIcons = {};
  
  /// Current zoom level (updated on camera move).
  double _currentZoom = 12.0;

  /// Build map markers from maternity units with zoom-aware clustering.
  Set<Marker> _buildMarkers(List<MaternityUnit> units, MaternityUnit? selected) {
    // Fallback to default markers if custom ones aren't loaded yet
    final defaultIcon = _defaultMarkerIcon ?? 
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    final selectedIcon = _selectedMarkerIcon ?? 
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    
    // Filter out units without valid coordinates
    final validUnits = units.where((u) => u.latitude != null && u.longitude != null).toList();
    
    // If we have few enough units, show them all individually without clustering
    if (validUnits.length <= _maxVisibleMarkers) {
      return _buildIndividualMarkers(validUnits, selected, defaultIcon, selectedIcon);
    }
    
    // Otherwise use zoom-aware clustering
    return _buildZoomAwareClusteredMarkers(validUnits, selected, defaultIcon, selectedIcon);
  }
  
  /// Build individual markers for each unit (no clustering).
  Set<Marker> _buildIndividualMarkers(
    List<MaternityUnit> units,
    MaternityUnit? selected,
    BitmapDescriptor defaultIcon,
    BitmapDescriptor selectedIcon,
  ) {
    return units.map((unit) {
      final isSelected = selected?.id == unit.id;
      
      return Marker(
        markerId: MarkerId(unit.id),
        position: LatLng(unit.latitude!, unit.longitude!),
        icon: isSelected ? selectedIcon : defaultIcon,
        anchor: const Offset(0.5, 1.0),
        onTap: () {
          ref.read(hospitalMapProvider.notifier).selectUnit(unit);
        },
        infoWindow: InfoWindow(
          title: unit.name,
          snippet: unit.bestAvailableRating.displayName,
        ),
      );
    }).toSet();
  }
  
  /// Calculate grid size based on current zoom level.
  /// 
  /// At higher zoom levels (zoomed in), use smaller grid cells.
  /// At lower zoom levels (zoomed out), use larger grid cells.
  double _gridSizeForZoom(double zoom) {
    // Base: at zoom 14, use 0.01 degrees (~1km grid)
    // Each zoom level change doubles/halves the grid size
    // zoom 14 -> 0.01, zoom 13 -> 0.02, zoom 12 -> 0.04, etc.
    final baseGridSize = 0.01;
    final zoomDiff = 14.0 - zoom;
    return baseGridSize * math.pow(2, zoomDiff);
  }
  
  /// Build markers with zoom-aware clustering.
  /// 
  /// Grid size adjusts based on zoom level so clusters merge when zooming out.
  Set<Marker> _buildZoomAwareClusteredMarkers(
    List<MaternityUnit> units,
    MaternityUnit? selected,
    BitmapDescriptor defaultIcon,
    BitmapDescriptor selectedIcon,
  ) {
    if (units.isEmpty) return {};
    
    // Calculate grid size based on current zoom
    final gridSize = _gridSizeForZoom(_currentZoom);
    
    // Group units by grid cell
    final Map<String, List<MaternityUnit>> clusters = {};
    
    for (final unit in units) {
      final gridX = (unit.latitude! / gridSize).floor();
      final gridY = (unit.longitude! / gridSize).floor();
      final key = '$gridX,$gridY';
      
      clusters.putIfAbsent(key, () => []).add(unit);
    }
    
    // If we still have too many markers, merge clusters recursively
    var mergedClusters = clusters;
    var currentGridSize = gridSize;
    
    while (mergedClusters.length > _maxVisibleMarkers && currentGridSize < 2.0) {
      currentGridSize *= 2;
      mergedClusters = _mergeClusters(mergedClusters, currentGridSize);
    }
    
    final markers = <Marker>{};
    
    for (final entry in mergedClusters.entries) {
      final clusterUnits = entry.value;
      
      if (clusterUnits.length == 1) {
        // Single unit - show normal marker
        final unit = clusterUnits.first;
        final isSelected = selected?.id == unit.id;
        
        markers.add(Marker(
          markerId: MarkerId(unit.id),
          position: LatLng(unit.latitude!, unit.longitude!),
          icon: isSelected ? selectedIcon : defaultIcon,
          anchor: const Offset(0.5, 1.0),
          onTap: () {
            ref.read(hospitalMapProvider.notifier).selectUnit(unit);
          },
          infoWindow: InfoWindow(
            title: unit.name,
            snippet: unit.bestAvailableRating.displayName,
          ),
        ));
      } else {
        // Multiple units - show cluster marker
        // Calculate cluster center
        double sumLat = 0, sumLng = 0;
        for (final unit in clusterUnits) {
          sumLat += unit.latitude!;
          sumLng += unit.longitude!;
        }
        final centerLat = sumLat / clusterUnits.length;
        final centerLng = sumLng / clusterUnits.length;
        
        // Get cluster icon (we'll use a cached version or fallback)
        final clusterIcon = _clusterIcons[clusterUnits.length.toString()] ?? defaultIcon;
        
        // Async load cluster icon if not cached
        if (!_clusterIcons.containsKey(clusterUnits.length.toString())) {
          _loadClusterIcon(clusterUnits.length);
        }
        
        markers.add(Marker(
          markerId: MarkerId('cluster_${entry.key}'),
          position: LatLng(centerLat, centerLng),
          icon: clusterIcon,
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            // Zoom in to the cluster area - calculate appropriate zoom
            final targetZoom = math.min(_currentZoom + 2, 15.0);
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(centerLat, centerLng),
                targetZoom,
              ),
            );
          },
          infoWindow: InfoWindow(
            title: '${clusterUnits.length} hospitals',
            snippet: 'Tap to zoom in',
          ),
        ));
      }
    }
    
    return markers;
  }
  
  /// Merge existing clusters into larger grid cells.
  Map<String, List<MaternityUnit>> _mergeClusters(
    Map<String, List<MaternityUnit>> clusters,
    double newGridSize,
  ) {
    final merged = <String, List<MaternityUnit>>{};
    
    for (final clusterUnits in clusters.values) {
      // Calculate center of this cluster
      double sumLat = 0, sumLng = 0;
      for (final unit in clusterUnits) {
        sumLat += unit.latitude!;
        sumLng += unit.longitude!;
      }
      final centerLat = sumLat / clusterUnits.length;
      final centerLng = sumLng / clusterUnits.length;
      
      // Assign to new grid cell
      final gridX = (centerLat / newGridSize).floor();
      final gridY = (centerLng / newGridSize).floor();
      final key = '$gridX,$gridY';
      
      merged.putIfAbsent(key, () => []).addAll(clusterUnits);
    }
    
    return merged;
  }
  
  /// Load cluster icon asynchronously.
  Future<void> _loadClusterIcon(int count) async {
    final icon = await CustomMapMarker.getClusterMarker(count);
    if (mounted) {
      setState(() {
        _clusterIcons[count.toString()] = icon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if providers are ready before accessing them
    final locationReady = ref.watch(hospitalLocationReadyProvider);
    final mapReady = ref.watch(hospitalMapReadyProvider);

    // Show loading screen while dependencies are initializing
    if (!locationReady || !mapReady) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Find a Hospital',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
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

    final locationState = ref.watch(hospitalLocationProvider);
    final mapState = ref.watch(hospitalMapProvider);

    // Listen for location state changes
    ref.listen<HospitalLocationState>(hospitalLocationProvider, (prev, next) {
      _onLocationStateChanged(next);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Find a Hospital',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Location bar
          _LocationBar(
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
    );
  }

  Widget _buildContent(HospitalLocationState locationState, HospitalMapState mapState) {
    // Determine if we should show permission prompt overlay
    // Show if: no location, permission can be requested, haven't requested yet, not loading, initialized
    final showPermissionPrompt = !locationState.hasLocation && 
        locationState.canRequestPermission &&
        !_hasRequestedPermission &&
        !locationState.isLoading &&
        locationState.isInitialized;

    // Check if we're in a "waiting for location" state
    final isWaitingForLocation = !locationState.hasLocation && 
        locationState.isInitialized && 
        !locationState.isLoading;

    // Show list view if toggled and we have location
    if (_isListView && locationState.hasLocation) {
      return _buildListView(locationState, mapState);
    }

    // Otherwise show map view
    return _buildMapView(locationState, mapState, showPermissionPrompt, isWaitingForLocation);
  }

  /// Build the list view for hospitals.
  Widget _buildListView(HospitalLocationState locationState, HospitalMapState mapState) {
    return Column(
      children: [
        // Search bar and filter button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingMD,
            vertical: AppSpacing.paddingSM,
          ),
          child: _SearchBarWithFilter(
            controller: _searchController,
            filters: mapState.filters,
            onFilterTap: () => _showFiltersSheet(
              showDistanceFilter: true,
              sortLocation: locationState.userLocation,
            ),
          ),
        ),
        
        // Active filter chips (show distance filter in list view)
        if (mapState.filters.hasActiveFilters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingMD),
            child: _ActiveFilterChips(
              filters: mapState.filters,
              showDistanceFilter: true,
              onRemoveFilter: (newFilters) {
                // Use user's location for sorting in list view
                ref.read(hospitalMapProvider.notifier).applyFilters(
                  newFilters,
                  sortLocation: locationState.userLocation,
                );
              },
            ),
          ),
        
        // Hospital list
        Expanded(
          child: HospitalListView(
            units: mapState.nearbyUnits,
            userLocation: locationState.userLocation,
            filters: mapState.filters,
            isLoading: _isLoadingUnits || mapState.isLoading,
            favoriteIds: _favoriteIds,
            onHospitalTap: (unit) {
              // TODO: Navigate to hospital detail
              ref.read(hospitalMapProvider.notifier).selectUnit(unit);
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
            onSortChanged: (sort) {
              final newFilters = mapState.filters.copyWith(sortBy: sort);
              // Use user's location for sorting so distances match displayed values
              ref.read(hospitalMapProvider.notifier).applyFilters(
                newFilters,
                sortLocation: locationState.userLocation,
              );
            },
            onMapViewTap: () {
              setState(() => _isListView = false);
            },
          ),
        ),
      ],
    );
  }

  /// Build the map view for hospitals.
  Widget _buildMapView(
    HospitalLocationState locationState,
    HospitalMapState mapState,
    bool showPermissionPrompt,
    bool isWaitingForLocation,
  ) {
    // Determine initial camera position
    // Use saved position if available (when returning from list view)
    // Otherwise use user location or default
    final CameraPosition initialPosition = _lastCameraPosition ?? 
        CameraPosition(
          target: locationState.hasLocation && locationState.userLocation != null
              ? LatLng(locationState.userLocation!.latitude, locationState.userLocation!.longitude)
              : _defaultLondonLocation,
          zoom: 12.0,
        );

    return Stack(
      children: [
        // Google Map (always visible, showing London as default)
        GoogleMap(
          initialCameraPosition: initialPosition,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onCameraMove: (position) {
            // Track zoom level for clustering (don't setState here for performance)
            _currentZoom = position.zoom;
            // Save camera position for restoring when switching views
            _lastCameraPosition = position;
          },
          onCameraIdle: () {
            // Only reload units if we have a location
            if (!locationState.hasLocation) return;
            // Update markers with new zoom level when camera stops
            setState(() {});
            _onCameraIdle();
          },
          markers: _buildMarkers(mapState.nearbyUnits, mapState.selectedUnit),
          myLocationEnabled: locationState.permissionStatus == loc.LocationPermissionStatus.granted,
          myLocationButtonEnabled: locationState.hasLocation,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          onTap: (_) {
            ref.read(hospitalMapProvider.notifier).clearSelection();
          },
        ),
        
        // Search bar and filter button overlay (only when we have location)
        if (locationState.hasLocation)
          Positioned(
            top: AppSpacing.paddingSM,
            left: AppSpacing.paddingMD,
            right: AppSpacing.paddingMD,
            child: _SearchBarWithFilter(
              controller: _searchController,
              filters: mapState.filters,
              onFilterTap: _showFiltersSheet,
            ),
          ),
        
        // Active filter chips
        if (locationState.hasLocation && mapState.filters.hasActiveFilters)
          Positioned(
            top: 70,
            left: AppSpacing.paddingMD,
            right: AppSpacing.paddingMD,
            child: _ActiveFilterChips(
              filters: mapState.filters,
              onRemoveFilter: (newFilters) {
                ref.read(hospitalMapProvider.notifier).applyFilters(newFilters);
              },
            ),
          ),
        
        // Permission prompt overlay
        if (showPermissionPrompt)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.9),
              child: _PermissionPrompt(
                onAllowTap: _requestLocationPermission,
                onManualTap: _showPostcodeSheet,
              ),
            ),
          ),
        
        // Waiting for postcode overlay
        if (isWaitingForLocation && !showPermissionPrompt)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.gapLG),
                    Text(
                      'Enter your postcode to find nearby hospitals',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.gapLG),
                    ElevatedButton(
                      onPressed: _showPostcodeSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Enter Postcode'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Loading overlay
        if (locationState.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.gapLG),
                    Text('Getting location...'),
                  ],
                ),
              ),
            ),
          ),
        
        // Loading units indicator
        if (_isLoadingUnits || mapState.isLoading)
          Positioned(
            top: locationState.hasLocation ? 120 : AppSpacing.paddingMD,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.paddingLG,
                  vertical: AppSpacing.paddingSM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppSpacing.gapSM),
                    Text('Finding hospitals...'),
                  ],
                ),
              ),
            ),
          ),
        
        // List view button (bottom center)
        if (locationState.hasLocation && !_isLoadingUnits && mapState.hasUnits)
          Positioned(
            bottom: AppSpacing.paddingXL,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() => _isListView = true);
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.paddingLG,
                        vertical: AppSpacing.paddingSM,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.list,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.gapSM),
                          Text(
                            'List View',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        
        // Error message
        if (mapState.error != null)
          Positioned(
            bottom: AppSpacing.paddingLG,
            left: AppSpacing.paddingLG,
            right: AppSpacing.paddingLG,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mapState.error!,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Search bar with filter button.
class _SearchBarWithFilter extends StatelessWidget {
  final TextEditingController controller;
  final HospitalFilterCriteria filters;
  final VoidCallback onFilterTap;

  const _SearchBarWithFilter({
    required this.controller,
    required this.filters,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search by hospital name...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.paddingMD,
                  vertical: AppSpacing.paddingSM,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gapSM),
        // Filter button
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.paddingMD),
                child: Icon(
                  Icons.tune,
                  color: filters.hasActiveFilters 
                      ? AppColors.primary 
                      : AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Active filter chips display.
class _ActiveFilterChips extends StatelessWidget {
  final HospitalFilterCriteria filters;
  final void Function(HospitalFilterCriteria) onRemoveFilter;
  
  /// Whether to show distance filter (only for list view).
  final bool showDistanceFilter;

  const _ActiveFilterChips({
    required this.filters,
    required this.onRemoveFilter,
    this.showDistanceFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    
    // Add distance filter chip if non-default (only in list view)
    if (showDistanceFilter && filters.maxDistanceMiles != 15.0) {
      final distanceLabel = filters.maxDistanceMiles < 1 
          ? 'Within ${filters.maxDistanceMiles.toStringAsFixed(1)}mi'
          : 'Within ${filters.maxDistanceMiles.toInt()}mi';
      chips.add(_FilterChip(
        label: distanceLabel,
        onRemove: () {
          onRemoveFilter(filters.copyWith(maxDistanceMiles: 15.0));
        },
      ));
    }
    
    // Add rating filter chip if filtering by specific ratings
    if (filters.hasRatingFilter) {
      chips.add(_FilterChip(
        label: 'CQC: ${filters.ratingFilterDisplayName}',
        onRemove: () {
          onRemoveFilter(filters.copyWith(
            allowedRatings: HospitalFilterCriteria.allRatings,
          ));
        },
      ));
    }
    
    // Add NHS/Independent filter chips if not both selected
    if (!filters.includeNhs) {
      chips.add(_FilterChip(
        label: 'Independent only',
        onRemove: () {
          onRemoveFilter(filters.copyWith(includeNhs: true));
        },
      ));
    }
    if (!filters.includeIndependent) {
      chips.add(_FilterChip(
        label: 'NHS only',
        onRemove: () {
          onRemoveFilter(filters.copyWith(includeIndependent: true));
        },
      ));
    }
    
    if (chips.isEmpty) return const SizedBox.shrink();
    
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }
}

/// Individual filter chip.
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.gapSM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingSM,
        vertical: AppSpacing.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.backgroundGrey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.gapXS),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Location bar showing current postcode with change option.
class _LocationBar extends StatelessWidget {
  final String? postcode;
  final bool isLoading;
  final VoidCallback onChangeTap;

  const _LocationBar({
    this.postcode,
    this.isLoading = false,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingLG,
        vertical: AppSpacing.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.backgroundGrey100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.gapSM),
          Expanded(
            child: isLoading
                ? const Text('Getting location...')
                : Text(
                    postcode ?? 'Location not set',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
          TextButton(
            onPressed: onChangeTap,
            child: Text(
              'Change',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Permission prompt widget.
class _PermissionPrompt extends StatelessWidget {
  final VoidCallback onAllowTap;
  final VoidCallback onManualTap;

  const _PermissionPrompt({
    required this.onAllowTap,
    required this.onManualTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.gapXL),
          Text(
            'Find Hospitals Near You',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.gapMD),
          Text(
            'Allow location access to find maternity units nearby, or enter your postcode manually.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.gapXL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAllowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMD),
              ),
              child: const Text('Allow Location Access'),
            ),
          ),
          const SizedBox(height: AppSpacing.gapMD),
          TextButton(
            onPressed: onManualTap,
            child: Text(
              'Enter Postcode Manually',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
