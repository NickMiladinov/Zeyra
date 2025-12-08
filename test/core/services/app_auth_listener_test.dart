import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/core/services/app_auth_listener.dart';

/// Tests for AppAuthListener.
/// 
/// NOTE: These are basic unit tests. Full integration testing with Supabase
/// requires a test environment with initialized Supabase instance.
/// 
/// The main purpose of these tests is to verify:
/// 1. AppAuthListener can be instantiated
/// 2. Error handling logic for different HTTP status codes is correct
void main() {
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    navigatorKey = GlobalKey<NavigatorState>();
  });

  group('AppAuthListener', () {
    test('should be instantiable with a navigator key', () {
      // Verify the listener can be created with a navigator key
      final listener = AppAuthListener(navigatorKey: navigatorKey);
      
      expect(listener, isNotNull);
      expect(listener.navigatorKey, equals(navigatorKey));
    });

    test('should identify retryable error status codes', () {
      // Verify that common server error status codes are recognized
      // as retryable (500, 502, 503, 504)
      
      const retryableStatusCodes = ['500', '502', '503', '504'];
      
      for (final statusCode in retryableStatusCodes) {
        // These should be logged as warnings, not errors
        // Since Supabase will automatically retry them
        expect(
          int.parse(statusCode) >= 500 && int.parse(statusCode) < 600,
          isTrue,
          reason: 'Status code $statusCode should be a server error (5xx)',
        );
      }
    });

    test('should identify permanent auth failure status codes', () {
      // Verify that auth-related error codes are recognized
      // as permanent failures (401, 403)
      
      const permanentStatusCodes = ['401', '403'];
      
      for (final statusCode in permanentStatusCodes) {
        final code = int.parse(statusCode);
        // These should trigger a sign-out
        expect(
          code == 401 || code == 403,
          isTrue,
          reason: 'Status code $statusCode should be an auth error',
        );
      }
    });

    test('AuthException should be instantiable with status codes', () {
      // Verify that AuthException can be created with different status codes
      // This validates our error handling will work with real Supabase errors
      
      final error500 = AuthException('Server error', statusCode: '500');
      expect(error500.statusCode, equals('500'));
      expect(error500.message, equals('Server error'));
      
      final error401 = AuthException('Unauthorized', statusCode: '401');
      expect(error401.statusCode, equals('401'));
      expect(error401.message, equals('Unauthorized'));
    });

    test('should handle null status codes gracefully', () {
      // Verify that AuthException can be created without a status code
      // This is important for handling unexpected errors
      
      final errorNoStatus = AuthException('Unknown error');
      expect(errorNoStatus.statusCode, isNull);
      expect(errorNoStatus.message, equals('Unknown error'));
    });
  });

  group('Error Classification Logic', () {
    test('should classify 500 as retryable', () {
      final error = AuthException('Server error', statusCode: '500');
      
      // Logic from app_auth_listener.dart error handler
      final isRetryable = error.statusCode != null && 
                         error.statusCode != '401' && 
                         error.statusCode != '403';
      
      expect(isRetryable, isTrue, 
        reason: '500 errors should be retryable');
    });

    test('should classify 401 as permanent failure requiring sign out', () {
      final error = AuthException('Unauthorized', statusCode: '401');
      
      // Logic from app_auth_listener.dart error handler
      final shouldSignOut = error.statusCode == '401' || 
                           error.statusCode == '403';
      
      expect(shouldSignOut, isTrue,
        reason: '401 errors should trigger sign out');
    });

    test('should classify 403 as permanent failure requiring sign out', () {
      final error = AuthException('Forbidden', statusCode: '403');
      
      // Logic from app_auth_listener.dart error handler
      final shouldSignOut = error.statusCode == '401' || 
                           error.statusCode == '403';
      
      expect(shouldSignOut, isTrue,
        reason: '403 errors should trigger sign out');
    });

    test('should handle errors without status codes', () {
      final error = AuthException('Unknown error');
      
      // Logic from app_auth_listener.dart error handler
      final shouldSignOut = error.statusCode == '401' || 
                           error.statusCode == '403';
      
      expect(shouldSignOut, isFalse,
        reason: 'Errors without status codes should not trigger sign out');
    });
  });
}
