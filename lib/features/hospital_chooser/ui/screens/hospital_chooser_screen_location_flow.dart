part of 'hospital_chooser_screen.dart';

extension _HospitalChooserScreenLocationFlow on _HospitalChooserScreenState {
  void _checkInitialPermissionStateImpl() {
    final locationReady = ref.read(hospitalLocationReadyProvider);
    if (!locationReady) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _checkInitialPermissionState();
      });
      return;
    }

    final locationState = ref.read(hospitalLocationProvider);
    final mapState = ref.read(hospitalMapProvider);
    final hasPersistedViewport =
        mapState.mapCenter != null && mapState.mapZoom != null;

    if (locationState.hasLocation &&
        locationState.userLocation != null &&
        !_hasCompletedInitialLoad &&
        !_isLoadingUnits) {
      final initialLoadLocation = hasPersistedViewport
          ? mapState.mapCenter!
          : locationState.userLocation!;
      _loadUnitsWithAutoExpand(
        initialLoadLocation,
        animateToLocation: !hasPersistedViewport,
      );
      return;
    }

    if (!locationState.hasLocation &&
        locationState.canRequestPermission &&
        !_hasRequestedPermission &&
        locationState.isInitialized &&
        !locationState.isLoading) {
      logger.debug('Auto-requesting location permission on first visit');
      _requestLocationPermission();
    }
  }

  void _onLocationStateChangedImpl(HospitalLocationState locationState) {
    if (!locationState.isInitialized || locationState.isLoading) return;

    if (locationState.hasLocation && !_isLoadingUnits) {
      _loadUnitsWithAutoExpand(locationState.userLocation!);
      return;
    }

    if (locationState.wasPermissionPermanentlyDenied &&
        !locationState.hasLocation) {
      _showPostcodeSheet();
      return;
    }

    if (locationState.wasPermissionDenied &&
        !locationState.hasLocation &&
        _hasRequestedPermission) {
      _showPostcodeSheet();
    }
  }

  Future<void> _requestLocationPermissionImpl() async {
    _markPermissionRequested();

    final notifier = ref.read(hospitalLocationProvider.notifier);
    final granted = await notifier.requestPermission();
    if (!granted && mounted) {
      _showPostcodeSheet();
    }
  }

  void _showPostcodeSheetImpl() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => PostcodeBottomSheet(
        onPostcodeSubmitted: (postcode) async {
          Navigator.pop(bottomSheetContext);
          final notifier = ref.read(hospitalLocationProvider.notifier);
          final success = await notifier.setPostcode(postcode);
          if (!success && bottomSheetContext.mounted) {
            ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
              const SnackBar(
                content: Text('Invalid postcode. Please try again.'),
              ),
            );
          }
        },
      ),
    );
  }
}
