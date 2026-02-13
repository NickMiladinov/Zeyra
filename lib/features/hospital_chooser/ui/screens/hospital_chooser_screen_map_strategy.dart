part of 'hospital_chooser_screen.dart';

extension _HospitalChooserScreenMapStrategy on _HospitalChooserScreenState {
  double _zoomForRadiusImpl(double radiusMiles) {
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

  double _radiusFromBoundsImpl(LatLngBounds bounds) {
    final latDiff = (bounds.northeast.latitude - bounds.southwest.latitude)
        .abs();
    final lngDiff = (bounds.northeast.longitude - bounds.southwest.longitude)
        .abs();

    final centerLat =
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    final cosLat = math.cos(centerLat * math.pi / 180);

    final latMiles = latDiff * 69.0;
    final lngMiles = lngDiff * 69.0 * cosLat;

    final diagonal = math.sqrt(latMiles * latMiles + lngMiles * lngMiles);
    return (diagonal / 2) * 1.2;
  }

  Future<void> _loadUnitsWithAutoExpandImpl(
    loc.LatLng location, {
    required bool animateToLocation,
  }) async {
    if (_isLoadingUnits) return;
    _setUnitsLoading(true);

    final mapNotifier = ref.read(hospitalMapProvider.notifier);
    double finalRadius = _HospitalChooserScreenState._radiusSteps.first;

    try {
      for (final radius in _HospitalChooserScreenState._radiusSteps) {
        logger.debug('Loading units within $radius miles');
        finalRadius = radius;

        await mapNotifier.loadNearbyUnitsWithRadius(
          location,
          radiusMiles: radius,
        );

        final state = ref.read(hospitalMapProvider);
        if (state.nearbyUnits.length >= _HospitalChooserScreenState._minUnitsThreshold) {
          logger.info(
            'Found ${state.nearbyUnits.length} units within $radius miles',
          );
          break;
        }

        if (radius == _HospitalChooserScreenState._radiusSteps.last) {
          logger.info(
            'Max radius reached, found ${state.nearbyUnits.length} units',
          );
        }
      }

      _currentSearchRadius = finalRadius;
      if (animateToLocation) {
        _animateToLocation(location, radiusMiles: finalRadius);
      }
    } finally {
      if (mounted) {
        _finishInitialUnitsLoad();
      }
    }
  }

  Future<void> _loadUnitsForVisibleAreaImpl() async {
    if (_isLoadingUnits) return;
    if (_mapController == null) return;

    _setUnitsLoading(true);

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
        _setUnitsLoading(false);
      }
    }
  }

  void _centerOnUserLocationImpl() {
    final locationState = ref.read(hospitalLocationProvider);
    if (!locationState.hasLocation || locationState.userLocation == null) {
      return;
    }
    if (_mapController == null) {
      return;
    }

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
