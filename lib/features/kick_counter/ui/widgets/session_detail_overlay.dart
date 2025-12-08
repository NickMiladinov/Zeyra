import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_analytics.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';
import 'package:zeyra/shared/widgets/app_dialog.dart';

/// Actions that can be performed on a session
enum SessionAction {
  editNote,
  delete,
}

/// Result returned from session detail overlay
class SessionDetailResult {
  final SessionAction action;
  final String? note;

  const SessionDetailResult({
    required this.action,
    this.note,
  });
}

/// Overlay showing session details with edit/delete options
class SessionDetailOverlay extends StatelessWidget {
  final KickSession session;
  final KickSessionAnalytics? sessionAnalytics;

  const SessionDetailOverlay({
    super.key,
    required this.session,
    this.sessionAnalytics,
  });

  /// Show the session detail overlay
  static Future<SessionDetailResult?> show({
    required BuildContext context,
    required KickSession session,
    KickSessionAnalytics? sessionAnalytics,
  }) async {
    return await AppBottomSheet.show<SessionDetailResult>(
      context: context,
      child: SessionDetailOverlay(
        session: session,
        sessionAnalytics: sessionAnalytics,
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    final sessionDate = session.startTime;
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDay = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

    if (sessionDay == today) {
      return 'Today, ${_formatTime(sessionDate)}';
    } else if (sessionDay == yesterday) {
      return 'Yesterday, ${_formatTime(sessionDate)}';
    } else {
      return '${_formatMonthDay(sessionDate)}, ${_formatTime(sessionDate)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatMonthDay(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Get duration display - uses durationToTenthKick for valid sessions,
  /// activeDuration for incomplete sessions. Rounds to nearest minute.
  String _getDurationDisplay() {
    final hasMinimumKicks = sessionAnalytics?.hasMinimumKicks ?? (session.kicks.length >= 10);
    final durationSeconds = hasMinimumKicks && session.durationToTenthKick != null
        ? session.durationToTenthKick!.inSeconds
        : session.activeDuration.inSeconds;
    // Round to nearest minute
    final minutes = durationSeconds > 0 ? ((durationSeconds + 30) / 60).floor().clamp(1, 999) : 1;
    return '$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with date and menu button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(),
              style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            PopupMenuButton<SessionAction>(
              icon: Icon(AppIcons.moreVertical, size: AppSpacing.iconLG, color: AppColors.iconDefault),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEffects.radiusMD),
                side: const BorderSide(
                  color: AppColors.border,
                  width: AppSpacing.borderWidthThin,
                ),
              ),
              padding: EdgeInsets.zero,
              menuPadding: EdgeInsets.zero,
              onSelected: (action) async {
                if (action == SessionAction.editNote) {
                  if (!context.mounted) return;
                  final note = await _showEditNoteDialog(context);
                  if (note != null && context.mounted) {
                    Navigator.of(context).pop(SessionDetailResult(
                      action: SessionAction.editNote,
                      note: note,
                    ));
                  }
                } else if (action == SessionAction.delete) {
                  if (!context.mounted) return;
                  final confirmed = await _showDeleteConfirmation(context);
                  if (confirmed == true && context.mounted) {
                    Navigator.of(context).pop(const SessionDetailResult(
                      action: SessionAction.delete,
                    ));
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: SessionAction.editNote,
                  child: Row(
                    children: [
                      Icon(AppIcons.edit, size: AppSpacing.iconSM, color: AppColors.iconDefault),
                      const SizedBox(width: AppSpacing.gapSM),
                      Text('Edit Note', style: AppTypography.bodyLarge),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: AppSpacing.borderWidthThin),
                PopupMenuItem(
                  value: SessionAction.delete,
                  child: Row(
                    children: [
                      Icon(AppIcons.delete, size: AppSpacing.iconSM, color: AppColors.iconError),
                      const SizedBox(width: AppSpacing.gapSM),
                      Text('Delete Session', style: AppTypography.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gapLG),
        
        // Warning card for abnormal sessions
        if (sessionAnalytics != null && (!sessionAnalytics!.hasMinimumKicks || sessionAnalytics!.isOutlier)) ...[
          if (!sessionAnalytics!.hasMinimumKicks)
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingLG),
              decoration: BoxDecoration(
                color: AppColors.warningLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppEffects.radiusLG),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.warningIcon,
                    size: AppSpacing.iconSM,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.gapSM),
                  Expanded(
                    child: Text(
                      'Count to 10 movements for the session to be part of your analytics',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (sessionAnalytics!.isOutlier)
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingLG),
              decoration: BoxDecoration(
                color: AppColors.warningLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppEffects.radiusLG),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.warningIcon,
                    size: AppSpacing.iconLG,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.gapMD),
                  Expanded(
                    child: Text(
                      'This session took longer than usual. If you\'re worried about reduced movements, contact your midwife or maternity unit.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.gapLG),
        ],
        
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '${session.kickCount}',
                label: 'Movements',
                isHighlighted: sessionAnalytics?.hasMinimumKicks == false,
              ),
            ),
            const SizedBox(width: AppSpacing.gapMD),
            Expanded(
              child: _StatCard(
                // For sessions with 10+ kicks, show time to 10 movements (matches graph)
                value: _getDurationDisplay(),
                label: 'Minutes',
                isHighlighted: sessionAnalytics?.isOutlier == true && sessionAnalytics?.hasMinimumKicks == true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gapXL),
        
        // Note section
        Text(
          'Your Note',
          style: AppTypography.headlineExtraSmall,
        ),
        const SizedBox(height: AppSpacing.gapMD),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppEffects.radiusMD),
          ),
          child: Text(
            session.note ?? 'No note added',
            style: AppTypography.bodyLarge.copyWith(
              color: session.note != null ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _showEditNoteDialog(BuildContext context) {
    final controller = TextEditingController(text: session.note ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Note', style: AppTypography.headlineMedium),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add a note about this session...',
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Save', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return AppDialog.show(
      context: context,
      title: 'Delete Session?',
      message: 'This will permanently delete this session. Are you sure?',
      primaryActionLabel: 'Delete',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isHighlighted;

  const _StatCard({
    required this.value,
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        border: isHighlighted
            ? Border.all(
                color: AppColors.warningLight.withValues(alpha: 0.5),
                width: AppSpacing.borderWidthMedium,
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.gapXS),
          Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

