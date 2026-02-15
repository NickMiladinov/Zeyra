import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 2: Value Proposition - Find Your Perfect Place.
///
/// Features:
/// - Mascot with tracking/timeline visuals
/// - "Track Your Journey" heading
/// - Description about tracking pregnancy milestones
class ValueProp3Screen extends ConsumerWidget {
  /// Creates the value prop 3 screen.
  const ValueProp3Screen({super.key});

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
      data: (notifier) {
        const progress = 0.5;

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.welcome);
            }
          },
          body: Column(
            children: [
              // Mascot image - takes flexible space at top
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.paddingMD,
                  ),
                  child: Image.asset(
                    'assets/images/OnboardingValueProp3.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Text content at bottom
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bold heading
                    Text(
                      'Find Your Perfect Place',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.gapMD),

                    // Description
                    Text(
                      'Discover local maternity units rated by real NHS data. Compare birth options, facilities, and patient feedback to choose the hospital that feels right for you.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomAction: OnboardingPrimaryButton(
            label: 'Next',
            onPressed: () async {
              await notifier.nextStep();
              if (context.mounted) {
                context.go(OnboardingRoutes.auth);
              }
            },
          ),
        );
      },
    );
  }
}
