import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../shared/widgets/app_accordion.dart';

/// Information screen about baby's movements and kick counting.
/// 
/// Provides NHS-based guidance on when to feel movements, what's normal,
/// when to worry, and answers common questions.
class KickCounterInfoScreen extends StatelessWidget {
  const KickCounterInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'About Your Baby\'s Movements',
          style: AppTypography.headlineSmall,
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: AppColors.iconDefault),
          onPressed: () => context.pop(),
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
                  'Feeling your baby move is a sign that they are well. This guide is here to help you understand your baby\'s unique pattern. Remember, the most important thing is to trust your instincts.',
                  style: AppTypography.bodyMedium,
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapXL),
              
              // Accordion 1: When will I feel my baby move?
              AppAccordion(
                title: 'When will I feel my baby move?',
                initiallyExpanded: true,
                child: Text(
                  'You should start to feel your baby move between 16 and 24 weeks of pregnancy. If this is your first baby, you might not feel movements until after 20 weeks. The movements can feel like a gentle swirling or fluttering at first. If you have not felt your baby move by 24 weeks, you should contact your midwife.',
                  style: AppTypography.bodyMedium,
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapMD),
              
              // Accordion 2: Understanding Your Baby's Pattern
              AppAccordion(
                title: 'Understanding Your Baby\'s Pattern',
                child: Text(
                  'There is no set number of movements you should feel each day—every baby is different. This tool helps you learn your baby\'s unique pattern by timing how long it takes to feel a set number of movements (you can change the target number in settings).\n\n'
                  'Find a time when your baby is usually active (often after a meal or in the evening), relax on your left side, and start a session. Tap for every kick, flutter, swish, or roll you feel. Over time, the \'History & Patterns\' screen will show you what\'s normal for your baby.',
                  style: AppTypography.bodyMedium,
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapMD),
              
              // Accordion 3: When should I be worried?
              AppAccordion(
                title: 'When should I be worried?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Call your midwife or maternity unit immediately if:',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.gapMD),
                    _BulletPoint(
                      text: 'Your baby is moving less than usual.',
                    ),
                    const SizedBox(height: AppSpacing.gapSM),
                    _BulletPoint(
                      text: 'You cannot feel your baby moving anymore.',
                    ),
                    const SizedBox(height: AppSpacing.gapSM),
                    _BulletPoint(
                      text: 'There is a significant change to your baby\'s usual pattern of movements.',
                    ),
                    const SizedBox(height: AppSpacing.gapLG),
                    RichText(
                      text: TextSpan(
                        style: AppTypography.bodyMedium,
                        children: const [
                          TextSpan(
                            text: 'Do not wait until the next day—call immediately, even if it\'s the middle of the night. ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: 'It is NOT true that babies move less towards the end of pregnancy. You should continue to feel your baby move right up to and during labour.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.gapMD),
              
              // Accordion 4: What is normal?
              AppAccordion(
                title: 'What is normal?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Do I need to count kicks every day?',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.gapSM),
                    Text(
                      'No, you do not need to count kicks every single day. The important thing is to be aware of your baby\'s movements from day to day. Use this tool whenever you want to check in and focus on their pattern.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.gapLG),
                    Text(
                      'My placenta is at the front (anterior).',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.gapSM),
                    Text(
                      'If your placenta is at the front, it can be harder to feel movements, especially early on. You will still develop a pattern, but it might take longer to notice.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
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
                title: 'NHS - Your baby\'s movements in pregnancy',
              ),
              const SizedBox(height: AppSpacing.gapMD),
              const _NHSLinkPlaceholder(
                title: 'Kicks Count - Your Baby\'s Movements',
              ),
              
              const SizedBox(height: AppSpacing.gapXXL),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bullet point widget for list items.
class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({
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

