import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/bump_photo/bump_photo_constants.dart';

void main() {
  group('BumpPhotoConstants', () {
    test('has correct week range', () {
      expect(BumpPhotoConstants.minWeek, 1);
      expect(BumpPhotoConstants.maxWeek, 44);
    });

    test('has correct image constraints', () {
      expect(BumpPhotoConstants.maxImageWidth, 1920);
      expect(BumpPhotoConstants.jpegQuality, 85);
      expect(BumpPhotoConstants.maxFileSizeBytes, 5 * 1024 * 1024);
      expect(BumpPhotoConstants.imageExtension, 'jpg');
    });

    group('isValidWeek', () {
      test('returns true for valid weeks', () {
        expect(BumpPhotoConstants.isValidWeek(1), isTrue);
        expect(BumpPhotoConstants.isValidWeek(20), isTrue);
        expect(BumpPhotoConstants.isValidWeek(44), isTrue);
      });

      test('returns false for invalid weeks', () {
        expect(BumpPhotoConstants.isValidWeek(0), isFalse);
        expect(BumpPhotoConstants.isValidWeek(-1), isFalse);
        expect(BumpPhotoConstants.isValidWeek(45), isFalse);
        expect(BumpPhotoConstants.isValidWeek(100), isFalse);
      });
    });

    test('getInvalidWeekMessage returns correct message', () {
      final message = BumpPhotoConstants.getInvalidWeekMessage(50);
      expect(message, contains('1'));
      expect(message, contains('44'));
      expect(message, contains('50'));
    });
  });
}
