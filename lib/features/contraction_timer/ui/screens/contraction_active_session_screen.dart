import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../domain/entities/contraction_timer/contraction.dart';
import '../../../../domain/entities/contraction_timer/contraction_timer_constants.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../logic/contraction_timer_state.dart';
import '../../logic/contraction_timer_banner_provider.dart';
import '../../logic/contraction_history_provider.dart';
import '../widgets/rule_511_progress.dart';
import '../widgets/contraction_list_sheet.dart';
import '../widgets/animated_contraction_circle.dart';
import '../widgets/edit_contraction_sheet.dart';
import '../widgets/session_complete_overlay.dart';

class ContractionActiveSessionScreen extends ConsumerStatefulWidget {
  const ContractionActiveSessionScreen({super.key});
  
  @override
  ConsumerState<ContractionActiveSessionScreen> createState() =>
      _ContractionActiveSessionScreenState();
}

class _ContractionActiveSessionScreenState
    extends ConsumerState<ContractionActiveSessionScreen> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  
  /// Prevents concurrent execution of start/stop contraction operations
  bool _isProcessingContractionAction = false;
  
  /// Timestamp of last contraction action (for time-based debounce)
  DateTime? _lastContractionActionTime;
  
  /// Minimum delay between contraction actions (milliseconds)
  static const int _minActionDelayMs = 800;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Hide banner when entering active session screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contractionTimerBannerProvider.notifier).hide();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  /// Minimize the active session screen and show the floating banner.
  /// Called when user taps the down arrow to go back to previous screen.
  void _minimizeToBackground() {
    // Only show banner if there's an active session
    final stateAsync = ref.read(contractionTimerProvider);
    final hasActiveSession = stateAsync.valueOrNull?.activeSession != null;
    if (hasActiveSession) {
      ref.read(contractionTimerBannerProvider.notifier).show();
    }
    context.pop();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = _getElapsedTime();
        });
        
        // Trigger state recalculation every 10 seconds to detect time-based resets
        // (e.g., frequency reset when >20 min passes since last contraction)
        if (timer.tick % 10 == 0) {
          final notifier = ref.read(contractionTimerNotifierProvider);
          notifier?.refresh();
        }
      }
    });
  }
  
  Duration _getElapsedTime() {
    final session = ref.read(contractionTimerProvider).valueOrNull?.activeSession;
    final activeContraction = session?.activeContraction;
    
    if (activeContraction != null) {
      return DateTime.now().difference(activeContraction.startTime);
    }
    
    return Duration.zero;
  }
  
  Duration _getSessionDuration() {
    final session = ref.read(contractionTimerProvider).valueOrNull?.activeSession;
    if (session != null) {
      return DateTime.now().difference(session.startTime);
    }
    return Duration.zero;
  }
  
  /// Handles editing a contraction with proper async/mounted checks
  Future<void> _handleEditContraction(Contraction contraction, String contractionId) async {
    bool showLabourAlert = false;
    
    await EditContractionSheet.show(
      context: context,
      contraction: contraction,
      onSave: (startTime, duration, intensity) async {
        // Update the contraction
        await ref.read(contractionTimerNotifierProvider)
            ?.updateContraction(
              contractionId,
              startTime: startTime,
              duration: duration,
              intensity: intensity,
            );
        
        // Check if 5-1-1 rule is now met after edit
        final updatedState = ref.read(contractionTimerProvider).valueOrNull;
        final rule511 = updatedState?.rule511Status;
        
        if (rule511 != null && rule511.alertActive) {
          showLabourAlert = true;
        }
      },
    );
    
    // Show alert dialog after sheet closes, with proper mounted check
    if (!mounted) return;
    
    if (showLabourAlert) {
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            '🚨 Active Labour Alert',
            style: AppTypography.headlineSmall,
          ),
          content: Text(
            'Your contractions now meet the 5-1-1 rule. Call your midwife or maternity unit.',
            style: AppTypography.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'OK',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
  
  String _formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
  
  /// Handles start/stop contraction with strong debounce protection.
  /// 
  /// Uses both a processing flag AND time-based debounce to prevent:
  /// - Rapid taps creating multiple 0s contractions
  /// - Race conditions from concurrent operations
  /// - Accidental double-taps within 800ms window
  Future<void> _handleStartStopContraction() async {
    final now = DateTime.now();
    
    // Time-based debounce: reject if within minimum delay window
    if (_lastContractionActionTime != null) {
      final timeSinceLastAction = now.difference(_lastContractionActionTime!).inMilliseconds;
      if (timeSinceLastAction < _minActionDelayMs) {
        return; // Silently reject too-rapid taps
      }
    }
    
    // Flag-based debounce: prevent concurrent operations
    if (_isProcessingContractionAction) return;
    
    _isProcessingContractionAction = true;
    _lastContractionActionTime = now;
    
    try {
      final notifier = ref.read(contractionTimerNotifierProvider);
      if (notifier == null) return;
      
      final state = ref.read(contractionTimerProvider).valueOrNull;
      final session = state?.activeSession;
      
      if (session == null) {
        // Start new session and first contraction
        await notifier.startSession();
        await notifier.startContraction();
      } else if (session.activeContraction != null) {
        // Capture elapsed time before stopping
        final activeContraction = session.activeContraction!;
        final elapsedTime = DateTime.now().difference(activeContraction.startTime);
        
        // Stop active contraction
        await notifier.stopContraction();
        
        // Check if duration was capped
        if (elapsedTime > ContractionTimerConstants.maxContractionDuration) {
          _showDurationCappedSnackbar();
        }
      } else {
        // Start new contraction
        await notifier.startContraction();
      }
    } finally {
      // Always reset the flag, even if an error occurs
      _isProcessingContractionAction = false;
    }
  }
  
  /// Show a snackbar notification when contraction duration is automatically capped.
  void _showDurationCappedSnackbar() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Contraction duration capped at 2 minutes. Please ensure you stop the timer promptly for accurate tracking.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginLG),
      ),
    );
  }
  
  Future<void> _handleUndo() async {
    final session = ref.read(contractionTimerProvider).valueOrNull?.activeSession;
    if (session == null || session.contractions.isEmpty) return;
    
    // Find last completed contraction
    final lastContraction = session.contractions
        .where((c) => c.endTime != null)
        .lastOrNull;
    
    if (lastContraction == null) return;
    
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Delete Last Contraction?',
      message: 'This will remove the most recent contraction from your session.',
      primaryActionLabel: 'Delete',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );
    
    if (confirmed == true && mounted) {
      await ref.read(contractionTimerNotifierProvider)
          ?.deleteContraction(lastContraction.id);
    }
  }
  
  Future<void> _handleFinishSession() async {
    final session = ref.read(contractionTimerProvider).valueOrNull?.activeSession;
    if (session == null) return;
    
    // Show session complete overlay
    final result = await SessionCompleteOverlay.show(
      context: context,
      contractionCount: session.contractionCount,
      sessionDuration: session.totalDuration,
      achieved511Alert: session.achieved511Alert,
      initialNote: session.note,
    );
    
    if (!mounted) return;
    
    final notifier = ref.read(contractionTimerNotifierProvider);
    if (notifier == null) return;
    
    if (result != null) {
      if (result.shouldSave) {
        // Save the session with the note
        await notifier.finishSession(note: result.note);
        // Refresh history so the new session appears in the list
        await ref.read(contractionHistoryProvider.notifier).refresh();
        if (mounted) {
          context.pop();
        }
      } else {
        // Discard the session
        await notifier.discardSession();
        if (mounted) {
          context.pop();
        }
      }
    }
  }

  Future<void> _handleDiscardSession() async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Discard Session?',
      message: 'This will permanently delete all contractions in this session.',
      primaryActionLabel: 'Discard',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );
    
    if (confirmed == true && mounted) {
      await ref.read(contractionTimerNotifierProvider)?.discardSession();
      if (mounted) {
        context.pop();
      }
    }
  }
  
  
  Contraction? _getLastCompletedContraction(List<Contraction> contractions) {
    return contractions
        .where((c) => c.endTime != null)
        .lastOrNull;
  }
  
  String _formatLastContractionTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else {
      return '${difference.inMinutes} min ago';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(contractionTimerProvider);
    
    // Handle loading/error states
    return stateAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
      data: (state) => _buildActiveSession(context, state),
    );
  }
  
  Widget _buildActiveSession(BuildContext context, ContractionTimerState state) {
    final session = state.activeSession;
    final activeContraction = session?.activeContraction;
    final isActive = activeContraction != null;
    final rule511Status = state.rule511Status;
    final hasStarted = session != null;
    
    // Get last completed contraction
    final lastContraction = session != null
        ? _getLastCompletedContraction(session.contractions)
        : null;
    
    // Calculate progress for active contraction (0.0 to 1.0)
    final contractionProgress = isActive
        ? math.min(
            _elapsedTime.inSeconds /
                ContractionTimerConstants.durationValidThreshold.inSeconds,
            1.0,
          )
        : 0.0;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Active Labour', style: AppTypography.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            AppIcons.arrowDown,
            size: AppSpacing.iconLG,
            color: AppColors.iconDefault,
          ),
          onPressed: _minimizeToBackground,
        ),
        actions: [
          IconButton(
            icon: Icon(
              AppIcons.infoIcon,
              size: AppSpacing.iconMD,
              color: AppColors.iconDefault,
            ),
            onPressed: () => context.push(ToolRoutes.contractionTimerInfo),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          bottom: false, // Allow sheet to extend to screen edge
          child: Stack(
            children: [
              // Main content with fixed button position
              SizedBox.expand(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate space distribution (40% above, 60% below)
                    const buttonHeight = 192.0;
                    final totalContentSpace = constraints.maxHeight - buttonHeight;
                    final topSpace = totalContentSpace * 0.43;
                    final bottomSpace = totalContentSpace * 0.57;
                    
                    return Column(
                      children: [
                        // Top area with max height constraint
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: topSpace,
                            maxHeight: topSpace,
                          ),
                          child: SingleChildScrollView(
                            reverse: true,
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Top content area - 5-1-1 rule widget
                                if (hasStarted && !isActive && rule511Status != null) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.paddingLG,
                                    ),
                                    child: Rule511Progress(
                                      status: rule511Status,
                                      contractionCount: session.contractionCount,
                                    ),
                                  ),
                                ],

                                // Contraction time display (only during active contraction)
                                if (isActive) ...[
                                  Text(
                                    'Contraction Time',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_elapsedTime.inSeconds}s',
                                    style: AppTypography.displayMedium.copyWith(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.gapXL),
                                  Text(
                                    'Tap to Stop',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                
                                const SizedBox(height: AppSpacing.gapXL),
                              ],
                            ),
                          ),
                        ),
                        
                        // Main circle button (fixed position)
                        AnimatedContractionCircle(
                          hasStarted: hasStarted,
                          isActive: isActive,
                          progress: contractionProgress,
                          onTap: _handleStartStopContraction,
                        ),
                        
                        // Bottom area with max height constraint
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: bottomSpace,
                            maxHeight: bottomSpace,
                          ),
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: AppSpacing.gapXL),
                                
                                // Session time (always visible when session started)
                                if (hasStarted) ...[
                                  Text(
                                    'Session time',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _formatElapsedTime(_getSessionDuration()),
                                    style: AppTypography.displayMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                
                                // Action buttons (only in resting state)
                                if (hasStarted && !isActive) ...[
                                  const SizedBox(height: AppSpacing.gapXL),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.paddingXL,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildCircleActionButton(
                                          icon: AppIcons.undo,
                                          onPressed: session.contractions
                                                  .where((c) => c.endTime != null)
                                                  .isEmpty
                                              ? null
                                              : _handleUndo,
                                          color: AppColors.white,
                                          iconColor: AppColors.iconDefault,
                                        ),
                                        const SizedBox(width: AppSpacing.gapXXXL),
                                        _buildCircleActionButton(
                                          icon: AppIcons.flag,
                                          onPressed: session.contractionCount > 0
                                              ? _handleFinishSession
                                              : null,
                                          color: AppColors.white,
                                          iconColor: AppColors.secondary,
                                          fill: 1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.gapMD),
                                  TextButton(
                                    onPressed: _handleDiscardSession,
                                    child: Text(
                                      'Discard Session',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                                
                                // Last contraction widget (only during active contraction)
                                if (isActive && lastContraction != null) ...[
                                  const SizedBox(height: AppSpacing.gapXL),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.marginLG,
                                    ),
                                    padding: const EdgeInsets.all(AppSpacing.paddingLG),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(AppEffects.radiusLG),
                                      boxShadow: AppEffects.shadowSM,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Last Contraction',
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              _formatLastContractionTime(
                                                lastContraction.startTime,
                                              ),
                                              style: AppTypography.bodyLarge,
                                            ),
                                            const SizedBox(width: AppSpacing.gapMD),
                                            Text(
                                              '${lastContraction.duration?.inSeconds ?? 0}s',
                                              style: AppTypography.bodyLarge.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                
                                const SizedBox(height: AppSpacing.gapXL),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Draggable contraction list (only in resting state)
              if (hasStarted && !isActive && session.contractions.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.15,
                    minChildSize: 0.15,
                    maxChildSize: 0.4,
                    snap: true,
                    snapSizes: const [0.15, 0.4],
                    builder: (context, scrollController) {
                      return ContractionListSheet(
                        contractions: session.contractions,
                        scrollController: scrollController,
                        onAction: (action, contractionId) async {
                          if (action == ContractionAction.edit) {
                            // Find the contraction to edit
                            final contraction = session.contractions
                                .firstWhere((c) => c.id == contractionId);
                            
                            // Delegate to helper method with proper mounted checks
                            _handleEditContraction(contraction, contractionId);
                          } else if (action == ContractionAction.delete) {
                            // Show confirmation dialog before deleting
                            final confirmed = await AppDialog.show(
                              context: context,
                              title: 'Delete Contraction?',
                              message: 'This will permanently remove this contraction from your session.',
                              primaryActionLabel: 'Delete',
                              secondaryActionLabel: 'Cancel',
                              isPrimaryDestructive: true,
                            );
                            
                            if (confirmed == true && mounted) {
                              await ref.read(contractionTimerNotifierProvider)
                                  ?.deleteContraction(contractionId);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppSpacing.buttonHeightLG,
        height: AppSpacing.buttonHeightLG,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: AppEffects.shadowSM,
        ),
        child: Icon(
          icon,
          size: AppSpacing.iconMD,
          color: onPressed == null
              ? iconColor.withValues(alpha: 0.3)
              : iconColor,
          fill: fill,
        ),
      ),
    );
  }
}
