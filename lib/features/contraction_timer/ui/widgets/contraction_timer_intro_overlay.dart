import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_timer_onboarding_provider.dart';
import 'package:zeyra/shared/widgets/app_overlay.dart';

/// Intro overlay shown when user first enters contraction timer.
///
/// Displays:
/// - Title and subtitle explaining the feature
/// - Benefits list
/// - Illustration
/// - "Got it!" button to dismiss and proceed
class ContractionTimerIntroOverlay extends ConsumerWidget {
  const ContractionTimerIntroOverlay({super.key});

  /// Show the intro overlay
  ///
  /// Returns `true` if user tapped the button to proceed,
  /// `false` or `null` if dismissed otherwise.
  static Future<bool?> show(BuildContext context) {
    return AppOverlay.show<bool>(
      context: context,
      showCloseButton: true,
      dismissOnTapOutside: false,
      barrierDismissible: false,
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.paddingXL,
        AppSpacing.screenPaddingVerticalXL,
        AppSpacing.paddingXL,
        AppSpacing.paddingXL,
      ),
      child: const ContractionTimerIntroOverlay(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon illustration
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.gapXL),

        // Title
        Text(
          'When you feel a contraction begin, we\'re ready.',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.gapMD),

        // Subtitle
        Text(
          'Find a comfortable position. We\'ll handle the tracking.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.gapXL),

        // Benefits list
        const _BenefitsList(),

        const SizedBox(height: AppSpacing.gapXL),

        // "Got it!" button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              // Mark onboarding as completed
              ref.read(contractionTimerOnboardingProvider.notifier).setHasStarted();
              Navigator.of(context).pop(true);
            },
            child: const Text('Got it!'),
          ),
        ),
      ],
    );
  }
}

/// Benefits list widget showing key features
class _BenefitsList extends StatelessWidget {
  const _BenefitsList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _BenefitItem(text: 'Smart 5-1-1 Tracking'),
        SizedBox(height: AppSpacing.gapMD),
        _BenefitItem(text: 'Flexible Session Logs'),
        SizedBox(height: AppSpacing.gapMD),
        _BenefitItem(text: 'Instant Labor Stats'),
      ],
    );
  }
}

/// Single benefit item with check icon
class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.paddingXS),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            AppIcons.checkIcon,
            size: AppSpacing.iconXS,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.gapMD),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium,
          ),
        ),
      ],
    );
  }
}

