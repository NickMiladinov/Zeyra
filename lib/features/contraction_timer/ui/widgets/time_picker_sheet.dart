import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';

/// Bottom sheet for picking a time (start time of contraction)
/// Uses iOS-style scrollable picker constrained by session start and current time
class TimePickerSheet extends StatefulWidget {
  final DateTime initialTime;
  final DateTime sessionStartTime;
  final DateTime maxTime; // Usually DateTime.now()
  
  const TimePickerSheet({
    super.key,
    required this.initialTime,
    required this.sessionStartTime,
    required this.maxTime,
  });
  
  /// Show the time picker sheet
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialTime,
    required DateTime sessionStartTime,
    DateTime? maxTime,
  }) async {
    return await AppBottomSheet.show<DateTime>(
      context: context,
      child: _TimePickerContent(
        initialTime: initialTime,
        sessionStartTime: sessionStartTime,
        maxTime: maxTime ?? DateTime.now(),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
  
  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  @override
  Widget build(BuildContext context) {
    return _TimePickerContent(
      initialTime: widget.initialTime,
      sessionStartTime: widget.sessionStartTime,
      maxTime: widget.maxTime,
    );
  }
}

/// Internal content widget for the time picker sheet
class _TimePickerContent extends StatefulWidget {
  final DateTime initialTime;
  final DateTime sessionStartTime;
  final DateTime maxTime;
  
  const _TimePickerContent({
    required this.initialTime,
    required this.sessionStartTime,
    required this.maxTime,
  });
  
  @override
  State<_TimePickerContent> createState() => _TimePickerContentState();
}

class _TimePickerContentState extends State<_TimePickerContent> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  
  late int _selectedHour;
  late int _selectedMinute;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with the initial time (24-hour format)
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
  }
  
  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }
  
  DateTime _getSelectedDateTime() {
    return DateTime(
      widget.initialTime.year,
      widget.initialTime.month,
      widget.initialTime.day,
      _selectedHour,
      _selectedMinute,
    );
  }
  
  void _handleOk() async {
    final selectedTime = _getSelectedDateTime();
    
    // Validate the selected time is within bounds
    if (selectedTime.isAfter(widget.maxTime) || selectedTime.isBefore(widget.sessionStartTime)) {
      // Show error dialog on top of the bottom sheet
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Invalid Time',
            style: AppTypography.headlineSmall,
          ),
          content: Text(
            'Selected time must be within the session time range.',
            style: AppTypography.bodyMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEffects.radiusLG),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }
    
    Navigator.of(context).pop(selectedTime);
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
                'Start Time',
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
        
        const SizedBox(height: AppSpacing.gapXL),
        
        // Time picker (24-hour format)
        SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Hour picker (0-23)
              Expanded(
                flex: 2,
                child: CupertinoPicker(
                  scrollController: _hourController,
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedHour = index;
                    });
                  },
                  children: List.generate(24, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingSM),
                child: Text(
                  ':',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              // Minute picker (0-59)
              Expanded(
                flex: 2,
                child: CupertinoPicker(
                  scrollController: _minuteController,
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedMinute = index;
                    });
                  },
                  children: List.generate(60, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.gapXXL),
        
        // Ok button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleOk,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
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
              'Ok',
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

