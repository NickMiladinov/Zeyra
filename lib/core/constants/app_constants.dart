import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Supabase Credentials
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';
  
  // Sentry Configuration
  static String sentryDsn = '';

  // Add other constants here as needed

  // Private constructor to prevent instantiation
  AppConstants._();

  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';

      // Note: Logging now handled by centralized logging service
      // Will be initialized after this method completes
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        // ignore: avoid_print
        print('Warning: .env file loaded but SUPABASE_URL or SUPABASE_ANON_KEY might be missing or empty.');
      }
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('Error loading .env file: $e\n$stackTrace');
      // Provide default fallback or rethrow if critical
      // Depending on your app's needs, you might want to throw an exception here
      // if these values are absolutely necessary for the app to run.
      supabaseUrl = ''; // Fallback to empty or a default dev URL
      supabaseAnonKey = ''; // Fallback to empty or a default dev key
      sentryDsn = ''; // Fallback to empty (Sentry will be disabled)
    }
  }
} 