import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// "Next Steps" checklist section for the hospital workspace.
class HospitalShortlistChecklistSection extends StatelessWidget {
  final bool hasShortlist;
  final bool hasFinalChoice;
  final bool hasVisitedOrContactedTopChoices;
  final bool hasMarkedFinalChoiceStep;
  final bool hasRegisteredWithChosenHospital;
  final VoidCallback? onCreateShortlistTap;
  final VoidCallback onVisitedOrContactedTap;
  final VoidCallback? onFinalChoiceStepTap;
  final VoidCallback onRegisteredTap;

  const HospitalShortlistChecklistSection({
    super.key,
    required this.hasShortlist,
    required this.hasFinalChoice,
    required this.hasVisitedOrContactedTopChoices,
    required this.hasMarkedFinalChoiceStep,
    required this.hasRegisteredWithChosenHospital,
    required this.onCreateShortlistTap,
    required this.onVisitedOrContactedTap,
    required this.onFinalChoiceStepTap,
    required this.onRegisteredTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next Steps', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.gapMD),
        _ChecklistItem(
          label: 'Create a shortlist',
          isChecked: hasShortlist,
          onTap: onCreateShortlistTap,
        ),
        const SizedBox(height: AppSpacing.gapMD),
        _ChecklistItem(
          label: 'Visit or contact your top choices',
          isChecked: hasVisitedOrContactedTopChoices,
          onTap: onVisitedOrContactedTap,
        ),
        const SizedBox(height: AppSpacing.gapMD),
        _ChecklistItem(
          label: 'Make your final choice',
          isChecked: hasFinalChoice || hasMarkedFinalChoiceStep,
          onTap: onFinalChoiceStepTap,
        ),
        const SizedBox(height: AppSpacing.gapMD),
        _ChecklistItem(
          label: 'Register with your chosen hospital',
          isChecked: hasRegisteredWithChosenHospital,
          onTap: onRegisteredTap,
        ),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String label;
  final bool isChecked;
  final VoidCallback? onTap;

  const _ChecklistItem({
    required this.label,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppEffects.radiusSM),
      child: Row(
        children: [
          Container(
            width: AppSpacing.iconSM,
            height: AppSpacing.iconSM,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.secondary : AppColors.transparent,
              border: Border.all(
                color: isChecked ? AppColors.secondary : AppColors.border,
                width: AppSpacing.borderWidthThin,
              ),
              borderRadius: BorderRadius.circular(AppEffects.radiusXS),
            ),
            child: isChecked
                ? const Icon(
                    AppIcons.checkIcon,
                    size: AppSpacing.iconXS,
                    color: AppColors.white,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.gapMD),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: isChecked
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                decoration: isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
