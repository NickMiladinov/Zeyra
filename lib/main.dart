import 'package:flutter/material.dart';
import 'package:zeyra/app/app.dart';
import 'package:zeyra/core/di/di_graph.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';

// Global logging service instance
// Initialized by DIGraph.initialize() during app startup
late final LoggingService logger;

/// App entry point.
/// 
/// Initializes all services via DIGraph before starting the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all services and get the navigator key
  // This handles: environment, Sentry, logging, encryption, Supabase, auth listener, preferences
  final navigatorKey = await DIGraph.initialize();

  // Run the app with the initialized navigator key
  runApp(App(navigatorKey: navigatorKey));
}
