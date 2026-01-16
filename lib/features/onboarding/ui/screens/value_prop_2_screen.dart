import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 6: Value Proposition 2 - Find Your Perfect Place.
///
/// Features:
/// - Mascot with hospital stats and rating bubbles
/// - "Find Your Perfect Place" heading
/// - Description about discovering local maternity units with NHS data
class ValueProp2Screen extends ConsumerWidget {
  /// Creates the value prop 2 screen.
  const ValueProp2Screen({super.key});

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
        // Calculate progress: screen 6 of 11 (index 5)
        const progress = 5 / 10;

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.valueProp1);
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
                    'assets/images/OnboardingValueProp2.png',
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
                      'All Your Tools in One Place',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.gapMD),

                    // Description
                    Text(
                      'From your baby\'s first kick to your final contraction, track every milestone with confidence. We\'ve built everything you need to feel ready for the big day.',
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
                context.go(OnboardingRoutes.valueProp3);
              }
            },
          ),
        );
      },
    );
  }
}
