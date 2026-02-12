import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_state.dart';

/// A floating pill banner that displays the active kick counter session status.
/// 
class KickCounterBanner extends ConsumerWidget {
  const KickCounterBanner({
    super.key,
    required this.onTap,
  });

  /// Called when the banner is tapped (excluding play/pause button)
  final VoidCallback onTap;

  /// Formats duration as: #h ##m if >= 1 hour, otherwise ##m ##s
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      // Format: #h ##m
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    } else {
      // Format: ##m ##s
      return '${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kickCounterProvider);
    final session = state.activeSession;
    final duration = state.sessionDuration;
    
    if (session == null) {
      return const SizedBox.shrink();
    }
    
    final isPaused = session.isPaused;
    final kickCount = session.kickCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingMD,
          vertical: AppSpacing.paddingSM,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimaryVerySubtle,
          borderRadius: AppEffects.roundedCircle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: AppSpacing.borderWidthThin,
          ),
          boxShadow: AppEffects.shadowLG,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baby foot icon
            AppIcons.babyFoot(
              size: AppSpacing.iconMD,
              color: AppColors.iconDefault,
            ),

            // Movement count
            Text(
              '$kickCount',
              style: AppTypography.headlineSmall,
            ),
            
            // Vertical divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.gapMD),
              height: AppSpacing.iconSM,
              width: AppSpacing.borderWidthThin,
              color: AppColors.backgroundGrey500.withValues(alpha: 0.5),
            ),
            
            // Duration
            Text(
              _formatDuration(duration),
              style: AppTypography.headlineSmall,
            ),
            
            const SizedBox(width: AppSpacing.gapXL),
            
            // Play/Pause button
            _PlayPauseButton(
              isPaused: isPaused,
              onTap: () {
                if (isPaused) {
                  ref.read(kickCounterProvider.notifier).resumeSession();
                } else {
                  ref.read(kickCounterProvider.notifier).pauseSession();
                }
              },
            ),
            
            const SizedBox(width: AppSpacing.gapMD),
            
            // Expand chevron (indicates tapping expands to full screen)
            Icon(
              AppIcons.arrowUp,
              size: AppSpacing.iconLG,
              color: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular play/pause button for the banner
class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPaused,
    required this.onTap,
  });

  final bool isPaused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        isPaused ? AppIcons.play : AppIcons.pause,
        size: AppSpacing.iconLG,
        color: AppColors.iconDefault,
        fill: 1.0,
      ),
    );
  }
}

