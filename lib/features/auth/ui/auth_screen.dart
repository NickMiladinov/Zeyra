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
import '../../../core/di/main_providers.dart';
import '../../../features/baby/logic/pregnancy_data_provider.dart';
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
  
  /// Flag to prevent concurrent calls to _handleAuthSuccess (race condition guard)
  bool _isHandlingAuth = false;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    // Check if already authenticated (e.g., returning from onboarding flow)
    _checkExistingAuth();
  }

  /// Check if user is already authenticated and handle accordingly.
  ///
  /// This handles the case where a user is already logged in but arrives
  /// at the auth screen (e.g., going through onboarding after logging in
  /// on a device that was previously onboarded by another user).
  Future<void> _checkExistingAuth() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      // User is already authenticated - process as if they just signed in
      await _handleAuthSuccess();
    }
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
  ///
  /// Checks if onboarding is complete in metadata AND verifies local entities exist.
  /// If metadata says complete but local entities are missing, re-runs finalization.
  Future<void> _handleAuthSuccess() async {
    if (!mounted) return;
    
    // Guard against concurrent calls (race condition from listener + checkExistingAuth)
    if (_isHandlingAuth) return;
    _isHandlingAuth = true;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authNotifierProvider);

      // Check if this user already completed onboarding (from Supabase metadata)
      await authNotifier.checkOnboardingStatus();

      if (authNotifier.hasCompletedOnboarding) {
        // Invalidate database provider to ensure we get the correct user's database.
        // This is critical when switching between accounts on the same device.
        // Without this, the cached database from a previous user could persist.
        ref.invalidate(appDatabaseProvider);
        
        // Metadata says complete - verify local entities actually exist
        final hasLocalEntities = await _verifyLocalEntitiesExist();
        
        if (hasLocalEntities) {
          // All good - ensure device is marked as onboarded and go to main app
          await authNotifier.markDeviceOnboarded();
          // Invalidate pregnancy provider to ensure fresh data is loaded
          ref.invalidate(pregnancyDataProvider);
          if (mounted) {
            context.go(MainRoutes.today);
          }
          return;
        }
        
        // Metadata says complete but local entities missing!
        // This can happen after reinstall or data loss.
        // Try to recreate entities using available onboarding data.
        final recreated = await _recreateLocalEntities();
        if (recreated) {
          // markDeviceOnboarded is called in finalizeOnboarding
          // Invalidate pregnancy provider to ensure fresh data is loaded
          ref.invalidate(pregnancyDataProvider);
          if (mounted) {
            context.go(MainRoutes.today);
          }
          return;
        }
        
        // Failed to recreate - show error
        if (mounted) {
          setState(() {
            _errorMessage = 'Your data could not be restored. Please complete setup again.';
            _isLoading = false;
          });
        }
        return;
      }

      // New user or incomplete onboarding - check if we have data to finalize
      final onboardingNotifier = await ref.read(onboardingNotifierProviderAsync.future);
      final data = onboardingNotifier.data;

      // Check if onboarding data is complete
      if (!data.isComplete) {
        // No complete onboarding data - redirect to onboarding flow
        // User is already authenticated, so they'll skip the auth step at the end
        if (mounted) {
          context.go(OnboardingRoutes.welcome);
        }
        return;
      }

      // We have complete data - finalize it
      
      // Invalidate auth-dependent providers to force re-creation with authenticated user.
      // The appDatabaseProvider checks currentUser and may have been cached as "no user"
      // before the sign-in completed.
      ref.invalidate(appDatabaseProvider);
      ref.invalidate(onboardingServiceProvider);
      
      final onboardingService = await ref.read(onboardingServiceProvider.future);
      final success = await onboardingService.finalizeOnboarding(data);

      if (success) {
        // Clear local onboarding data
        await onboardingNotifier.clearAfterFinalization();
        
        // Invalidate pregnancy provider to ensure fresh data is loaded
        // when the baby tab is accessed (prevents stale data from previous user)
        ref.invalidate(pregnancyDataProvider);

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
    } finally {
      // Always reset the guard flag to allow future auth attempts
      _isHandlingAuth = false;
    }
  }

  /// Verify that required local entities (UserProfile and Pregnancy) exist.
  Future<bool> _verifyLocalEntitiesExist() async {
    try {
      // Check for active pregnancy - this implicitly requires user profile too
      final getActivePregnancyUseCase = await ref.read(getActivePregnancyUseCaseProvider.future);
      final pregnancy = await getActivePregnancyUseCase.execute();
      return pregnancy != null;
    } catch (e) {
      return false;
    }
  }

  /// Attempt to recreate local entities using available onboarding data.
  ///
  /// This is a recovery path for users whose local data was lost but
  /// Supabase metadata says onboarding was completed.
  Future<bool> _recreateLocalEntities() async {
    try {
      final onboardingNotifier = await ref.read(onboardingNotifierProviderAsync.future);
      final onboardingService = await ref.read(onboardingServiceProvider.future);
      
      // Check if we have onboarding data to work with
      final data = onboardingNotifier.data;
      if (!data.isComplete) {
        // No complete onboarding data available - can't recreate
        return false;
      }
      
      // Try to recreate entities
      return await onboardingService.finalizeOnboarding(data);
    } catch (e) {
      return false;
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
