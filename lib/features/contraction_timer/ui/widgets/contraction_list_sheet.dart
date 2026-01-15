import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';

/// Actions that can be performed on a contraction
enum ContractionAction {
  edit,
  delete,
}

/// Draggable bottom sheet showing list of contractions in current session
/// Used in the active session screen to display recent contractions
class ContractionListSheet extends StatelessWidget {
  final List<Contraction> contractions;
  final ScrollController scrollController;
  final Function(ContractionAction, String) onAction;
  
  const ContractionListSheet({
    super.key,
    required this.contractions,
    required this.scrollController,
    required this.onAction,
  });
  
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  String _formatDuration(Duration? duration) {
    if (duration == null) return '—';
    final seconds = duration.inSeconds;
    return '$seconds sec';
  }
  
  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Get only completed contractions (reverse to show latest first)
    final completed = contractions
        .where((c) => c.endTime != null)
        .toList()
        .reversed
        .toList();
    
    return AppBottomSheet(
      title: 'Recent Contractions',
      titleStyle: AppTypography.headlineExtraSmall,
      backgroundColor: AppColors.white,
      scrollController: scrollController,
      useSliverLayout: true,
      applyContentPadding: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          completed.length,
          (index) {
            final contraction = completed[index];
            final isLast = index == completed.length - 1;
            return ContractionListItem(
              contraction: contraction,
              timeAgo: _getTimeAgo(contraction.startTime),
              time: _formatTime(contraction.startTime),
              duration: _formatDuration(contraction.duration),
              showDivider: !isLast,
              onAction: (action) => onAction(action, contraction.id),
            );
          },
        ),
      ),
    );
  }
}

/// List item widget for displaying a single contraction
/// Used in both the bottom sheet and draggable sheet
class ContractionListItem extends StatelessWidget {
  final Contraction contraction;
  final String timeAgo;
  final String time;
  final String duration;
  final bool showDivider;
  final Function(ContractionAction) onAction;
  
  const ContractionListItem({
    super.key,
    required this.contraction,
    required this.timeAgo,
    required this.time,
    required this.duration,
    this.showDivider = true,
    required this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXL,
            vertical: AppSpacing.paddingSM,
          ),
          child: Row(
            children: [
              // Left side: Time and Intensity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.gapXS),
                    Text(
                      contraction.intensity.displayName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right side: Duration and Time ago
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    duration,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gapXS),
                  Text(
                    timeAgo,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: AppSpacing.gapSM),
              
              // More menu
              PopupMenuButton<ContractionAction>(
                icon: Icon(
                  AppIcons.more,
                  size: AppSpacing.iconMD,
                  color: AppColors.iconDefault,
                ),
                padding: EdgeInsets.zero,
                menuPadding: EdgeInsets.zero,
                onSelected: onAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ContractionAction.edit,
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.edit,
                          size: AppSpacing.iconSM,
                          color: AppColors.iconDefault,
                        ),
                        const SizedBox(width: AppSpacing.gapSM),
                        Text('Edit', style: AppTypography.bodyLarge),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: AppSpacing.borderWidthThin),
                  PopupMenuItem(
                    value: ContractionAction.delete,
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.delete,
                          size: AppSpacing.iconSM,
                          color: AppColors.iconError,
                        ),
                        const SizedBox(width: AppSpacing.gapSM),
                        Text('Delete', style: AppTypography.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Divider between items
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.paddingLG,
            endIndent: AppSpacing.paddingLG,
          ),
      ],
    );
  }
}

