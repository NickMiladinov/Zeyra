import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../monitoring/logging_service.dart';

/// Result of a drive time calculation from the Distance Matrix API.
class DriveTimeResult {
  /// Raw duration in seconds.
  final int durationSeconds;

  /// Human-readable duration (e.g., "15 mins").
  final String durationText;

  /// Distance in meters.
  final int distanceMeters;

  /// Human-readable distance (e.g., "3.2 mi").
  final String distanceText;

  const DriveTimeResult({
    required this.durationSeconds,
    required this.durationText,
    required this.distanceMeters,
    required this.distanceText,
  });

  /// Get duration in minutes (rounded).
  int get durationMinutes => (durationSeconds / 60).round();

  @override
  String toString() =>
      'DriveTimeResult(duration: $durationText, distance: $distanceText)';
}

/// Service for calculating drive times using Google Distance Matrix API.
///
/// ## Setup Requirements
/// 
/// This service uses the same API key as Google Maps. To enable drive time
/// calculations, you must:
/// 
/// 1. Go to Google Cloud Console (https://console.cloud.google.com)
/// 2. Select the same project used for Google Maps
/// 3. Navigate to APIs & Services > Library
/// 4. Search for "Distance Matrix API" and enable it
/// 5. Ensure your existing Maps API key has access to Distance Matrix API
///
/// No additional environment variables needed - uses existing:
/// - `GOOGLE_MAPS_API_KEY_IOS` for iOS
/// - `GOOGLE_MAPS_API_KEY_ANDROID` for Android
class DriveTimeService {
  final LoggingService _logger;
  final http.Client _httpClient;

  /// Base URL for Google Distance Matrix API.
  static const String _apiBaseUrl =
      'https://maps.googleapis.com/maps/api/distancematrix/json';

  /// Whether the HTTP client was created internally (vs injected).
  final bool _ownsHttpClient;

  /// In-memory cache for drive time results.
  /// Key format: "originLat,originLng|destLat,destLng"
  final Map<String, DriveTimeResult> _cache = {};

  /// Cache expiry duration (drive times don't change frequently).
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// Timestamps for cache entries.
  final Map<String, DateTime> _cacheTimestamps = {};

  DriveTimeService({
    required LoggingService logger,
    http.Client? httpClient,
  })  : _logger = logger,
        _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null;

  /// Close the HTTP client to release network resources.
  ///
  /// Only closes the client if it was created internally (not injected).
  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  /// Get the Distance Matrix API key.
  /// Uses a dedicated key without app restrictions (required for HTTP API calls).
  String get _apiKey {
    return AppConstants.googleDistanceMatrixApiKey;
  }

  /// Generate cache key for origin/destination pair.
  /// Rounds to 4 decimal places (~11m precision) to improve cache hits.
  String _cacheKey(
    double originLat,
    double originLng,
    double destLat,
    double destLng,
  ) {
    final oLat = originLat.toStringAsFixed(4);
    final oLng = originLng.toStringAsFixed(4);
    final dLat = destLat.toStringAsFixed(4);
    final dLng = destLng.toStringAsFixed(4);
    return '$oLat,$oLng|$dLat,$dLng';
  }

  /// Check if a cached entry is still valid.
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Get drive time between two coordinates.
  ///
  /// Returns null if the API call fails or no route is found.
  /// Results are cached for 30 minutes to reduce API calls.
  Future<DriveTimeResult?> getDriveTime({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    _logger.debug('getDriveTime called: origin=($originLat,$originLng) dest=($destLat,$destLng)');
    
    // Check cache first
    final key = _cacheKey(originLat, originLng, destLat, destLng);
    if (_cache.containsKey(key) && _isCacheValid(key)) {
      _logger.debug('Drive time cache hit for $key');
      return _cache[key];
    }

    // Validate API key
    if (_apiKey.isEmpty) {
      _logger.warning('Distance Matrix API key not configured - add GOOGLE_DISTANCE_MATRIX_API_KEY to .env');
      return null;
    }

    _logger.debug(
        'Fetching drive time: ($originLat, $originLng) → ($destLat, $destLng)');

    try {
      final url = Uri.parse(_apiBaseUrl).replace(queryParameters: {
        'origins': '$originLat,$originLng',
        'destinations': '$destLat,$destLng',
        'mode': 'driving',
        'units': 'imperial', // Use miles for UK
        'key': _apiKey,
      });

      final response = await _httpClient.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Drive time request timed out'),
      );

      if (response.statusCode != 200) {
        _logger.warning(
            'Distance Matrix API error: ${response.statusCode} - ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Check API status
      final status = data['status'] as String?;
      if (status != 'OK') {
        final errorMsg = data['error_message'] as String?;
        _logger.warning('Distance Matrix API status: $status ${errorMsg != null ? "- $errorMsg" : ""}');
        return null;
      }

      // Parse the response
      final rows = data['rows'] as List<dynamic>?;
      if (rows == null || rows.isEmpty) {
        _logger.warning('No rows in Distance Matrix response');
        return null;
      }

      final elements = rows[0]['elements'] as List<dynamic>?;
      if (elements == null || elements.isEmpty) {
        _logger.warning('No elements in Distance Matrix response');
        return null;
      }

      final element = elements[0] as Map<String, dynamic>;
      final elementStatus = element['status'] as String?;

      if (elementStatus != 'OK') {
        _logger.warning('Distance Matrix element status: $elementStatus');
        return null;
      }

      // Extract distance and duration
      final distance = element['distance'] as Map<String, dynamic>?;
      final duration = element['duration'] as Map<String, dynamic>?;

      if (distance == null || duration == null) {
        _logger.warning('Missing distance or duration in response');
        return null;
      }

      final result = DriveTimeResult(
        durationSeconds: duration['value'] as int,
        durationText: duration['text'] as String,
        distanceMeters: distance['value'] as int,
        distanceText: distance['text'] as String,
      );

      // Cache the result
      _cache[key] = result;
      _cacheTimestamps[key] = DateTime.now();

      _logger.debug('Drive time result: $result');
      return result;
    } catch (e, stackTrace) {
      _logger.error('Error fetching drive time', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Clear all cached drive time results.
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _logger.debug('Drive time cache cleared');
  }

  /// Get the number of cached entries.
  int get cacheSize => _cache.length;
}
