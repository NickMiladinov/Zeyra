import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_onboarding_provider.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_active_session_screen.dart';

class KickCounterLandingScreen extends ConsumerWidget {
  const KickCounterLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kick Counter', style: AppTypography.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(AppIcons.back, size: AppSpacing.iconMD, color: AppColors.iconDefault),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingLG),
          child: Column(
            children: [
              // Illustration
              // Placeholder for the illustration in image.png
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant, // Placeholder color
                    borderRadius: BorderRadius.circular(AppEffects.radiusLG),
                    // image: DecorationImage(image: AssetImage('assets/images/kick_counter_landing.png')), // TODO: Add photo and remove icon
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.baby_changing_station, size: AppSpacing.iconXXL, color: AppColors.primary), // Temporary icon
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapXL),

              // Title
              Text(
                'Get to Know Their Rhythm',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.gapMD),

              // Description
              Text(
                'It’s not just about counting - it’s about learning what is normal for your baby.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.gapXL),

              // Benefits List
              Expanded(
                flex: 3,
              child: Column(
                children: [
                   _BenefitItem(text: 'Track daily movements'),
                   SizedBox(height: AppSpacing.gapMD),
                   _BenefitItem(text: 'Analyse your session trends'),
                   SizedBox(height: AppSpacing.gapMD),
                   _BenefitItem(text: 'Get alerts for changes in rhythm'),
                ],
              ),
              ),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(kickCounterOnboardingProvider.notifier).setHasStarted();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const KickActiveSessionScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6CBFB2), // Teal color from image
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppEffects.radiusXL),
                    ),
                  ),
                  child: Text(
                    'Start Tracking',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.gapMD),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(AppIcons.checkIcon, size: AppSpacing.iconMD, color: AppColors.primary),
        const SizedBox(width: AppSpacing.gapSM),
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

