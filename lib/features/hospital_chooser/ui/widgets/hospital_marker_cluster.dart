import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../domain/entities/hospital/maternity_unit.dart';
import 'custom_map_marker.dart';

/// Callback type for when a unit marker is tapped.
typedef OnUnitTap = void Function(MaternityUnit unit);

/// Callback type for when a cluster is tapped (to zoom in).
typedef OnClusterTap = void Function(double centerLat, double centerLng);

/// Utility class for building clustered map markers.
///
/// Handles zoom-aware clustering of maternity units on the map.
/// Automatically clusters nearby units when there are too many
/// to display individually.
class HospitalMarkerCluster {
  /// Maximum number of markers before clustering is required.
  static const int maxVisibleMarkers = 50;

  /// Base grid size at zoom level 14.
  static const double _baseGridSize = 0.01;

  /// Maximum grid size to prevent over-merging.
  static const double _maxGridSize = 2.0;

  /// Custom marker icons.
  BitmapDescriptor? defaultMarkerIcon;
  BitmapDescriptor? selectedMarkerIcon;

  /// Cluster marker icons cache.
  final Map<String, BitmapDescriptor> _clusterIcons = {};

  /// Callback to notify when a cluster icon is loaded.
  final VoidCallback? onClusterIconLoaded;

  HospitalMarkerCluster({
    this.defaultMarkerIcon,
    this.selectedMarkerIcon,
    this.onClusterIconLoaded,
  });

  /// Load custom marker icons asynchronously.
  Future<void> loadCustomMarkers() async {
    defaultMarkerIcon = await CustomMapMarker.getDefaultMarker();
    selectedMarkerIcon = await CustomMapMarker.getSelectedMarker();
  }

  /// Load a cluster icon asynchronously.
  Future<void> loadClusterIcon(int count) async {
    if (_clusterIcons.containsKey(count.toString())) return;

    final icon = await CustomMapMarker.getClusterMarker(count);
    _clusterIcons[count.toString()] = icon;
    onClusterIconLoaded?.call();
  }

  /// Get a cached cluster icon, or null if not loaded yet.
  BitmapDescriptor? getClusterIcon(int count) {
    return _clusterIcons[count.toString()];
  }

  /// Calculate grid size based on current zoom level.
  ///
  /// At higher zoom levels (zoomed in), use smaller grid cells.
  /// At lower zoom levels (zoomed out), use larger grid cells.
  static double gridSizeForZoom(double zoom) {
    final zoomDiff = 14.0 - zoom;
    return _baseGridSize * math.pow(2, zoomDiff);
  }

  /// Build map markers from maternity units with zoom-aware clustering.
  ///
  /// [units] - List of maternity units to display
  /// [selected] - Currently selected unit (if any)
  /// [currentZoom] - Current map zoom level
  /// [onUnitTap] - Callback when a unit marker is tapped
  /// [onClusterTap] - Callback when a cluster is tapped
  Set<Marker> buildMarkers({
    required List<MaternityUnit> units,
    MaternityUnit? selected,
    required double currentZoom,
    required OnUnitTap onUnitTap,
    OnClusterTap? onClusterTap,
  }) {
    // Use fallback icons if custom ones aren't loaded yet
    final defaultIcon = defaultMarkerIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    final selectedIcon = selectedMarkerIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

    // Filter out units without valid coordinates
    final validUnits =
        units.where((u) => u.latitude != null && u.longitude != null).toList();

    // If we have few enough units, show them all individually
    if (validUnits.length <= maxVisibleMarkers) {
      return _buildIndividualMarkers(
        units: validUnits,
        selected: selected,
        defaultIcon: defaultIcon,
        selectedIcon: selectedIcon,
        onUnitTap: onUnitTap,
      );
    }

    // Otherwise use zoom-aware clustering
    return _buildClusteredMarkers(
      units: validUnits,
      selected: selected,
      defaultIcon: defaultIcon,
      selectedIcon: selectedIcon,
      currentZoom: currentZoom,
      onUnitTap: onUnitTap,
      onClusterTap: onClusterTap,
    );
  }

