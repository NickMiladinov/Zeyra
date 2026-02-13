import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/di_graph.dart';
import '../../../../core/di/main_providers.dart';
import '../../../../main.dart' show logger;

/// Home screen (Today tab).
///
/// The bottom navigation bar is provided by [MainShell].
/// Auth state changes are handled by [AuthNotifier] which will redirect
/// to the auth screen on sign out.
///
/// On mount, triggers background incremental sync for maternity units
/// to fetch any updates from the remote server.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: Trigger incremental sync in background
    // This fetches any updates from Supabase since last sync
    _performBackgroundSync();
  }

  /// Initialize and sync maternity unit data in background.
  ///
  /// Runs async without blocking the UI. This handles:
  /// 1. Initial asset load (if database is empty or outdated)
  /// 2. Incremental sync from Supabase for any updates
  ///
  /// Errors are logged but don't affect the user experience - data can be synced later.
  void _performBackgroundSync() {
    Future(() async {
      try {
        // Guard: Only sync if user is authenticated
        // HomeScreen can be briefly mounted during route transitions before auth redirect
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          logger.debug('Skipping background sync - no authenticated user');
          return;
        }

        final syncService = await ref.read(maternityUnitSyncServiceProvider.future);
        // Use initialize() which handles both initial load and incremental sync
        await syncService.initialize();
        logger.debug('Background data sync completed');
      } catch (e, stackTrace) {
        // Log but don't show error to user - this is non-critical background work
        logger.warning(
          'Background data sync failed (will retry later)',
          error: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // Clear encryption keys from memory to prevent unauthorized access.
      // Keys are still stored securely and will be retrieved on next login.
      // Note: Provider invalidation happens on login (auth_screen.dart) to ensure
      // the correct user's database is opened and data is refreshed.
      DIGraph.clearEncryptionCache();

      // Clear database cache to ensure fresh instance on next login
      await clearDatabaseCache();

      await Supabase.instance.client.auth.signOut();
      // AuthNotifier will handle the redirect to auth screen
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Zeyra',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Your secure health companion.\nManage medical files and track biomarkers with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
      // Bottom nav bar is provided by MainShell
    );
  }
} 