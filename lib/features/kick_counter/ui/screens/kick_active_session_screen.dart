import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../domain/entities/kick_counter/kick.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../logic/kick_counter_banner_provider.dart';
import '../../logic/kick_counter_state.dart';
import '../../logic/kick_history_provider.dart';
import '../widgets/rate_intensity_overlay.dart';
import '../widgets/session_complete_overlay.dart';

class KickActiveSessionScreen extends ConsumerStatefulWidget {
  const KickActiveSessionScreen({super.key});

  static const String routeName = '/kick-counter/active';

  @override
  ConsumerState<KickActiveSessionScreen> createState() => _KickActiveSessionScreenState();
}

class _KickActiveSessionScreenState extends ConsumerState<KickActiveSessionScreen> with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Hide banner when entering active session screen
      ref.read(kickCounterBannerProvider.notifier).hide();
      
      final state = ref.read(kickCounterProvider);
      if (state.activeSession == null) {
         // Initial state waiting for user to tap "Tap to begin"
      }
    });
  }

  /// Minimize the active session screen and show the floating banner.
  /// Called when user taps the down arrow to go back to previous screen.
  void _minimizeToBackground(BuildContext context) {
    // Only show banner if there's an active session
    final state = ref.read(kickCounterProvider);
    if (state.activeSession != null) {
      ref.read(kickCounterBannerProvider.notifier).show();
    }
    context.pop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kickCounterProvider);
    final session = state.activeSession;
    final duration = state.sessionDuration;
    final isRunning = session != null && !session.isPaused;
    final hasStarted = session != null;
    final count = session?.kickCount ?? 0;

    // Listen for "shouldPromptEnd"
    ref.listen(kickCounterProvider.select((s) => s.shouldPromptEnd), (previous, next) {
      if (next) {
        _showEndSessionDialog(context, ref);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Active Session', style: AppTypography.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(AppIcons.arrowDown, size: AppSpacing.iconLG, color: AppColors.iconDefault),
          onPressed: () => _minimizeToBackground(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(AppIcons.infoIcon, size: AppSpacing.iconMD, color: AppColors.iconDefault),
            onPressed: () => context.push(ToolRoutes.kickCounterInfo),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 0.75, 1.0],
            colors: [
              Color(0xFFC7F2EF),
              Color(0xFFD7F0F5),
              Color(0xFFE7E3FF),
              Color(0xFFF3E7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasStarted) ...[
                 const SizedBox(height: AppSpacing.gapXXXL),
                 Text(
                   'Session time',
                   style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                 ),
                 Text(
                   _formatDuration(duration),
                   style: AppTypography.displayMedium.copyWith(
                     fontSize: 36,
                     color: AppColors.textPrimary,
                     fontFeatures: [const FontFeature.tabularFigures()],
                   ),
                 ),
              ] else
                 const Spacer(), 
              
              const Spacer(),
              
              // Main Circle Indicator
              _AnimatedSessionCircle(
                key: const ValueKey('sessionCircle'),
                hasStarted: hasStarted,
                count: count,
                isRunning: isRunning,
                onStart: () => ref.read(kickCounterProvider.notifier).startSession(),
                onPauseResume: () {
                  if (isRunning) {
                    ref.read(kickCounterProvider.notifier).pauseSession();
                  } else {
                    ref.read(kickCounterProvider.notifier).resumeSession();
                  }
                },
              ),
              
              const Spacer(),
              
              // Controls
              if (hasStarted) ...[
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingXL),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       _buildCircleActionButton(
                         icon: AppIcons.undo,
                         onPressed: session.kicks.isEmpty ? null : () => ref.read(kickCounterProvider.notifier).undoLastKick(),
                         color: AppColors.white,
                         iconColor: AppColors.iconDefault,
                       ),
                       
                       _buildLargeAddButton(ref),
                       
                       _buildCircleActionButton(
                         icon: AppIcons.stop,
                         onPressed: () => _showEndSessionDialog(context, ref),
                         color: AppColors.white,
                         iconColor: AppColors.iconError,
                         fill: 1.0,
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: AppSpacing.gapXL),
                 
                 TextButton(
                   onPressed: () => _showDiscardDialog(context, ref),
                   child: Text(
                     'Discard Session',
                     style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
                   ),
                 ),
                 const SizedBox(height: AppSpacing.gapLG),
              ] else 
                 const Spacer(), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeAddButton(WidgetRef ref) {
    final session = ref.watch(kickCounterProvider).activeSession;
    final isPaused = session?.isPaused ?? false;
    
    return _AnimatedButton(
      onTap: () async {
        if (isPaused) {
          _showPausedMessage(context);
        } else {
          await _handleRecordKick(context, ref);
        }
      },
      child: Container(
        width: AppSpacing.buttonHeightXXXL,
        height: AppSpacing.buttonHeightXXXL,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPaused ? AppColors.white.withValues(alpha: 0.6) : AppColors.white,
          boxShadow: AppEffects.shadowMD,
        ),
        child: Icon(
          AppIcons.add, 
          size: AppSpacing.iconXXL, 
          color: isPaused ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
        ),
      ),
    );
  }

  /// Handle recording a kick with intensity rating overlay
  Future<void> _handleRecordKick(BuildContext context, WidgetRef ref) async {
    // Show rating overlay and get selected intensity
    final intensity = await RateIntensityOverlay.show(context: context);
    
    // Use moderate as default if user dismisses without selection
    final selectedIntensity = intensity ?? MovementStrength.moderate;
    
    // Record the kick with the selected intensity
    await ref.read(kickCounterProvider.notifier).recordKick(selectedIntensity);
  }

  void _showPausedMessage(BuildContext context) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // Show SnackBar with margin to ensure visibility
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(AppIcons.infoIcon, color: AppColors.white, size: AppSpacing.iconSM),
            const SizedBox(width: AppSpacing.gapSM),
            Expanded(
              child: Text(
                'Session is paused. Resume to record movements.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: AppEffects.roundedMD),
        margin: const EdgeInsets.only(
          bottom: AppSpacing.gapXXXL,
          left: AppSpacing.marginLG,
          right: AppSpacing.marginLG,
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required Color iconColor,
    double? fill,
  }) {
    return _AnimatedButton(
      onTap: onPressed,
      child: Container(
        width: AppSpacing.buttonHeightLG,
        height: AppSpacing.buttonHeightLG,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: AppEffects.shadowSM,
        ),
        child: Icon(icon, size: AppSpacing.iconMD, color: onPressed == null ? iconColor.withValues(alpha: 0.3) : iconColor, fill: fill),
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context, WidgetRef ref) async {
    final state = ref.read(kickCounterProvider);
    final session = state.activeSession;
    
    if (session == null) return;
    
    final wasRunning = !session.isPaused;
    final kickCount = session.kickCount;
    
    // Pause session while in dialog
    if (wasRunning) {
      await ref.read(kickCounterProvider.notifier).pauseSession();
    }
    
    // Special warning for 0 movements
    if (kickCount == 0) {
      if (!context.mounted) return;
      final shouldDiscard = await _showNoMovementsWarningDialog(context);
      
      if (shouldDiscard == true) {
        // User confirmed discard - delete session without showing overlay
        await ref.read(kickCounterProvider.notifier).discardSession();
        if (context.mounted) Navigator.pop(context);
        return;
      } else {
        // User canceled - resume if needed
        if (wasRunning) {
          await ref.read(kickCounterProvider.notifier).resumeSession();
        }
        return;
      }
    }
    
    // Special dialog when exactly 10 movements reached
    if (kickCount == 10) {
      if (!context.mounted) return;
      final shouldFinish = await _showReachedGoalDialog(context);
      
      if (shouldFinish == true) {
        // User wants to finish - show session complete overlay
        if (!context.mounted) return;
        await _showSessionCompleteOverlay(context, ref, session);
        return;
      } else if (shouldFinish == false) {
        // User wants to keep counting - resume session
        if (wasRunning) {
          await ref.read(kickCounterProvider.notifier).resumeSession();
        }
        return;
      } else {
        // User canceled dialog - resume if needed
        if (wasRunning) {
          await ref.read(kickCounterProvider.notifier).resumeSession();
        }
        return;
      }
    }
    
    // Show warning dialog if 1-9 movements
    if (kickCount < 10) {
      if (!context.mounted) return;
      final shouldContinue = await _showLowCountWarningDialog(context, kickCount);
      
      if (shouldContinue == true) {
        // User wants to continue counting - resume session
        if (wasRunning) {
          await ref.read(kickCounterProvider.notifier).resumeSession();
        }
        return;
      } else if (shouldContinue == null) {
        // User canceled dialog - resume if needed
        if (wasRunning) {
          await ref.read(kickCounterProvider.notifier).resumeSession();
        }
        return;
      }
      // shouldContinue == false: proceed directly to overlay (skip confirmation)
      if (!context.mounted) return;
      await _showSessionCompleteOverlay(context, ref, session);
      return;
    }
    
    // For 11+ movements: Show standard finish confirmation dialog
    if (!context.mounted) return;
    final shouldFinish = await _showFinishConfirmationDialog(context);
    
    if (shouldFinish == true) {
      // User confirmed - show session complete overlay
      if (!context.mounted) return;
      await _showSessionCompleteOverlay(context, ref, session);
    } else {
      // User canceled - resume session if it was running
      if (wasRunning) {
        await ref.read(kickCounterProvider.notifier).resumeSession();
      }
    }
  }

  /// Show warning dialog when user tries to end session with 0 movements
  /// Returns: true = discard session, false/null = cancel
  Future<bool?> _showNoMovementsWarningDialog(BuildContext context) {
    return AppDialog.show(
      context: context,
      title: 'No Movements Recorded',
      message: 'You haven\'t recorded any movements during this session. If you\'re concerned about your baby\'s movements, please contact your midwife or maternity unit immediately.\n\nWould you like to discard this session?',
      primaryActionLabel: 'Discard',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );
  }

  /// Show dialog when user reaches the recommended 10 movements
  /// Returns: true = finish, false = keep counting, null = canceled
  Future<bool?> _showReachedGoalDialog(BuildContext context) {
    return AppDialog.show(
      context: context,
      title: 'Recommended Count Reached',
      message: 'You\'ve recorded 10 movements, which is the recommended amount by healthcare providers. You can finish your session now or continue counting if you prefer.',
      primaryActionLabel: 'Finish',
      secondaryActionLabel: 'Keep Counting',
    );
  }

  /// Show warning dialog when user tries to end session with 1-9 movements
  /// Returns: true = continue counting, false = finish anyway, null = canceled
  Future<bool?> _showLowCountWarningDialog(BuildContext context, int currentCount) {
    return AppDialog.show(
      context: context,
      title: 'End Session Early?',
      message: 'You\'ve recorded $currentCount movement${currentCount == 1 ? '' : 's'}. '
          'Healthcare providers typically recommend counting 10 movements.',
      primaryActionLabel: 'Finish Anyway',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    ).then((result) {
      // Invert result since "Cancel" is secondary but should return true
      if (result == null) return null;
      return !result; // false (secondary) -> true (keep counting), true (primary) -> false (finish)
    });
  }

  /// Show standard finish confirmation dialog
  /// Returns: true = finish, false/null = cancel
  Future<bool?> _showFinishConfirmationDialog(BuildContext context) {
    return AppDialog.show(
      context: context,
      title: 'Finish Session?',
      message: 'Are you sure you want to finish this session?',
      primaryActionLabel: 'Finish',
      secondaryActionLabel: 'Cancel',
    );
  }

  /// Show session complete overlay and handle result
  Future<void> _showSessionCompleteOverlay(
    BuildContext context,
    WidgetRef ref,
    dynamic session,
    {String? initialNote}
  ) async {
    final result = await SessionCompleteOverlay.show(
      context: context,
      kickCount: session.kickCount,
      duration: session.activeDuration,
      initialNote: initialNote,
    );
    
    if (result != null) {
      if (result.shouldSave) {
        // End session and save with note
        await ref.read(kickCounterProvider.notifier).endSession(note: result.note);
        // Refresh history to show new session
        ref.invalidate(kickHistoryProvider);
        if (context.mounted) Navigator.pop(context);
      } else {
        // User clicked discard - show confirmation with note preserved
        if (!context.mounted) return;
        await _showDiscardConfirmationFromOverlay(context, ref, result.note);
      }
    } else {
      // Overlay was dismissed (swiped down) - save without note
      await ref.read(kickCounterProvider.notifier).endSession();
      // Refresh history to show new session
      ref.invalidate(kickHistoryProvider);
      if (context.mounted) Navigator.pop(context);
    }
  }

  /// Show discard confirmation when user clicks discard in session complete overlay
  Future<void> _showDiscardConfirmationFromOverlay(BuildContext context, WidgetRef ref, String? preservedNote) async {
    final shouldDiscard = await AppDialog.show(
      context: context,
      title: 'Discard Session?',
      message: 'This will permanently delete the current session. Are you sure?',
      primaryActionLabel: 'Discard',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );
    
    if (shouldDiscard == true) {
      await ref.read(kickCounterProvider.notifier).discardSession();
      // Refresh history after discard (though no new session to show)
      ref.invalidate(kickHistoryProvider);
      if (context.mounted) Navigator.pop(context);
    } else {
      // User canceled discard - show session complete overlay again with preserved note
      final session = ref.read(kickCounterProvider).activeSession;
      if (session != null) {
        if (!context.mounted) return;
        await _showSessionCompleteOverlay(context, ref, session, initialNote: preservedNote);
      }
    }
  }

  void _showDiscardDialog(BuildContext context, WidgetRef ref) async {
    final wasRunning = ref.read(kickCounterProvider).activeSession?.isPaused == false;
    
    // Pause session while in dialog
    if (wasRunning) {
      ref.read(kickCounterProvider.notifier).pauseSession();
    }
    
    final shouldDiscard = await AppDialog.show(
      context: context,
      title: 'Discard Session?',
      message: 'This will permanently delete the current session. Are you sure?',
      primaryActionLabel: 'Discard',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );
    
    if (shouldDiscard == true) {
      // Pop immediately before discarding to avoid showing initial state
      if (context.mounted) {
        Navigator.pop(context);
        // Discard after popping so user doesn't see the rebuild
        await ref.read(kickCounterProvider.notifier).discardSession();
      }
    } else {
      // Resume session if it was running before and user canceled
      if (wasRunning) {
        ref.read(kickCounterProvider.notifier).resumeSession();
      }
    }
  }
}

class _AnimatedSessionCircle extends StatefulWidget {
  final bool hasStarted;
  final int count;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPauseResume;

  const _AnimatedSessionCircle({
    super.key,
    required this.hasStarted,
    required this.count,
    required this.isRunning,
    required this.onStart,
    required this.onPauseResume,
  });

  @override
  State<_AnimatedSessionCircle> createState() => _AnimatedSessionCircleState();
}

class _AnimatedSessionCircleState extends State<_AnimatedSessionCircle> {
  static const double largeSize = 256.0;
  static const double startButtonSize = 200.0;
  static const double pauseButtonSize = AppSpacing.buttonHeightXXL;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largeSize,
      height: largeSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Ring with animated progress
          // TweenAnimationBuilder smoothly animates progress changes
          // Progress bar caps at 10 movements (1.0 progress)
          TweenAnimationBuilder<double>(
            duration: AppEffects.durationSlow,
            curve: Curves.easeOut,
            tween: Tween<double>(
              begin: widget.count > 0 ? math.min((widget.count - 1) / 10.0, 1.0) : 0.0,
              end: math.min(widget.count / 10.0, 1.0),
            ),
            builder: (context, animatedProgress, child) {
              return SizedBox(
                width: largeSize,
                height: largeSize,
                child: CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: animatedProgress,
                    ringColor: AppColors.white.withValues(alpha: 0.3),
                    progressColor: AppColors.white,
                    strokeWidth: AppSpacing.borderWidthThick,
                  ),
                ),
              );
            },
          ),

          // 2. The Transforming Button (Start -> Pause)
          // We use AnimatedContainer to morph size and position?
          // Or AnimatedScale/Positioned.
          // Start Button is Center, 200x200.
          // Pause Button is Bottom Center, 56x56.
          
          AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: widget.hasStarted ? const Alignment(0, 0.7) : Alignment.center,
            child: _AnimatedButton(
              onTap: widget.hasStarted ? widget.onPauseResume : widget.onStart,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: widget.hasStarted ? pauseButtonSize : startButtonSize,
                height: widget.hasStarted ? pauseButtonSize : startButtonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  boxShadow: widget.hasStarted ? AppEffects.shadowSM : AppEffects.shadowMD,
                  border: widget.hasStarted 
                      ? null 
                      : Border.all(color: AppColors.white.withValues(alpha: 0.5), width: 8),
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.hasStarted
                      ? Icon(
                          widget.isRunning ? AppIcons.pause : AppIcons.play,
                          key: const ValueKey('icon'),
                          size: AppSpacing.iconXL,
                          color: AppColors.iconDefault,
                          fill: 1.0,
                        )
                      : Text(
                          'Tap to\nbegin',
                          key: const ValueKey('text'),
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary),
                        ),
                ),
              ),
            ),
          ),

          // 3. Text Content (Fades in when started)
          IgnorePointer(
            ignoring: !widget.hasStarted,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: widget.hasStarted ? 1.0 : 0.0,
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   // Shift text up slightly to not overlap with the pause button which moved down
                   Transform.translate(
                     offset: const Offset(0, -20), 
                     child: Column(
                       children: [
                         Text(
                           '${widget.count}',
                           style: AppTypography.displayLarge.copyWith(fontSize: 80, height: 1.0),
                         ),
                         Text(
                           'movement${widget.count == 1 ? '' : 's'}',
                           style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
            ),
          ),
        ],
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
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
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
    // Draw it ONLY if there is some progress, OR if we want to show the starting point?
    // Design usually shows knob at start or end.
    if (progress >= 0) {
       final knobRadius = strokeWidth * 1.5; // Slightly larger than stroke (4.0 * 1.5 = 6.0)
       // If we want it perfectly centered on the stroke, standard trigonometry.
       final angle = -math.pi / 2 + sweepAngle;
       final knobX = center.dx + radius * math.cos(angle);
       final knobY = center.dy + radius * math.sin(angle);
       
       final knobPaint = Paint()
         ..color = AppColors.white
         ..style = PaintingStyle.fill;

       // Draw shadow for visibility if needed
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
