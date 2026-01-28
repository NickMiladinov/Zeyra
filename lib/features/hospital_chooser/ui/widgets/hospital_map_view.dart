import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/location_service.dart' as loc;
import '../../../../domain/entities/hospital/maternity_unit.dart';
import '../../logic/hospital_location_state.dart';
import '../../logic/hospital_map_state.dart';
import '../../logic/hospital_search_state.dart';
import 'hospital_detail_overlay.dart';
import 'hospital_filter_chips.dart';
import 'hospital_marker_cluster.dart';
import 'hospital_permission_prompt.dart';
import 'hospital_search_bar.dart';
import 'hospital_search_results.dart';
import 'hospital_view_toggle_button.dart';

/// Map view widget for displaying hospitals on a Google Map.
///
/// Handles:
/// - Google Map rendering with custom markers
/// - Marker clustering for dense areas (via [HospitalMarkerCluster])
/// - Search overlay
/// - Filter chips
/// - Hospital preview sheet
/// - Various overlay states (loading, permission, waiting for postcode)
class HospitalMapView extends ConsumerStatefulWidget {
  /// Current location state.
  final HospitalLocationState locationState;

  /// Current map state with nearby units.
  final HospitalMapState mapState;

  /// Whether to show permission prompt overlay.
  final bool showPermissionPrompt;

  /// Whether waiting for location (shows postcode prompt).
  final bool isWaitingForLocation;

  /// Whether currently loading units.
  final bool isLoadingUnits;

  /// Search text controller.
  final TextEditingController searchController;

  /// Search focus node.
  final FocusNode searchFocusNode;

  /// Last camera position (for restoring view state).
  final CameraPosition? lastCameraPosition;

  /// Callback when map controller is created.
  final void Function(GoogleMapController controller) onMapCreated;

  /// Callback when camera movement ends.
  final void Function(CameraPosition position) onCameraMove;

  /// Callback when camera becomes idle.
  final VoidCallback onCameraIdle;

  /// Callback when filter button is tapped.
  final VoidCallback onFilterTap;

  /// Callback to clear search.
  final VoidCallback onClearSearch;

  /// Callback to dismiss search overlay.
  final VoidCallback onDismissSearch;

  /// Callback when a search result is selected.
  final void Function(MaternityUnit unit) onSearchResultSelected;

  /// Callback to switch to list view.
  final VoidCallback onListViewTap;

  /// Callback when permission is requested.
  final VoidCallback onRequestPermission;

  /// Callback to show postcode sheet.
  final VoidCallback onShowPostcodeSheet;

  const HospitalMapView({
    super.key,
    required this.locationState,
    required this.mapState,
    required this.showPermissionPrompt,
    required this.isWaitingForLocation,
    required this.isLoadingUnits,
    required this.searchController,
    required this.searchFocusNode,
    this.lastCameraPosition,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onFilterTap,
    required this.onClearSearch,
    required this.onDismissSearch,
    required this.onSearchResultSelected,
    required this.onListViewTap,
    required this.onRequestPermission,
    required this.onShowPostcodeSheet,
  });

  @override
  ConsumerState<HospitalMapView> createState() => _HospitalMapViewState();
}

class _HospitalMapViewState extends ConsumerState<HospitalMapView> {
  /// Marker cluster utility.
  late final HospitalMarkerCluster _markerCluster;

  /// Current zoom level (updated on camera move).
  double _currentZoom = 12.0;

  /// Default location (Central London - Trafalgar Square area).
  static const LatLng _defaultLondonLocation = LatLng(51.5074, -0.1278);

  @override
  void initState() {
    super.initState();
    _markerCluster = HospitalMarkerCluster(
      onClusterIconLoaded: () {
        if (mounted) setState(() {});
      },
    );
    _loadCustomMarkers();
  }

  /// Load custom marker icons asynchronously.
  Future<void> _loadCustomMarkers() async {
    await _markerCluster.loadCustomMarkers();
    if (mounted) setState(() {});
  }

  /// Handle unit marker tap - show detail overlay directly.
  void _onUnitTap(MaternityUnit unit) {
    // Calculate distance for the unit
    final distanceMiles = widget.locationState.userLocation != null
        ? unit.distanceFrom(
            widget.locationState.userLocation!.latitude,
            widget.locationState.userLocation!.longitude,
          )
        : null;

    // Show the detail overlay directly
    showHospitalDetailOverlay(
      context: context,
      unit: unit,
      distanceMiles: distanceMiles,
      userLat: widget.locationState.userLocation?.latitude,
      userLng: widget.locationState.userLocation?.longitude,
    );
  }

