import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget.
///
/// Uses [MaterialApp.router] with go_router for declarative routing.
/// Authentication state changes trigger automatic route redirects via
/// [AuthNotifier] and [GoRouter.refreshListenable].
///
/// The bottom navigation shell ([MainShell]) handles the active tracker
/// banner overlay, replacing the previous [ActiveTrackerBannerOverlay]
/// implementation.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Zeyra Health App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
