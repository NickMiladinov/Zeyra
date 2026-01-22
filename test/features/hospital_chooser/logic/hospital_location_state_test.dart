@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/core/services/location_service.dart';
import 'package:zeyra/features/hospital_chooser/logic/hospital_location_state.dart';

void main() {
  group('[HospitalChooser] HospitalLocationState', () {
    test('should have correct initial values', () {
      const state = HospitalLocationState();

      expect(state.permissionStatus, LocationPermissionStatus.unknown);
      expect(state.userLocation, isNull);
      expect(state.userPostcode, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isInitialized, false);
    });

    test('should compute hasLocation correctly', () {
      const noLocation = HospitalLocationState();
      final withLocation = HospitalLocationState(
        userLocation: LatLng(51.5074, -0.1278),
      );

      expect(noLocation.hasLocation, false);
      expect(withLocation.hasLocation, true);
    });

    test('should compute wasPermissionDenied for denied status', () {
      const denied = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.denied,
      );
      const deniedForever = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.deniedForever,
      );
      const granted = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.granted,
      );
      const unknown = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.unknown,
      );

      expect(denied.wasPermissionDenied, true);
      expect(deniedForever.wasPermissionDenied, true);
      expect(granted.wasPermissionDenied, false);
      expect(unknown.wasPermissionDenied, false);
    });

    test('should compute requiresManualPostcode correctly', () {
      // Denied and no postcode - needs manual entry
      const needsManual = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.denied,
        userPostcode: null,
      );

      // Denied but has postcode - doesn't need manual entry
      const hasPostcode = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.denied,
        userPostcode: 'SW1A 1AA',
      );

      // Granted - doesn't need manual entry
      const granted = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.granted,
      );

      expect(needsManual.requiresManualPostcode, true);
      expect(hasPostcode.requiresManualPostcode, false);
      expect(granted.requiresManualPostcode, false);
    });

    test('should copyWith update fields correctly', () {
      const original = HospitalLocationState();
      final updated = original.copyWith(
        permissionStatus: LocationPermissionStatus.granted,
        userLocation: LatLng(51.5074, -0.1278),
        userPostcode: 'SW1A 1AA',
        isLoading: true,
        isInitialized: true,
      );

      expect(updated.permissionStatus, LocationPermissionStatus.granted);
      expect(updated.userLocation, isNotNull);
      expect(updated.userPostcode, 'SW1A 1AA');
      expect(updated.isLoading, true);
      expect(updated.isInitialized, true);
    });

    test('should copyWith preserve unchanged fields', () {
      final original = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.granted,
        userLocation: LatLng(51.5074, -0.1278),
        userPostcode: 'SW1A 1AA',
      );
      final updated = original.copyWith(isLoading: true);

      expect(updated.permissionStatus, LocationPermissionStatus.granted);
      expect(updated.userLocation, isNotNull);
      expect(updated.userPostcode, 'SW1A 1AA');
      expect(updated.isLoading, true);
    });

    test('should copyWith clear error with null', () {
      const withError = HospitalLocationState(error: 'Test error');
      final cleared = withError.copyWith(error: null);

      expect(cleared.error, isNull);
    });
  });

  group('[HospitalChooser] HospitalLocationState - edge cases', () {
    test('should handle all permission status values', () {
      for (final status in LocationPermissionStatus.values) {
        final state = HospitalLocationState(permissionStatus: status);
        expect(state.permissionStatus, status);
      }
    });

    test('should handle loading state with existing data', () {
      final state = HospitalLocationState(
        userLocation: LatLng(51.5074, -0.1278),
        userPostcode: 'SW1A 1AA',
        isLoading: true,
      );

      expect(state.isLoading, true);
      expect(state.hasLocation, true);
    });

    test('should handle error state with existing data', () {
      final state = HospitalLocationState(
        userLocation: LatLng(51.5074, -0.1278),
        error: 'Network error',
      );

      expect(state.error, isNotNull);
      expect(state.hasLocation, true);
    });

    test('should have independent hasLocation from permission status', () {
      // Can have location even if permission not granted (from postcode)
      final withLocationDenied = HospitalLocationState(
        permissionStatus: LocationPermissionStatus.denied,
        userLocation: LatLng(51.5074, -0.1278), // From postcode lookup
        userPostcode: 'SW1A 1AA',
      );

      expect(withLocationDenied.hasLocation, true);
      expect(withLocationDenied.wasPermissionDenied, true);
      expect(withLocationDenied.requiresManualPostcode, false);
    });
  });

  group('[HospitalChooser] LatLng', () {
    test('should create with latitude and longitude', () {
      final latLng = LatLng(51.5074, -0.1278);

      expect(latLng.latitude, 51.5074);
      expect(latLng.longitude, -0.1278);
    });

    test('should handle negative coordinates', () {
      final latLng = LatLng(-33.8688, 151.2093); // Sydney

      expect(latLng.latitude, -33.8688);
      expect(latLng.longitude, 151.2093);
    });

    test('should handle zero coordinates', () {
      final latLng = LatLng(0, 0);

      expect(latLng.latitude, 0);
      expect(latLng.longitude, 0);
    });
  });
}
