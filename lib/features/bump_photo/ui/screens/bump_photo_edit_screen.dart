import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../logic/bump_photo_provider.dart';
import 'photo_crop_screen.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/widgets/app_dialog.dart';

/// Screen for adding or editing a bump photo for a specific week.
class BumpPhotoEditScreen extends ConsumerStatefulWidget {
  final int weekNumber;

  const BumpPhotoEditScreen({
    super.key,
    required this.weekNumber,
  });

  @override
  ConsumerState<BumpPhotoEditScreen> createState() => _BumpPhotoEditScreenState();
}

class _BumpPhotoEditScreenState extends ConsumerState<BumpPhotoEditScreen> {
  final _noteController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  File? _croppedImage;
  bool _isSaving = false;
  Timer? _debounceTimer;
  String? _currentPhotoId;
  String? _originalPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadExistingPhoto();
    _noteController.addListener(_onNoteChanged);
  }

  @override
  void deactivate() {
    // Save note when leaving screen if there's no photo but user has typed a note
    // deactivate() is called before dispose() and ref is still valid here
    _saveNoteBeforeDispose();
    super.deactivate();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    super.dispose();
  }

  /// Save note when leaving screen if there's no photo but user has typed a note
  void _saveNoteBeforeDispose() {
    final note = _noteController.text.trim();
    // Only save if: no photo exists AND note is not empty
    if (_croppedImage == null && note.isNotEmpty) {
      // Capture the notifier reference before the widget is disposed
      final notifier = ref.read(bumpPhotoProvider.notifier);
      final weekNum = widget.weekNumber;
      
      // Delay the modification to avoid modifying provider during widget lifecycle
      // This ensures the update happens after the widget tree is done building
      Future.microtask(() {
        notifier.saveNoteOnly(
          weekNumber: weekNum,
          note: note,
        ).catchError((e) {
          debugPrint('Failed to save note on screen exit: $e');
        });
      });
    }
  }

  void _loadExistingPhoto() {
    final stateAsync = ref.read(bumpPhotoProvider);
    stateAsync.whenData((state) {
      final photo = state.photos.where((p) => p.weekNumber == widget.weekNumber).firstOrNull;

      if (photo != null && mounted) {
        setState(() {
          _currentPhotoId = photo.id;
          _originalPhotoPath = photo.filePath;
          _noteController.text = photo.note ?? '';
          if (photo.filePath != null) {
            _selectedImage = File(photo.filePath!);
            _croppedImage = _selectedImage;
          }
        });
      }
    });
  }

  /// Debounced auto-save for note changes
  void _onNoteChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _autoSaveNote();
    });
  }

  /// Auto-save note (creates new record if needed, updates if exists)
  Future<void> _autoSaveNote() async {
    final note = _noteController.text.trim();

    // Don't save if note is empty
    if (note.isEmpty) return;

    try {
      if (_currentPhotoId != null) {
        // Update existing record
        await ref.read(bumpPhotoProvider.notifier).updatePhotoNote(
          _currentPhotoId!,
          note,
        );
      } else {
        // Create new note-only record
        await ref.read(bumpPhotoProvider.notifier).saveNoteOnly(
          weekNumber: widget.weekNumber,
          note: note,
        );

        // Update _currentPhotoId after creating the record
        final stateAsync = ref.read(bumpPhotoProvider);
        stateAsync.whenData((state) {
          final photo = state.photos
              .where((p) => p.weekNumber == widget.weekNumber)
              .firstOrNull;
          if (photo != null && mounted) {
            setState(() {
              _currentPhotoId = photo.id;
            });
          }
        });
      }
    } catch (e) {
      // Silent fail for auto-save
      debugPrint('Auto-save note failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationNone,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: AppColors.iconDefault),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Week ${widget.weekNumber}',
          style: AppTypography.headlineSmall,
        ),
        actions: [
          // More menu (only shown when photo exists)
          if (_currentPhotoId != null && !_isSaving)
            PopupMenuButton<String>(
              icon: Icon(
                AppIcons.moreVertical,
                size: AppSpacing.iconLG,
                color: AppColors.iconDefault,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppEffects.roundedMD,
                side: const BorderSide(
                  color: AppColors.border,
                  width: AppSpacing.borderWidthThin,
                ),
              ),
              onSelected: (value) async {
                if (value == 'change') {
                  await _changePhoto();
                } else if (value == 'delete') {
                  await _confirmAndDeletePhoto();
                } else if (value == 'delete_all') {
                  await _confirmAndDeleteAll();
                }
              },
              itemBuilder: (context) => [
                // Only show "Change Photo" if a photo exists
                if (_croppedImage != null) ...[
                  PopupMenuItem(
                    value: 'change',
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.edit,
                          size: AppSpacing.iconSM,
                          color: AppColors.iconDefault,
                        ),
                        const SizedBox(width: AppSpacing.gapSM),
                        Text('Change Photo', style: AppTypography.bodyLarge),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: AppSpacing.borderWidthThin),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.delete,
                          size: AppSpacing.iconSM,
                          color: AppColors.iconError,
                        ),
                        const SizedBox(width: AppSpacing.gapSM),
                        Text('Delete Photo', style: AppTypography.bodyLarge),
                      ],
                    ),
                  ),
                ] else ...[
                  // If only note exists, show option to delete everything
                  PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.delete,
                          size: AppSpacing.iconSM,
                          color: AppColors.iconError,
                        ),
                        const SizedBox(width: AppSpacing.gapSM),
                        Text('Delete Note', style: AppTypography.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.paddingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoSection(),
            const SizedBox(height: AppSpacing.gapXL),
            _buildNoteSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _isSaving
          ? null
          : _croppedImage != null
              ? _showFullScreenPhoto
              : _showImageSourceDialog,
      child: Container(
        height: 400.0, // Fixed height for photo section
        decoration: BoxDecoration(
          color: _croppedImage != null ? AppColors.black : AppColors.surface,
          borderRadius: AppEffects.roundedXL,
          border: _croppedImage == null
              ? Border.all(
                  color: AppColors.border,
                  width: AppSpacing.borderWidthThin,
                )
              : null,
        ),
        child: _croppedImage != null
            ? ClipRRect(
                borderRadius: AppEffects.roundedXL,
                child: Image.file(
                  _croppedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0x0D4DB6AC), // rgba(77, 182, 172, 0.05)
                      Color(0x1A4DB6AC), // rgba(77, 182, 172, 0.1)
                    ],
                  ),
                  borderRadius: AppEffects.roundedXL,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Layered circles with camera icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppEffects.roundedCircle,
                        ),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: AppEffects.roundedCircle,
                            ),
                            child: Icon(
                              AppIcons.camera,
                              size: AppSpacing.iconSM,
                              color: AppColors.primary,
                              fill: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.gapLG),
                      Text(
                        'Add This Week\'s Photo',
                        style: AppTypography.headlineExtraSmall,
                      ),
                      const SizedBox(height: AppSpacing.gapXS),
                      Text(
                        'Capture this moment in your journey',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s on your mind this week?',
          style: AppTypography.headlineExtraSmall,
        ),
        const SizedBox(height: AppSpacing.gapSM),
        TextField(
          controller: _noteController,
          maxLines: 10,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Any new cravings or feelings to remember?',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: AppEffects.roundedXL,
              borderSide: const BorderSide(
                color: AppColors.border,
                width: AppSpacing.borderWidthThin,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppEffects.roundedXL,
              borderSide: const BorderSide(
                color: AppColors.border,
                width: AppSpacing.borderWidthThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppEffects.roundedXL,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: AppSpacing.borderWidthMedium,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.paddingLG),
          ),
        ),
      ],
    );
  }

  /// Show full-screen photo viewer
  Future<void> _showFullScreenPhoto() async {
    if (_croppedImage == null) return;

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenPhotoViewer(imageFile: _croppedImage!);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// Show dialog to choose image source
  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Photo',
          style: AppTypography.headlineMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(AppIcons.camera, color: AppColors.primary),
              title: Text('Camera', style: AppTypography.bodyLarge),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(AppIcons.image, color: AppColors.primary),
              title: Text('Gallery', style: AppTypography.bodyLarge),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.labelLarge),
          ),
        ],
      ),
    );

    if (source != null && mounted) {
      await _pickAndCropImage(source);
    }
  }

  /// Pick image from source and show crop screen
  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        // User cancelled image picker
        return;
      }

      if (!mounted) return;

      // Navigate to crop screen
      final File? croppedFile = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => PhotoCropScreen(
            imageFile: File(pickedFile.path),
          ),
        ),
      );

      // Clean up original picked file
      try {
        await File(pickedFile.path).delete();
      } catch (e) {
        debugPrint('Failed to delete original image: $e');
      }

      if (croppedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _croppedImage = croppedFile;
        });

        // Automatically save the photo
        await _savePhoto();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Save the photo
  Future<void> _savePhoto() async {
    if (_croppedImage == null) return;

    setState(() => _isSaving = true);

    try {
      // Delete old photo file if changing photo
      if (_originalPhotoPath != null && _originalPhotoPath != _croppedImage!.path) {
        try {
          final oldFile = File(_originalPhotoPath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          debugPrint('Failed to delete old photo: $e');
        }
      }

      final imageBytes = await _croppedImage!.readAsBytes();

      await ref.read(bumpPhotoProvider.notifier).savePhoto(
            weekNumber: widget.weekNumber,
            imageBytes: imageBytes,
            note: _noteController.text.trim().isEmpty 
                ? null 
                : _noteController.text.trim(),
          );

      // Update current photo ID and path after save
      final stateAsync = ref.read(bumpPhotoProvider);
      stateAsync.whenData((state) {
        final photo = state.photos
            .where((p) => p.weekNumber == widget.weekNumber)
            .firstOrNull;
        if (photo != null && mounted) {
          setState(() {
            _currentPhotoId = photo.id;
            _originalPhotoPath = photo.filePath;
          });
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo saved!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Change photo - shows image picker and cropper
  Future<void> _changePhoto() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Photo',
          style: AppTypography.headlineMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(AppIcons.camera, color: AppColors.primary),
              title: Text('Camera', style: AppTypography.bodyLarge),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(AppIcons.image, color: AppColors.primary),
              title: Text('Gallery', style: AppTypography.bodyLarge),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.labelLarge),
          ),
        ],
      ),
    );

    if (source != null && mounted) {
      await _pickAndCropImage(source);
    }
  }

  /// Confirm and delete photo
  Future<void> _confirmAndDeletePhoto() async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Delete Photo?',
      message: 'This will permanently delete this photo. Are you sure?',
      primaryActionLabel: 'Delete',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );

    if (confirmed == true && _currentPhotoId != null) {
      // Show loading
      setState(() => _isSaving = true);

      try {
        // Delete the photo file
        if (_originalPhotoPath != null) {
          try {
            final file = File(_originalPhotoPath!);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            debugPrint('Failed to delete photo file: $e');
          }
        }

        await ref.read(bumpPhotoProvider.notifier).deletePhoto(_currentPhotoId!);

        if (mounted) {
          // Reload the photo to get updated state from repository
          final stateAsync = ref.read(bumpPhotoProvider);
          stateAsync.whenData((updatedState) {
            final updatedPhoto = updatedState.photos
                .where((p) => p.weekNumber == widget.weekNumber)
                .firstOrNull;

            if (mounted) {
              setState(() {
                _croppedImage = null;
                _selectedImage = null;
                _originalPhotoPath = null;
                // Update _currentPhotoId based on whether note was preserved
                _currentPhotoId = updatedPhoto?.id;
              });
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete photo: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  /// Confirm and delete everything (note and photo record)
  Future<void> _confirmAndDeleteAll() async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'Delete Note?',
      message: 'This will permanently delete your note. Are you sure?',
      primaryActionLabel: 'Delete',
      secondaryActionLabel: 'Cancel',
      isPrimaryDestructive: true,
    );

    if (confirmed == true && _currentPhotoId != null) {
      setState(() => _isSaving = true);

      try {
        await ref.read(bumpPhotoProvider.notifier).deletePhoto(_currentPhotoId!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note deleted'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete note: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }
}

/// Full-screen photo viewer with swipe-to-dismiss functionality
class _FullScreenPhotoViewer extends StatefulWidget {
  final File imageFile;

  const _FullScreenPhotoViewer({required this.imageFile});

  @override
  State<_FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<_FullScreenPhotoViewer> {
  double _dragDistance = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (_dragDistance.abs() / 300)).clamp(0.0, 1.0);

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _isDragging = true;
          _dragDistance += details.delta.dy;
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragDistance.abs() > 100) {
          // Dismiss if dragged more than 100 pixels
          Navigator.of(context).pop();
        } else {
          // Reset position if not dragged enough
          setState(() {
            _dragDistance = 0.0;
            _isDragging = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black.withValues(alpha: opacity),
        body: Stack(
          children: [
            // Photo in the center
            Center(
              child: Transform.translate(
                offset: Offset(0, _dragDistance),
                child: Opacity(
                  opacity: opacity,
                  child: InteractiveViewer(
                    panEnabled: !_isDragging,
                    scaleEnabled: !_isDragging,
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Close button at top-left
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.paddingLG),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(AppSpacing.paddingSM),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.5),
                        borderRadius: AppEffects.roundedCircle,
                      ),
                      child: Icon(
                        AppIcons.close,
                        color: AppColors.white,
                        size: AppSpacing.iconMD,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
