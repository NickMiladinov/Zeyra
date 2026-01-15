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
import '../../../../core/di/main_providers.dart';
import '../../../../domain/entities/kick_counter/kick_session.dart';
import '../../../../domain/entities/kick_counter/kick_analytics.dart';
import '../../../../shared/widgets/app_jit_tooltip.dart';
import '../../../../shared/providers/tooltip_provider.dart';
import '../../../../shared/providers/active_tracker_coordinator.dart';
import '../../logic/kick_counter_state.dart';
import '../../logic/kick_history_provider.dart';
import '../widgets/session_detail_overlay.dart';
import '../widgets/kick_duration_graph_card.dart';

class KickCounterHistoryScreen extends ConsumerStatefulWidget {
  const KickCounterHistoryScreen({super.key});

  @override
  ConsumerState<KickCounterHistoryScreen> createState() => _KickCounterHistoryScreenState();
}

class _KickCounterHistoryScreenState extends ConsumerState<KickCounterHistoryScreen> {
  // GlobalKeys for tooltip highlighting - created fresh each time to avoid stale references
  late final GlobalKey _firstSessionCardKey;
  late final GlobalKey _graphCardKey;
  
  // Track if tooltips have been checked this session
  bool _tooltipsChecked = false;
  
  // Queue of pending tooltips to show sequentially
  final List<_TooltipData> _tooltipQueue = [];
  bool _isShowingTooltip = false;

  // Track previous history state to detect relevant changes
  int _previousHistoryCount = 0;
  int _previousValidSessionCount = 0;

  // TODO: Remove this flag before release - for testing tooltips on every session
  static const bool _skipShownCheck = false;

