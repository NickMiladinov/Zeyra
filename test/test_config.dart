/// Test configuration and constants.
/// This file contains configuration values and constants used across tests.

class TestConfig {
  // Test database configuration
  static const String testDatabaseName = 'test_database.db';
  
  // Test timeout values
  static const Duration defaultTestTimeout = Duration(seconds: 30);
  static const Duration integrationTestTimeout = Duration(minutes: 2);
  
  // Test user data
  static const String testUserEmail = 'test@example.com';
  static const String testUserPassword = 'testPassword123';
  
  // TODO: Add more test configuration as needed
}

