import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 1: Welcome screen introducing Zeyra.
///
/// Features:
/// - "Hi, I'm Zeyra" heading with wavy underline
/// - Subtitle explaining the app purpose
/// - Zeyra mascot image
/// - Primary "Hi, Zeyra →" button to continue
/// - "I already have an account" link for existing users
class WelcomeScreen extends ConsumerWidget {
  /// Creates the welcome screen.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(onboardingNotifierProviderAsync);

    return onboardingAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: Text('Error: $error')),
      ),
      data: (notifier) => OnboardingScaffold(
        progress: 0.0, // First screen
        showBackButton: false, // No back button on first screen
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.gapXL),

            // "Hi, I'm Zeyra" with wavy underline
            UnderlinedText(
              text: "Hi, I'm Zeyra",
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppSpacing.gapXS),

            // Subtitle
            Text(
              "I'm here to guide you through your  pregnancy journey.",
              style: AppTypography.headlineLarge,
            ),

            // Mascot image - takes remaining space
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.paddingXL,
                  ),
                  child: Image.asset(
                    'assets/images/OnboardingWelcome.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomAction: OnboardingPrimaryButton(
          label: 'Hi, Zeyra',
          onPressed: () async {
            await notifier.nextStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.name);
            }
          },
        ),
        secondaryAction: GestureDetector(
          onTap: () {
            // Navigate directly to auth - the auth screen handles returning users
            // by checking Supabase metadata for onboarding completion status
            context.go(AuthRoutes.auth);
          },
          child: Text(
            'I already have an account',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
