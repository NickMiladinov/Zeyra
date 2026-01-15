import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';

/// Widget displaying 5-1-1 rule status with checkbox-style indicators.
/// 
/// This widget is designed for completed/historical sessions and shows
/// whether each criterion was achieved during the session.
class Session511StatusCard extends StatelessWidget {
  final ContractionSession session;
  
  const Session511StatusCard({
    super.key,
    required this.session,
  });
  
  /// Get progress message based on achieved 5-1-1 criteria
  String _getProgressMessage() {
    final achievedCount = [
      session.achievedFrequency,
      session.achievedDuration,
      session.achievedConsistency,
    ].where((achieved) => achieved).length;
    
    // Scenario 1: All three criteria met
    if (session.achieved511Alert) {
      return '🚨 This session met all 5-1-1 rule criteria. If you experienced this pattern, you should have contacted your midwife or maternity unit.';
    }
    
    // Scenario 2: Two criteria met
    if (achievedCount == 2) {
      if (session.achievedDuration && session.achievedFrequency) {
        return 'Contractions were regular and strong during this session. Continue monitoring for consistency in future sessions.';
      } else if (session.achievedFrequency && session.achievedConsistency) {
        return 'Contractions were regular and consistent. Keep tracking their strength and duration.';
      } else if (session.achievedDuration && session.achievedConsistency) {
        return 'Contractions were strong and consistent. Continue monitoring how often they occur.';
      }
    }
    
    // Scenario 3: One criterion met
    if (achievedCount == 1) {
      if (session.achievedFrequency) {
        return 'Contractions came regularly during this session. Track their strength and duration in future sessions.';
      } else if (session.achievedDuration) {
        return 'Contractions lasted long enough. Continue monitoring how often they occur.';
      } else if (session.achievedConsistency) {
        return 'The pattern was maintained for an hour. Keep tracking frequency and duration.';
      }
    }
    
    // Scenario 4: No criteria met
    if (session.contractionCount > 0) {
      return 'This session provided useful tracking data. Continue monitoring your contractions to identify patterns.';
    }
    
    // Default: No contractions
    return 'No contractions were recorded in this session.';
  }
  
  @override
  Widget build(BuildContext context) {
    final message = _getProgressMessage();
    final isAlert = session.achieved511Alert;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: isAlert 
            ? AppColors.errorLight.withValues(alpha: 0.15)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppEffects.radiusXL),
        boxShadow: isAlert ? null : AppEffects.shadowXS,
        border: isAlert
            ? Border.all(
                color: AppColors.errorLight.withValues(alpha: 0.25),
                width: AppSpacing.borderWidthThin,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '5-1-1 Rule Progress',
            style: AppTypography.headlineExtraSmall.copyWith(
              color: isAlert ? AppColors.error : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Checklist items
          _ChecklistItem(
            label: 'Contractions every 5 minutes',
            isChecked: session.achievedFrequency,
          ),
          const SizedBox(height: AppSpacing.gapMD),
          _ChecklistItem(
            label: 'Lasting 1 minute each',
            isChecked: session.achievedDuration,
          ),
          const SizedBox(height: AppSpacing.gapMD),
          _ChecklistItem(
            label: 'For 1 hour consistently',
            isChecked: session.achievedConsistency,
          ),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Message box
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingMD),
            decoration: BoxDecoration(
              color: isAlert 
                  ? AppColors.errorLight.withValues(alpha: 0.1)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppEffects.radiusMD),
            ),
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual checklist item with checkbox icon
class _ChecklistItem extends StatelessWidget {
  final String label;
  final bool isChecked;
  
  const _ChecklistItem({
    required this.label,
    required this.isChecked,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Checkbox icon
        Container(
          width: AppSpacing.iconSM,
          height: AppSpacing.iconSM,
          decoration: BoxDecoration(
            color: isChecked ? AppColors.primary : AppColors.transparent,
            border: Border.all(
              color: isChecked ? AppColors.primary : AppColors.border,
              width: AppSpacing.borderWidthMedium,
            ),
            borderRadius: BorderRadius.circular(AppEffects.radiusSM),
          ),
          child: isChecked
              ? Icon(
                  AppIcons.checkIcon,
                  size: AppSpacing.iconXS,
                  color: AppColors.white,
                )
              : null,
        ),
        const SizedBox(width: AppSpacing.gapMD),
        
        // Label
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isChecked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

