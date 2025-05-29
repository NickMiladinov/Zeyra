import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // The user is already in a password recovery session handled by Supabase client
      // after being redirected from the email link.
      await _supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );
      setState(() {
        _successMessage = 'Password updated successfully! You can now log in with your new password.';
        // Optionally, navigate back to login or show a button to go to login
        // For now, we'll just show the message.
      });
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (_successMessage == null) ...[
                    Text(
                      'Enter your new password below.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // New Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'New Password'),
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // Confirm New Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(labelText: 'Confirm New Password'),
                      obscureText: true,
                      validator: _validateConfirmPassword,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Error Message Display
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Success Message Display
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                  // Submit Button or Back to Login Button
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_successMessage != null)
                     ElevatedButton(
                        onPressed: () {
                           // Navigate back to the login screen
                           // This assumes AuthScreen is the root when not logged in.
                           Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Back to Login'),
                      )
                  else
                    ElevatedButton(
                      onPressed: _handlePasswordReset,
                      child: const Text('Set New Password'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 