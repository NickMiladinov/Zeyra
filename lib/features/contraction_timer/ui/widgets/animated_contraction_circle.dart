import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';

/// Animated circle widget that shows start/stop button with progress ring
/// Used in the active contraction timer screen
class AnimatedContractionCircle extends StatelessWidget {
  final bool hasStarted;
  final bool isActive;
  final double progress;
  final VoidCallback onTap;
  
  const AnimatedContractionCircle({
    super.key,
    required this.hasStarted,
    required this.isActive,
    required this.progress,
    required this.onTap,
  });
  
  static const double totalSize = 192.0;
  static const double innerSize = 144.0;
  
  @override
  Widget build(BuildContext context) {
    return _AnimatedButton(
      onTap: onTap,
      child: SizedBox(
        width: totalSize,
        height: totalSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring (always visible)
            CustomPaint(
              size: const Size(totalSize, totalSize),
              painter: _ProgressRingPainter(
                progress: isActive ? progress : 0.0,
                ringColor: AppColors.white.withValues(alpha: 0.3),
                progressColor: AppColors.white,
                strokeWidth: AppSpacing.borderWidthThick,
              ),
            ),
            
            // Inner white circle
            Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: isActive
                    ? AppEffects.shadowSM
                    : AppEffects.shadowMD,
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: isActive
                        ? Icon(
                            AppIcons.stop,
                            size: AppSpacing.buttonHeightXXXL,
                            color: AppColors.iconError,
                            fill: 1.0,
                          )
                        : Text(
                            hasStarted
                                ? 'Start\nContraction'
                                : 'Tap to\nBegin',
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineSmall,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated button widget that scales down on tap
class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  const _AnimatedButton({
    required this.child,
    required this.onTap,
  });
  
  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: AppEffects.durationFast,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

/// Custom painter for progress ring
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
    
    // Draw Knob (Small white circle at the end of progress)
    if (progress >= 0) {
      final knobRadius = strokeWidth * 1.5;
      final angle = -math.pi / 2 + sweepAngle;
      final knobX = center.dx + radius * math.cos(angle);
      final knobY = center.dy + radius * math.sin(angle);
      
      final knobPaint = Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(knobX, knobY), knobRadius, knobPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.progressColor != progressColor;
  }
}

