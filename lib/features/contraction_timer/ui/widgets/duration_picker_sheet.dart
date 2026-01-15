import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';

/// Bottom sheet for picking a duration (contraction duration)
/// Uses iOS-style scrollable picker from 1s to 75s
class DurationPickerSheet extends StatefulWidget {
  final Duration initialDuration;
  
  const DurationPickerSheet({
    super.key,
    required this.initialDuration,
  });
  
  /// Show the duration picker sheet
  static Future<Duration?> show({
    required BuildContext context,
    required Duration initialDuration,
  }) async {
    return await AppBottomSheet.show<Duration>(
      context: context,
      child: _DurationPickerContent(
        initialDuration: initialDuration,
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
  
  @override
  State<DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<DurationPickerSheet> {
  @override
  Widget build(BuildContext context) {
    return _DurationPickerContent(
      initialDuration: widget.initialDuration,
    );
  }
}

/// Internal content widget for the duration picker sheet
class _DurationPickerContent extends StatefulWidget {
  final Duration initialDuration;
  
  const _DurationPickerContent({
    required this.initialDuration,
  });
  
  @override
  State<_DurationPickerContent> createState() => _DurationPickerContentState();
}

class _DurationPickerContentState extends State<_DurationPickerContent> {
  late FixedExtentScrollController _controller;
  late int _selectedSeconds;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with the initial duration (clamp between 1 and 90)
    _selectedSeconds = widget.initialDuration.inSeconds.clamp(1, 90);
    
    // Controller starts at index (seconds - 1) because list is 1-indexed
    _controller = FixedExtentScrollController(initialItem: _selectedSeconds - 1);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleOk() {
    Navigator.of(context).pop(Duration(seconds: _selectedSeconds));
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
                'Duration',
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
        
        // Duration picker
        SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Seconds picker
              Expanded(
                flex: 2,
                child: CupertinoPicker(
                  scrollController: _controller,
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedSeconds = index + 1; // Add 1 because list is 1-indexed
                    });
                  },
                  children: List.generate(90, (index) {
                    final seconds = index + 1;
                    return Center(
                      child: Text(
                        seconds.toString(),
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              // "sec" label
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.paddingSM),
                    child: Text(
                      'sec',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
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

