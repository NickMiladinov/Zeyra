import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

import '../../../app/theme/app_colors.dart';

/// A customizable Cupertino-style date picker with dynamic date constraints.
///
/// Features:
/// - Configurable height
/// - Min/max date constraints
/// - Default date that auto-adjusts to constraints
/// - Dynamic updates when constraints change
class CustomDatePicker extends StatefulWidget {
  /// Creates a custom date picker.
  const CustomDatePicker({
    required this.onDateChanged,
    required this.minDate,
    required this.maxDate,
    this.defaultDate,
    this.height = 220,
    super.key,
  });

  /// Callback when the selected date changes.
  final ValueChanged<DateTime> onDateChanged;

  /// Minimum selectable date.
  final DateTime minDate;

  /// Maximum selectable date.
  final DateTime maxDate;

  /// Default date to show initially.
  /// If null or out of bounds, will use a date within min/max range.
  final DateTime? defaultDate;

  /// Height of the date picker widget.
  final double height;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = _getValidDate(widget.defaultDate);
    // Note: We do NOT call onDateChanged here.
    // The parent already knows the default date since it passed it.
    // Callback only fires when USER changes the date or when auto-adjusted.
  }

  @override
  void didUpdateWidget(CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only adjust the date if the current selection is now out of bounds.
    // We do NOT reset based on defaultDate changes since DateTime.now()
    // creates new objects on every rebuild.
    final isOutOfBounds = _currentDate.isBefore(widget.minDate) ||
        _currentDate.isAfter(widget.maxDate);

    if (isOutOfBounds) {
      final validDate = _getValidDate(widget.defaultDate);
      _currentDate = validDate;

      // Defer the parent callback to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onDateChanged(_currentDate);
        }
      });
    }
  }

  /// Returns a valid date within the min/max constraints.
  DateTime _getValidDate(DateTime? date) {
    // If no date provided, use the default date
    final targetDate = date ?? widget.defaultDate ?? widget.minDate;

    // Clamp to min/max bounds
    if (targetDate.isBefore(widget.minDate)) {
      return widget.minDate;
    } else if (targetDate.isAfter(widget.maxDate)) {
      return widget.maxDate;
    }
    return targetDate;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _currentDate,
        minimumDate: widget.minDate,
        maximumDate: widget.maxDate,
        onDateTimeChanged: (DateTime newDate) {
          setState(() {
            _currentDate = newDate;
          });
          widget.onDateChanged(newDate);
        },
        dateOrder: DatePickerDateOrder.dmy,
        backgroundColor: AppColors.white,
      ),
    );
  }
}
