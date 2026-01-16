import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../logic/onboarding_notifier.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 9: Notification permission request.
///
/// Features:
/// - "Stay in the loop" heading with "loop" underlined
/// - Description about notification benefits
/// - Phone with notification illustration
/// - "Maybe Later" (outlined) and "Allow →" (filled) buttons
class NotificationsScreen extends ConsumerWidget {
  /// Creates the notifications screen.
  const NotificationsScreen({super.key});

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
        // Calculate progress: screen 9 of 11 (index 8)
        const progress = 8 / 10;

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.birthDate);
            }
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.gapMD),

              // Heading with underlined "loop"
              _buildHeading(),

              const SizedBox(height: AppSpacing.gapMD),

              // Description
              Text(
                'Enable notifications to get timely reminders for appointments, weekly baby updates, and daily checklists. We promise to only send what matters.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),

              // Phone illustration - takes remaining space
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.paddingMD,
                    ),
                    child: Image.asset(
                      'assets/images/OnboardingNotifications.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomAction: _ActionButtons(
            onMaybeLater: () => _handleMaybeLater(context, notifier),
            onAllow: () => _handleAllow(context, notifier),
          ),
        );
      },
    );
  }

  Widget _buildHeading() {
    final baseStyle = AppTypography.headlineLarge.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Stay in the ', style: baseStyle),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: UnderlinedText(
              text: 'loop',
              style: baseStyle.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMaybeLater(
    BuildContext context,
    OnboardingNotifier notifier,
  ) async {
    await notifier.skipNotificationPermission();
    await notifier.nextStep();
    if (context.mounted) {
      context.go(OnboardingRoutes.paywall);
    }
  }

  Future<void> _handleAllow(
    BuildContext context,
    OnboardingNotifier notifier,
  ) async {
    await notifier.requestNotificationPermission();
    await notifier.nextStep();
    if (context.mounted) {
      context.go(OnboardingRoutes.paywall);
    }
  }
}

/// Side-by-side action buttons for notifications screen.
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onMaybeLater,
    required this.onAllow,
  });

  final VoidCallback onMaybeLater;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Maybe Later - outlined button
        Expanded(
          child: SizedBox(
            height: AppSpacing.buttonHeightXXL,
            child: OutlinedButton(
              onPressed: onMaybeLater,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(
                  color: AppColors.textPrimary,
                  width: AppSpacing.borderWidthThin,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppEffects.roundedCircle,
                ),
              ),
              child: Text(
                'Maybe Later',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.gapMD),

        // Allow - filled button
        Expanded(
          child: OnboardingPrimaryButton(
            label: 'Allow',
            onPressed: onAllow,
          ),
        ),
      ],
    );
  }
}