  /// Build individual markers for each unit (no clustering).
  Set<Marker> _buildIndividualMarkers({
    required List<MaternityUnit> units,
    MaternityUnit? selected,
    required BitmapDescriptor defaultIcon,
    required BitmapDescriptor selectedIcon,
    required OnUnitTap onUnitTap,
  }) {
    return units.map((unit) {
      final isSelected = selected?.id == unit.id;

      return Marker(
        markerId: MarkerId(unit.id),
        position: LatLng(unit.latitude!, unit.longitude!),
        icon: isSelected ? selectedIcon : defaultIcon,
        anchor: const Offset(0.5, 1.0),
        onTap: () => onUnitTap(unit),
        infoWindow: InfoWindow(
          title: unit.name,
          snippet: unit.bestAvailableRating.displayName,
        ),
      );
    }).toSet();
  }

  /// Build markers with zoom-aware clustering.
  Set<Marker> _buildClusteredMarkers({
    required List<MaternityUnit> units,
    MaternityUnit? selected,
    required BitmapDescriptor defaultIcon,
    required BitmapDescriptor selectedIcon,
    required double currentZoom,
    required OnUnitTap onUnitTap,
    OnClusterTap? onClusterTap,
  }) {
    if (units.isEmpty) return {};

    final gridSize = gridSizeForZoom(currentZoom);

    // Group units by grid cell
    final Map<String, List<MaternityUnit>> clusters = {};

    for (final unit in units) {
      final gridX = (unit.latitude! / gridSize).floor();
      final gridY = (unit.longitude! / gridSize).floor();
      final key = '$gridX,$gridY';

      clusters.putIfAbsent(key, () => []).add(unit);
    }

    // Merge clusters if still too many
    var mergedClusters = clusters;
    var currentGridSize = gridSize;

    while (mergedClusters.length > maxVisibleMarkers &&
        currentGridSize < _maxGridSize) {
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
          onTap: () => onUnitTap(unit),
          infoWindow: InfoWindow(
            title: unit.name,
            snippet: unit.bestAvailableRating.displayName,
          ),
        ));
      } else {
        // Multiple units - show cluster marker
        final center = _calculateClusterCenter(clusterUnits);
        final centerLat = center.$1;
        final centerLng = center.$2;

        final clusterIcon =
            _clusterIcons[clusterUnits.length.toString()] ?? defaultIcon;

        // Async load cluster icon if not cached
        if (!_clusterIcons.containsKey(clusterUnits.length.toString())) {
          loadClusterIcon(clusterUnits.length);
        }

        markers.add(Marker(
          markerId: MarkerId('cluster_${entry.key}'),
          position: LatLng(centerLat, centerLng),
          icon: clusterIcon,
          anchor: const Offset(0.5, 0.5),
          onTap: () => onClusterTap?.call(centerLat, centerLng),
          infoWindow: InfoWindow(
            title: '${clusterUnits.length} hospitals',
            snippet: 'Tap to zoom in',
          ),
        ));
      }
    }

    return markers;
  }

  /// Calculate the center point of a cluster.
  (double, double) _calculateClusterCenter(List<MaternityUnit> units) {
    double sumLat = 0, sumLng = 0;
    for (final unit in units) {
      sumLat += unit.latitude!;
      sumLng += unit.longitude!;
    }
    return (sumLat / units.length, sumLng / units.length);
  }

  /// Merge existing clusters into larger grid cells.
  Map<String, List<MaternityUnit>> _mergeClusters(
    Map<String, List<MaternityUnit>> clusters,
    double newGridSize,
  ) {
    final merged = <String, List<MaternityUnit>>{};

    for (final clusterUnits in clusters.values) {
      final center = _calculateClusterCenter(clusterUnits);
      final centerLat = center.$1;
      final centerLng = center.$2;

      final gridX = (centerLat / newGridSize).floor();
      final gridY = (centerLng / newGridSize).floor();
      final key = '$gridX,$gridY';

      merged.putIfAbsent(key, () => []).addAll(clusterUnits);
    }

    return merged;
  }
}

/// Typedef for void callbacks (used in clustering).
typedef VoidCallback = void Function();
