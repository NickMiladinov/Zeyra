import 'dart:io';
import 'dart:typed_data';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';

/// Aspect ratio preset
class AspectRatioPreset {
  final String label;
  final double? ratio; // null = free crop
  final IconData icon;

  const AspectRatioPreset({
    required this.label,
    required this.ratio,
    required this.icon,
  });
}

/// Native-feeling crop screen with manual controls
class PhotoCropScreen extends StatefulWidget {
  final File imageFile;

  const PhotoCropScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<PhotoCropScreen> createState() => _PhotoCropScreenState();
}

class _PhotoCropScreenState extends State<PhotoCropScreen> {
  late CropController _cropController;
  bool _isProcessing = false;
  int _cropKey = 0; // Key to force CropImage rebuild
  AspectRatioPreset _selectedRatio = const AspectRatioPreset(
    label: 'Free',
    ratio: null,
    icon: AppIcons.cropFree,
  );

  static const _presets = [
    AspectRatioPreset(label: 'Free', ratio: null, icon: AppIcons.cropFree),
    AspectRatioPreset(label: '1:1', ratio: 1.0, icon: AppIcons.cropSquare),
    AspectRatioPreset(label: '3:4', ratio: 0.75, icon: AppIcons.cropPortrait),
    AspectRatioPreset(label: '4:3', ratio: 1.333, icon: AppIcons.cropLandscape),
    AspectRatioPreset(label: '9:16', ratio: 0.5625, icon: AppIcons.smartphone),
    AspectRatioPreset(label: '16:9', ratio: 1.778, icon: AppIcons.crop169),
  ];

  @override
  void initState() {
    super.initState();
    _cropController = CropController(
      aspectRatio: _selectedRatio.ratio,
      defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
    );
  }

  void _changeAspectRatio(AspectRatioPreset preset) {
    _cropController.dispose();
    setState(() {
      _selectedRatio = preset;
      _cropKey++; // Increment key to force rebuild
      _cropController = CropController(
        aspectRatio: preset.ratio,
        defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
      );
    });
  }

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  void _showAspectRatioSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppEffects.roundedTopXL,
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingLG),
                child: Row(
                  children: [
                    Text(
                      'Aspect Ratio',
                      style: AppTypography.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(AppIcons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.gapSM),
              Wrap(
                spacing: AppSpacing.gapMD,
                runSpacing: AppSpacing.gapMD,
                children: _presets.map((preset) {
                  final isSelected = preset.label == _selectedRatio.label;
                  return InkWell(
                    onTap: () {
                      _changeAspectRatio(preset);
                      Navigator.pop(context);
                    },
                    borderRadius: AppEffects.roundedLG,
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(AppSpacing.paddingMD),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.background,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: AppEffects.roundedLG,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            preset.icon,
                            color: isSelected ? AppColors.primary : AppColors.iconDefault,
                            size: 32,
                          ),
                          const SizedBox(height: AppSpacing.gapXS),
                          Text(
                            preset.label,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.gapSM),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    setState(() => _isProcessing = true);

    try {
      // Read original image
      final imageBytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Get crop area
      final cropRect = _cropController.crop;
      final imageWidth = originalImage.width;
      final imageHeight = originalImage.height;

      // Calculate pixel coordinates
      final x = (cropRect.left * imageWidth).round();
      final y = (cropRect.top * imageHeight).round();
      final width = (cropRect.width * imageWidth).round();
      final height = (cropRect.height * imageHeight).round();

      // Crop image
      final croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      // Encode as JPEG
      final croppedBytes = Uint8List.fromList(
        img.encodeJpg(croppedImage, quality: 90),
      );

      // Save to temp file
      final tempDir = await Directory.systemTemp.createTemp('bump_photo_');
      final tempFile = File(
        '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(croppedBytes);

      if (mounted) {
        Navigator.of(context).pop(tempFile);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to crop image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.close, color: AppColors.white),
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Crop Photo',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.white),
        ),
        actions: [
          if (_isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _cropImage,
              child: Text(
                'Done',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CropImage(
              key: ValueKey(_cropKey), // Force rebuild when aspect ratio changes
              controller: _cropController,
              image: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
              ),
              gridColor: AppColors.white.withValues(alpha: 0.3),
              gridCornerSize: 30,
              gridThinWidth: 1,
              gridThickWidth: 2,
              scrimColor: AppColors.black.withValues(alpha: 0.7),
              alwaysShowThirdLines: true,
            ),
          ),
          Container(
            color: AppColors.black,
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Text(
                    'Pinch to zoom • Drag to reposition',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.gapLG),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: AppIcons.rotateLeft,
                        label: 'Rotate',
                        onPressed: _isProcessing
                            ? null
                            : () {
                                _cropController.rotateLeft();
                              },
                      ),
                      _buildActionButton(
                        icon: _selectedRatio.icon,
                        label: _selectedRatio.label,
                        onPressed: _isProcessing ? null : _showAspectRatioSheet,
                      ),
                      _buildActionButton(
                        icon: AppIcons.rotateRight,
                        label: 'Rotate',
                        onPressed: _isProcessing
                            ? null
                            : () {
                                _cropController.rotateRight();
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    return InkWell(
      onTap: onPressed,
      borderRadius: AppEffects.roundedLG,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingSM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDisabled
                  ? AppColors.white.withValues(alpha: 0.3)
                  : AppColors.white,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.gapXS),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDisabled
                    ? AppColors.white.withValues(alpha: 0.3)
                    : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
