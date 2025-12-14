@Tags(['bump_photo'])
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await database.close();
  });

  group('[BumpPhoto] BumpPhotoDao', () {
    final now = DateTime.now();

    BumpPhotoDto createTestPhoto({
      String? id,
      String? pregnancyId,
      int? weekNumber,
      String? note,
    }) {
      return BumpPhotoDto(
        id: id ?? 'test-photo-id',
        pregnancyId: pregnancyId ?? 'test-pregnancy-id',
        weekNumber: weekNumber ?? 20,
        filePath: '/test/path/${weekNumber ?? 20}.jpg',
        note: note,
        photoDateMillis: now.millisecondsSinceEpoch,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );
    }

    group('insertBumpPhoto', () {
      test('creates record successfully', () async {
        // Arrange
        final photo = createTestPhoto();

        // Act
        await database.bumpPhotoDao.insertBumpPhoto(photo);

        // Assert
        final result = await database.bumpPhotoDao.getBumpPhoto(photo.id);
        expect(result, isNotNull);
        expect(result!.id, photo.id);
        expect(result.weekNumber, photo.weekNumber);
      });

      test('throws on duplicate (pregnancyId, weekNumber)', () async {
        // Arrange
        final photo1 = createTestPhoto(id: 'photo-1', weekNumber: 20);
        final photo2 = createTestPhoto(id: 'photo-2', weekNumber: 20); // Same week

        // Act
        await database.bumpPhotoDao.insertBumpPhoto(photo1);

        // Assert
        expect(
          () => database.bumpPhotoDao.insertBumpPhoto(photo2),
          throwsA(isA<SqliteException>()),
        );
      });
    });

    group('getBumpPhotoByWeek', () {
      test('returns correct photo', () async {
        // Arrange
        final photo = createTestPhoto(weekNumber: 25);
        await database.bumpPhotoDao.insertBumpPhoto(photo);

        // Act
        final result = await database.bumpPhotoDao.getBumpPhotoByWeek('test-pregnancy-id', 25);

        // Assert
        expect(result, isNotNull);
        expect(result!.weekNumber, 25);
      });

      test('returns null for non-existent week', () async {
        // Act
        final result = await database.bumpPhotoDao.getBumpPhotoByWeek('test-pregnancy-id', 30);

        // Assert
        expect(result, isNull);
      });
    });

    group('getBumpPhotosForPregnancy', () {
      test('returns all photos for pregnancy', () async {
        // Arrange
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p1', weekNumber: 20));
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p2', weekNumber: 25));
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p3', weekNumber: 30));

        // Act
        final result = await database.bumpPhotoDao.getBumpPhotosForPregnancy('test-pregnancy-id');

        // Assert
        expect(result.length, 3);
      });

      test('returns photos sorted by weekNumber ascending', () async {
        // Arrange
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p1', weekNumber: 30));
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p2', weekNumber: 10));
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p3', weekNumber: 20));

        // Act
        final result = await database.bumpPhotoDao.getBumpPhotosForPregnancy('test-pregnancy-id');

        // Assert
        expect(result[0].weekNumber, 10);
        expect(result[1].weekNumber, 20);
        expect(result[2].weekNumber, 30);
      });

      test('returns empty list when no photos exist', () async {
        // Act
        final result = await database.bumpPhotoDao.getBumpPhotosForPregnancy('test-pregnancy-id');

        // Assert
        expect(result, isEmpty);
      });

      test('filters by pregnancyId correctly', () async {
        // Arrange
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p1', pregnancyId: 'preg-1', weekNumber: 20));
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p2', pregnancyId: 'preg-2', weekNumber: 20));

        // Act
        final result = await database.bumpPhotoDao.getBumpPhotosForPregnancy('preg-1');

        // Assert
        expect(result.length, 1);
        expect(result[0].pregnancyId, 'preg-1');
      });
    });

    group('updateBumpPhoto', () {
      test('modifies existing record', () async {
        // Arrange
        final original = createTestPhoto();
        await database.bumpPhotoDao.insertBumpPhoto(original);

        final updated = BumpPhotoDto(
          id: original.id,
          pregnancyId: original.pregnancyId,
          weekNumber: original.weekNumber,
          filePath: original.filePath,
          note: 'Updated note',
          photoDateMillis: original.photoDateMillis,
          createdAtMillis: original.createdAtMillis,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );

        // Act
        await database.bumpPhotoDao.updateBumpPhoto(updated);

        // Assert
        final result = await database.bumpPhotoDao.getBumpPhoto(original.id);
        expect(result!.note, 'Updated note');
      });
    });

    group('upsertBumpPhoto', () {
      test('inserts new photo', () async {
        // Arrange
        final photo = createTestPhoto();

        // Act
        await database.bumpPhotoDao.upsertBumpPhoto(photo);

        // Assert
        final result = await database.bumpPhotoDao.getBumpPhoto(photo.id);
        expect(result, isNotNull);
      });

      test('updates existing photo with same id', () async {
        // Arrange
        final photo1 = createTestPhoto(
          id: 'photo-1',
          weekNumber: 20,
          note: 'Original note',
        );
        await database.bumpPhotoDao.insertBumpPhoto(photo1);

        // Create updated version with same id
        final photo2 = createTestPhoto(
          id: 'photo-1', // Same id
          weekNumber: 20,
          note: 'Updated note',
        );

        // Act
        await database.bumpPhotoDao.upsertBumpPhoto(photo2);

        // Assert
        final result = await database.bumpPhotoDao.getBumpPhoto('photo-1');
        expect(result, isNotNull);
        expect(result!.note, 'Updated note');

        // Should still be only one photo
        final allPhotos = await database.bumpPhotoDao.getBumpPhotosForPregnancy('test-pregnancy-id');
        expect(allPhotos.length, 1);
      });
    });

    group('deleteBumpPhoto', () {
      test('removes record', () async {
        // Arrange
        final photo = createTestPhoto();
        await database.bumpPhotoDao.insertBumpPhoto(photo);

        // Act
        await database.bumpPhotoDao.deleteBumpPhoto(photo.id);

        // Assert
        final result = await database.bumpPhotoDao.getBumpPhoto(photo.id);
        expect(result, isNull);
      });

      test('does nothing for non-existent photo', () async {
        // Act & Assert - should not throw
        await expectLater(
          database.bumpPhotoDao.deleteBumpPhoto('non-existent'),
          completes,
        );
      });
    });

    group('deleteAllForPregnancy', () {
      test('removes all photos for pregnancy', () async {
        // Arrange
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p1', weekNumber: 20));
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p2', weekNumber: 25));
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p3', weekNumber: 30));

        // Act
        final deletedCount = await database.bumpPhotoDao.deleteAllForPregnancy('test-pregnancy-id');

        // Assert
        expect(deletedCount, 3);
        final result = await database.bumpPhotoDao.getBumpPhotosForPregnancy('test-pregnancy-id');
        expect(result, isEmpty);
      });

      test('returns 0 when no photos exist', () async {
        // Act
        final deletedCount = await database.bumpPhotoDao.deleteAllForPregnancy('test-pregnancy-id');

        // Assert
        expect(deletedCount, 0);
      });
    });

    group('getBumpPhotoCount', () {
      test('returns correct count', () async {
        // Arrange
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p1', weekNumber: 20));
        await database.bumpPhotoDao.insertBumpPhoto(createTestPhoto(id: 'p2', weekNumber: 25));

        // Act
        final count = await database.bumpPhotoDao.getBumpPhotoCount('test-pregnancy-id');

        // Assert
        expect(count, 2);
      });

      test('returns 0 when no photos exist', () async {
        // Act
        final count = await database.bumpPhotoDao.getBumpPhotoCount('test-pregnancy-id');

        // Assert
        expect(count, 0);
      });
    });
  });
}
