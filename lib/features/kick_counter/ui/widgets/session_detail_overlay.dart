import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
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

  const SessionDetailOverlay({
    super.key,
    required this.session,
  });

  /// Show the session detail overlay
  static Future<SessionDetailResult?> show({
    required BuildContext context,
    required KickSession session,
  }) async {
    return await AppBottomSheet.show<SessionDetailResult>(
      context: context,
      child: SessionDetailOverlay(session: session),
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
        const SizedBox(height: AppSpacing.gapSM),
        
        // Divider after date row
        Divider(
          color: AppColors.divider,
          thickness: AppSpacing.borderWidthThin,
          height: AppSpacing.borderWidthThin,
        ),
        const SizedBox(height: AppSpacing.gapXL),
        
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '${session.kickCount}',
                label: 'Movements',
              ),
            ),
            const SizedBox(width: AppSpacing.gapMD),
            Expanded(
              child: _StatCard(
                value: session.activeDuration.inMinutes.toString(),
                label: 'Minutes',
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

  const _StatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
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

