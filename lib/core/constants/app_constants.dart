import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AppConstants {
  // Initialize the logger
  static final _logger = Logger();

  // Supabase Credentials
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';

  // Add other constants here as needed

  // Private constructor to prevent instantiation
  AppConstants._();

  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        _logger.w('.env file loaded but SUPABASE_URL or SUPABASE_ANON_KEY might be missing or empty.');
      }
    } catch (e, stackTrace) {
      _logger.e('Error loading .env file', error: e, stackTrace: stackTrace);
      // Provide default fallback or rethrow if critical
      // Depending on your app's needs, you might want to throw an exception here
      // if these values are absolutely necessary for the app to run.
      supabaseUrl = ''; // Fallback to empty or a default dev URL
      supabaseAnonKey = ''; // Fallback to empty or a default dev key
    }
  }
} 