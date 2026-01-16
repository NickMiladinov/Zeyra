import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 5: Value Proposition 1 - Your Personal Midwife.
///
/// Features:
/// - "Your Personal Midwife" title
/// - Mascot with tablet showing health data
/// - "Powered by your own data & NHS guidelines." heading
/// - Description about uploading documents and personalised answers
class ValueProp1Screen extends ConsumerWidget {
  /// Creates the value prop 1 screen.
  const ValueProp1Screen({super.key});

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
        // Calculate progress: screen 5 of 11 (index 4)
        const progress = 4 / 10;

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.congratulations);
            }
          },
          body: Column(
            children: [
              const SizedBox(height: AppSpacing.gapMD),

              // Title
              Text(
                'Your Personal Midwife',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              // Mascot image - takes flexible space
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.paddingMD,
                  ),
                  child: Image.asset(
                    'assets/images/OnboardingValueProp1.png',
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
                      'Powered by your own data & NHS guidelines.',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.gapMD),

                    // Description
                    Text(
                      'Securely upload all your medical documents, giving you personalised answers instantly. Prepare for your appointments with smart reminders, ensuring you know exactly what to do at every step of your journey.',
                      style: AppTypography.bodyLarge.copyWith(
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
                context.go(OnboardingRoutes.valueProp2);
              }
            },
          ),
        );
      },
    );
  }
}