  @override
  void initState() {
    super.initState();
    // Create fresh GlobalKeys to avoid any stale state from previous screen instances
    _firstSessionCardKey = GlobalKey(debugLabel: 'firstSessionCard');
    _graphCardKey = GlobalKey(debugLabel: 'graphCard');
    
    // Schedule initial tooltip check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTooltips();
    });
    
    // Listen for history changes to re-check tooltips when relevant conditions are met
    // (e.g., first session recorded while on this screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupHistoryListener();
    });
  }
  
  /// Set up a listener for history changes to trigger tooltip re-checks.
  /// 
  /// This handles the case where a user completes their first session
  /// and stays on the history screen - the tooltip should appear when
  /// the history updates, not only on screen entry.
  void _setupHistoryListener() {
    ref.listenManual(kickHistoryProvider, (previous, next) {
      if (!mounted) return;
      
      final history = next.history;
      final validSessionCount = history
          .where((s) => s.kicks.length >= 10 && s.durationToTenthKick != null)
          .length;
      
      // Check if relevant conditions for tooltips have been met
      final firstSessionJustRecorded = _previousHistoryCount == 0 && history.isNotEmpty;
      final graphJustUnlocked = _previousValidSessionCount < 7 && validSessionCount >= 7;
      
      // Update tracked counts
      _previousHistoryCount = history.length;
      _previousValidSessionCount = validSessionCount;
      
      // Re-trigger tooltip check if a relevant condition was just met
      if (firstSessionJustRecorded || graphJustUnlocked) {
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

    // Check if dependencies are ready first
    final useCaseAsync = ref.read(manageSessionUseCaseProvider);
    if (!useCaseAsync.hasValue) {
      // Dependencies not ready yet, retry after delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _tooltipsChecked = false;
        _checkAndShowTooltips();
      });
      return;
    }

    final tooltipState = ref.read(tooltipProvider);
    final historyState = ref.read(kickHistoryProvider);
    final history = historyState.history;

    // Don't show tooltips if still loading (unless skipping check for testing)
    if (!_skipShownCheck && (!tooltipState.isLoaded || historyState.isLoading)) {
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _tooltipsChecked = false;
        _checkAndShowTooltips();
      });
      return;
    }

    // Wait for history to load even in test mode
    if (historyState.isLoading) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _tooltipsChecked = false;
        _checkAndShowTooltips();
      });
      return;
    }

    // Count valid sessions (10+ kicks)
    final validSessionCount = history
        .where((s) => s.kicks.length >= 10 && s.durationToTenthKick != null)
        .length;

    // Helper to check if tooltip should show
    bool shouldShow(String tooltipId, bool conditionMet) {
      if (_skipShownCheck) return conditionMet;
      return tooltipState.shouldShow(tooltipId, conditionMet);
    }

    // Queue tooltips in priority order (graph unlocked first, then first session)
    if (shouldShow(KickCounterTooltipIds.graphUnlocked, validSessionCount >= 7)) {
      _tooltipQueue.add(_TooltipData(
        id: KickCounterTooltipIds.graphUnlocked,
        targetKey: _graphCardKey,
        config: const JitTooltipConfig(
          title: 'We\'ve found their rhythm! 🎉',
          message: 'The green shaded area is your baby\'s \'Safe Range\'. If sessions take longer than this, let your midwife or maternity unit know.',
          position: TooltipPosition.below,
        ),
      ));
    }

    if (shouldShow(KickCounterTooltipIds.firstSession, history.isNotEmpty)) {
      _tooltipQueue.add(_TooltipData(
        id: KickCounterTooltipIds.firstSession,
        targetKey: _firstSessionCardKey,
        config: const JitTooltipConfig(
          message: 'Tap any session to view details, add notes, or delete it.',
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
        // Mark tooltip as shown (persists to SharedPreferences)
        ref.read(tooltipProvider.notifier).dismissTooltip(tooltipData.id);
        
        _isShowingTooltip = false;
        
        // Show next tooltip after a brief delay for smooth transition
        if (_tooltipQueue.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _showNextTooltip();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if dependencies are ready
    final useCaseAsync = ref.watch(manageSessionUseCaseProvider);

    if (!useCaseAsync.hasValue) {
      // Show loading while dependencies initialize
      return Scaffold(
        appBar: AppBar(
          title: Text('Your Baby\'s Patterns', style: AppTypography.headlineSmall),
          centerTitle: true,
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final historyState = ref.watch(kickHistoryProvider);
    final history = historyState.history;
    final activeSession = ref.watch(kickCounterProvider).activeSession;
    // Check if we can start a new kick counter session
    // (no active kick counter OR contraction timer session)
    final canStartSession = ref.watch(canStartKickCounterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Baby\'s Patterns', style: AppTypography.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(AppIcons.back, size: AppSpacing.iconMD, color: AppColors.iconDefault),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.infoIcon, size: AppSpacing.iconMD, color: AppColors.iconDefault),
            onPressed: () => context.push(ToolRoutes.kickCounterInfo),
          ),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(kickHistoryProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.paddingLG),
                children: [
                  // Info card at the top
                  _buildInfoCard(),
                  const SizedBox(height: AppSpacing.gapXL),

                  // Graph card (key passed directly to container for tooltip highlighting)
                  if (historyState.analytics != null)
                    KickDurationGraphCard(
                      allSessions: history,
                      highlightKey: _graphCardKey,
                    ),
                  const SizedBox(height: AppSpacing.gapXL),

                  Text(
                    'Session History',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.gapMD),

                  if (history.isEmpty)
                    _buildEmptyState()
                  else
                    ...history.asMap().entries.map((entry) {
                      final index = entry.key;
                      final session = entry.value;
                      final sessionAnalytic = index < historyState.sessionAnalytics.length
                          ? historyState.sessionAnalytics[index]
                          : null;
                      return _SessionHistoryItem(
                        session: session,
                        sessionAnalytics: sessionAnalytic,
                        onTap: () => _showSessionDetail(session),
                        // Pass key for first item only (for tooltip highlighting)
                        highlightKey: index == 0 ? _firstSessionCardKey : null,
                      );
                    }),
                ],
              ),
            ),
      // Hide FAB if there's an active session (kick counter OR contraction timer)
      // When an active session exists, the banner is shown instead
      floatingActionButton: canStartSession && activeSession == null
          ? ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.buttonHeightLG,
                maxHeight: AppSpacing.buttonHeightLG,
              ),
              child: FloatingActionButton.extended(
                heroTag: 'kick_counter_start_tracking_fab',
                onPressed: () => context.push(ToolRoutes.kickCounterActive),
                backgroundColor: AppColors.primary,
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
                icon: const Icon(AppIcons.add, size: AppSpacing.iconMD, color: AppColors.white),
                label: Text(
                  'Start Tracking',
                  style: AppTypography.labelLarge.copyWith(color: AppColors.white),
                ),
              ),
            )
          : null,
      // Bottom nav bar is provided by MainShell
    );
  }

  Widget _buildInfoCard() {
    return GestureDetector(
      onTap: () => context.push(ToolRoutes.kickCounterInfo),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'If you\'re ever worried about your baby\'s movements, contact your midwife or maternity unit right away.',
                style: AppTypography.bodyMedium
              ),
            ),
            const SizedBox(width: AppSpacing.gapMD),
            Icon(AppIcons.infoIcon, color: AppColors.primary, size: AppSpacing.iconMD),
          ],
        ),
      ),
    );
  }

  void _showSessionDetail(KickSession session) async {
    // Find the session analytics for this session
    final historyState = ref.read(kickHistoryProvider);
    final sessionIndex = historyState.history.indexOf(session);
    final sessionAnalytic = sessionIndex >= 0 && sessionIndex < historyState.sessionAnalytics.length
        ? historyState.sessionAnalytics[sessionIndex]
        : null;
    
    final result = await SessionDetailOverlay.show(
      context: context,
      session: session,
      sessionAnalytics: sessionAnalytic,
      onNoteUpdated: (sessionId, note) async {
        await ref.read(kickHistoryProvider.notifier).updateSessionNote(sessionId, note);
      },
    );
    
    if (result != null && mounted) {
      if (result.action == SessionAction.delete) {
        await ref.read(kickHistoryProvider.notifier).deleteSession(session.id);
      }
    }
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
          Icon(AppIcons.history, size: AppSpacing.iconXXL, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.gapMD),
          Text(
            'No sessions recorded yet',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.gapSM),
          Text(
            'Record your baby\'s movements to see patterns here.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Helper class to hold tooltip data for the queue.
class _TooltipData {
  final String id;
  final GlobalKey targetKey;
  final JitTooltipConfig config;

  const _TooltipData({
    required this.id,
    required this.targetKey,
    required this.config,
  });
}

class _SessionHistoryItem extends StatelessWidget {
  final KickSession session;
  final KickSessionAnalytics? sessionAnalytics;
  final VoidCallback onTap;
  /// Optional key to attach to the card for tooltip highlighting.
  final GlobalKey? highlightKey;

  const _SessionHistoryItem({
    required this.session,
    this.sessionAnalytics,
    required this.onTap,
    this.highlightKey,
  });

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

  @override
  Widget build(BuildContext context) {
    // For sessions with 10+ kicks, show time to 10 movements (matches graph/outlier detection)
    // For incomplete sessions, show active duration
    final hasMinimumKicks = sessionAnalytics?.hasMinimumKicks ?? (session.kicks.length >= 10);
    final durationSeconds = hasMinimumKicks && session.durationToTenthKick != null
        ? session.durationToTenthKick!.inSeconds
        : session.activeDuration.inSeconds;
    // Round to nearest minute for display
    final durationMin = durationSeconds > 0 ? ((durationSeconds + 30) / 60).floor().clamp(1, 999) : 1;
    final hasNote = session.note != null && session.note!.isNotEmpty;
    final isOutlier = sessionAnalytics?.isOutlier ?? false;

    // Determine stripe color and status label for abnormal sessions
    Color? stripeColor;
    String? statusLabel;
    IconData? statusIcon;
    
    if (!hasMinimumKicks) {
      stripeColor = AppColors.warning;
      statusLabel = 'Incomplete';
      statusIcon = AppIcons.warningIcon;
    } else if (isOutlier) {
      stripeColor = AppColors.warningLight;
      statusLabel = 'Long Session';
      statusIcon = AppIcons.schedule;
    }

    // Build the card - key is on the container itself (not including margin)
    // Explicit width ensures consistent highlight positioning in tooltip
    final card = Container(
      key: highlightKey,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        boxShadow: AppEffects.shadowXS,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left stripe indicator (only for abnormal sessions)
            if (stripeColor != null)
              Container(
                width: AppSpacing.borderWidthThick,
                decoration: BoxDecoration(
                  color: stripeColor.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppEffects.radiusLG),
                    bottomLeft: Radius.circular(AppEffects.radiusLG),
                  ),
                ),
              ),
            
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.paddingLG),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: AppSpacing.xxxl,
                      height: AppSpacing.xxxl,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppEffects.roundedCircle,
                      ),
                      child: Icon(AppIcons.favorite, fill: 1, color: AppColors.primary, size: AppSpacing.iconSM),
                    ),
                    const SizedBox(width: AppSpacing.gapMD),
                    
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(session.startTime),
                                style: AppTypography.bodyLarge,
                              ),
                              Text(
                                '$durationMin min',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.gapXS),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side: movement count and note icon
                              Row(
                                children: [
                                  Text(
                                    '${session.kickCount} movements',
                                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                  ),
                                  if (hasNote) ...[
                                    const SizedBox(width: AppSpacing.gapSM),
                                    Icon(
                                      AppIcons.chat,
                                      size: AppSpacing.iconXXS,
                                      color: AppColors.iconDefault,
                                    ),
                                  ],
                                ],
                              ),
                              // Right side: status label (only for abnormal sessions)
                              if (statusLabel != null && statusIcon != null)
                                Row(
                                  children: [
                                    Icon(
                                      statusIcon,
                                      size: AppSpacing.iconXXS,
                                      color: stripeColor,
                                    ),
                                    const SizedBox(width: AppSpacing.gapXS),
                                    Text(
                                      statusLabel,
                                      style: AppTypography.labelSmall.copyWith(color: stripeColor),
                                    ),
                                  ],
                                ),
                            ],
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
      ),
    );

    // Wrap with GestureDetector and add margin separately (margin not included in highlight)
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.marginMD),
      child: GestureDetector(
        onTap: onTap,
        child: card,
      ),
    );
  }
}

