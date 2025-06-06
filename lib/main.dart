import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/core/constants/app_constants.dart';
import 'package:zeyra/app.dart'; // Import the App widget

// Global NavigatorKey - can be used by App widget
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await AppConstants.loadEnv();

  // Initialize Supabase with values from AppConstants
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  // Run the App widget, which contains ProviderScope and MaterialApp
  runApp(App(navigatorKey: navigatorKey)); // Pass navigatorKey to App
}
