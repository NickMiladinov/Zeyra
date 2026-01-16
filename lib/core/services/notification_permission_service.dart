import 'package:permission_handler/permission_handler.dart';

import '../monitoring/logging_service.dart';

/// Service for managing notification permissions.
///
/// Handles requesting and checking notification permission status.
/// Used during onboarding and for later permission management.
class NotificationPermissionService {
  final LoggingService _logger;

  NotificationPermissionService(this._logger);

  /// Request notification permission from the user.
  ///
  /// Returns true if permission was granted, false otherwise.
  /// On Android 12 and below, notifications are granted by default.
  Future<bool> requestPermission() async {
    try {
      _logger.info('Requesting notification permission');

      final status = await Permission.notification.request();

      final granted = status.isGranted;
      _logger.info('Notification permission ${granted ? 'granted' : 'denied'}');

      return granted;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to request notification permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Check if notification permission is currently granted.
  Future<bool> isPermissionGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      _logger.warning('Failed to check notification permission: $e');
      return false;
    }
  }

  /// Check if permission was permanently denied.
  ///
  /// If true, user must enable notifications from system settings.
  Future<bool> isPermanentlyDenied() async {
    try {
      final status = await Permission.notification.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      _logger.warning('Failed to check permanent denial status: $e');
      return false;
    }
  }

  /// Open app settings for user to enable notifications manually.
  ///
  /// Returns true if settings were opened successfully.
  Future<bool> openSettings() async {
    try {
      _logger.info('Opening app settings for notification permission');
      return await openAppSettings();
    } catch (e) {
      _logger.warning('Failed to open app settings: $e');
      return false;
    }
  }
}
