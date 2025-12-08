import 'dart:io';

/// Loads JSON and sample test data from fixture files.
/// Use this to load test data for unit and integration tests.

class Fixtures {
  /// Load a fixture file from the test/fixtures directory.
  static Future<String> loadFixture(String fileName) async {
    final file = File('test/fixtures/$fileName');
    return await file.readAsString();
  }

  // Example:
  // static Future<UserProfile> loadUserProfile() async {
  //   final json = await loadFixture('user_profile.json');
  //   return UserProfile.fromJson(jsonDecode(json));
  // }
}

