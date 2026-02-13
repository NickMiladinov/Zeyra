import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_counter_info_screen.dart';

/// Result returned when session complete overlay is closed
class SessionCompleteResult {
  final String? note;
  final bool shouldSave;

  const SessionCompleteResult({
    this.note,
    required this.shouldSave,
  });
}

/// Overlay shown when a kick counting session is completed.
/// 
/// Displays session summary and allows user to add an optional note.
class SessionCompleteOverlay extends StatefulWidget {
  final int kickCount;
  final Duration duration;
  final String? initialNote;

  const SessionCompleteOverlay({
    super.key,
    required this.kickCount,
    required this.duration,
    this.initialNote,
  });

  /// Show the session complete overlay
  static Future<SessionCompleteResult?> show({
    required BuildContext context,
    required int kickCount,
    required Duration duration,
    String? initialNote,
  }) async {
    return await AppBottomSheet.show<SessionCompleteResult>(
      context: context,
      child: SessionCompleteOverlay(
        kickCount: kickCount,
        duration: duration,
        initialNote: initialNote,
      ),
      isDismissible: true, // Allow swipe down to save without note
      enableDrag: true,
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
    // Round to nearest minute (minimum 1 minute)
    final seconds = widget.duration.inSeconds;
    final minutes = seconds > 0 ? ((seconds + 30) / 60).floor().clamp(1, 999) : 1;
    return '$minutes minute${minutes == 1 ? '' : 's'}';
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
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTypography.headlineLarge,
              children: [
                const TextSpan(text: 'You felt '),
                TextSpan(
                  text: '${widget.kickCount} movement${widget.kickCount == 1 ? '' : 's'}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' in\n'),
                TextSpan(
                  text: _formatDuration(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.gapXL),
        
        // Warning for sessions with < 10 kicks
        if (widget.kickCount < 10) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingMD),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppEffects.radiusMD),
              border: Border.all(
                color: AppColors.warning,
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
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.gapSM),
                    Expanded(
                      child: Text(
                        'This session has fewer than 10 movements and won\'t be included in your pattern analysis.',
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
                  'If you\'re worried about reduced movements, contact your midwife or maternity unit right away.',
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
                        builder: (context) => const KickCounterInfoScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Learn more about baby movements',
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
            hintText: 'Add a note...',
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLG,
              vertical: AppSpacing.paddingLG, // Increased from paddingMD
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
                vertical: AppSpacing.paddingMD, // Reduced from paddingLG
              ),
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Save to Diary'),
          ),
        ),
        const SizedBox(height: AppSpacing.gapMD),
        
        // Discard button (uses theme TextButtonTheme)
        TextButton(
          onPressed: () {
            // Save the current note in the result so it can be restored if user cancels
            final currentNote = _noteController.text.trim();
            Navigator.of(context).pop(SessionCompleteResult(
              note: currentNote.isEmpty ? null : currentNote,
              shouldSave: false,
            ));
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Discard'),
        ),
      ],
    );
  }
}

