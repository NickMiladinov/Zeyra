@Tags(['bump_photo'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/exceptions/bump_photo_exception.dart';

void main() {
  group('BumpPhotoException', () {
    group('Base BumpPhotoException', () {
      test('creates with message', () {
        const exception = BumpPhotoException('Test error message');

        expect(exception.message, 'Test error message');
        expect(exception.originalError, isNull);
        expect(exception.stackTrace, isNull);
      });

      test('creates with originalError and stackTrace', () {
        final originalError = Exception('Original error');
        final stackTrace = StackTrace.current;

        final exception = BumpPhotoException(
          'Wrapped error',
          originalError: originalError,
          stackTrace: stackTrace,
        );

        expect(exception.message, 'Wrapped error');
        expect(exception.originalError, originalError);
        expect(exception.stackTrace, stackTrace);
      });

      test('has correct toString output', () {
        const exception = BumpPhotoException('Test error');

        expect(exception.toString(), 'BumpPhotoException: Test error');
      });
    });

    group('InvalidWeekException', () {
      test('creates with week number and message', () {
        const exception = InvalidWeekException(50, 'Week 50 is out of range');

        expect(exception.weekNumber, 50);
        expect(exception.message, 'Week 50 is out of range');
      });

      test('has correct toString output', () {
        const exception = InvalidWeekException(0, 'Week must be 1-42');

        final str = exception.toString();
        expect(str, contains('InvalidWeekException'));
        expect(str, contains('0'));
        expect(str, contains('Week must be 1-42'));
      });

      test('is a BumpPhotoException', () {
        const exception = InvalidWeekException(50, 'Invalid week');

        expect(exception, isA<BumpPhotoException>());
        expect(exception, isA<Exception>());
      });
    });

    group('PhotoFileException', () {
      test('creates with filePath and message', () {
        const exception = PhotoFileException('/path/to/photo.jpg', 'File not found');

        expect(exception.filePath, '/path/to/photo.jpg');
        expect(exception.message, 'File not found');
      });

      test('creates with originalError', () {
        final originalError = Exception('IO error');
        final stackTrace = StackTrace.current;

        final exception = PhotoFileException(
          '/path/to/photo.jpg',
          'Failed to save file',
          originalError: originalError,
          stackTrace: stackTrace,
        );

        expect(exception.originalError, originalError);
        expect(exception.stackTrace, stackTrace);
      });

      test('has correct toString output', () {
        const exception = PhotoFileException('/path/photo.jpg', 'Write failed');

        final str = exception.toString();
        expect(str, contains('PhotoFileException'));
        expect(str, contains('/path/photo.jpg'));
        expect(str, contains('Write failed'));
      });

      test('is a BumpPhotoException', () {
        const exception = PhotoFileException('/path/photo.jpg', 'Error');

        expect(exception, isA<BumpPhotoException>());
        expect(exception, isA<Exception>());
      });
    });

    group('PhotoNotFoundException', () {
      test('creates with message only', () {
        const exception = PhotoNotFoundException('Photo not found');

        expect(exception.message, 'Photo not found');
        expect(exception.pregnancyId, isNull);
        expect(exception.weekNumber, isNull);
      });

      test('creates with pregnancyId and weekNumber', () {
        const exception = PhotoNotFoundException(
          'Photo not found',
          pregnancyId: 'pregnancy-123',
          weekNumber: 20,
        );

        expect(exception.pregnancyId, 'pregnancy-123');
        expect(exception.weekNumber, 20);
      });

      test('has correct toString with details', () {
        const exception = PhotoNotFoundException(
          'Photo not found',
          pregnancyId: 'preg-456',
          weekNumber: 15,
        );

        final str = exception.toString();
        expect(str, contains('PhotoNotFoundException'));
        expect(str, contains('Photo not found'));
        expect(str, contains('preg-456'));
        expect(str, contains('15'));
      });

      test('is a BumpPhotoException', () {
        const exception = PhotoNotFoundException('Not found');

        expect(exception, isA<BumpPhotoException>());
        expect(exception, isA<Exception>());
      });
    });

    group('ImageTooLargeException and ImageProcessingException', () {
      test('ImageTooLargeException creates with sizes', () {
        const exception = ImageTooLargeException(
          10 * 1024 * 1024, // 10MB
          5 * 1024 * 1024,  // 5MB max
          'Image exceeds maximum size',
        );

        expect(exception.actualSize, 10 * 1024 * 1024);
        expect(exception.maxSize, 5 * 1024 * 1024);
        expect(exception.message, 'Image exceeds maximum size');
      });

      test('ImageTooLargeException has correct toString', () {
        const exception = ImageTooLargeException(
          10485760, // 10MB
          5242880,  // 5MB
          'Image too large',
        );

        final str = exception.toString();
        expect(str, contains('ImageTooLargeException'));
        expect(str, contains('10485760'));
        expect(str, contains('5242880'));
      });

      test('ImageProcessingException creates with message', () {
        const exception = ImageProcessingException('Failed to decode image');

        expect(exception.message, 'Failed to decode image');
        expect(exception, isA<BumpPhotoException>());
      });

      test('ImageProcessingException wraps original error', () {
        final originalError = Exception('Codec error');
        final stackTrace = StackTrace.current;

        final exception = ImageProcessingException(
          'Image processing failed',
          originalError: originalError,
          stackTrace: stackTrace,
        );

        expect(exception.originalError, originalError);
        expect(exception.stackTrace, stackTrace);
        expect(exception.toString(), contains('ImageProcessingException'));
      });
    });
  });
}
