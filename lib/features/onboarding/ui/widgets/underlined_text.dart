import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// A text widget with a wavy/scribble underline decoration.
///
/// Used for emphasized headings in onboarding screens.
class UnderlinedText extends StatelessWidget {
  /// Creates an underlined text widget.
  const UnderlinedText({
    super.key,
    required this.text,
    required this.style,
    this.underlineColor,
  });

  /// The text to display.
  final String text;

  /// The text style to apply.
  final TextStyle style;

  /// The color of the underline. Defaults to secondary color.
  final Color? underlineColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavyUnderlinePainter(
        color: underlineColor ?? AppColors.secondary,
      ),
      child: Padding(
        // Add bottom padding to make room for the underline
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(text, style: style),
      ),
    );
  }
}

/// Custom painter for drawing a wavy underline.
class _WavyUnderlinePainter extends CustomPainter {
  _WavyUnderlinePainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Start from bottom left, slightly above the very bottom
    const waveHeight = 3.0;
    const waveWidth = 8.0;
    final yPosition = size.height - 4;

    path.moveTo(0, yPosition);

    // Draw wavy line across the width
    double x = 0;
    bool up = true;
    while (x < size.width) {
      final double nextX = (x + waveWidth).clamp(0.0, size.width);
      final y = up ? yPosition - waveHeight : yPosition + waveHeight;
      path.quadraticBezierTo(
        x + waveWidth / 2,
        y,
        nextX,
        yPosition,
      );
      x = nextX;
      up = !up;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavyUnderlinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
