import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../data/weekly_insights.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 4: Congratulations screen showing gestational week and insight.
///
/// Features:
/// - "Congratulations, [Name]!" heading with wavy underline
/// - "You're in week X" with large week number
/// - Weekly development insight
/// - Zeyra mascot holding baby image
class CongratulationsScreen extends ConsumerWidget {
  /// Creates the congratulations screen.
  const CongratulationsScreen({super.key});

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
        // Calculate progress: screen 4 of 11 (index 3)
        const progress = 3 / 10;

        final name = notifier.data.firstName ?? 'Mum';
        final week = notifier.data.gestationalWeek;
        final insight = getWeeklyInsight(week);

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.dueDate);
            }
          },
          body: Column(
            children: [
              const SizedBox(height: AppSpacing.gapMD),

              // Congratulations heading with name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UnderlinedText(
                    text: 'Congratulations, $name!',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapXS),
                  Text(
                    "You're",
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // "in week" text
              Text(
                'in week',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.gapSM),

              // Large week number
              Text(
                '$week',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w400,
                  fontSize: 72,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: AppSpacing.gapLG),

              // Weekly insight
              Text(
                'Right now, $insight',
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              // Mascot with baby image - takes remaining space
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.paddingLG,
                    ),
                    child: Image.asset(
                      'assets/images/OnboardingDueDate.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomAction: OnboardingPrimaryButton(
            label: 'Continue',
            onPressed: () async {
              await notifier.nextStep();
              if (context.mounted) {
                context.go(OnboardingRoutes.valueProp1);
              }
            },
          ),
        );
      },
    );
  }
}
