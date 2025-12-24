import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/widgets/app_accordion.dart';

/// Information screen about timing contractions during labour.
/// 
/// Provides NHS-based guidance on how to time contractions, 
/// the 5-1-1 rule, when to call your midwife, and what contractions feel like.
class ContractionTimerInfoScreen extends StatelessWidget {
  const ContractionTimerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'About Timing Contractions',
          style: AppTypography.headlineSmall,
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: AppColors.iconDefault),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro card
              Container(
                padding: const EdgeInsets.all(AppSpacing.paddingLG),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimaryVerySubtle,
                  borderRadius: AppEffects.roundedLG,
                  border: Border.all(
                    color: AppColors.borderPrimary,
                    width: AppSpacing.borderWidthThin,
                  ),
                ),
                child: Text(
                  'Timing contractions helps you understand your body\'s rhythm during labour. This guide is here to help you know when it might be time to call for professional advice.',
                  style: AppTypography.bodyMedium,
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapXL),
              
              // Accordion 1: How do I time contractions?
              AppAccordion(
                title: 'How do I time contractions?',
                initiallyExpanded: true,
                child: Text(
                  'This tool is designed to be very simple. When you feel a contraction begin to build, tap the large \'Start Contraction\' button. When the feeling subsides, tap the \'Stop\' button. The app will automatically calculate the duration (how long it lasted) and the frequency (the time from the start of one contraction to the start of the next). Once your contractions consistently meet the 5-1-1 rule, the app will alert you.',
                  style: AppTypography.bodyMedium,
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapMD),
              
              // Accordion 2: What is the "5-1-1 Rule"?
              AppAccordion(
                title: 'What is the "5-1-1 Rule"?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For many first-time mums, the \'5-1-1 Rule\' is a helpful guide to know when labour is becoming established. The app tracks this for you. It means:',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.gapLG),
                    _BulletPoint(
                      boldText: 'FREQUENCY: ',
                      text: 'Contractions are consistently coming every 5 minutes.',
                    ),
                    const SizedBox(height: AppSpacing.gapSM),
                    _BulletPoint(
                      boldText: 'DURATION: ',
                      text: 'They are lasting for around 1 minute (60 seconds).',
                    ),
                    const SizedBox(height: AppSpacing.gapSM),
                    _BulletPoint(
                      boldText: 'CONSISTENCY: ',
                      text: 'This pattern has been happening for over 1 hour.',
                    ),
                    const SizedBox(height: AppSpacing.gapLG),
                    Text(
                      'When your pattern matches this, the app will alert you that it might be time to call your midwife.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapMD),
              
              // Accordion 3: When should I call my midwife?
              AppAccordion(
                title: 'When should I call my midwife?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You should call your midwife or maternity unit for advice when your contractions are getting stronger, longer, and more frequent. Following the \'5-1-1 Rule\' is a good indicator for first-time pregnancies.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.gapLG),
                    Text(
                      'Always call immediately if:',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.gapMD),
                    const _SimpleBulletPoint(text: 'Your waters break.'),
                    const SizedBox(height: AppSpacing.gapSM),
                    const _SimpleBulletPoint(text: 'You are bleeding.'),
                    const SizedBox(height: AppSpacing.gapSM),
                    const _SimpleBulletPoint(
                      text: 'You are worried about your baby\'s movements.',
                    ),
                    const SizedBox(height: AppSpacing.gapSM),
                    const _SimpleBulletPoint(
                      text: 'You feel unwell or have a fever.',
                    ),
                    const SizedBox(height: AppSpacing.gapLG),
                    Text(
                      'Trust your instincts. It\'s always okay to call for advice, no matter what stage you are at. They are there to help you 24/7.',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapMD),
              
              // Accordion 4: What does a contraction feel like?
              AppAccordion(
                title: 'What does a contraction feel like?',
                child: Text(
                  'Early contractions can feel like period pains or a tightening feeling across your bump that comes and goes. They are different for everyone. As labour progresses, they will become stronger, longer, and more regular. You won\'t be able to talk through them at their peak. Braxton Hicks, or \'practice contractions\', are usually irregular and don\'t increase in strength.',
                  style: AppTypography.bodyMedium,
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapXXL),
              
              // Spacer to push content to bottom
              const SizedBox(height: AppSpacing.gapXXL),
              
              // NHS Links section - pushed to bottom
              Text(
                'All information is based on the latest guidance from the NHS. For more detailed information, please refer to the official sources below.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapLG),
              
              // Link placeholders
              const _NHSLinkPlaceholder(
                title: 'NHS - Signs that labour has begun',
              ),
              const SizedBox(height: AppSpacing.gapMD),
              const _NHSLinkPlaceholder(
                title: 'Tommy\'s - The stages of labour and birth',
              ),
              
              const SizedBox(height: AppSpacing.gapXXL),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bullet point widget for list items with bold prefix text.
class _BulletPoint extends StatelessWidget {
  final String? boldText;
  final String text;

  const _BulletPoint({
    this.boldText,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: AppTypography.bodyMedium,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyMedium,
              children: [
                if (boldText != null)
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Simple bullet point widget for list items.
class _SimpleBulletPoint extends StatelessWidget {
  final String text;

  const _SimpleBulletPoint({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: AppTypography.bodyMedium,
        ),
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

/// Placeholder widget for NHS resource links.
/// 
/// Will be implemented with actual links in future iteration.
class _NHSLinkPlaceholder extends StatelessWidget {
  final String title;

  const _NHSLinkPlaceholder({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gapSM),
        Icon(
          AppIcons.newTab,
          size: AppSpacing.iconSM,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