  /// Handle cluster tap (zoom in).
  void _onClusterTap(double centerLat, double centerLng) {
    // Cluster tap is handled via info window currently
    // Could animate camera to zoom in on the cluster
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(hospitalSearchProvider);

    // Determine initial camera position
    final CameraPosition initialPosition = widget.lastCameraPosition ??
        CameraPosition(
          target: widget.locationState.hasLocation &&
                  widget.locationState.userLocation != null
              ? LatLng(
                  widget.locationState.userLocation!.latitude,
                  widget.locationState.userLocation!.longitude,
                )
              : _defaultLondonLocation,
          zoom: 12.0,
        );

    // Build markers using the cluster utility
    final markers = _markerCluster.buildMarkers(
      units: widget.mapState.nearbyUnits,
      selected: widget.mapState.selectedUnit,
      currentZoom: _currentZoom,
      onUnitTap: _onUnitTap,
      onClusterTap: _onClusterTap,
    );

    return Stack(
      children: [
        // Google Map (always visible)
        GoogleMap(
          initialCameraPosition: initialPosition,
          onMapCreated: widget.onMapCreated,
          onCameraMove: (position) {
            _currentZoom = position.zoom;
            widget.onCameraMove(position);
          },
          onCameraIdle: () {
            if (!widget.locationState.hasLocation) return;
            setState(() {}); // Rebuild markers with new zoom
            widget.onCameraIdle();
          },
          markers: markers,
          myLocationEnabled: widget.locationState.permissionStatus ==
              loc.LocationPermissionStatus.granted,
          myLocationButtonEnabled: widget.locationState.hasLocation,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          onTap: (_) {
            ref.read(hospitalMapProvider.notifier).clearSelection();
            if (ref.read(hospitalSearchProvider).isActive) {
              widget.onClearSearch();
            }
          },
        ),

        // Search bar overlay (only when we have location)
        if (widget.locationState.hasLocation)
          Positioned(
            top: AppSpacing.paddingSM,
            left: AppSpacing.paddingMD,
            right: AppSpacing.paddingMD,
            child: HospitalSearchBar(
              controller: widget.searchController,
              focusNode: widget.searchFocusNode,
              filters: widget.mapState.filters,
              onFilterTap: widget.onFilterTap,
              onClear: widget.onClearSearch,
            ),
          ),

        // Search dismiss layer
        if (widget.locationState.hasLocation &&
            searchState.isActive &&
            searchState.query.isNotEmpty)
          Positioned(
            top: 56 + AppSpacing.paddingSM,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: widget.onDismissSearch,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),

        // Search results overlay
        if (widget.locationState.hasLocation &&
            searchState.isActive &&
            searchState.query.isNotEmpty)
          Positioned(
            top: 56 + AppSpacing.paddingSM,
            left: AppSpacing.paddingMD,
            right: AppSpacing.paddingMD,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: HospitalSearchResults(
                    searchState: searchState,
                    onResultTap: widget.onSearchResultSelected,
                    onClose: widget.onClearSearch,
                  ),
                ),
              ),
            ),
          ),

        // Active filter chips
        if (widget.locationState.hasLocation &&
            widget.mapState.filters.hasActiveFilters &&
            !searchState.isActive)
          Positioned(
            top: 70,
            left: AppSpacing.paddingMD,
            right: AppSpacing.paddingMD,
            child: HospitalFilterChips(
              filters: widget.mapState.filters,
              onRemoveFilter: (newFilters) {
                ref.read(hospitalMapProvider.notifier).applyFilters(newFilters);
              },
            ),
          ),

        // Permission prompt overlay
        if (widget.showPermissionPrompt)
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.9),
              child: HospitalPermissionPrompt(
                onAllowTap: widget.onRequestPermission,
                onManualTap: widget.onShowPostcodeSheet,
              ),
            ),
          ),

        // Waiting for postcode overlay
        if (widget.isWaitingForLocation && !widget.showPermissionPrompt)
          Positioned.fill(
            child: _PostcodePromptOverlay(
              onEnterPostcode: widget.onShowPostcodeSheet,
            ),
          ),

        // Loading location overlay
        if (widget.locationState.isLoading)
          const Positioned.fill(
            child: _LoadingLocationOverlay(),
          ),

        // Loading units indicator
        if (widget.isLoadingUnits || widget.mapState.isLoading)
          Positioned(
            top: widget.locationState.hasLocation ? 120 : AppSpacing.paddingMD,
            left: 0,
            right: 0,
            child: const Center(child: _LoadingUnitsIndicator()),
          ),

        // List view toggle button
        if (widget.locationState.hasLocation &&
            !widget.isLoadingUnits &&
            widget.mapState.hasUnits)
          Positioned(
            bottom: AppSpacing.paddingXL,
            left: 0,
            right: 0,
            child: Center(
              child: HospitalViewToggleButton(
                targetView: HospitalViewType.list,
                onTap: widget.onListViewTap,
              ),
            ),
          ),

        // Error message
        if (widget.mapState.error != null)
          Positioned(
            bottom: AppSpacing.paddingLG,
            left: AppSpacing.paddingLG,
            right: AppSpacing.paddingLG,
            child: _ErrorBanner(message: widget.mapState.error!),
          ),
      ],
    );
  }
}

/// Overlay shown when waiting for postcode input.
class _PostcodePromptOverlay extends StatelessWidget {
  final VoidCallback onEnterPostcode;

  const _PostcodePromptOverlay({required this.onEnterPostcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.9),
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
              onPressed: onEnterPostcode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enter Postcode'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay shown while loading location.
class _LoadingLocationOverlay extends StatelessWidget {
  const _LoadingLocationOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.7),
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
    );
  }
}

/// Indicator shown while loading hospital units.
class _LoadingUnitsIndicator extends StatelessWidget {
  const _LoadingUnitsIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingLG,
        vertical: AppSpacing.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
    );
  }
}

/// Error banner shown when there's an error.
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
