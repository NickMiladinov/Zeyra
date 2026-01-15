import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';
import 'package:zeyra/shared/widgets/app_dialog.dart';
import 'package:zeyra/features/contraction_timer/ui/screens/contraction_timer_info_screen.dart';

/// Result returned when session complete overlay is closed
class SessionCompleteResult {
  final String? note;
  final bool shouldSave;

  const SessionCompleteResult({
    this.note,
    required this.shouldSave,
  });
}

/// Overlay shown when a contraction timing session is completed.
/// 
/// Displays session summary and allows user to add an optional note.
class SessionCompleteOverlay extends StatefulWidget {
  final int contractionCount;
  final Duration sessionDuration;
  final bool achieved511Alert;
  final String? initialNote;

  const SessionCompleteOverlay({
    super.key,
    required this.contractionCount,
    required this.sessionDuration,
    required this.achieved511Alert,
    this.initialNote,
  });

  /// Show the session complete overlay
  static Future<SessionCompleteResult?> show({
    required BuildContext context,
    required int contractionCount,
    required Duration sessionDuration,
    required bool achieved511Alert,
    String? initialNote,
  }) async {
    return await AppBottomSheet.show<SessionCompleteResult>(
      context: context,
      child: SessionCompleteOverlay(
        contractionCount: contractionCount,
        sessionDuration: sessionDuration,
        achieved511Alert: achieved511Alert,
        initialNote: initialNote,
      ),
      isDismissible: false, // Prevent accidental dismissal
      enableDrag: false,
    );
  }

  @override
  State<SessionCompleteOverlay> createState() => _SessionCompleteOverlayState();
}

class _SessionCompleteOverlayState extends State<SessionCompleteOverlay> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with initial note if provided
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDuration() {
    final hours = widget.sessionDuration.inHours;
    final minutes = widget.sessionDuration.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours hour${hours == 1 ? '' : 's'} $minutes minute${minutes == 1 ? '' : 's'}';
    } else if (minutes > 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      return 'Less than 1 minute';
    }
  }

  Future<void> _handleDiscard() async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Discard Session?',
      message: 'This will permanently delete all contractions in this session.',
      primaryActionLabel: 'Discard',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );
    
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const SessionCompleteResult(
        shouldSave: false,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Session Complete!',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.gapXL),
        
        // Summary (wrapped in a box)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppEffects.radiusXL),
          ),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.headlineLarge,
                  children: [
                    const TextSpan(text: 'You tracked '),
                    TextSpan(
                      text: '${widget.contractionCount} contraction${widget.contractionCount == 1 ? '' : 's'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ' over\n'),
                    TextSpan(
                      text: _formatDuration(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.gapXL),
        
        // 5-1-1 Alert notification (if achieved)
        if (widget.achieved511Alert) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingMD),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppEffects.radiusMD),
              border: Border.all(
                color: AppColors.primary,
                width: AppSpacing.borderWidthThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.infoIcon,
                      size: AppSpacing.iconSM,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.gapSM),
                    Expanded(
                      child: Text(
                        '5-1-1 Rule Achieved',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.gapMD),
                Text(
                  'Your contractions meet the 5-1-1 criteria. This indicates you may be in active labour. Contact your midwife or maternity unit.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapMD),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const ContractionTimerInfoScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Learn more about the 5-1-1 rule',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gapXS),
                      Icon(
                        AppIcons.arrowForward,
                        size: AppSpacing.iconXS,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.gapXL),
        ],
        
        // Note input
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: 'Add a note about this session...',
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLG,
              vertical: AppSpacing.paddingLG,
            ),
          ),
          minLines: 1,
          maxLines: 5,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.gapXL),
        
        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(SessionCompleteResult(
                note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                shouldSave: true,
              ));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingXXL,
                vertical: AppSpacing.paddingMD,
              ),
            ),
            child: const Text('Save to Diary'),
          ),
        ),
        const SizedBox(height: AppSpacing.gapMD),
        
        // Discard button (uses theme TextButtonTheme)
        TextButton(
          onPressed: _handleDiscard,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Discard Session'),
        ),
      ],
    );
  }
}

