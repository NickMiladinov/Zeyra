@Tags(['bump_photo'])
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';
import 'package:zeyra/core/services/photo_file_service.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/repositories/bump_photo_repository_impl.dart';
import 'package:zeyra/domain/exceptions/bump_photo_exception.dart';

class MockPhotoFileService extends Mock implements PhotoFileService {}
class MockLoggingService extends Mock implements LoggingService {}

void main() {
  late AppDatabase database;
  late BumpPhotoRepositoryImpl repository;
  late MockPhotoFileService mockFileService;
  late MockLoggingService mockLogger;

  const testUserId = 'user-123';
  const testPregnancyId = 'pregnancy-123';

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');

    mockFileService = MockPhotoFileService();
    mockLogger = MockLoggingService();

    repository = BumpPhotoRepositoryImpl(
      dao: database.bumpPhotoDao,
      fileService: mockFileService,
      logger: mockLogger,
      userId: testUserId,
    );

    // Setup default logger behavior
    when(() => mockLogger.debug(any())).thenReturn(null);
    when(() => mockLogger.debug(any(), data: any(named: 'data'))).thenReturn(null);
    when(() => mockLogger.info(any())).thenReturn(null);
    when(() => mockLogger.info(any(), data: any(named: 'data'))).thenReturn(null);
    when(() => mockLogger.warning(any(), data: any(named: 'data'))).thenReturn(null);
    when(() => mockLogger.error(
          any(),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
        )).thenReturn(null);
    when(() => mockLogger.error(
          any(),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
          data: any(named: 'data'),
        )).thenReturn(null);
    when(() => mockLogger.logDatabaseOperation(
          any(),
          table: any(named: 'table'),
          success: any(named: 'success'),
        )).thenReturn(null);
    when(() => mockLogger.logDatabaseOperation(
          any(),
          table: any(named: 'table'),
          success: any(named: 'success'),
          error: any(named: 'error'),
        )).thenReturn(null);
  });

  tearDown(() async {
    await database.close();
  });

  group('[Integration] Bump Photo Flow', () {
    test('should save photo and retrieve it', () async {
      // Arrange
      final imageBytes = List<int>.filled(100, 0);
      const filePath = '/path/to/photo.jpg';

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 20,
          )).thenAnswer((_) async => filePath);

      // Act
      final saved = await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 20,
        imageBytes: imageBytes,
        note: 'Week 20 photo',
      );

      // Assert
      final retrieved = await repository.getBumpPhoto(testPregnancyId, 20);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, saved.id);
      expect(retrieved.weekNumber, 20);
      expect(retrieved.filePath, filePath);
      expect(retrieved.note, 'Week 20 photo');
    });

    test('should save note only without photo', () async {
      // Act
      final saved = await repository.saveNoteOnly(
        pregnancyId: testPregnancyId,
        weekNumber: 15,
        note: 'Just a note for week 15',
      );

      // Assert
      expect(saved.filePath, isNull);
      expect(saved.note, 'Just a note for week 15');
      expect(saved.weekNumber, 15);

      final retrieved = await repository.getBumpPhoto(testPregnancyId, 15);
      expect(retrieved, isNotNull);
      expect(retrieved!.filePath, isNull);
      expect(retrieved.note, 'Just a note for week 15');
    });

    test('should save photo with note', () async {
      // Arrange
      final imageBytes = List<int>.filled(100, 0);

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 25,
          )).thenAnswer((_) async => '/path/25.jpg');

      // Act
      final saved = await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 25,
        imageBytes: imageBytes,
        note: 'Baby is kicking a lot!',
      );

      // Assert
      expect(saved.filePath, '/path/25.jpg');
      expect(saved.note, 'Baby is kicking a lot!');
    });

    test('should update note on existing photo', () async {
      // Arrange - save photo first
      final imageBytes = List<int>.filled(100, 0);

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 18,
          )).thenAnswer((_) async => '/path/18.jpg');

      final saved = await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 18,
        imageBytes: imageBytes,
        note: 'Original note',
      );

      // Act - update the note
      final updated = await repository.updateNote(saved.id, 'Updated note');

      // Assert
      expect(updated.note, 'Updated note');
      expect(updated.filePath, '/path/18.jpg'); // Photo preserved
    });

    test('should delete photo and preserve note', () async {
      // Arrange - save photo with note
      final imageBytes = List<int>.filled(100, 0);
      const filePath = '/path/22.jpg';

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 22,
          )).thenAnswer((_) async => filePath);

      when(() => mockFileService.deletePhoto(filePath))
          .thenAnswer((_) async {});

      final saved = await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 22,
        imageBytes: imageBytes,
        note: 'Important memory',
      );

      // Act - delete the photo
      await repository.deleteBumpPhoto(saved.id);

      // Assert - note should be preserved
      final retrieved = await repository.getBumpPhoto(testPregnancyId, 22);
      expect(retrieved, isNotNull);
      expect(retrieved!.filePath, isNull); // Photo removed
      expect(retrieved.note, 'Important memory'); // Note preserved
    });

    test('should delete photo without note completely', () async {
      // Arrange - save photo without note
      final imageBytes = List<int>.filled(100, 0);
      const filePath = '/path/23.jpg';

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 23,
          )).thenAnswer((_) async => filePath);

      when(() => mockFileService.deletePhoto(filePath))
          .thenAnswer((_) async {});

      final saved = await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 23,
        imageBytes: imageBytes,
        note: null, // No note
      );

      // Act - delete the photo
      await repository.deleteBumpPhoto(saved.id);

      // Assert - record should be completely deleted
      final retrieved = await repository.getBumpPhoto(testPregnancyId, 23);
      expect(retrieved, isNull);
    });

    test('should replace photo when saving to same week', () async {
      // Arrange
      final imageBytes1 = List<int>.filled(100, 1);
      final imageBytes2 = List<int>.filled(100, 2);
      const oldPath = '/path/old_30.jpg';
      const newPath = '/path/new_30.jpg';

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes1,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 30,
          )).thenAnswer((_) async => oldPath);

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes2,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 30,
          )).thenAnswer((_) async => newPath);

      when(() => mockFileService.deletePhoto(oldPath))
          .thenAnswer((_) async {});

      // Save first photo
      await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 30,
        imageBytes: imageBytes1,
      );

      // Act - save second photo to same week
      final replaced = await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 30,
        imageBytes: imageBytes2,
      );

      // Assert - old file should be deleted
      verify(() => mockFileService.deletePhoto(oldPath)).called(1);
      expect(replaced.filePath, newPath);

      // Should only have one entry for week 30
      final photos = await repository.getBumpPhotos(testPregnancyId);
      final week30Photos = photos.where((p) => p.weekNumber == 30).toList();
      expect(week30Photos.length, 1);
    });

    test('should handle multiple weeks', () async {
      // Arrange
      final imageBytes = List<int>.filled(100, 0);

      for (var week = 10; week <= 15; week++) {
        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: testPregnancyId,
              weekNumber: week,
            )).thenAnswer((_) async => '/path/$week.jpg');
      }

      // Act - save photos for multiple weeks
      for (var week = 10; week <= 15; week++) {
        await repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: week,
          imageBytes: imageBytes,
          note: 'Week $week',
        );
      }

      // Assert
      final photos = await repository.getBumpPhotos(testPregnancyId);
      expect(photos.length, 6);
      expect(photos.first.weekNumber, 10); // Sorted ascending
      expect(photos.last.weekNumber, 15);
    });

    test('should reject invalid week number (too low)', () async {
      // Arrange
      final imageBytes = List<int>.filled(100, 0);

      // Act & Assert
      expect(
        () => repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: 0,
          imageBytes: imageBytes,
        ),
        throwsA(isA<InvalidWeekException>()),
      );
    });

    test('should reject invalid week number (too high)', () async {
      // Arrange
      final imageBytes = List<int>.filled(100, 0);

      // Act & Assert
      expect(
        () => repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: 45,
          imageBytes: imageBytes,
        ),
        throwsA(isA<InvalidWeekException>()),
      );
    });

    test('should preserve note when changing photo', () async {
      // Arrange
      final imageBytes1 = List<int>.filled(100, 1);
      final imageBytes2 = List<int>.filled(100, 2);
      const note = 'My precious memory';

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes1,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 28,
          )).thenAnswer((_) async => '/path/old_28.jpg');

      when(() => mockFileService.savePhoto(
            imageBytes: imageBytes2,
            userId: testUserId,
            pregnancyId: testPregnancyId,
            weekNumber: 28,
          )).thenAnswer((_) async => '/path/new_28.jpg');

      when(() => mockFileService.deletePhoto('/path/old_28.jpg'))
          .thenAnswer((_) async {});

      // Save original with note
      await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 28,
        imageBytes: imageBytes1,
        note: note,
      );

      // Act - replace photo, keep same note
      final updated = await repository.saveBumpPhoto(
        pregnancyId: testPregnancyId,
        weekNumber: 28,
        imageBytes: imageBytes2,
        note: note,
      );

      // Assert
      expect(updated.filePath, '/path/new_28.jpg');
      expect(updated.note, note);
    });

    test('should clear note when null provided', () async {
      // Arrange - save note only
      await repository.saveNoteOnly(
        pregnancyId: testPregnancyId,
        weekNumber: 12,
        note: 'Original note',
      );

      // Act - clear the note on a note-only entry
      final result = await repository.saveNoteOnly(
        pregnancyId: testPregnancyId,
        weekNumber: 12,
        note: null,
      );

      // Assert - the entry should be deleted when clearing note on note-only entry
      // (keeping an entry with both filePath and note null is pointless)
      final retrieved = await repository.getBumpPhoto(testPregnancyId, 12);
      expect(retrieved, isNull); // Entry deleted
      expect(result.note, isNull); // Returned tombstone has null note
    });

    test('should delete all photos for pregnancy', () async {
      // Arrange
      final imageBytes = List<int>.filled(100, 0);

      for (var week = 5; week <= 8; week++) {
        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: testPregnancyId,
              weekNumber: week,
            )).thenAnswer((_) async => '/path/$week.jpg');
      }

      when(() => mockFileService.deleteAllPhotosForPregnancy(
            userId: testUserId,
            pregnancyId: testPregnancyId,
          )).thenAnswer((_) async => 4);

      // Save multiple photos
      for (var week = 5; week <= 8; week++) {
        await repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: week,
          imageBytes: imageBytes,
        );
      }

      // Act
      final deletedCount = await repository.deleteAllForPregnancy(testPregnancyId);

      // Assert
      expect(deletedCount, 4);
      final photos = await repository.getBumpPhotos(testPregnancyId);
      expect(photos, isEmpty);
    });

    test('should handle empty pregnancy (no photos)', () async {
      // Act
      final photos = await repository.getBumpPhotos(testPregnancyId);

      // Assert
      expect(photos, isEmpty);
      expect(photos, isA<List>());
    });

    test('should handle concurrent saves to different weeks', () async {
      // Arrange
      final imageBytes = List<int>.filled(100, 0);

      for (var week = 1; week <= 5; week++) {
        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: testPregnancyId,
              weekNumber: week,
            )).thenAnswer((_) async => '/path/$week.jpg');
      }

      // Act - save multiple weeks concurrently
      await Future.wait([
        repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: 1,
          imageBytes: imageBytes,
        ),
        repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: 2,
          imageBytes: imageBytes,
        ),
        repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: 3,
          imageBytes: imageBytes,
        ),
        repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: 4,
          imageBytes: imageBytes,
        ),
        repository.saveBumpPhoto(
          pregnancyId: testPregnancyId,
          weekNumber: 5,
          imageBytes: imageBytes,
        ),
      ]);

      // Assert
      final photos = await repository.getBumpPhotos(testPregnancyId);
      expect(photos.length, 5);
    });
  });
}
