part of 'hospital_chooser_screen.dart';

extension _HospitalChooserScreenSearchOrchestration on _HospitalChooserScreenState {
  void _setupSearchListenerImpl() {
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  void _onSearchChangedImpl() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _searchDebounceTimer?.cancel();
      ref.read(hospitalSearchProvider.notifier).clearSearch();
      return;
    }

    ref.read(hospitalSearchProvider.notifier).setActive(true);

    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final locationState = ref.read(hospitalLocationProvider);
      final mapState = ref.read(hospitalMapProvider);
      if (!locationState.hasLocation || locationState.userLocation == null) {
        return;
      }

      ref
          .read(hospitalSearchProvider.notifier)
          .search(
            query: query,
            nearbyUnits: mapState.nearbyUnits,
            userLocation: locationState.userLocation!,
          );
    });
  }

  void _onSearchFocusChangedImpl() {
    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      ref.read(hospitalSearchProvider.notifier).setActive(true);
      return;
    }

    if (_searchFocusNode.hasFocus) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_searchFocusNode.hasFocus) {
        ref.read(hospitalSearchProvider.notifier).setActive(false);
      }
    });
  }

  void _clearSearchImpl() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(hospitalSearchProvider.notifier).clearSearch();
  }

  void _dismissSearchOverlayImpl() {
    _searchFocusNode.unfocus();
    ref.read(hospitalSearchProvider.notifier).setActive(false);
  }
}
