import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/router/auth_notifier.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_effects.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../features/onboarding/logic/onboarding_providers.dart';

/// Authentication screen with OAuth-only login (Apple + Google).
///
/// This screen is used at the end of onboarding to create an account.
/// After successful authentication:
/// 1. Checks if onboarding was completed
/// 2. If not, finalizes onboarding (creates UserProfile + Pregnancy)
/// 3. Navigates to main app
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Listen for auth state changes to handle OAuth callback.
  void _setupAuthListener() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _handleAuthSuccess();
      }
    });
  }

  /// Handle successful authentication.
  Future<void> _handleAuthSuccess() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authNotifierProvider);

      // Check if this user already completed onboarding
      await authNotifier.checkOnboardingStatus();

      if (authNotifier.hasCompletedOnboarding) {
        // Existing user - go to main app
        if (mounted) {
          context.go(MainRoutes.today);
        }
        return;
      }

      // New user or incomplete onboarding - finalize it
      final onboardingNotifier = await ref.read(onboardingNotifierProviderAsync.future);
      final onboardingService = await ref.read(onboardingServiceProvider.future);

      // Get the collected onboarding data
      final data = onboardingNotifier.data;

      // Finalize onboarding (create UserProfile + Pregnancy)
      final success = await onboardingService.finalizeOnboarding(data);

      if (success) {
        // Clear local onboarding data
        await onboardingNotifier.clearAfterFinalization();

        if (mounted) {
          context.go(MainRoutes.today);
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to complete setup. Please try again.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  /// Sign in with Google OAuth.
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.zeyra.app://login-callback',
      );
      // Auth listener will handle the callback
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred with Google Sign-In';
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
        redirectTo: kIsWeb ? null : 'com.zeyra.app://login-callback',
      );
      // Auth listener will handle the callback
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred with Apple Sign-In';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingHorizontal,
            vertical: AppSpacing.screenPaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.gapXXL),

              // Heading
              Text(
                "Let's Secure Your Journey",
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 26,                
                ),
              ),

              const SizedBox(height: AppSpacing.gapSM),

              // Subtitle
              Text(
                'Create an account to save your progress and keep your data safe.',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 18,
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.gapLG),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppEffects.roundedMD,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],

              // Mascot image
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.paddingLG,
                    ),
                    child: Image.asset(
                      'assets/images/OnboardingAuth.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // OAuth buttons
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.paddingXL),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                // Sign in with Apple - Black button variant
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeightXXL,
                  child: SignInButton(
                    Buttons.appleDark,
                    onPressed: _signInWithApple,
                    text: 'Sign in with Apple',
                    shape: RoundedRectangleBorder(
                      borderRadius: AppEffects.roundedCircle,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.gapXL),

                // Sign in with Google - Official styling from sign_in_button
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeightXXL,
                  child: SignInButton(
                    Buttons.googleDark,
                    onPressed: _signInWithGoogle,
                    text: 'Sign in with Google',
                    shape: RoundedRectangleBorder(
                      borderRadius: AppEffects.roundedCircle,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.screenPaddingVertical),
            ],
          ),
        ),
      ),
    );
  }

}
