import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_state.dart';
import 'package:zeyra/features/kick_counter/logic/kick_history_provider.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_active_session_screen.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_counter_info_screen.dart';
import 'package:zeyra/features/kick_counter/ui/widgets/session_detail_overlay.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/shared/widgets/app_bottom_nav_bar.dart';

class KickCounterHistoryScreen extends ConsumerStatefulWidget {
  const KickCounterHistoryScreen({super.key});

  @override
  ConsumerState<KickCounterHistoryScreen> createState() => _KickCounterHistoryScreenState();
}

class _KickCounterHistoryScreenState extends ConsumerState<KickCounterHistoryScreen> {
  
  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(kickHistoryProvider);
    final history = historyState.history;
    final activeSession = ref.watch(kickCounterProvider).activeSession;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Baby\'s Patterns', style: AppTypography.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(AppIcons.back, size: AppSpacing.iconMD, color: AppColors.iconDefault),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.infoIcon, size: AppSpacing.iconMD, color: AppColors.iconDefault),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const KickCounterInfoScreen(),
                ),
              );
            },
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

                  Text(
                    'Session History',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.gapMD),

                  if (history.isEmpty)
                    _buildEmptyState()
                  else
                    ...history.map((session) => _SessionHistoryItem(
                      session: session,
                      onTap: () => _showSessionDetail(session),
                    )),
                ],
              ),
            ),
      // Hide FAB if there's an active session (show banner instead)
      floatingActionButton: activeSession == null 
        ? FloatingActionButton.extended( // TODO: Lower padding top-bottom
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const KickActiveSessionScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: AppEffects.durationSlow,
              reverseTransitionDuration: AppEffects.durationSlow,        // Disappearing animation
            ),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: AppSpacing.elevationSM,
        shape: RoundedRectangleBorder(
          borderRadius: AppEffects.roundedCircle,
        ),
        icon: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.paddingSM),
          child: Icon(AppIcons.add, size: AppSpacing.iconMD, color: AppColors.white),
        ),
        label: Padding(
          padding: EdgeInsets.only(
            right: AppSpacing.paddingLG,
            top: AppSpacing.paddingXS,
            bottom: AppSpacing.paddingXS,
          ),
          child: Text(
            'Start Tracking',
            style: AppTypography.labelLarge.copyWith(color: AppColors.white),
          ),
        ),
      )
      : null,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3, // Tools tab
        onTap: (index) {
          // TODO: Handle navigation based on index
          // For now, just pop if navigating away
          if (index != 3) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
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
    );
  }

  void _showSessionDetail(KickSession session) async {
    final result = await SessionDetailOverlay.show(
      context: context,
      session: session,
    );
    
    if (result != null && mounted) {
      if (result.action == SessionAction.delete) {
        await ref.read(kickHistoryProvider.notifier).deleteSession(session.id);
      } else if (result.action == SessionAction.editNote) {
        await ref.read(kickHistoryProvider.notifier).updateSessionNote(session.id, result.note);
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

class _SessionHistoryItem extends StatelessWidget {
  final KickSession session;
  final VoidCallback onTap;

  const _SessionHistoryItem({
    required this.session,
    required this.onTap,
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
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final durationMin = session.activeDuration.inMinutes;
    final hasNote = session.note != null && session.note!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.marginMD),
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppEffects.radiusLG),
          boxShadow: AppEffects.shadowXS,
        ),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${session.kickCount} movements counted',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      if (hasNote) ...[
                        const SizedBox(width: AppSpacing.gapSM),
                        Icon(
                          AppIcons.chat,
                          size: AppSpacing.iconXS,
                          color: AppColors.iconDefault,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

