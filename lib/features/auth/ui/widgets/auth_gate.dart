import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/features/auth/ui/auth_screen.dart';
import 'package:zeyra/features/dashboard/ui/screens/main_screen.dart';

/// A widget that checks the initial authentication state when the app starts.
/// All subsequent dynamic navigation is handled by the global AppAuthListener.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null ? const MainScreen() : const AuthScreen();
  }
} 