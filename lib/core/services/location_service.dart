import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../monitoring/logging_service.dart';

/// Simple latitude/longitude pair.
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

/// Permission status for location access.
enum LocationPermissionStatus {
  /// Permission not yet determined.
  unknown,

  /// Permission granted (always or while in use).
  granted,

  /// Permission denied but can ask again.
  denied,

  /// Permission permanently denied (user must go to settings).
  deniedForever,

  /// Location services are disabled on the device.
  serviceDisabled,
}

/// Service for handling device location and UK postcode lookup.
///
/// Uses geolocator for device location and postcodes.io for UK-specific
/// postcode operations (free, no API key required).
class LocationService {
  final LoggingService _logger;
  final http.Client _httpClient;

  /// Base URL for postcodes.io API.
  static const String _postcodeBaseUrl = 'https://api.postcodes.io';

  /// Whether the HTTP client was created internally (vs injected).
  final bool _ownsHttpClient;

  LocationService({
    required LoggingService logger,
    http.Client? httpClient,
  })  : _logger = logger,
        _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null;

  /// Close the HTTP client to release network resources.
  ///
  /// Only closes the client if it was created internally (not injected).
  /// Should be called when the service is no longer needed.
  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Device Location (geolocator)
  // ---------------------------------------------------------------------------

  /// Get current location permission status.
  Future<LocationPermissionStatus> getPermissionStatus() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // Check permission
    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  /// Request location permission.
  ///
  /// Returns the new permission status after the request.
  Future<LocationPermissionStatus> requestPermission() async {
    _logger.debug('Requesting location permission');

    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.warning('Location services are disabled');
      return LocationPermissionStatus.serviceDisabled;
    }

    // Check current permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
    }

    final status = _mapPermission(permission);
    _logger.debug('Location permission status: $status');
    return status;
  }

  /// Map geolocator permission to our enum.
  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unknown;
    }
  }

  /// Check if location permission is granted.
  Future<bool> hasPermission() async {
    final status = await getPermissionStatus();
    return status == LocationPermissionStatus.granted;
  }

  /// Get current device location.
  ///
  /// Returns null if permission is not granted or location is unavailable.
  Future<LatLng?> getCurrentLocation() async {
    _logger.debug('Getting current device location');

    try {
      // Check permission first
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        _logger.warning('No location permission');
        return null;
      }

      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location request timed out'),
      );

      _logger.debug('Got location: ${position.latitude}, ${position.longitude}');
      return LatLng(position.latitude, position.longitude);
    } catch (e, stackTrace) {
      _logger.error('Error getting location', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Open app settings for location permission.
  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Open location settings on the device.
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  // ---------------------------------------------------------------------------
  // Postcodes.io API (UK-specific, free, no API key)
  // ---------------------------------------------------------------------------

  /// Reverse geocode: coordinates to nearest UK postcode.
  ///
  /// Returns the nearest postcode or null if not found.
  Future<String?> getPostcodeFromCoordinates(double lat, double lng) async {
    _logger.debug('Reverse geocoding coordinates: $lat, $lng');

    try {
      final response = await _httpClient.get(
        Uri.parse('$_postcodeBaseUrl/postcodes?lon=$lng&lat=$lat'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['result'] as List<dynamic>?;

        if (result != null && result.isNotEmpty) {
          final postcode = result[0]['postcode'] as String?;
          _logger.debug('Found postcode: $postcode');
          return postcode;
        }
      }

      _logger.warning('No postcode found for coordinates');
      return null;
    } catch (e, stackTrace) {
      _logger.error('Error reverse geocoding', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Forward geocode: UK postcode to coordinates.
  ///
  /// Returns coordinates or null if postcode is invalid.
  Future<LatLng?> getCoordinatesFromPostcode(String postcode) async {
    _logger.debug('Forward geocoding postcode: $postcode');

    try {
      final encoded = Uri.encodeComponent(postcode.replaceAll(' ', ''));
      final response = await _httpClient.get(
        Uri.parse('$_postcodeBaseUrl/postcodes/$encoded'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>?;

        if (result != null) {
          final lat = result['latitude'] as num?;
          final lng = result['longitude'] as num?;

          if (lat != null && lng != null) {
            _logger.debug('Found coordinates: $lat, $lng');
            return LatLng(lat.toDouble(), lng.toDouble());
          }
        }
      }

      _logger.warning('Postcode not found: $postcode');
      return null;
    } catch (e, stackTrace) {
      _logger.error('Error forward geocoding', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Validate a UK postcode.
  ///
  /// Returns true if the postcode exists and is valid.
  Future<bool> isValidPostcode(String postcode) async {
    try {
      final encoded = Uri.encodeComponent(postcode.replaceAll(' ', ''));
      final response = await _httpClient.get(
        Uri.parse('$_postcodeBaseUrl/postcodes/$encoded/validate'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['result'] == true;
      }

      return false;
    } catch (e) {
      _logger.warning('Error validating postcode: $e');
      return false;
    }
  }

  /// Autocomplete partial postcode.
  ///
  /// Returns list of matching postcodes.
  Future<List<String>> autocompletePostcode(String partial) async {
    if (partial.length < 2) return [];

    try {
      final encoded = Uri.encodeComponent(partial.replaceAll(' ', ''));
      final response = await _httpClient.get(
        Uri.parse('$_postcodeBaseUrl/postcodes/$encoded/autocomplete'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['result'] as List<dynamic>?;

        if (result != null) {
          return result.cast<String>();
        }
      }

      return [];
    } catch (e) {
      _logger.warning('Error autocompleting postcode: $e');
      return [];
    }
  }

  /// Get postcode details (region, district, etc.).
  Future<PostcodeDetails?> getPostcodeDetails(String postcode) async {
    try {
      final encoded = Uri.encodeComponent(postcode.replaceAll(' ', ''));
      final response = await _httpClient.get(
        Uri.parse('$_postcodeBaseUrl/postcodes/$encoded'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>?;

        if (result != null) {
          // Defensive null-checking for required fields (consistent with
          // getCoordinatesFromPostcode pattern)
          final postcodeValue = result['postcode'] as String?;
          final lat = result['latitude'] as num?;
          final lng = result['longitude'] as num?;

          if (postcodeValue != null && lat != null && lng != null) {
            return PostcodeDetails(
              postcode: postcodeValue,
              latitude: lat.toDouble(),
              longitude: lng.toDouble(),
              region: result['region'] as String?,
              country: result['country'] as String?,
              adminDistrict: result['admin_district'] as String?,
              parish: result['parish'] as String?,
            );
          }
        }
      }

      return null;
    } catch (e) {
      _logger.warning('Error getting postcode details: $e');
      return null;
    }
  }
}

/// Details about a UK postcode.
class PostcodeDetails {
  final String postcode;
  final double latitude;
  final double longitude;
  final String? region;
  final String? country;
  final String? adminDistrict;
  final String? parish;

  const PostcodeDetails({
    required this.postcode,
    required this.latitude,
    required this.longitude,
    this.region,
    this.country,
    this.adminDistrict,
    this.parish,
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  @override
  String toString() =>
      'PostcodeDetails($postcode, region: $region, district: $adminDistrict)';
}
