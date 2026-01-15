import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';

/// Position of the tooltip relative to the highlighted element.
enum TooltipPosition {
  /// Tooltip appears above the highlighted element.
  above,
  /// Tooltip appears below the highlighted element.
  below,
}

/// Configuration for a just-in-time tooltip.
class JitTooltipConfig {
  /// The text to display in the tooltip.
  final String message;

  /// Optional title for the tooltip (displayed in bold above the message).
  final String? title;

  /// Position of the tooltip relative to the highlighted area.
  final TooltipPosition position;

  /// Padding around the highlighted element.
  final EdgeInsets highlightPadding;

  /// Border radius for the highlight cutout.
  final double highlightBorderRadius;

  const JitTooltipConfig({
    required this.message,
    this.title,
    this.position = TooltipPosition.below,
    this.highlightPadding = EdgeInsets.zero, // No extra padding - exact card borders
    this.highlightBorderRadius = AppEffects.radiusLG,
  });
}

/// A just-in-time tooltip overlay that highlights a specific area and shows 
/// contextual help.
///
/// Features:
/// - Blurred background (outside highlighted area only)
/// - Clear highlighted area with border to draw attention
/// - Tooltip card with arrow pointing to the highlighted area
/// - Dismiss button
/// - One-time display (tracked via preferences)
///
/// Usage:
/// ```dart
/// AppJitTooltip.show(
///   context: context,
///   targetKey: _sessionCardKey,
///   config: JitTooltipConfig(
///     title: 'Tap to view details',
///     message: 'Tap any session to view details, add notes, or delete it.',
///   ),
///   onDismiss: () => markTooltipAsShown(),
/// );
/// ```
class AppJitTooltip extends StatefulWidget {
  /// GlobalKey of the widget to highlight.
  final GlobalKey targetKey;

  /// Configuration for the tooltip.
  final JitTooltipConfig config;

  /// Callback when the tooltip is dismissed.
  final VoidCallback? onDismiss;

  const AppJitTooltip({
    super.key,
    required this.targetKey,
    required this.config,
    this.onDismiss,
  });

  /// Show the tooltip as a modal overlay.
  static Future<void> show({
    required BuildContext context,
    required GlobalKey targetKey,
    required JitTooltipConfig config,
    VoidCallback? onDismiss,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return AppJitTooltip(
            targetKey: targetKey,
            config: config,
            onDismiss: onDismiss,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: AppEffects.curveDefault,
            ),
            child: child,
          );
        },
        transitionDuration: AppEffects.durationNormal,
        reverseTransitionDuration: AppEffects.durationFast,
      ),
    );
  }

  @override
  State<AppJitTooltip> createState() => _AppJitTooltipState();
}

