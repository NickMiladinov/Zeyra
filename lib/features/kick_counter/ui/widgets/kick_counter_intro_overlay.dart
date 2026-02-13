import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_onboarding_provider.dart';
import 'package:zeyra/shared/widgets/app_overlay.dart';

/// Intro overlay shown when user first enters kick counter.
///
/// Displays:
/// - Title and subtitle explaining the feature
/// - Benefits list
/// - Illustration image
/// - "Got it!" button to dismiss and proceed
class KickCounterIntroOverlay extends ConsumerWidget {
  const KickCounterIntroOverlay({super.key});

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
      child: const KickCounterIntroOverlay(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Get to Know Their Rhythm',
          style: AppTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.gapMD),

        // Subtitle
        Text(
          "It's not just about counting - it's about learning what is normal for your baby.",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.gapXL),

        // Illustration image
        ClipRRect(
          borderRadius: AppEffects.roundedXL,
          child: Image.asset(
            'assets/images/KickCounterLanding.jpg',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image is not found
              return Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppEffects.roundedXL,
                ),
                child: Center(
                  child: AppIcons.baby(
                    size: AppSpacing.iconXXL,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
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
              ref.read(kickCounterOnboardingProvider.notifier).setHasStarted();
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
        _BenefitItem(text: 'Track daily movements'),
        SizedBox(height: AppSpacing.gapMD),
        _BenefitItem(text: 'Analyse your session trends'),
        SizedBox(height: AppSpacing.gapMD),
        _BenefitItem(text: 'Get alerts for changes in rhythm'),
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
            color: AppColors.primaryDark,
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

