import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/features/auth/ui/widgets/auth_gate.dart';
import 'package:zeyra/app/theme/app_theme.dart';

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const App({super.key, required this.navigatorKey}); // Add navigatorKey to constructor

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
      ),
    );
  }
} 