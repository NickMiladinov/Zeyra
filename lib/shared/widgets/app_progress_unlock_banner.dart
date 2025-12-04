import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';

/// Reusable banner showing progress toward unlocking a feature.
/// 
/// Used across the app for features that require minimum data points
/// (e.g., kick counter analytics, symptom patterns, etc.)
class AppProgressUnlockBanner extends StatelessWidget {
  /// Current progress count (e.g., 3 sessions recorded)
  final int currentCount;
  
  /// Required count to unlock (e.g., 7 sessions needed)
  final int requiredCount;
  
  /// Customizable message template. Use {remaining} for remaining count.
  /// e.g., "Record {remaining} more sessions to unlock pattern insights"
  final String messageTemplate;
  
  /// Optional icon (defaults to lock icon)
  final IconData? icon;
  
  /// Number of progress bars to display (default matches requiredCount)
  final int? barCount;

  const AppProgressUnlockBanner({
    super.key,
    required this.currentCount,
    required this.requiredCount,
    required this.messageTemplate,
    this.icon,
    this.barCount,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = requiredCount - currentCount;
    final message = messageTemplate.replaceAll('{remaining}', remaining.toString());
    final displayBarCount = barCount ?? requiredCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Column(
        children: [
          // Icon and message
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon ?? AppIcons.lock,
                size: AppSpacing.iconMD,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.gapMD),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Progress bars - fill available width
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate bar width: (total width - gaps between bars) / number of bars
              final totalGaps = (displayBarCount - 1) * AppSpacing.gapSM;
              final barWidth = (constraints.maxWidth - totalGaps) / displayBarCount;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  displayBarCount,
                  (index) {
                    final isCompleted = index < currentCount;
                    return Container(
                      margin: EdgeInsets.only(
                        right: index < displayBarCount - 1 ? AppSpacing.gapSM : 0,
                      ),
                      width: barWidth,
                      height: AppSpacing.xs,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

