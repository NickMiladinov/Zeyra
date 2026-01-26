import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Bottom sheet for entering a UK postcode.
///
/// Used when location permission is denied or user wants to change location.
class PostcodeBottomSheet extends StatefulWidget {
  /// Callback when a valid postcode is submitted.
  final Future<void> Function(String postcode) onPostcodeSubmitted;

  const PostcodeBottomSheet({
    super.key,
    required this.onPostcodeSubmitted,
  });

  @override
  State<PostcodeBottomSheet> createState() => _PostcodeBottomSheetState();
}

class _PostcodeBottomSheetState extends State<PostcodeBottomSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Validate and submit the postcode.
  Future<void> _submit() async {
    final postcode = _controller.text.trim().toUpperCase();
    
    // Basic validation
    if (postcode.isEmpty) {
      setState(() => _error = 'Please enter a postcode');
      return;
    }
    
    // UK postcode format check (basic)
    final postcodeRegex = RegExp(
      r'^[A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{2}$',
      caseSensitive: false,
    );
    
    if (!postcodeRegex.hasMatch(postcode)) {
      setState(() => _error = 'Please enter a valid UK postcode');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.onPostcodeSubmitted(postcode);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Could not find postcode. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.paddingLG,
        right: AppSpacing.paddingLG,
        top: AppSpacing.paddingLG,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.paddingLG,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Title
          Text(
            'Set Your Search Area',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.gapXL),
          
          // Postcode input
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter Your Postcode',
              errorText: _error,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingLG,
                vertical: AppSpacing.paddingMD,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.gapLG),
          
          // Submit button
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColors.backgroundGrey200,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Show Hospitals'),
          ),
          const SizedBox(height: AppSpacing.gapMD),
        ],
      ),
    );
  }
}
