import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../domain/entities/contraction_timer/contraction_session.dart';
import '../../../../domain/entities/contraction_timer/contraction.dart';
import '../../../../domain/entities/contraction_timer/contraction_intensity.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../widgets/session_511_status_card.dart';
import '../../logic/contraction_history_provider.dart';

/// Actions that can be performed on a session
enum SessionAction {
  editNote,
  delete,
}

/// Detail screen showing comprehensive information about a contraction session
class ContractionSessionDetailScreen extends ConsumerStatefulWidget {
  final ContractionSession session;
  
  const ContractionSessionDetailScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<ContractionSessionDetailScreen> createState() => _ContractionSessionDetailScreenState();
}

class _ContractionSessionDetailScreenState extends ConsumerState<ContractionSessionDetailScreen> {
  late String? _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.session.note;
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
  
  String _formatContractionDuration(Duration? duration) {
    if (duration == null) return '—';
    return '${duration.inSeconds}s';
  }
  
  String _formatFrequency(Duration? frequency) {
    if (frequency == null) return '—';

    final totalSeconds = frequency.inSeconds;
    final minutes = frequency.inMinutes;

    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    } else if (minutes < 60) {
      final secs = totalSeconds % 60;
      if (secs > 0) {
        return '${minutes}m ${secs}s';
      }
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
  }
  
  /// Handle session actions (edit note, delete)
  Future<void> _handleSessionAction(
    BuildContext context,
    SessionAction action,
  ) async {
    switch (action) {
      case SessionAction.editNote:
        final note = await _showEditNoteDialog(context);
        if (note != null && mounted) {
          // Update the note
          await ref.read(contractionHistoryProvider.notifier).updateSessionNote(widget.session.id, note.isEmpty ? null : note);
          // Update local state to reflect the change
          setState(() {
            _currentNote = note.isEmpty ? null : note;
          });
        }
        break;
        
      case SessionAction.delete:
        final confirmed = await AppDialog.show(
          context: context,
          title: 'Delete Session?',
          message: 'This will permanently delete this session and all its contractions. Are you sure?',
          primaryActionLabel: 'Delete',
          secondaryActionLabel: 'Cancel',
          isPrimaryDestructive: true,
        );
        
        if (confirmed == true && mounted) {
          // Delete the session
          await ref.read(contractionHistoryProvider.notifier).deleteSession(widget.session.id);
          
          // Navigate back to history screen
          if (mounted) {
            context.pop();
          }
        }
        break;
    }
  }
  
