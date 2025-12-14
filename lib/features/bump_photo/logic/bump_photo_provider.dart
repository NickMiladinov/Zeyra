import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/main_providers.dart';
import '../../../domain/entities/bump_photo/bump_photo.dart';
import '../../../domain/entities/pregnancy/pregnancy.dart';
import '../../../domain/exceptions/bump_photo_exception.dart';
import '../../../domain/usecases/bump_photo/delete_bump_photo.dart';
import '../../../domain/usecases/bump_photo/get_bump_photos.dart';
import '../../../domain/usecases/bump_photo/save_bump_photo.dart';
import '../../../domain/usecases/bump_photo/save_bump_photo_note.dart';
import '../../../domain/usecases/bump_photo/update_bump_photo_note.dart';
import '../../baby/logic/pregnancy_data_provider.dart' as baby;
import 'bump_photo_state.dart';

/// Notifier for managing bump photo state.
///
/// Handles loading photos, saving/updating/deleting photos, and generating
/// week slots based on the current pregnancy.
class BumpPhotoNotifier extends StateNotifier<BumpPhotoState> {
  final GetBumpPhotos _getBumpPhotos;
  final SaveBumpPhoto _saveBumpPhoto;
  final SaveBumpPhotoNote _saveBumpPhotoNote;
  final UpdateBumpPhotoNote _updateNote;
  final DeleteBumpPhoto _deleteBumpPhoto;
  final Pregnancy _pregnancy;

  BumpPhotoNotifier({
    required GetBumpPhotos getBumpPhotos,
    required SaveBumpPhoto saveBumpPhoto,
    required SaveBumpPhotoNote saveBumpPhotoNote,
    required UpdateBumpPhotoNote updateNote,
    required DeleteBumpPhoto deleteBumpPhoto,
    required Pregnancy pregnancy,
  })  : _getBumpPhotos = getBumpPhotos,
        _saveBumpPhoto = saveBumpPhoto,
        _saveBumpPhotoNote = saveBumpPhotoNote,
        _updateNote = updateNote,
        _deleteBumpPhoto = deleteBumpPhoto,
        _pregnancy = pregnancy,
        super(const BumpPhotoState()) {
    loadPhotos();
  }

  /// Public getter to access current state.
  BumpPhotoState get currentState => state;

  // --------------------------------------------------------------------------
  // Load Photos
  // --------------------------------------------------------------------------

  /// Load all photos for the current pregnancy and generate week slots.
  Future<void> loadPhotos() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final photos = await _getBumpPhotos(_pregnancy.id);
      final weekSlots = _generateWeekSlots(photos);

      state = state.copyWith(
        photos: photos,
        weekSlots: weekSlots,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load photos: ${e.toString()}',
      );
    }
  }

  /// Generate week slots from weeks 1 to current gestational week.
  ///
  /// Each slot indicates if it has a photo, is the current week, or is in the future.
  /// Display week starts from 1 (even if gestational week is 0, we show week 1).
  List<WeekSlot> _generateWeekSlots(List<BumpPhoto> photos) {
    // Display week = gestational week + 1 (so week 0 shows as week 1)
    final gestationalWeek = _pregnancy.gestationalWeek;
    final displayWeek = gestationalWeek + 1;
    final photoMap = {for (var photo in photos) photo.weekNumber: photo};

    final slots = <WeekSlot>[];
    // Always show at least week 1, up to current display week
    for (int week = 1; week <= displayWeek; week++) {
      slots.add(WeekSlot(
        weekNumber: week,
        photo: photoMap[week],
        isCurrentWeek: week == displayWeek,
        isFutureWeek: false,
      ));
    }

    return slots.reversed.toList(); // Most recent week first
  }

  // --------------------------------------------------------------------------
  // Save Photo
  // --------------------------------------------------------------------------

  /// Save a new photo or replace an existing one for the given week.
  ///
  /// [weekNumber] - Week number (1-42)
  /// [imageBytes] - Raw image data
  /// [note] - Optional user note
  ///
  /// Updates state optimistically and reverts on error.
  Future<void> savePhoto({
    required int weekNumber,
    required List<int> imageBytes,
    String? note,
  }) async {
    // Show loading
    state = state.copyWith(isLoading: true, error: null);

    try {
      final savedPhoto = await _saveBumpPhoto(
        pregnancyId: _pregnancy.id,
        weekNumber: weekNumber,
        imageBytes: imageBytes,
        note: note,
      );

      // Update state with new/updated photo
      final updatedPhotos = [...state.photos];
      final existingIndex = updatedPhotos.indexWhere((p) => p.weekNumber == weekNumber);

      if (existingIndex != -1) {
        updatedPhotos[existingIndex] = savedPhoto;
      } else {
        updatedPhotos.add(savedPhoto);
        updatedPhotos.sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
      }

      final weekSlots = _generateWeekSlots(updatedPhotos);

      state = state.copyWith(
        photos: updatedPhotos,
        weekSlots: weekSlots,
        isLoading: false,
      );
    } on BumpPhotoException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save photo: ${e.toString()}',
      );
    }
  }

  // --------------------------------------------------------------------------
  // Update Note
  // --------------------------------------------------------------------------

  /// Update the note for an existing photo.
  ///
  /// [id] - Photo ID
  /// [note] - New note text (null to clear)
  Future<void> updatePhotoNote(String id, String? note) async {
    try {
      final updatedPhoto = await _updateNote(id, note);

      // Update state
      final updatedPhotos = state.photos.map((p) {
        return p.id == id ? updatedPhoto : p;
      }).toList();

      final weekSlots = _generateWeekSlots(updatedPhotos);

      state = state.copyWith(
        photos: updatedPhotos,
        weekSlots: weekSlots,
      );
    } on BumpPhotoException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update note: ${e.toString()}',
      );
    }
  }

  // --------------------------------------------------------------------------
  // Save Note Only
  // --------------------------------------------------------------------------

  /// Save a note without requiring a photo.
  ///
  /// [weekNumber] - Week number (1-42)
  /// [note] - Note text (null to clear)
  ///
  /// Updates state optimistically and reverts on error.
  Future<void> saveNoteOnly({
    required int weekNumber,
    required String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final savedPhoto = await _saveBumpPhotoNote(
        pregnancyId: _pregnancy.id,
        weekNumber: weekNumber,
        note: note,
      );

      // Update state with new/updated photo
      final updatedPhotos = [...state.photos];
      final existingIndex = updatedPhotos.indexWhere((p) => p.weekNumber == weekNumber);

      if (existingIndex != -1) {
        updatedPhotos[existingIndex] = savedPhoto;
      } else {
        updatedPhotos.add(savedPhoto);
        updatedPhotos.sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
      }

      final weekSlots = _generateWeekSlots(updatedPhotos);

      state = state.copyWith(
        photos: updatedPhotos,
        weekSlots: weekSlots,
        isLoading: false,
      );
    } on BumpPhotoException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save note: ${e.toString()}',
      );
    }
  }

  // --------------------------------------------------------------------------
  // Delete Photo
  // --------------------------------------------------------------------------

  /// Delete a photo.
  ///
  /// [id] - Photo ID
  ///
  /// Note: If the photo has a note, the note is preserved and only the photo is deleted.
  /// The photo record remains in the database with filePath set to null.
  Future<void> deletePhoto(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteBumpPhoto(id);

      // Reload photos to get the updated state from repository
      // (photo may still exist with just a note, or be completely deleted)
      final photos = await _getBumpPhotos(_pregnancy.id);
      final weekSlots = _generateWeekSlots(photos);

      state = state.copyWith(
        photos: photos,
        weekSlots: weekSlots,
        isLoading: false,
      );
    } on BumpPhotoException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete photo: ${e.toString()}',
      );
    }
  }

  /// Clear any error message.
  void clearError() {
    state = state.clearError();
  }
}

