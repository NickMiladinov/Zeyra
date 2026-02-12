import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../domain/entities/contraction_timer/contraction_session.dart';
import '../../../../shared/widgets/app_jit_tooltip.dart';
import '../../../../shared/providers/tooltip_provider.dart';
import '../../../../shared/providers/active_tracker_coordinator.dart';
import '../../logic/contraction_timer_state.dart';
import '../../logic/contraction_history_provider.dart';
import '../../logic/contraction_timer_onboarding_provider.dart';
import '../widgets/contraction_timer_intro_overlay.dart';

class LabourOverviewScreen extends ConsumerStatefulWidget {
  const LabourOverviewScreen({super.key});
  
  @override
  ConsumerState<LabourOverviewScreen> createState() => _LabourOverviewScreenState();
}

class _LabourOverviewScreenState extends ConsumerState<LabourOverviewScreen> {
  // GlobalKey for tooltip highlighting
  late final GlobalKey _firstSessionCardKey;
  
  // Track if tooltips have been checked this session
  bool _tooltipsChecked = false;
  
  // Queue of pending tooltips to show sequentially
  final List<_TooltipData> _tooltipQueue = [];
  bool _isShowingTooltip = false;

  // Track previous history state to detect relevant changes
  int _previousHistoryCount = 0;
  
  @override
  void initState() {
    super.initState();
    // Create fresh GlobalKey
    _firstSessionCardKey = GlobalKey(debugLabel: 'firstSessionCard');
    
    // Check if should show intro overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowIntroOverlay();
      _checkAndShowTooltips();
    });
    
    // Listen for history changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupHistoryListener();
    });
  }
  
  /// Check if intro overlay should be shown
  Future<void> _checkAndShowIntroOverlay() async {
    final onboardingState = ref.read(contractionTimerOnboardingProvider);
    
    if (onboardingState == null) {
      // Wait for state to load
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) _checkAndShowIntroOverlay();
      return;
    }
    
    if (!onboardingState) {
      if (mounted) {
        await ContractionTimerIntroOverlay.show(context);
      }
    }
  }
  
  /// Set up a listener for history changes to trigger tooltip re-checks.
  void _setupHistoryListener() {
    ref.listenManual(contractionHistoryProvider, (previous, next) {
      if (!mounted) return;
      
      final history = next.history;
      
      // Check if first session was just recorded
      final firstSessionJustRecorded = _previousHistoryCount == 0 && history.isNotEmpty;
      
      // Update tracked count
      _previousHistoryCount = history.length;
      
      // Re-trigger tooltip check if a relevant condition was just met
      if (firstSessionJustRecorded) {
        _tooltipsChecked = false; // Allow re-check
        // Small delay to ensure UI has updated with new data
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _checkAndShowTooltips();
        });
      }
    });
  }
  
  /// Check conditions and queue appropriate tooltips.
  void _checkAndShowTooltips() {
    if (_tooltipsChecked) return;
    _tooltipsChecked = true;

    final tooltipState = ref.read(tooltipProvider);
    final historyState = ref.read(contractionHistoryProvider);
    final history = historyState.history;

    // Don't show tooltips if still loading
    if (!tooltipState.isLoaded || historyState.isLoading) {
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _tooltipsChecked = false;
        _checkAndShowTooltips();
      });
      return;
    }

    if (tooltipState.shouldShow(ContractionTimerTooltipIds.firstSession, history.isNotEmpty)) {
      _tooltipQueue.add(_TooltipData(
        id: ContractionTimerTooltipIds.firstSession,
        targetKey: _firstSessionCardKey,
        config: const JitTooltipConfig(
          message: 'Tap any session to view details and statistics.',
          position: TooltipPosition.below,
        ),
      ));
    }

    // Start showing tooltips from the queue
    _showNextTooltip();
  }

  /// Show the next tooltip in the queue, if any.
  void _showNextTooltip() {
    if (!mounted || _isShowingTooltip || _tooltipQueue.isEmpty) return;

    _isShowingTooltip = true;
    final tooltipData = _tooltipQueue.removeAt(0);

    AppJitTooltip.show(
      context: context,
      targetKey: tooltipData.targetKey,
      config: tooltipData.config,
      onDismiss: () {
        // Mark tooltip as shown
        ref.read(tooltipProvider.notifier).dismissTooltip(tooltipData.id);
        
        _isShowingTooltip = false;
        
        // Show next tooltip after a brief delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showNextTooltip();
        });
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDay = DateTime(date.year, date.month, date.day);
    
    if (sessionDay == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (sessionDay == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(date);
    }
  }
  
  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  String _formatFrequency(Duration? frequency) {
    if (frequency == null) return '—';

    final totalSeconds = frequency.inSeconds;
    final minutes = frequency.inMinutes;

    if (totalSeconds < 60) {
      return '${totalSeconds}s apart';
    } else if (minutes < 60) {
      final secs = totalSeconds % 60;
      if (secs > 0) {
        return '${minutes}m ${secs}s apart';
      }
      return '${minutes}m apart';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m apart';
    }
  }
  
  String _formatContractionDuration(Duration? duration) {
    if (duration == null) return '—';
    return '${duration.inSeconds}s';
  }
  
  @override
  Widget build(BuildContext context) {
    // Handle async loading of contraction history provider
    ContractionHistoryState historyState;
    try {
      historyState = ref.watch(contractionHistoryProvider);
    } catch (e) {
      // Provider dependencies still loading, show loading state
      historyState = const ContractionHistoryState(isLoading: true);
    }
    final history = historyState.history;

    // Handle async loading of contraction timer provider
    ContractionSession? activeSession;
    try {
      final timerStateAsync = ref.watch(contractionTimerProvider);
      activeSession = timerStateAsync.valueOrNull?.activeSession;
    } catch (e) {
      // Provider dependencies still loading or error occurred
      activeSession = null;
    }

    // Check if we can start a new contraction timer session
    // (no active contraction timer OR kick counter session)
    final canStartSession = ref.watch(canStartContractionTimerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Labour Overview', style: AppTypography.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            size: AppSpacing.iconMD,
            color: AppColors.iconDefault,
          ),
          onPressed: () => context.pop(),
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
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(contractionHistoryProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.paddingLG),
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.paddingLG),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppEffects.radiusLG),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'If you\'re ever worried about your contractions or labour, contact your midwife or maternity unit right away.',
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.gapMD),
                        Icon(
                          AppIcons.infoIcon,
                          color: AppColors.primary,
                          size: AppSpacing.iconMD,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gapXL),
                  
                  // Session history header
                  Text(
                    'Session History',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.gapXL),
                  
                  // Empty state or session list
                  if (history.isEmpty)
                    _buildEmptyState()
                  else
                    ...history.asMap().entries.map((entry) {
                      final index = entry.key;
                      final session = entry.value;
                      // Attach key to first session for tooltip
                      return _SessionHistoryCard(
                        key: index == 0 ? _firstSessionCardKey : null,
                        session: session,
                        formatDate: _formatDate,
                        formatDuration: _formatDuration,
                        formatFrequency: _formatFrequency,
                        formatContractionDuration: _formatContractionDuration,
                        onTap: () => _showSessionDetail(context, session),
                      );
                    }),
                ],
              ),
            ),
      // Hide FAB if there's an active session (contraction timer OR kick counter)
      // When an active session exists, the banner is shown instead via MainShell
      floatingActionButton: canStartSession && activeSession == null
          ? ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.buttonHeightLG,
                maxHeight: AppSpacing.buttonHeightLG,
              ),
              child: FloatingActionButton.extended(
                heroTag: 'contraction_timer_start_fab',
                onPressed: () => context.push(ToolRoutes.contractionTimerActive),
                backgroundColor: AppColors.secondary,
                elevation: AppSpacing.elevationSM,
                extendedPadding: const EdgeInsets.only(
                  left: AppSpacing.paddingMD,
                  right: AppSpacing.paddingLG,
                  top: 0,
                  bottom: 0,
                ),
                extendedIconLabelSpacing: AppSpacing.gapSM,
                shape: RoundedRectangleBorder(
                  borderRadius: AppEffects.roundedCircle,
                ),
                icon: const Icon(
                  AppIcons.add,
                  size: AppSpacing.iconMD,
                  color: AppColors.white,
                ),
                label: Text(
                  'Start Timing',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            )
          : null,
      // Bottom nav bar is provided by MainShell
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingXL),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.history,
            size: AppSpacing.iconXXL,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.gapMD),
          Text(
            'No sessions recorded yet',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.gapSM),
          Text(
            'Time your contractions to track labour patterns.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _showSessionDetail(BuildContext context, ContractionSession session) {
    // Pass session via extra parameter since it's a complex object
    context.push(
      ToolRoutes.contractionSessionDetailPath(session.id),
      extra: session,
    );
  }
}

