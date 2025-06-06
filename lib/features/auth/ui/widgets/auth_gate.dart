import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../screens/auth_screen.dart'; // Previous attempt
import 'package:zeyra/features/auth/ui/auth_screen.dart'; // Package-relative path
import 'package:zeyra/features/dashboard/ui/screens/main_screen.dart'; // Your main app screen with BottomNavBar

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show a loading indicator while waiting for the auth state
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal), // Match your theme
              ),
            ),
          );
        }

        final authState = snapshot.data;
        final session = authState?.session;

        if (session != null) {
          // User is signed in, show the main application screen
          return const MainScreen();
        } else {
          // User is not signed in, show the authentication screen
          return const AuthScreen();
        }
      },
    );
  }
} 