// ----------------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------------

/// Provider for bump photo state management.
///
/// Requires active pregnancy to be available.
/// Automatically updates when pregnancy data changes (e.g., due date update).
///
/// This is an async StateNotifierProvider that waits for all dependencies to be ready.
final bumpPhotoProvider =
    AsyncNotifierProvider.autoDispose<BumpPhotoAsyncNotifier, BumpPhotoState>(
  BumpPhotoAsyncNotifier.new,
);

/// Async notifier wrapper for BumpPhotoNotifier
class BumpPhotoAsyncNotifier extends AutoDisposeAsyncNotifier<BumpPhotoState> {
  BumpPhotoNotifier? _notifier;

  @override
  Future<BumpPhotoState> build() async {
    // Watch the pregnancy data provider which updates reactively when pregnancy changes
    final pregnancyAsync = ref.watch(baby.pregnancyDataProvider);

    if (!pregnancyAsync.hasValue || pregnancyAsync.value == null) {
      throw StateError(
        'bumpPhotoProvider accessed before pregnancy is available. '
        'User must have an active pregnancy.',
      );
    }

    final pregnancy = pregnancyAsync.requireValue!;

    // Get use cases - wait for all async providers
    final getBumpPhotos = await ref.watch(getBumpPhotosUseCaseProvider.future);
    final saveBumpPhoto = await ref.watch(saveBumpPhotoUseCaseProvider.future);
    final saveBumpPhotoNote = await ref.watch(saveBumpPhotoNoteUseCaseProvider.future);
    final updateNote = await ref.watch(updateBumpPhotoNoteUseCaseProvider.future);
    final deleteBumpPhoto = await ref.watch(deleteBumpPhotoUseCaseProvider.future);

    // Create the notifier
    _notifier = BumpPhotoNotifier(
      getBumpPhotos: getBumpPhotos,
      saveBumpPhoto: saveBumpPhoto,
      saveBumpPhotoNote: saveBumpPhotoNote,
      updateNote: updateNote,
      deleteBumpPhoto: deleteBumpPhoto,
      pregnancy: pregnancy,
    );

    // Listen to notifier state changes and update this provider's state
    _notifier!.addListener(_onNotifierStateChange);

    return _notifier!.currentState;
  }

  void _onNotifierStateChange(BumpPhotoState newState) {
    if (_notifier != null) {
      state = AsyncValue.data(_notifier!.currentState);
    }
  }

  // Forward method calls to the notifier
  Future<void> loadPhotos() async {
    await _notifier?.loadPhotos();
  }

  Future<void> savePhoto({
    required int weekNumber,
    required List<int> imageBytes,
    String? note,
  }) async {
    await _notifier?.savePhoto(
      weekNumber: weekNumber,
      imageBytes: imageBytes,
      note: note,
    );
  }

  Future<void> saveNoteOnly({
    required int weekNumber,
    required String? note,
  }) async {
    await _notifier?.saveNoteOnly(
      weekNumber: weekNumber,
      note: note,
    );
  }

  Future<void> updatePhotoNote(String id, String? note) async {
    await _notifier?.updatePhotoNote(id, note);
  }

  Future<void> deletePhoto(String id) async {
    await _notifier?.deletePhoto(id);
  }

  void clearError() {
    _notifier?.clearError();
  }
}
