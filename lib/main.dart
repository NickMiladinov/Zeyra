import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/di/di_graph.dart';
import 'core/monitoring/logging_service.dart';

// Global logging service instance
// Initialized by DIGraph.initialize() during app startup
late final LoggingService logger;

/// App entry point.
///
/// Initializes all services via DIGraph before starting the app.
/// Navigation is handled by go_router with declarative routing.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all services (environment, Sentry, logging, encryption, Supabase, preferences)
  // Note: Auth state is now managed by AuthNotifier with go_router, not AppAuthListener
  await DIGraph.initialize();

  // Run the app with ProviderScope for Riverpod state management
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
