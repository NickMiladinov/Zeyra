import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:zeyra/features/auth/ui/widgets/auth_gate.dart';
import 'package:zeyra/shared/widgets/active_tracker_banner_overlay.dart';
import 'package:zeyra/app/theme/app_theme.dart';
import 'package:zeyra/main.dart' show logger;

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const App({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire application with ProviderScope for Riverpod state management
    return ProviderScope(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Zeyra Health App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        // Navigation observer for logging route changes
        navigatorObservers: [
          TalkerRouteObserver(logger.talker),
        ],
        // Wrap all routes with unified banner overlay for active trackers
        // Shows appropriate banner (kick counter or contraction timer) based on active session
        builder: (context, child) {
          return ActiveTrackerBannerOverlay(
            navigatorKey: navigatorKey,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
