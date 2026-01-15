import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_effects.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

/// Authentication screen with OAuth-only login (Apple + Google).
///
/// Users authenticate via their Apple or Google accounts. Password management
/// is handled by the OAuth providers, so no email/password or password reset
/// functionality is needed.
///
/// After successful authentication, the [AuthNotifier] will notify go_router,
/// which will automatically redirect to the main screen (or onboarding).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  final _supabase = Supabase.instance.client;

  /// Sign in with Google OAuth.
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
        redirectTo: kIsWeb ? null : 'com.zeyra.app://login-callback',
      );

      // The auth state listener (AuthNotifier) will handle navigation
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

  /// Sign in with Apple OAuth.
  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        // For web, redirectTo can be null to use Supabase dashboard settings.
        // For mobile, specify your custom deep link.
        redirectTo: kIsWeb ? null : 'com.zeyra.app://login-callback',
      );

      // The auth state listener (AuthNotifier) will handle navigation
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred with Apple Sign-In: $e';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.paddingXL),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App branding/logo
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.paddingMD),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.gapXL),
                  ],

                  // OAuth buttons
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    _buildAppleButton(),
                    const SizedBox(height: AppSpacing.gapMD),
                    _buildGoogleButton(),
                  ],

                  const SizedBox(height: AppSpacing.xxxl),

                  // Terms and privacy notice
                  _buildTermsNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App logo placeholder
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppEffects.radiusXL),
          ),
          child: Icon(
            Icons.health_and_safety_rounded,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.gapXL),
        Text(
          'Welcome to Zeyra',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.gapSM),
        Text(
          'Your secure pregnancy health companion',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAppleButton() {
    return SizedBox(
      height: AppSpacing.buttonHeightLG,
      child: ElevatedButton.icon(
        onPressed: _signInWithApple,
        icon: const Icon(Icons.apple_rounded, size: 24),
        label: Text(
          'Continue with Apple',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEffects.radiusMD),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: AppSpacing.buttonHeightLG,
      child: OutlinedButton.icon(
        onPressed: _signInWithGoogle,
        icon: Image.network(
          'https://www.google.com/favicon.ico',
          width: 20,
          height: 20,
          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
        ),
        label: Text(
          'Continue with Google',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEffects.radiusMD),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsNotice() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