class _SessionHistoryCard extends StatelessWidget {
  final ContractionSession session;
  final String Function(DateTime) formatDate;
  final String Function(Duration) formatDuration;
  final String Function(Duration?) formatFrequency;
  final String Function(Duration?) formatContractionDuration;
  final VoidCallback onTap;
  
  const _SessionHistoryCard({
    super.key,
    required this.session,
    required this.formatDate,
    required this.formatDuration,
    required this.formatFrequency,
    required this.formatContractionDuration,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.marginMD),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppEffects.radiusXL),
            boxShadow: AppEffects.shadowXS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Labour Session: ${formatDate(session.startTime)}',
                    style: AppTypography.headlineExtraSmall,
                  ),
                  Icon(
                    AppIcons.arrowForward,
                    size: AppSpacing.iconSM,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapMD),
              
              // Stats
              _StatRow(
                label: 'Total Duration:',
                value: formatDuration(session.totalDuration),
              ),
              const SizedBox(height: AppSpacing.gapSM),
              _StatRow(
                label: 'Closest Frequency:',
                value: formatFrequency(session.closestFrequency),
              ),
              const SizedBox(height: AppSpacing.gapSM),
              _StatRow(
                label: 'Longest Contraction:',
                value: formatContractionDuration(session.longestContraction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}

/// Data class for queued tooltips
class _TooltipData {
  final String id;
  final GlobalKey targetKey;
  final JitTooltipConfig config;

  _TooltipData({
    required this.id,
    required this.targetKey,
    required this.config,
  });
}
