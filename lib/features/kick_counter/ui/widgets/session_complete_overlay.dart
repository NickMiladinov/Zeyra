import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';

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
    final minutes = widget.duration.inMinutes;
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