  /// Show dialog to edit session note
  Future<String?> _showEditNoteDialog(BuildContext context) {
    final controller = TextEditingController(text: _currentNote ?? '');
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
  @override
  Widget build(BuildContext context) {
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
          PopupMenuButton<SessionAction>(
            icon: Icon(
              AppIcons.moreVertical,
              size: AppSpacing.iconMD,
              color: AppColors.iconDefault,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEffects.radiusMD),
              side: const BorderSide(
                color: AppColors.border,
                width: AppSpacing.borderWidthThin,
              ),
            ),
            padding: EdgeInsets.zero,
            menuPadding: EdgeInsets.zero,
            onSelected: (action) => _handleSessionAction(context, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SessionAction.editNote,
                child: Row(
                  children: [
                    Icon(
                      AppIcons.edit,
                      size: AppSpacing.iconSM,
                      color: AppColors.iconDefault,
                    ),
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
                    Icon(
                      AppIcons.delete,
                      size: AppSpacing.iconSM,
                      color: AppColors.iconError,
                    ),
                    const SizedBox(width: AppSpacing.gapSM),
                    Text('Delete Session', style: AppTypography.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        children: [
          // Session Summary Card
          _buildSessionSummaryCard(),
          const SizedBox(height: AppSpacing.gapLG),
          
          // 5-1-1 Rule Status Card
          Session511StatusCard(session: widget.session),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Note Card
          _buildNoteCard(),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Complete Log Card
          _buildCompleteLogCard(),
        ],
      ),
      // Bottom nav bar is provided by MainShell
    );
  }
  
  Widget _buildSessionSummaryCard() {
    return Container(
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
          Text(
            'Session Summary',
            style: AppTypography.headlineExtraSmall,
          ),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Stats rows
          _StatRow(
            label: 'Total Time in Labour',
            value: _formatDuration(widget.session.totalDuration),
          ),
          const SizedBox(height: AppSpacing.gapSM),
          _StatRow(
            label: 'Average Contractions (Last Hour)',
            value: _formatContractionDuration(widget.session.averageDurationLastHour),
          ),
          const SizedBox(height: AppSpacing.gapSM),
          _StatRow(
            label: 'Average Frequency (Last Hour)',
            value: _formatFrequency(widget.session.averageFrequencyLastHour),
          ),
          const SizedBox(height: AppSpacing.gapSM),
          _StatRow(
            label: 'Closest Frequency',
            value: _formatFrequency(widget.session.closestFrequency),
          ),
          const SizedBox(height: AppSpacing.gapSM),
          _StatRow(
            label: 'Longest Contraction',
            value: _formatContractionDuration(widget.session.longestContraction),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoteCard() {
    return Container(
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
          Text(
            'Your Note',
            style: AppTypography.headlineExtraSmall,
          ),
          const SizedBox(height: AppSpacing.gapMD),
          
          // Note content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppEffects.radiusMD),
            ),
            child: Text(
              _currentNote ?? 'No note saved for this session',
              style: AppTypography.bodyLarge.copyWith(
                color: _currentNote != null ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCompleteLogCard() {
    // Sort contractions in descending order (most recent first)
    final sortedContractions = List<Contraction>.from(widget.session.contractions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    return Container(
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
          Text(
            'Complete Log',
            style: AppTypography.headlineExtraSmall,
          ),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Table
          if (sortedContractions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.paddingXL),
                child: Text(
                  'No contractions recorded',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            _buildContractionTable(sortedContractions),
        ],
      ),
    );
  }
  
  Widget _buildContractionTable(List<Contraction> sortedContractions) {
    return Column(
      children: [
        // Table header
        _buildTableHeader(),
        const SizedBox(height: AppSpacing.gapLG),
        
        // Table rows with dividers between them
        ...sortedContractions.asMap().entries.expand((entry) {
          final index = entry.key;
          final contraction = entry.value;
          
          // Calculate frequency (time since previous contraction)
          // In descending order, "previous" is the next item in the list
          Duration? frequency;
          if (index < sortedContractions.length - 1) {
            final previousContraction = sortedContractions[index + 1];
            frequency = contraction.startTime.difference(previousContraction.startTime);
          }
          
          final row = _buildTableRow(
            startTime: _formatTime(contraction.startTime),
            duration: _formatContractionDuration(contraction.duration),
            frequency: _formatFrequency(frequency),
            intensity: contraction.intensity,
          );
          
          // Add divider after each row except the last one
          if (index < sortedContractions.length - 1) {
            return [
              row,
              const SizedBox(height: AppSpacing.gapMD),
              Container(
                height: AppSpacing.borderWidthThin,
                color: AppColors.border,
              ),
              const SizedBox(height: AppSpacing.gapMD),
            ];
          } else {
            return [row];
          }
        }),
      ],
    );
  }
  
  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Start Time',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Duration',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Frequency',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Intensity',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTableRow({
    required String startTime,
    required String duration,
    required String frequency,
    required ContractionIntensity intensity,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            startTime,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            duration,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            frequency,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: _IntensityBadge(intensity: intensity),
          ),
        ),
      ],
    );
  }
}

/// Stat row widget showing label and value
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

/// Intensity badge with color coding
class _IntensityBadge extends StatelessWidget {
  final ContractionIntensity intensity;
  
  const _IntensityBadge({
    required this.intensity,
  });
  
  Color get _backgroundColor {
    switch (intensity) {
      case ContractionIntensity.strong:
        return AppColors.error;
      case ContractionIntensity.moderate:
        return AppColors.secondary;
      case ContractionIntensity.mild:
        return AppColors.primary;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingSM,
        vertical: AppSpacing.paddingXS,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
      ),
      child: Text(
        intensity.displayName,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

