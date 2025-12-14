@Tags(['bump_photo'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/pregnancy/pregnancy.dart';
import 'package:zeyra/domain/exceptions/bump_photo_exception.dart';
import 'package:zeyra/domain/usecases/bump_photo/delete_bump_photo.dart';
import 'package:zeyra/domain/usecases/bump_photo/get_bump_photos.dart';
import 'package:zeyra/domain/usecases/bump_photo/save_bump_photo.dart';
import 'package:zeyra/domain/usecases/bump_photo/save_bump_photo_note.dart';
import 'package:zeyra/domain/usecases/bump_photo/update_bump_photo_note.dart';
import 'package:zeyra/features/bump_photo/logic/bump_photo_provider.dart';

import '../../../mocks/fake_data/bump_photo_fakes.dart';

// Mock use cases
class MockGetBumpPhotos extends Mock implements GetBumpPhotos {}
class MockSaveBumpPhoto extends Mock implements SaveBumpPhoto {}
class MockSaveBumpPhotoNote extends Mock implements SaveBumpPhotoNote {}
class MockUpdateBumpPhotoNote extends Mock implements UpdateBumpPhotoNote {}
class MockDeleteBumpPhoto extends Mock implements DeleteBumpPhoto {}

void main() {
  late MockGetBumpPhotos mockGetBumpPhotos;
  late MockSaveBumpPhoto mockSaveBumpPhoto;
  late MockSaveBumpPhotoNote mockSaveBumpPhotoNote;
  late MockUpdateBumpPhotoNote mockUpdateNote;
  late MockDeleteBumpPhoto mockDeleteBumpPhoto;
  late Pregnancy testPregnancy;

  setUp(() {
    mockGetBumpPhotos = MockGetBumpPhotos();
    mockSaveBumpPhoto = MockSaveBumpPhoto();
    mockSaveBumpPhotoNote = MockSaveBumpPhotoNote();
    mockUpdateNote = MockUpdateBumpPhotoNote();
    mockDeleteBumpPhoto = MockDeleteBumpPhoto();

    // Create a test pregnancy at gestational week 20
    // Start date ~20 weeks ago, due date ~20 weeks from now
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 140)); // ~20 weeks ago
    final dueDate = now.add(const Duration(days: 140)); // ~20 weeks remaining
    testPregnancy = Pregnancy(
      id: 'test-pregnancy-id',
      userId: 'test-user-id',
      startDate: startDate,
      dueDate: dueDate,
      createdAt: startDate,
      updatedAt: now,
    );
  });

  BumpPhotoNotifier createNotifier() {
    return BumpPhotoNotifier(
      getBumpPhotos: mockGetBumpPhotos,
      saveBumpPhoto: mockSaveBumpPhoto,
      saveBumpPhotoNote: mockSaveBumpPhotoNote,
      updateNote: mockUpdateNote,
      deleteBumpPhoto: mockDeleteBumpPhoto,
      pregnancy: testPregnancy,
    );
  }

  group('BumpPhotoNotifier', () {
    group('Initial State', () {
      test('starts with empty state before loadPhotos completes', () {
        // Arrange - mock to return empty list
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        // Act
        final notifier = createNotifier();

        // Assert - initial state before async completes
        expect(notifier.currentState.photos, isEmpty);
        expect(notifier.currentState.isLoading, isTrue); // Loading starts
      });

      test('calls loadPhotos on creation', () async {
        // Arrange
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        // Act
        createNotifier();

        // Wait for async operation
        await Future<void>.delayed(Duration.zero);

        // Assert
        verify(() => mockGetBumpPhotos(testPregnancy.id)).called(1);
      });
    });

    group('loadPhotos', () {
      test('loads photos and generates week slots', () async {
        // Arrange
        final photos = [
          BumpPhotoFakes.forWeek(10, pregnancyId: testPregnancy.id),
          BumpPhotoFakes.forWeek(15, pregnancyId: testPregnancy.id),
        ];

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => photos);

        // Act
        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(notifier.currentState.photos.length, 2);
        expect(notifier.currentState.isLoading, isFalse);
        expect(notifier.currentState.error, isNull);
        expect(notifier.currentState.weekSlots, isNotEmpty);
      });

      test('sets error on failure', () async {
        // Arrange
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenThrow(Exception('Database error'));

        // Act
        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(notifier.currentState.isLoading, isFalse);
        expect(notifier.currentState.error, isNotNull);
        expect(notifier.currentState.error, contains('Failed to load photos'));
      });

      test('generates correct week slots from pregnancy', () async {
        // Arrange
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        // Act
        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Assert - slots should be generated based on gestational week
        final slots = notifier.currentState.weekSlots;
        expect(slots, isNotEmpty);
        // Slots are in reverse order (newest first)
        expect(slots.first.isCurrentWeek, isTrue);
      });
    });

    group('savePhoto', () {
      test('saves photo and updates state', () async {
        // Arrange
        final imageBytes = List<int>.filled(100, 0);
        final savedPhoto = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id);

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        when(() => mockSaveBumpPhoto(
              pregnancyId: testPregnancy.id,
              weekNumber: 20,
              imageBytes: imageBytes,
              note: null,
            )).thenAnswer((_) async => savedPhoto);

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.savePhoto(weekNumber: 20, imageBytes: imageBytes);

        // Assert
        expect(notifier.currentState.photos.length, 1);
        expect(notifier.currentState.photos.first.weekNumber, 20);
        expect(notifier.currentState.isLoading, isFalse);
      });

      test('replaces existing photo for same week', () async {
        // Arrange
        final existingPhoto = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id);
        final newPhoto = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id, note: 'Updated');
        final imageBytes = List<int>.filled(100, 0);

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [existingPhoto]);

        when(() => mockSaveBumpPhoto(
              pregnancyId: testPregnancy.id,
              weekNumber: 20,
              imageBytes: imageBytes,
              note: null,
            )).thenAnswer((_) async => newPhoto);

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.savePhoto(weekNumber: 20, imageBytes: imageBytes);

        // Assert - should still have only 1 photo
        expect(notifier.currentState.photos.length, 1);
      });

      test('sets error on BumpPhotoException', () async {
        // Arrange
        final imageBytes = List<int>.filled(100, 0);

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        when(() => mockSaveBumpPhoto(
              pregnancyId: testPregnancy.id,
              weekNumber: 0,
              imageBytes: imageBytes,
              note: null,
            )).thenThrow(const InvalidWeekException(0, 'Week must be 1-42'));

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.savePhoto(weekNumber: 0, imageBytes: imageBytes);

        // Assert
        expect(notifier.currentState.error, 'Week must be 1-42');
      });

      test('sets error on generic exception', () async {
        // Arrange
        final imageBytes = List<int>.filled(100, 0);

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        when(() => mockSaveBumpPhoto(
              pregnancyId: testPregnancy.id,
              weekNumber: 20,
              imageBytes: imageBytes,
              note: null,
            )).thenThrow(Exception('Unexpected error'));

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.savePhoto(weekNumber: 20, imageBytes: imageBytes);

        // Assert
        expect(notifier.currentState.error, contains('Failed to save photo'));
      });
    });

    group('updatePhotoNote', () {
      test('updates note in state', () async {
        // Arrange
        final photo = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id);
        final updatedPhoto = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id, note: 'New note');

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [photo]);

        when(() => mockUpdateNote(photo.id, 'New note'))
            .thenAnswer((_) async => updatedPhoto);

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.updatePhotoNote(photo.id, 'New note');

        // Assert
        expect(notifier.currentState.photos.first.note, 'New note');
      });

      test('regenerates week slots after update', () async {
        // Arrange
        final photo = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id);
        final updatedPhoto = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id, note: 'Note');

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [photo]);

        when(() => mockUpdateNote(photo.id, 'Note'))
            .thenAnswer((_) async => updatedPhoto);

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);
        final slotsBefore = notifier.currentState.weekSlots.length;

        // Act
        await notifier.updatePhotoNote(photo.id, 'Note');

        // Assert
        expect(notifier.currentState.weekSlots.length, slotsBefore);
      });

      test('sets error on failure', () async {
        // Arrange
        final photo = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id);

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [photo]);

        when(() => mockUpdateNote(photo.id, 'Note'))
            .thenThrow(const PhotoNotFoundException('Photo not found'));

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.updatePhotoNote(photo.id, 'Note');

        // Assert
        expect(notifier.currentState.error, 'Photo not found');
      });
    });

    group('saveNoteOnly', () {
      test('creates new entry with note only', () async {
        // Arrange
        final noteOnlyPhoto = BumpPhotoFakes.noteOnly(15, pregnancyId: testPregnancy.id, note: 'My note');

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        when(() => mockSaveBumpPhotoNote(
              pregnancyId: testPregnancy.id,
              weekNumber: 15,
              note: 'My note',
            )).thenAnswer((_) async => noteOnlyPhoto);

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.saveNoteOnly(weekNumber: 15, note: 'My note');

        // Assert
        expect(notifier.currentState.photos.length, 1);
        expect(notifier.currentState.photos.first.note, 'My note');
        expect(notifier.currentState.photos.first.filePath, isNull);
      });

      test('updates existing entry with note', () async {
        // Arrange
        final existingPhoto = BumpPhotoFakes.forWeek(15, pregnancyId: testPregnancy.id);
        final updatedPhoto = BumpPhotoFakes.withPhotoAndNote(
          15,
          pregnancyId: testPregnancy.id,
          note: 'Updated note',
        );

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [existingPhoto]);

        when(() => mockSaveBumpPhotoNote(
              pregnancyId: testPregnancy.id,
              weekNumber: 15,
              note: 'Updated note',
            )).thenAnswer((_) async => updatedPhoto);

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.saveNoteOnly(weekNumber: 15, note: 'Updated note');

        // Assert - should still have 1 photo, with updated note
        expect(notifier.currentState.photos.length, 1);
        expect(notifier.currentState.photos.first.note, 'Updated note');
      });

      test('sets error on failure', () async {
        // Arrange
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        when(() => mockSaveBumpPhotoNote(
              pregnancyId: testPregnancy.id,
              weekNumber: 0,
              note: 'Note',
            )).thenThrow(const InvalidWeekException(0, 'Invalid week'));

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.saveNoteOnly(weekNumber: 0, note: 'Note');

        // Assert
        expect(notifier.currentState.error, 'Invalid week');
      });
    });

    group('deletePhoto', () {
      test('removes photo from state', () async {
        // Arrange
        final photo = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id);

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [photo]);

        when(() => mockDeleteBumpPhoto(photo.id))
            .thenAnswer((_) async {});

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Setup second call to return empty (photo deleted)
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        // Act
        await notifier.deletePhoto(photo.id);

        // Assert
        expect(notifier.currentState.photos, isEmpty);
      });

      test('preserves note when photo deleted', () async {
        // Arrange
        final photoWithNote = BumpPhotoFakes.withPhotoAndNote(
          20,
          pregnancyId: testPregnancy.id,
          note: 'Keep this note',
        );
        final noteOnlyResult = BumpPhotoFakes.noteOnly(
          20,
          pregnancyId: testPregnancy.id,
          note: 'Keep this note',
        );

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [photoWithNote]);

        when(() => mockDeleteBumpPhoto(photoWithNote.id))
            .thenAnswer((_) async {});

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // After delete, repository returns note-only entry
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [noteOnlyResult]);

        // Act
        await notifier.deletePhoto(photoWithNote.id);

        // Assert - note should still exist
        expect(notifier.currentState.photos.length, 1);
        expect(notifier.currentState.photos.first.note, 'Keep this note');
        expect(notifier.currentState.photos.first.filePath, isNull);
      });

      test('reloads photos after delete', () async {
        // Arrange
        final photo = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id);

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [photo]);

        when(() => mockDeleteBumpPhoto(photo.id))
            .thenAnswer((_) async {});

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        reset(mockGetBumpPhotos);
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        // Act
        await notifier.deletePhoto(photo.id);

        // Assert - getBumpPhotos should be called again after delete
        verify(() => mockGetBumpPhotos(testPregnancy.id)).called(1);
      });

      test('sets error on failure', () async {
        // Arrange
        final photo = BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancy.id);

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => [photo]);

        when(() => mockDeleteBumpPhoto(photo.id))
            .thenThrow(Exception('Delete failed'));

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Act
        await notifier.deletePhoto(photo.id);

        // Assert
        expect(notifier.currentState.error, contains('Failed to delete photo'));
      });
    });

    group('clearError', () {
      test('clears error from state', () async {
        // Arrange
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenThrow(Exception('Error'));

        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        expect(notifier.currentState.error, isNotNull);

        // Act
        notifier.clearError();

        // Assert
        expect(notifier.currentState.error, isNull);
      });
    });

    group('Week Slot Generation', () {
      test('generates slots up to current gestational week', () async {
        // Arrange
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        // Act
        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Assert
        final slots = notifier.currentState.weekSlots;
        expect(slots, isNotEmpty);
        // All slots should have weekNumber between 1 and current week + 1
        for (final slot in slots) {
          expect(slot.weekNumber, greaterThanOrEqualTo(1));
        }
      });

      test('marks current week correctly', () async {
        // Arrange
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        // Act
        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Assert
        final slots = notifier.currentState.weekSlots;
        final currentWeekSlots = slots.where((s) => s.isCurrentWeek).toList();
        expect(currentWeekSlots.length, 1); // Only one current week
      });

      test('returns slots in reverse order (newest first)', () async {
        // Arrange
        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => []);

        // Act
        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Assert
        final slots = notifier.currentState.weekSlots;
        if (slots.length > 1) {
          expect(slots.first.weekNumber, greaterThan(slots.last.weekNumber));
        }
      });

      test('maps photos to correct week slots', () async {
        // Arrange
        final photos = [
          BumpPhotoFakes.forWeek(10, pregnancyId: testPregnancy.id),
          BumpPhotoFakes.forWeek(15, pregnancyId: testPregnancy.id),
        ];

        when(() => mockGetBumpPhotos(testPregnancy.id))
            .thenAnswer((_) async => photos);

        // Act
        final notifier = createNotifier();
        await Future<void>.delayed(Duration.zero);

        // Assert
        final slots = notifier.currentState.weekSlots;
        final slot10 = slots.firstWhere((s) => s.weekNumber == 10);
        final slot15 = slots.firstWhere((s) => s.weekNumber == 15);

        expect(slot10.photo, isNotNull);
        expect(slot15.photo, isNotNull);
        expect(slot10.hasPhoto, isTrue);
        expect(slot15.hasPhoto, isTrue);
      });
    });
  });
}
