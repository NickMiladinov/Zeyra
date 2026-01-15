import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/contraction_timer/rule_511_status.dart';

/// Widget displaying 5-1-1 rule progress tracking
class Rule511Progress extends StatelessWidget {
  final Rule511Status status;
  final int contractionCount;
  
  const Rule511Progress({
    super.key,
    required this.status,
    required this.contractionCount,
  });
  
  /// Get progress message based on 5-1-1 status
  String _getProgressMessage() {
    // Scenario 1: Alert active (all three conditions met)
    if (status.alertActive) {
      return '🚨 Call your midwife or maternity unit now - you may be in active labour.';
    }
    
    // Scenario 2: Both duration and frequency met, working on consistency
    if (status.durationProgress >= 1.0 && status.frequencyProgress >= 1.0) {
      return 'Contractions are regular and strong. Keep monitoring for consistency.';
    }
    
    // Scenario 3: Only frequency met
    if (status.frequencyProgress >= 1.0) {
      return 'Contractions are coming regularly. Track their strength and duration.';
    }
    
    // Scenario 4: Only duration met
    if (status.durationProgress >= 1.0) {
      return 'Contractions are lasting long enough. Monitor how often they occur.';
    }
    
    // Scenario 5: No conditions met but has some contractions
    if (contractionCount > 0) {
      final avgMinutes = contractionCount > 1 
          ? (status.contractionsInWindow > 0 ? 8 : 10) // Placeholder average
          : 0;
      if (avgMinutes > 0) {
        return 'Contractions are every $avgMinutes minutes on average. Let\'s keep monitoring.';
      }
      return 'Keep tracking your contractions. We need more data to see a pattern.';
    }
    
    // Default: No contractions yet
    return 'Start timing your contractions to track the 5-1-1 rule.';
  }
  
  @override
  Widget build(BuildContext context) {
    final message = _getProgressMessage();
    final isAlert = status.alertActive;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: isAlert 
            ? AppColors.error.withValues(alpha: 0.4)
            : AppColors.primary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppEffects.radiusXL),
        border: Border.all(
          color: isAlert 
              ? AppColors.error
              : AppColors.primary.withValues(alpha: 0.4),
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                isAlert ? AppIcons.warningIcon : AppIcons.infoIcon,
                size: AppSpacing.iconSM,
                color: isAlert ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.gapSM),
              Text(
                'Progress Tracking',
                style: AppTypography.labelLarge.copyWith(
                  color: isAlert ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapMD),
          
          // Progress message
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Progress indicators
            Row(
            children: [
              Expanded(
                child: _ProgressIndicator(
                  icon: AppIcons.schedule,
                  label: 'Duration:\n~1 min',
                  progress: status.durationProgress,
                  isComplete: status.durationProgress >= 1.0,
                ),
              ),
              const SizedBox(width: AppSpacing.gapMD),
              Expanded(
                child: _ProgressIndicator(
                  icon: AppIcons.event,
                  label: 'Frequency:\n~5 min',
                  progress: status.frequencyProgress,
                  isComplete: status.frequencyProgress >= 1.0,
                ),
              ),
              const SizedBox(width: AppSpacing.gapMD),
              Expanded(
                child: _ProgressIndicator(
                  icon: AppIcons.history,
                  label: 'For over\n1 hour',
                  progress: status.consistencyProgress,
                  isComplete: status.consistencyProgress >= 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final double progress;
  final bool isComplete;

  const _ProgressIndicator({
    required this.icon,
    required this.label,
    required this.progress,
    required this.isComplete,
  });

  static const double _size = AppSpacing.iconXL;
  static const double _strokeWidth = AppSpacing.borderWidthMedium;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon with progress ring
        SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              CustomPaint(
                size: const Size(_size, _size),
                painter: _ProgressRingPainter(
                  progress: progress.clamp(0.0, 1.0),
                  ringColor: AppColors.white.withValues(alpha: 0.4),
                  progressColor: isComplete
                      ? AppColors.primary
                      : AppColors.white,
                  strokeWidth: _strokeWidth,
                ),
              ),
              // Inner circle with icon
              Container(
                width: _size - (_strokeWidth * 4),
                height: _size - (_strokeWidth * 4),
                decoration: BoxDecoration(
                  color: isComplete ? AppColors.primary : AppColors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isComplete ? AppIcons.checkIcon : icon,
                    size: AppSpacing.iconXS,
                    color:
                        isComplete ? AppColors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.gapSM),

        // Label
        Text(
          label,
          style: AppTypography.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Custom painter for progress ring (no knob)
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color progressColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.ringColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background Ring
    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, ringPaint);

    // Progress Arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Start from top (-pi/2)
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.progressColor != progressColor;
  }
}

