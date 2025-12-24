import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_timer_state.dart';

/// A floating pill banner that displays the active contraction timer session status.
/// 
/// Shows contraction count and either:
/// - Active contraction duration (secondary color background) when timing a contraction
/// - Session duration (primary color background) when in rest/waiting state
class ContractionTimerBanner extends ConsumerStatefulWidget {
  const ContractionTimerBanner({
    super.key,
    required this.onTap,
  });

  /// Called when the banner is tapped
  final VoidCallback onTap;

  @override
  ConsumerState<ContractionTimerBanner> createState() => _ContractionTimerBannerState();
}

class _ContractionTimerBannerState extends ConsumerState<ContractionTimerBanner> {
  Timer? _timer;
  Duration _displayDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _displayDuration = _calculateDisplayDuration();
        });
      }
    });
  }

  /// Calculate the duration to display based on current state
  Duration _calculateDisplayDuration() {
    final stateAsync = ref.read(contractionTimerProvider);
    final session = stateAsync.valueOrNull?.activeSession;
    
    if (session == null) return Duration.zero;
    
    final activeContraction = session.activeContraction;
    
    if (activeContraction != null) {
      // Show contraction duration
      return DateTime.now().difference(activeContraction.startTime);
    } else {
      // Show session duration
      return DateTime.now().difference(session.startTime);
    }
  }

  /// Formats duration as: #h ##m if >= 1 hour, otherwise ##s (for contraction) or ##m ##s (for session)
  String _formatDuration(Duration duration, {required bool isContraction}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (isContraction) {
      // For active contractions, show seconds only (usually < 2 minutes)
      return '${seconds}s';
    }
    
    if (hours > 0) {
      // Format: #h ##m
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    } else {
      // Format: ##m ##s
      return '${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(contractionTimerProvider);
    final session = stateAsync.valueOrNull?.activeSession;
    
    if (session == null) {
      return const SizedBox.shrink();
    }
    
    final activeContraction = session.activeContraction;
    final isActiveContraction = activeContraction != null;
    final contractionCount = session.contractionCount;

    // Determine banner appearance based on state
    final backgroundColor = isActiveContraction
        ? AppColors.backgroundSecondaryVerySubtle
        : AppColors.backgroundPrimaryVerySubtle;
    final borderColor = isActiveContraction
        ? AppColors.secondary.withValues(alpha: 0.2)
        : AppColors.primary.withValues(alpha: 0.2);
    final accentColor = isActiveContraction
        ? AppColors.secondary
        : AppColors.primary;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingMD,
          vertical: AppSpacing.paddingSM,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppEffects.roundedCircle,
          border: Border.all(
            color: borderColor,
            width: AppSpacing.borderWidthThin,
          ),
          boxShadow: AppEffects.shadowLG,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Timer icon
            Icon(
              AppIcons.ecgHeart,
              size: AppSpacing.iconMD,
              color: accentColor,
            ),

            const SizedBox(width: AppSpacing.gapSM),

            // Contraction count
            Text(
              '$contractionCount',
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
              _formatDuration(_displayDuration, isContraction: isActiveContraction),
              style: AppTypography.headlineSmall,
            ),
            
            const SizedBox(width: AppSpacing.gapXL),
            
            // Expand chevron (indicates tapping expands to full screen)
            Icon(
              AppIcons.arrowUp,
              size: AppSpacing.iconLG,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

