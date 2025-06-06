import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/features/dashboard/ui/screens/main_screen.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final _forgotPasswordEmailController = TextEditingController(); // For forgot password dialog

  // Supabase client instance
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AuthResponse response;
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLoginMode) {
        response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        response = await _supabase.auth.signUp(
          email: email,
          password: password,
        );
        // Optionally, handle email confirmation if enabled in Supabase
      }

      if (mounted) {
        if (response.session != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else if (response.user != null && !_isLoginMode) {
          // User signed up, but requires confirmation (if enabled)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Sign up successful! Please check your email for confirmation.')),
          );
          // Optionally, navigate to a "please confirm email" page
          // or switch to login mode. For simplicity, we'll stay here.
          setState(() {
            _isLoginMode = true; // Switch to login mode after successful signup
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // For web, redirectTo can be null to use Supabase dashboard settings.
        // For mobile, specify your custom deep link.
        // This must be added to your Google Cloud Console Authorized Redirect URIs
        // and Supabase > Authentication > URL Configuration > Additional Redirect URLs.
        redirectTo: kIsWeb ? null : 'com.zeyra.app://login-callback',
      );

      // The auth state listener in main.dart will handle navigation to HomePage.
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred with Google Sign-In: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _forgotPasswordEmailController.text.trim();
    if (email.isEmpty) {
      // Could show a small inline error or rely on dialog validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        // This redirectTo is crucial. Supabase will append the necessary tokens.
        // It MUST be one of the URLs whitelisted in your Supabase project's
        // "Additional Redirect URLs" and match your deep link setup.
        redirectTo: 'com.zeyra.app://reset-password',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent! Check your inbox.')),
        );
        Navigator.of(context).pop(); // Close the dialog
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
        // Optionally keep the dialog open or re-show with error
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    _forgotPasswordEmailController.clear();
    _errorMessage = null; // Clear previous errors specific to the main form
    showDialog(
      context: context,
      builder: (context) {
        // Use a StatefulWidget for the dialog content if you need to manage its own state (like _isLoading specific to dialog)
        return AlertDialog(
          title: const Text('Forgot Password?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address and we will send you a link to reset your password.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _forgotPasswordEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail, // Can reuse existing email validator
              ),
              // Optionally show error message specific to this dialog action
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _handleForgotPassword, // This will use the main screen's _isLoading and _errorMessage
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
  }

  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null; // Clear error message when switching modes
      _formKey.currentState?.reset(); // Reset form fields
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email.';
    }
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Sign Up'),
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
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link (only in Login mode)
                  if (_isLoginMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _showForgotPasswordDialog,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                  const SizedBox(height: 16),

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

                  // Submit Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleAuth,
                          child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                        ),
                  const SizedBox(height: 16),

                  // Google Sign-In Button
                  _isLoading
                      ? const SizedBox.shrink() // Hide if already loading
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.login), // Placeholder, replace with Google icon
                          label: const Text('Continue with Google'),
                          onPressed: _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Google's typical button color
                            foregroundColor: Colors.black, // Text color
                          ),
                        ),
                  const SizedBox(height: 16),

                  // Toggle between Login/Sign Up
                  TextButton(
                    onPressed: _isLoading ? null : _toggleAuthMode,
                    child: Text(
                      _isLoginMode
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Login',
                    ),
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