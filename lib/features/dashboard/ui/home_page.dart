import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// No explicit import needed for AuthScreen here, navigation is handled by main.dart's auth listener

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Function to handle user logout
  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      // After signOut, the auth state listener in main.dart will handle navigation
      // to the AuthScreen automatically.
      // You don't typically need an explicit Navigator.pushReplacement here if using
      // an auth state listener that rebuilds the widget tree.
    } on AuthException catch (e) {
      // Handle potential errors during sign out, e.g., show a SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle other unexpected errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred during logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context), // Call the logout function
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome! You are logged in.'),
      ),
    );
  }
} 