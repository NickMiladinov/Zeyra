import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';
import 'package:zeyra/features/contraction_timer/ui/widgets/time_picker_sheet.dart';
import 'package:zeyra/features/contraction_timer/ui/widgets/duration_picker_sheet.dart';

/// Bottom sheet for editing a contraction's details
/// Allows user to adjust start time, duration, and intensity
class EditContractionSheet extends StatefulWidget {
  final Contraction contraction;
  final Function(DateTime startTime, Duration duration, ContractionIntensity intensity) onSave;
  
  const EditContractionSheet({
    super.key,
    required this.contraction,
    required this.onSave,
  });
  
  /// Show the edit contraction sheet
  static Future<void> show({
    required BuildContext context,
    required Contraction contraction,
    required Function(DateTime startTime, Duration duration, ContractionIntensity intensity) onSave,
  }) async {
    await AppBottomSheet.show(
      context: context,
      child: _EditContractionContent(
        contraction: contraction,
        onSave: onSave,
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
  
  @override
  State<EditContractionSheet> createState() => _EditContractionSheetState();
}

class _EditContractionSheetState extends State<EditContractionSheet> {
  @override
  Widget build(BuildContext context) {
    return _EditContractionContent(
      contraction: widget.contraction,
      onSave: widget.onSave,
    );
  }
}

/// Internal content widget for the edit contraction sheet
class _EditContractionContent extends StatefulWidget {
  final Contraction contraction;
  final Function(DateTime startTime, Duration duration, ContractionIntensity intensity) onSave;
  
  const _EditContractionContent({
    required this.contraction,
    required this.onSave,
  });
  
  @override
  State<_EditContractionContent> createState() => _EditContractionContentState();
}

class _EditContractionContentState extends State<_EditContractionContent> {
  late DateTime _startTime;
  late Duration _duration;
  late ContractionIntensity _intensity;
  late DateTime _sessionStartTime;
  
  @override
  void initState() {
    super.initState();
    _startTime = widget.contraction.startTime;
    _duration = widget.contraction.duration ?? Duration.zero;
    _intensity = widget.contraction.intensity;
    // Session start time would ideally come from the session, for now use contraction start
    _sessionStartTime = widget.contraction.startTime.subtract(const Duration(hours: 2));
  }
  
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  String _formatDuration(Duration duration) {
    return '${duration.inSeconds}sec';
  }
  
  Future<void> _handleStartTimeTap() async {
    final selectedTime = await TimePickerSheet.show(
      context: context,
      initialTime: _startTime,
      sessionStartTime: _sessionStartTime,
      maxTime: DateTime.now(),
    );
    
    if (selectedTime != null && mounted) {
      setState(() {
        _startTime = selectedTime;
      });
    }
  }
  
  Future<void> _handleDurationTap() async {
    final selectedDuration = await DurationPickerSheet.show(
      context: context,
      initialDuration: _duration,
    );
    
    if (selectedDuration != null && mounted) {
      setState(() {
        _duration = selectedDuration;
      });
    }
  }
  
  void _handleSave() {
    widget.onSave(_startTime, _duration, _intensity);
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and close button
        Row(
          children: [
            Expanded(
              child: Text(
                'Edit Contraction at ${_formatTime(_startTime)}',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                AppIcons.close,
                size: AppSpacing.iconSM,
                color: AppColors.iconDefault,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.gapLG),
            
        // Start Time selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start Time',
              style: AppTypography.bodyLarge,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _handleStartTimeTap,
                  child: Text(
                    _formatTime(_startTime),
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.gapSM),
                GestureDetector(
                  onTap: _handleStartTimeTap,
                  child: Column(
                    children: [
                      Icon(
                        AppIcons.arrowUp,
                        size: AppSpacing.iconMD,
                        color: AppColors.iconDefault,
                      ),
                      Icon(
                        AppIcons.arrowDown,
                        size: AppSpacing.iconMD,
                        color: AppColors.iconDefault,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Divider - positioned on the right, 1/3 width
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingSM),
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.33,
              child: Container(
                height: 1,
                color: AppColors.divider,
              ),
            ),
          ),
        ),
        
        // Duration selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Duration',
              style: AppTypography.bodyLarge,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _handleDurationTap,
                  child: Text(
                    _formatDuration(_duration),
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.gapSM),
                GestureDetector(
                  onTap: _handleDurationTap,
                  child: Column(
                    children: [
                      Icon(
                        AppIcons.arrowUp,
                        size: AppSpacing.iconMD,
                        color: AppColors.iconDefault,
                      ),
                      Icon(
                        AppIcons.arrowDown,
                        size: AppSpacing.iconMD,
                        color: AppColors.iconDefault,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.gapXL),
        
        // Intensity selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intensity',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.gapMD),
            _AnimatedIntensitySelector(
              selectedIntensity: _intensity,
              onIntensityChanged: (intensity) {
                setState(() {
                  _intensity = intensity;
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.gapXXL),
        
        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.paddingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
              ),
            ),
            child: Text(
              'Save Changes',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.gapLG),
      ],
    );
  }
}

/// Animated intensity selector with sliding colored background
class _AnimatedIntensitySelector extends StatelessWidget {
  final ContractionIntensity selectedIntensity;
  final Function(ContractionIntensity) onIntensityChanged;
  
  const _AnimatedIntensitySelector({
    required this.selectedIntensity,
    required this.onIntensityChanged,
  });
  
  Color _getBackgroundColor(ContractionIntensity intensity) {
    switch (intensity) {
      case ContractionIntensity.mild:
        return AppColors.primary;
      case ContractionIntensity.moderate:
        return AppColors.secondary;
      case ContractionIntensity.strong:
        return AppColors.error;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final intensities = ContractionIntensity.values;
    final selectedIndex = intensities.indexOf(selectedIntensity);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (AppSpacing.gapMD * 2)) / 3;
        
        return Container(
          height: AppSpacing.buttonHeightSM,
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey100,
            borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
          ),
          child: Stack(
            clipBehavior: Clip.none, // Allow selected pill to overflow
            children: [
              // Animated sliding background
              AnimatedPositioned(
                duration: AppEffects.durationNormal,
                curve: Curves.easeInOut,
                left: selectedIndex * (itemWidth + AppSpacing.gapMD),
                top: (AppSpacing.buttonHeightSM - AppSpacing.buttonHeightMD) / 2,
                width: itemWidth,
                height: AppSpacing.buttonHeightMD,
                child: AnimatedContainer(
                  duration: AppEffects.durationNormal,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(selectedIntensity),
                    borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
                  ),
                ),
              ),
              
              // Intensity buttons
              Row(
                children: [
                  _buildIntensityButton(
                    label: 'Mild',
                    intensity: ContractionIntensity.mild,
                    width: itemWidth,
                  ),
                  const SizedBox(width: AppSpacing.gapMD),
                  _buildIntensityButton(
                    label: 'Moderate',
                    intensity: ContractionIntensity.moderate,
                    width: itemWidth,
                  ),
                  const SizedBox(width: AppSpacing.gapMD),
                  _buildIntensityButton(
                    label: 'Strong',
                    intensity: ContractionIntensity.strong,
                    width: itemWidth,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildIntensityButton({
    required String label,
    required ContractionIntensity intensity,
    required double width,
  }) {
    final isSelected = selectedIntensity == intensity;
    final foregroundColor = isSelected ? AppColors.white : AppColors.textSecondary;
    
    return GestureDetector(
      onTap: () => onIntensityChanged(intensity),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: AppSpacing.buttonHeightSM,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppEffects.durationNormal,
            curve: Curves.easeInOut,
            style: AppTypography.labelMedium.copyWith(
              color: foregroundColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