class _AppJitTooltipState extends State<AppJitTooltip> {
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    // Get target rect after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
    });
  }

  void _updateTargetRect() {
    final renderBox = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final position = renderBox.localToGlobal(Offset.zero);
      setState(() {
        // Use exact widget bounds without any padding adjustment
        _targetRect = Rect.fromLTWH(
          position.dx,
          position.dy,
          renderBox.size.width,
          renderBox.size.height,
        );
      });
    }
  }

  void _dismiss() {
    widget.onDismiss?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _dismiss,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Blurred background with clear highlighted area
            if (_targetRect != null)
              _buildBackgroundWithCutout(screenSize)
            else
              // Fallback while calculating rect - just blur, no overlay
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppEffects.blurMedium,
                  sigmaY: AppEffects.blurMedium,
                ),
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  color: Colors.transparent,
                ),
              ),

            // Tooltip card
            if (_targetRect != null)
              _buildTooltipCard(screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundWithCutout(Size screenSize) {
    return Stack(
      children: [
        // Blur only the area outside the highlighted region
        ClipPath(
          clipper: _InvertedRectClipper(
            targetRect: _targetRect!,
            borderRadius: widget.config.highlightBorderRadius,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppEffects.blurMedium,
              sigmaY: AppEffects.blurMedium,
            ),
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ),
        // Draw glowing teal highlight around the highlighted area
        CustomPaint(
          size: screenSize,
          painter: _HighlightGlowPainter(
            targetRect: _targetRect!,
            borderRadius: widget.config.highlightBorderRadius,
          ),
        ),
      ],
    );
  }

  Widget _buildTooltipCard(Size screenSize) {
    final config = widget.config;
    
    // Smart positioning: default to below, but use above if target is in bottom 40% of screen
    final targetBottomPosition = _targetRect!.bottom / screenSize.height;
    final shouldShowAbove = targetBottomPosition > 0.6; // If target is in bottom 40%, show above
    final isBelow = config.position == TooltipPosition.below ? !shouldShowAbove : false;
    
    // Calculate tooltip position
    final tooltipMargin = AppSpacing.paddingLG;
    final arrowSize = 12.0;
    
    // Horizontal positioning: center on target, but constrain to screen
    final targetCenterX = _targetRect!.center.dx;
    final tooltipWidth = screenSize.width - (tooltipMargin * 2);
    var tooltipLeft = targetCenterX - (tooltipWidth / 2);
    tooltipLeft = tooltipLeft.clamp(tooltipMargin, screenSize.width - tooltipWidth - tooltipMargin);

    // Vertical positioning
    double tooltipTop;
    if (isBelow) {
      tooltipTop = _targetRect!.bottom + arrowSize + AppSpacing.gapSM;
    } else {
      // Will be positioned from bottom
      tooltipTop = 0; // Not used when above
    }

    // Arrow horizontal position relative to tooltip
    final arrowLeftInTooltip = (targetCenterX - tooltipLeft).clamp(
      AppSpacing.paddingXL,
      tooltipWidth - AppSpacing.paddingXL,
    );

    return Positioned(
      left: tooltipLeft,
      top: isBelow ? tooltipTop : null,
      bottom: isBelow ? null : (screenSize.height - _targetRect!.top + arrowSize + AppSpacing.gapSM),
      child: SizedBox(
        width: tooltipWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arrow above tooltip (when below target)
            if (isBelow)
              Padding(
                padding: EdgeInsets.only(left: arrowLeftInTooltip - arrowSize),
                child: CustomPaint(
                  size: Size(arrowSize * 2, arrowSize),
                  painter: _ArrowPainter(pointUp: true),
                ),
              ),

            // Tooltip content card
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingLG),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppEffects.radiusLG),
                boxShadow: AppEffects.shadowMD,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (config.title != null) ...[
                          Text(
                            config.title!,
                            style: AppTypography.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.gapSM),
                        ],
                        Text(
                          config.message,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close button (icon only, no circle)
                  const SizedBox(width: AppSpacing.gapMD),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      AppIcons.close,
                      size: AppSpacing.iconMD,
                      color: AppColors.iconDefault,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow below tooltip (when above target)
            if (!isBelow)
              Padding(
                padding: EdgeInsets.only(left: arrowLeftInTooltip - arrowSize),
                child: CustomPaint(
                  size: Size(arrowSize * 2, arrowSize),
                  painter: _ArrowPainter(pointUp: false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom clipper that inverts the highlighted area (clips everything except the target).
class _InvertedRectClipper extends CustomClipper<Path> {
  final Rect targetRect;
  final double borderRadius;

  _InvertedRectClipper({
    required this.targetRect,
    required this.borderRadius,
  });

  @override
  Path getClip(Size size) {
    // Create a path for the entire screen
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a rounded rect path for the cutout
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        targetRect,
        Radius.circular(borderRadius),
      ));

    // Combine paths to exclude the highlighted area
    return Path.combine(
      PathOperation.difference,
      screenPath,
      cutoutPath,
    );
  }

  @override
  bool shouldReclip(covariant _InvertedRectClipper oldClipper) {
    return oldClipper.targetRect != targetRect ||
        oldClipper.borderRadius != borderRadius;
  }
}

/// Custom painter for the highlight glow effect (blurred teal shadow).
class _HighlightGlowPainter extends CustomPainter {
  final Rect targetRect;
  final double borderRadius;

  _HighlightGlowPainter({
    required this.targetRect,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle outward-only glow effect with reduced reach
    
    // Outer glow (softest, furthest)
    final outerRect = targetRect.inflate(6);
    final outerRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(borderRadius + 6),
    );
    final outerGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(outerRRect, outerGlowPaint);

    // Middle glow
    final middleRect = targetRect.inflate(3);
    final middleRRect = RRect.fromRectAndRadius(
      middleRect,
      Radius.circular(borderRadius + 3),
    );
    final middleGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(middleRRect, middleGlowPaint);

    // Inner glow (closest to edge, most visible)
    final innerRect = targetRect.inflate(1);
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(borderRadius + 1),
    );
    final innerGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawRRect(innerRRect, innerGlowPaint);
  }

  @override
  bool shouldRepaint(covariant _HighlightGlowPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// Custom painter for the tooltip arrow.
class _ArrowPainter extends CustomPainter {
  final bool pointUp;

  _ArrowPainter({required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the arrow with the same surface color as the tooltip
    final fillPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointUp) {
      // Arrow pointing up (tooltip below target)
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      // Arrow pointing down (tooltip above target)
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, fillPaint);

    // Add a subtle shadow/outline to make it more visible
    final shadowPaint = Paint()
      ..color = AppColors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.pointUp != pointUp;
  }
}
