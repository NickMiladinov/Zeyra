import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/main_providers.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/usecases/user_profile/get_user_profile_usecase.dart';
import '../../../domain/usecases/user_profile/update_user_profile_usecase.dart';

// ----------------------------------------------------------------------------
// State Classes
// ----------------------------------------------------------------------------

/// State for managing user location in the hospital chooser.
class HospitalLocationState {
  /// Permission status for device location.
  final LocationPermissionStatus permissionStatus;

  /// User's current coordinates (from device or postcode lookup).
  final LatLng? userLocation;

  /// User's saved postcode.
  final String? userPostcode;

  /// Whether location is being loaded.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  /// Whether initial location setup is complete.
  final bool isInitialized;

  const HospitalLocationState({
    this.permissionStatus = LocationPermissionStatus.unknown,
    this.userLocation,
    this.userPostcode,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  /// Whether we have a valid location to search from.
  bool get hasLocation => userLocation != null;

  /// Whether location permission was denied.
  bool get wasPermissionDenied =>
      permissionStatus == LocationPermissionStatus.denied ||
      permissionStatus == LocationPermissionStatus.deniedForever;

  /// Whether user must manually enter postcode.
  bool get requiresManualPostcode =>
      wasPermissionDenied && userPostcode == null;

  HospitalLocationState copyWith({
    LocationPermissionStatus? permissionStatus,
    LatLng? userLocation,
    String? userPostcode,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return HospitalLocationState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      userLocation: userLocation ?? this.userLocation,
      userPostcode: userPostcode ?? this.userPostcode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// ----------------------------------------------------------------------------
// Notifier
// ----------------------------------------------------------------------------

/// Notifier for managing hospital location state.
///
/// Handles:
/// - Checking for saved postcode in user profile
/// - Requesting device location permission
/// - Getting coordinates from device or postcode
/// - Saving postcode to user profile
class HospitalLocationNotifier extends StateNotifier<HospitalLocationState> {
  final LocationService _locationService;
  final GetUserProfileUseCase _getUserProfile;
  final UpdateUserProfileUseCase _updateUserProfile;

  HospitalLocationNotifier({
    required LocationService locationService,
    required GetUserProfileUseCase getUserProfile,
    required UpdateUserProfileUseCase updateUserProfile,
  })  : _locationService = locationService,
        _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        super(const HospitalLocationState()) {
    _initialize();
  }

  /// Initialize location state.
  ///
  /// Checks for saved postcode first, then falls back to device location.
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check for saved postcode in user profile
      final profile = await _getUserProfile.execute();
      if (profile?.postcode != null && profile!.postcode!.isNotEmpty) {
        // Have saved postcode - get coordinates
        final coords = await _locationService.getCoordinatesFromPostcode(
          profile.postcode!,
        );

        if (coords != null) {
          state = state.copyWith(
            userPostcode: profile.postcode,
            userLocation: coords,
            isLoading: false,
            isInitialized: true,
          );
          return;
        }
      }

      // No saved postcode - check permission status
      final permissionStatus = await _locationService.getPermissionStatus();

      state = state.copyWith(
        permissionStatus: permissionStatus,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isInitialized: true,
      );
    }
  }

  /// Request device location permission.
  ///
  /// If granted, gets current location and reverse geocodes to postcode.
  Future<bool> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final status = await _locationService.requestPermission();
      state = state.copyWith(permissionStatus: status);

      if (status == LocationPermissionStatus.granted) {
        // Get device location
        final location = await _locationService.getCurrentLocation();
        if (location != null) {
          // Reverse geocode to get postcode
          final postcode = await _locationService.getPostcodeFromCoordinates(
            location.latitude,
            location.longitude,
          );

          state = state.copyWith(
            userLocation: location,
            userPostcode: postcode,
            isLoading: false,
          );

          // Save postcode to user profile
          if (postcode != null) {
            await _savePostcode(postcode);
          }

          return true;
        }
      }

      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Set postcode manually.
  ///
  /// Validates and looks up coordinates for the postcode.
  Future<bool> setPostcode(String postcode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Validate postcode
      final isValid = await _locationService.isValidPostcode(postcode);
      if (!isValid) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid postcode',
        );
        return false;
      }

      // Get coordinates
      final coords = await _locationService.getCoordinatesFromPostcode(postcode);
      if (coords == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not find postcode',
        );
        return false;
      }

      state = state.copyWith(
        userPostcode: postcode,
        userLocation: coords,
        isLoading: false,
      );

      // Save to user profile
      await _savePostcode(postcode);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Refresh device location.
  Future<void> refreshLocation() async {
    if (state.permissionStatus != LocationPermissionStatus.granted) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        final postcode = await _locationService.getPostcodeFromCoordinates(
          location.latitude,
          location.longitude,
        );

        state = state.copyWith(
          userLocation: location,
          userPostcode: postcode ?? state.userPostcode,
          isLoading: false,
        );

        if (postcode != null && postcode != state.userPostcode) {
          await _savePostcode(postcode);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not get location',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Save postcode to user profile.
  Future<void> _savePostcode(String postcode) async {
    try {
      final profile = await _getUserProfile.execute();
      if (profile != null) {
        await _updateUserProfile.execute(
          profile.copyWith(postcode: postcode),
        );
      }
    } catch (e) {
      // Silently fail - postcode is cached in state anyway
    }
  }

  /// Open app settings for location permission.
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ----------------------------------------------------------------------------
// Provider
// ----------------------------------------------------------------------------

/// Provider for hospital location state.
final hospitalLocationProvider =
    StateNotifierProvider<HospitalLocationNotifier, HospitalLocationState>((ref) {
  final locationServiceAsync = ref.watch(locationServiceProvider);
  final getUserProfileAsync = ref.watch(getUserProfileUseCaseProvider);
  final updateUserProfileAsync = ref.watch(updateUserProfileUseCaseProvider);

  // Wait for async dependencies
  if (!getUserProfileAsync.hasValue || !updateUserProfileAsync.hasValue) {
    throw StateError(
      'hospitalLocationProvider accessed before dependencies are ready.',
    );
  }

  return HospitalLocationNotifier(
    locationService: locationServiceAsync,
    getUserProfile: getUserProfileAsync.requireValue,
    updateUserProfile: updateUserProfileAsync.requireValue,
  );
});
