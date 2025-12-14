// ignore: unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';
import 'package:zeyra/core/services/photo_file_service.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/local/daos/bump_photo_dao.dart';
import 'package:zeyra/data/repositories/bump_photo_repository_impl.dart';
import 'package:zeyra/domain/entities/bump_photo/bump_photo.dart';
import 'package:zeyra/domain/exceptions/bump_photo_exception.dart';

class MockBumpPhotoDao extends Mock implements BumpPhotoDao {}
class MockPhotoFileService extends Mock implements PhotoFileService {}
class MockLoggingService extends Mock implements LoggingService {}
class FakeBumpPhotosCompanion extends Fake implements BumpPhotosCompanion {}

void main() {
  setUpAll(() {
    // Register fallback values used across all tests
    registerFallbackValue(
      BumpPhotoDto(
        id: '',
        pregnancyId: '',
        weekNumber: 0,
        filePath: '',
        note: null,
        photoDateMillis: 0,
        createdAtMillis: 0,
        updatedAtMillis: 0,
      ),
    );
    registerFallbackValue(FakeBumpPhotosCompanion());
  });

  group('BumpPhotoRepositoryImpl', () {
    late BumpPhotoRepositoryImpl repository;
    late MockBumpPhotoDao mockDao;
    late MockPhotoFileService mockFileService;
    late MockLoggingService mockLogger;
    const testUserId = 'user-123';

    setUp(() {
      mockDao = MockBumpPhotoDao();
      mockFileService = MockPhotoFileService();
      mockLogger = MockLoggingService();
      repository = BumpPhotoRepositoryImpl(
        dao: mockDao,
        fileService: mockFileService,
        logger: mockLogger,
        userId: testUserId,
      );

      // Setup default logger behavior - don't use any() for all parameters
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

    group('saveBumpPhoto', () {
      test('saves file and creates database record', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final imageBytes = List<int>.filled(100, 0);
        const note = 'Test note';
        const filePath = '/path/to/photo.jpg';

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => null);

        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).thenAnswer((_) async => filePath);

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.saveBumpPhoto(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          imageBytes: imageBytes,
          note: note,
        );

        // Assert
        expect(result.pregnancyId, pregnancyId);
        expect(result.weekNumber, weekNumber);
        expect(result.filePath, filePath);
        expect(result.note, note);

        verify(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).called(1);

        verify(() => mockDao.upsertBumpPhoto(any())).called(1);
      });

      test('replaces existing photo file when upserting', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final imageBytes = List<int>.filled(100, 0);
        const filePath = '/path/to/photo.jpg';
        final now = DateTime.now();

        final existingDto = BumpPhotoDto(
          id: 'existing-id',
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: '/old/path.jpg',
          note: null,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => existingDto);

        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).thenAnswer((_) async => filePath);

        when(() => mockFileService.deletePhoto('/old/path.jpg'))
            .thenAnswer((_) async {});

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.saveBumpPhoto(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          imageBytes: imageBytes,
        );

        // Assert - should delete old file and save new one
        verify(() => mockFileService.deletePhoto('/old/path.jpg')).called(1);
        verify(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).called(1);
      });

      test('throws InvalidWeekException for invalid week number', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 0; // Invalid
        final imageBytes = List<int>.filled(100, 0);

        // Act & Assert
        expect(
          () => repository.saveBumpPhoto(
            pregnancyId: pregnancyId,
            weekNumber: weekNumber,
            imageBytes: imageBytes,
          ),
          throwsA(isA<InvalidWeekException>()),
        );

        verifyNever(() => mockFileService.savePhoto(
              imageBytes: any(named: 'imageBytes'),
              userId: any(named: 'userId'),
              pregnancyId: any(named: 'pregnancyId'),
              weekNumber: any(named: 'weekNumber'),
            ));
      });

      test('handles file service errors', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final imageBytes = List<int>.filled(100, 0);

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => null);

        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).thenThrow(const PhotoFileException('unknown', 'Failed to save file'));

        // Act & Assert
        expect(
          () => repository.saveBumpPhoto(
            pregnancyId: pregnancyId,
            weekNumber: weekNumber,
            imageBytes: imageBytes,
          ),
          throwsA(isA<PhotoFileException>()),
        );

        verifyNever(() => mockDao.upsertBumpPhoto(any()));
      });

      test('wraps database errors in BumpPhotoException', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final imageBytes = List<int>.filled(100, 0);
        const filePath = '/path/to/photo.jpg';

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => null);

        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).thenAnswer((_) async => filePath);

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.saveBumpPhoto(
            pregnancyId: pregnancyId,
            weekNumber: weekNumber,
            imageBytes: imageBytes,
          ),
          throwsA(isA<BumpPhotoException>()),
        );
      });
    });

    group('getBumpPhotos', () {
      test('returns mapped domain entities sorted by week', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        final now = DateTime.now();
        final dtos = [
          BumpPhotoDto(
            id: 'id-1',
            pregnancyId: pregnancyId,
            weekNumber: 15,
            filePath: '/path/15.jpg',
            note: 'Week 15',
            photoDateMillis: now.millisecondsSinceEpoch,
            createdAtMillis: now.millisecondsSinceEpoch,
            updatedAtMillis: now.millisecondsSinceEpoch,
          ),
          BumpPhotoDto(
            id: 'id-2',
            pregnancyId: pregnancyId,
            weekNumber: 20,
            filePath: '/path/20.jpg',
            note: 'Week 20',
            photoDateMillis: now.millisecondsSinceEpoch,
            createdAtMillis: now.millisecondsSinceEpoch,
            updatedAtMillis: now.millisecondsSinceEpoch,
          ),
        ];

        when(() => mockDao.getBumpPhotosForPregnancy(pregnancyId))
            .thenAnswer((_) async => dtos);

        // Act
        final result = await repository.getBumpPhotos(pregnancyId);

        // Assert
        expect(result, hasLength(2));
        expect(result[0].weekNumber, 15);
        expect(result[1].weekNumber, 20);
        expect(result[0], isA<BumpPhoto>());
        expect(result[1], isA<BumpPhoto>());
      });

      test('returns empty list when no photos exist', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';

        when(() => mockDao.getBumpPhotosForPregnancy(pregnancyId))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getBumpPhotos(pregnancyId);

        // Assert
        expect(result, isEmpty);
      });

      test('rethrows database errors', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';

        when(() => mockDao.getBumpPhotosForPregnancy(pregnancyId))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getBumpPhotos(pregnancyId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getBumpPhoto', () {
      test('returns mapped domain entity when found', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final now = DateTime.now();
        final dto = BumpPhotoDto(
          id: 'photo-123',
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: '/path/20.jpg',
          note: 'Week 20',
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => dto);

        // Act
        final result = await repository.getBumpPhoto(pregnancyId, weekNumber);

        // Assert
        expect(result, isNotNull);
        expect(result!.pregnancyId, pregnancyId);
        expect(result.weekNumber, weekNumber);
        expect(result, isA<BumpPhoto>());
      });

      test('returns null when photo not found', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getBumpPhoto(pregnancyId, weekNumber);

        // Assert
        expect(result, isNull);
      });
    });

    group('updateNote', () {
      test('updates note in database', () async {
        // Arrange
        const id = 'photo-123';
        const newNote = 'Updated note';

        final now = DateTime.now();
        final updatedDto = BumpPhotoDto(
          id: id,
          pregnancyId: 'pregnancy-123',
          weekNumber: 20,
          filePath: '/path/20.jpg',
          note: newNote,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.updateBumpPhotoFields(any(), any()))
            .thenAnswer((_) async {});

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => updatedDto);

        // Act
        final result = await repository.updateNote(id, newNote);

        // Assert
        expect(result.note, newNote);
        verify(() => mockDao.updateBumpPhotoFields(any(), any())).called(1);
      });

      test('throws PhotoNotFoundException when photo does not exist after update', () async {
        // Arrange
        const id = 'nonexistent';
        const newNote = 'Updated note';

        when(() => mockDao.updateBumpPhotoFields(any(), any()))
            .thenAnswer((_) async {});

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => repository.updateNote(id, newNote),
          throwsA(isA<PhotoNotFoundException>()),
        );
      });

      test('normalizes empty string to null', () async {
        // Arrange
        const id = 'photo-123';

        final now = DateTime.now();
        final updatedDto = BumpPhotoDto(
          id: id,
          pregnancyId: 'pregnancy-123',
          weekNumber: 20,
          filePath: '/path/20.jpg',
          note: null,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.updateBumpPhotoFields(any(), any()))
            .thenAnswer((_) async {});

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => updatedDto);

        // Act
        final result = await repository.updateNote(id, '');

        // Assert
        expect(result.note, isNull);
      });
    });

    group('deleteBumpPhoto', () {
      test('deletes file and database record', () async {
        // Arrange
        const id = 'photo-123';
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final now = DateTime.now();

        final dto = BumpPhotoDto(
          id: id,
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: '/path/20.jpg',
          note: null,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => dto);

        when(() => mockFileService.deletePhoto('/path/20.jpg'))
            .thenAnswer((_) async {});

        when(() => mockDao.deleteBumpPhoto(id))
            .thenAnswer((_) async => 1);

        // Act
        await repository.deleteBumpPhoto(id);

        // Assert
        verify(() => mockFileService.deletePhoto('/path/20.jpg')).called(1);
        verify(() => mockDao.deleteBumpPhoto(id)).called(1);
      });

      test('returns early when photo does not exist', () async {
        // Arrange
        const id = 'nonexistent';

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => null);

        // Act
        await repository.deleteBumpPhoto(id);

        // Assert - should not try to delete file or DB record
        verifyNever(() => mockFileService.deletePhoto(any()));
        verifyNever(() => mockDao.deleteBumpPhoto(any()));
      });

      test('continues with database deletion even if file deletion fails', () async {
        // Arrange
        const id = 'photo-123';
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final now = DateTime.now();

        final dto = BumpPhotoDto(
          id: id,
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: '/path/20.jpg',
          note: null,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => dto);

        when(() => mockFileService.deletePhoto('/path/20.jpg'))
            .thenThrow(const PhotoFileException('/path/20.jpg', 'File not found'));

        when(() => mockDao.deleteBumpPhoto(id))
            .thenAnswer((_) async => 1);

        // Act
        await repository.deleteBumpPhoto(id);

        // Assert - should still delete from database
        verify(() => mockDao.deleteBumpPhoto(id)).called(1);
      });
    });

    group('deleteAllForPregnancy', () {
      test('deletes all photos for pregnancy', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';

        when(() => mockFileService.deleteAllPhotosForPregnancy(
              userId: testUserId,
              pregnancyId: pregnancyId,
            )).thenAnswer((_) async => 5);

        when(() => mockDao.deleteAllForPregnancy(pregnancyId))
            .thenAnswer((_) async => 5);

        // Act
        final result = await repository.deleteAllForPregnancy(pregnancyId);

        // Assert
        expect(result, 5);
        verify(() => mockFileService.deleteAllPhotosForPregnancy(
              userId: testUserId,
              pregnancyId: pregnancyId,
            )).called(1);
        verify(() => mockDao.deleteAllForPregnancy(pregnancyId)).called(1);
      });

      test('rethrows errors', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';

        when(() => mockFileService.deleteAllPhotosForPregnancy(
              userId: testUserId,
              pregnancyId: pregnancyId,
            )).thenThrow(Exception('File deletion failed'));

        // Act & Assert
        expect(
          () => repository.deleteAllForPregnancy(pregnancyId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('saveNoteOnly', () {
      test('creates new entry with note only (no file)', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 15;
        const note = 'Just a note without photo';

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => null);

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.saveNoteOnly(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          note: note,
        );

        // Assert
        expect(result.pregnancyId, pregnancyId);
        expect(result.weekNumber, weekNumber);
        expect(result.filePath, isNull); // No file for note-only
        expect(result.note, note);

        // Should NOT call file service
        verifyNever(() => mockFileService.savePhoto(
              imageBytes: any(named: 'imageBytes'),
              userId: any(named: 'userId'),
              pregnancyId: any(named: 'pregnancyId'),
              weekNumber: any(named: 'weekNumber'),
            ));

        verify(() => mockDao.upsertBumpPhoto(any())).called(1);
      });

      test('preserves existing filePath when updating note', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 15;
        const existingFilePath = '/existing/photo.jpg';
        final now = DateTime.now();

        final existingDto = BumpPhotoDto(
          id: 'existing-id',
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: existingFilePath,
          note: 'Old note',
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => existingDto);

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.saveNoteOnly(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          note: 'Updated note',
        );

        // Assert
        expect(result.filePath, existingFilePath); // Preserved
        expect(result.note, 'Updated note');
        expect(result.id, 'existing-id'); // Same ID
      });

      test('throws InvalidWeekException for invalid week', () async {
        // Act & Assert
        expect(
          () => repository.saveNoteOnly(
            pregnancyId: 'pregnancy-123',
            weekNumber: 0,
            note: 'Some note',
          ),
          throwsA(isA<InvalidWeekException>()),
        );

        verifyNever(() => mockDao.getBumpPhotoByWeek(any(), any()));
      });

      test('wraps database errors in BumpPhotoException', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => null);

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.saveNoteOnly(
            pregnancyId: pregnancyId,
            weekNumber: weekNumber,
            note: 'Test note',
          ),
          throwsA(isA<BumpPhotoException>()),
        );
      });

      test('returns empty entry when null note and no existing entry', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 12;

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.saveNoteOnly(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          note: null,
        );

        // Assert - returns empty entry (not persisted)
        expect(result.note, isNull);
        expect(result.filePath, isNull);
        expect(result.pregnancyId, pregnancyId);
        expect(result.weekNumber, weekNumber);

        // Should NOT upsert when note is null and no existing entry
        verifyNever(() => mockDao.upsertBumpPhoto(any()));
      });

      test('deletes entry when clearing note on note-only entry', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 12;
        final now = DateTime.now();

        final existingDto = BumpPhotoDto(
          id: 'note-only-id',
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: null, // Note-only entry
          note: 'Original note',
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => existingDto);

        when(() => mockDao.deleteBumpPhoto('note-only-id'))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.saveNoteOnly(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          note: null,
        );

        // Assert - entry deleted, returns tombstone with null note
        expect(result.note, isNull);
        verify(() => mockDao.deleteBumpPhoto('note-only-id')).called(1);
        verifyNever(() => mockDao.upsertBumpPhoto(any()));
      });

      test('keeps entry when clearing note on photo+note entry', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 12;
        final now = DateTime.now();

        final existingDto = BumpPhotoDto(
          id: 'photo-note-id',
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: '/path/12.jpg', // Has photo
          note: 'Original note',
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => existingDto);

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.saveNoteOnly(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          note: null,
        );

        // Assert - entry preserved with null note, photo kept
        expect(result.note, isNull);
        expect(result.filePath, '/path/12.jpg');
        verify(() => mockDao.upsertBumpPhoto(any())).called(1);
        verifyNever(() => mockDao.deleteBumpPhoto(any()));
      });
    });

    group('deleteBumpPhoto - note preservation', () {
      test('preserves note when deleting photo with note', () async {
        // Arrange
        const id = 'photo-123';
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final now = DateTime.now();

        final dto = BumpPhotoDto(
          id: id,
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: '/path/20.jpg',
          note: 'Important memory', // Has a note
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => dto);

        when(() => mockFileService.deletePhoto('/path/20.jpg'))
            .thenAnswer((_) async {});

        when(() => mockDao.updateBumpPhotoFields(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteBumpPhoto(id);

        // Assert - should update fields (set filePath to null), not delete
        verify(() => mockFileService.deletePhoto('/path/20.jpg')).called(1);
        verify(() => mockDao.updateBumpPhotoFields(id, any())).called(1);
        verifyNever(() => mockDao.deleteBumpPhoto(id)); // Should NOT delete
      });

      test('completely deletes record when photo has no note', () async {
        // Arrange
        const id = 'photo-123';
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final now = DateTime.now();

        final dto = BumpPhotoDto(
          id: id,
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: '/path/20.jpg',
          note: null, // No note
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => dto);

        when(() => mockFileService.deletePhoto('/path/20.jpg'))
            .thenAnswer((_) async {});

        when(() => mockDao.deleteBumpPhoto(id))
            .thenAnswer((_) async => 1);

        // Act
        await repository.deleteBumpPhoto(id);

        // Assert - should completely delete
        verify(() => mockFileService.deletePhoto('/path/20.jpg')).called(1);
        verify(() => mockDao.deleteBumpPhoto(id)).called(1);
        verifyNever(() => mockDao.updateBumpPhotoFields(any(), any()));
      });

      test('completely deletes record when note is empty string', () async {
        // Arrange
        const id = 'photo-123';
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final now = DateTime.now();

        final dto = BumpPhotoDto(
          id: id,
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: '/path/20.jpg',
          note: '', // Empty string note = effectively no note
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => dto);

        when(() => mockFileService.deletePhoto('/path/20.jpg'))
            .thenAnswer((_) async {});

        when(() => mockDao.deleteBumpPhoto(id))
            .thenAnswer((_) async => 1);

        // Act
        await repository.deleteBumpPhoto(id);

        // Assert - should completely delete (empty string = no note)
        verify(() => mockDao.deleteBumpPhoto(id)).called(1);
      });

      test('handles note-only entry (null filePath)', () async {
        // Arrange - entry with note but no photo
        const id = 'note-only-123';
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final now = DateTime.now();

        final dto = BumpPhotoDto(
          id: id,
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: null, // Note-only entry
          note: 'Just a note',
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhoto(id))
            .thenAnswer((_) async => dto);

        when(() => mockDao.updateBumpPhotoFields(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteBumpPhoto(id);

        // Assert - should NOT try to delete any file
        verifyNever(() => mockFileService.deletePhoto(any()));
        // Should preserve record since it has a note
        verify(() => mockDao.updateBumpPhotoFields(id, any())).called(1);
      });
    });

    group('File Cleanup Scenarios', () {
      test('deletes old file when replacing photo for same week', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final imageBytes = List<int>.filled(100, 0);
        const oldFilePath = '/old/path.jpg';
        const newFilePath = '/new/path.jpg';
        final now = DateTime.now();

        final existingDto = BumpPhotoDto(
          id: 'existing-id',
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: oldFilePath,
          note: null,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => existingDto);

        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).thenAnswer((_) async => newFilePath);

        when(() => mockFileService.deletePhoto(oldFilePath))
            .thenAnswer((_) async {});

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.saveBumpPhoto(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          imageBytes: imageBytes,
        );

        // Assert
        verify(() => mockFileService.deletePhoto(oldFilePath)).called(1);
        expect(result.filePath, newFilePath);
      });

      test('continues if old file already deleted', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final imageBytes = List<int>.filled(100, 0);
        const oldFilePath = '/old/path.jpg';
        const newFilePath = '/new/path.jpg';
        final now = DateTime.now();

        final existingDto = BumpPhotoDto(
          id: 'existing-id',
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: oldFilePath,
          note: null,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => existingDto);

        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).thenAnswer((_) async => newFilePath);

        when(() => mockFileService.deletePhoto(oldFilePath))
            .thenThrow(const PhotoFileException(oldFilePath, 'File not found'));

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenAnswer((_) async {});

        // Act - should not throw even though old file deletion fails
        final result = await repository.saveBumpPhoto(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          imageBytes: imageBytes,
        );

        // Assert
        expect(result.filePath, newFilePath);
        verify(() => mockDao.upsertBumpPhoto(any())).called(1);
      });

      test('does not delete file when path unchanged', () async {
        // Arrange
        const pregnancyId = 'pregnancy-123';
        const weekNumber = 20;
        final imageBytes = List<int>.filled(100, 0);
        const samePath = '/same/path.jpg';
        final now = DateTime.now();

        final existingDto = BumpPhotoDto(
          id: 'existing-id',
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          filePath: samePath,
          note: null,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        when(() => mockDao.getBumpPhotoByWeek(pregnancyId, weekNumber))
            .thenAnswer((_) async => existingDto);

        when(() => mockFileService.savePhoto(
              imageBytes: imageBytes,
              userId: testUserId,
              pregnancyId: pregnancyId,
              weekNumber: weekNumber,
            )).thenAnswer((_) async => samePath); // Same path returned

        when(() => mockDao.upsertBumpPhoto(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.saveBumpPhoto(
          pregnancyId: pregnancyId,
          weekNumber: weekNumber,
          imageBytes: imageBytes,
        );

        // Assert - should NOT delete since path is the same
        verifyNever(() => mockFileService.deletePhoto(any()));
      });
    });
  });
}
