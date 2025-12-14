import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/bump_photo/bump_photo.dart';

void main() {
  group('BumpPhoto', () {
    final now = DateTime(2024, 1, 15);

    test('creates with all required fields', () {
      final photo = BumpPhoto(
        id: 'test-id',
        pregnancyId: 'pregnancy-id',
        weekNumber: 20,
        filePath: '/path/to/photo.jpg',
        note: 'Feeling great!',
        photoDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(photo.id, 'test-id');
      expect(photo.pregnancyId, 'pregnancy-id');
      expect(photo.weekNumber, 20);
      expect(photo.filePath, '/path/to/photo.jpg');
      expect(photo.note, 'Feeling great!');
      expect(photo.photoDate, now);
      expect(photo.createdAt, now);
      expect(photo.updatedAt, now);
    });

    test('creates with null note', () {
      final photo = BumpPhoto(
        id: 'test-id',
        pregnancyId: 'pregnancy-id',
        weekNumber: 20,
        filePath: '/path/to/photo.jpg',
        photoDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(photo.note, isNull);
    });

    test('copyWith creates correct copy', () {
      final original = BumpPhoto(
        id: 'test-id',
        pregnancyId: 'pregnancy-id',
        weekNumber: 20,
        filePath: '/path/to/photo.jpg',
        photoDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(
        note: 'New note',
        weekNumber: 21,
      );

      expect(copy.id, original.id);
      expect(copy.pregnancyId, original.pregnancyId);
      expect(copy.weekNumber, 21);
      expect(copy.note, 'New note');
      expect(copy.filePath, original.filePath);
    });

    test('equality is based on id', () {
      final photo1 = BumpPhoto(
        id: 'same-id',
        pregnancyId: 'pregnancy-id',
        weekNumber: 20,
        filePath: '/path1.jpg',
        photoDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final photo2 = BumpPhoto(
        id: 'same-id',
        pregnancyId: 'pregnancy-id',
        weekNumber: 21,
        filePath: '/path2.jpg',
        photoDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(photo1, equals(photo2));
      expect(photo1.hashCode, equals(photo2.hashCode));
    });

    test('different ids are not equal', () {
      final photo1 = BumpPhoto(
        id: 'id-1',
        pregnancyId: 'pregnancy-id',
        weekNumber: 20,
        filePath: '/path.jpg',
        photoDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final photo2 = BumpPhoto(
        id: 'id-2',
        pregnancyId: 'pregnancy-id',
        weekNumber: 20,
        filePath: '/path.jpg',
        photoDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(photo1, isNot(equals(photo2)));
    });

    test('toString includes key info', () {
      final photo = BumpPhoto(
        id: 'test-id',
        pregnancyId: 'pregnancy-id',
        weekNumber: 20,
        filePath: '/path/to/photo.jpg',
        photoDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final str = photo.toString();
      expect(str, contains('test-id'));
      expect(str, contains('pregnancy-id'));
      expect(str, contains('20'));
    });
  });
}
