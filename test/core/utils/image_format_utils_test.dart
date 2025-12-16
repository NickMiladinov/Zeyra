import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/core/utils/image_format_utils.dart';

void main() {
  group('ImageFormatUtils', () {
    group('isFormatSupported', () {
      test('returns true for supported formats', () {
        expect(ImageFormatUtils.isFormatSupported('jpg'), true);
        expect(ImageFormatUtils.isFormatSupported('jpeg'), true);
        expect(ImageFormatUtils.isFormatSupported('png'), true);
        expect(ImageFormatUtils.isFormatSupported('webp'), true);
        expect(ImageFormatUtils.isFormatSupported('bmp'), true);
        expect(ImageFormatUtils.isFormatSupported('gif'), true);
      });

      test('returns true for formats with dots', () {
        expect(ImageFormatUtils.isFormatSupported('.jpg'), true);
        expect(ImageFormatUtils.isFormatSupported('.png'), true);
      });

      test('is case insensitive', () {
        expect(ImageFormatUtils.isFormatSupported('JPG'), true);
        expect(ImageFormatUtils.isFormatSupported('PNG'), true);
        expect(ImageFormatUtils.isFormatSupported('JPEG'), true);
      });

      test('returns false for unsupported formats', () {
        expect(ImageFormatUtils.isFormatSupported('tiff'), false);
        expect(ImageFormatUtils.isFormatSupported('pdf'), false);
        expect(ImageFormatUtils.isFormatSupported('doc'), false);
        expect(ImageFormatUtils.isFormatSupported('heic'), false);
      });
    });

    group('isMimeTypeSupported', () {
      test('returns true for supported MIME types', () {
        expect(ImageFormatUtils.isMimeTypeSupported('image/jpeg'), true);
        expect(ImageFormatUtils.isMimeTypeSupported('image/jpg'), true);
        expect(ImageFormatUtils.isMimeTypeSupported('image/png'), true);
        expect(ImageFormatUtils.isMimeTypeSupported('image/webp'), true);
        expect(ImageFormatUtils.isMimeTypeSupported('image/bmp'), true);
        expect(ImageFormatUtils.isMimeTypeSupported('image/gif'), true);
      });

      test('is case insensitive', () {
        expect(ImageFormatUtils.isMimeTypeSupported('IMAGE/JPEG'), true);
        expect(ImageFormatUtils.isMimeTypeSupported('Image/Png'), true);
      });

      test('returns false for unsupported MIME types', () {
        expect(ImageFormatUtils.isMimeTypeSupported('image/tiff'), false);
        expect(ImageFormatUtils.isMimeTypeSupported('application/pdf'), false);
        expect(ImageFormatUtils.isMimeTypeSupported('text/plain'), false);
      });
    });

    group('detectFormatFromFileName', () {
      test('detects format from file name', () {
        expect(ImageFormatUtils.detectFormatFromFileName('photo.jpg'), 'jpg');
        expect(ImageFormatUtils.detectFormatFromFileName('image.png'), 'png');
        expect(ImageFormatUtils.detectFormatFromFileName('pic.webp'), 'webp');
      });

      test('detects format from full path', () {
        expect(
          ImageFormatUtils.detectFormatFromFileName('/path/to/photo.jpg'),
          'jpg',
        );
        expect(
          ImageFormatUtils.detectFormatFromFileName('C:\\Users\\photo.png'),
          'png',
        );
      });

      test('returns null for unsupported formats', () {
        expect(ImageFormatUtils.detectFormatFromFileName('doc.pdf'), null);
        expect(ImageFormatUtils.detectFormatFromFileName('photo.heic'), null);
      });

      test('is case insensitive', () {
        expect(ImageFormatUtils.detectFormatFromFileName('photo.JPG'), 'jpg');
        expect(ImageFormatUtils.detectFormatFromFileName('image.PNG'), 'png');
      });
    });

    group('detectFormatFromBytes', () {
      test('detects JPEG format', () {
        // JPEG magic number: FF D8 FF
        final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
        expect(ImageFormatUtils.detectFormatFromBytes(jpegBytes), 'jpeg');
      });

      test('detects PNG format', () {
        // PNG magic number: 89 50 4E 47
        final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]);
        expect(ImageFormatUtils.detectFormatFromBytes(pngBytes), 'png');
      });

      test('detects GIF format', () {
        // GIF magic number: 47 49 46 38
        final gifBytes = Uint8List.fromList([0x47, 0x49, 0x46, 0x38, 0x39, 0x61]);
        expect(ImageFormatUtils.detectFormatFromBytes(gifBytes), 'gif');
      });

      test('detects BMP format', () {
        // BMP magic number: 42 4D
        final bmpBytes = Uint8List.fromList([0x42, 0x4D, 0x00, 0x00]);
        expect(ImageFormatUtils.detectFormatFromBytes(bmpBytes), 'bmp');
      });

      test('detects WebP format', () {
        // WebP: RIFF + WEBP at byte 8
        final webpBytes = Uint8List.fromList([
          0x52, 0x49, 0x46, 0x46, // RIFF
          0x00, 0x00, 0x00, 0x00,
          0x57, 0x45, 0x42, 0x50, // WEBP
        ]);
        expect(ImageFormatUtils.detectFormatFromBytes(webpBytes), 'webp');
      });

      test('returns null for unrecognized format', () {
        final unknownBytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);
        expect(ImageFormatUtils.detectFormatFromBytes(unknownBytes), null);
      });

      test('returns null for too few bytes', () {
        final shortBytes = Uint8List.fromList([0xFF, 0xD8]);
        expect(ImageFormatUtils.detectFormatFromBytes(shortBytes), null);
      });
    });

    group('validateImageBytes', () {
      test('returns true for valid JPEG', () {
        final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
        expect(ImageFormatUtils.validateImageBytes(jpegBytes), true);
      });

      test('returns true for valid PNG', () {
        final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]);
        expect(ImageFormatUtils.validateImageBytes(pngBytes), true);
      });

      test('returns false for invalid format', () {
        final invalidBytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);
        expect(ImageFormatUtils.validateImageBytes(invalidBytes), false);
      });
    });

    group('getUnsupportedFormatMessage', () {
      test('returns generic message for null format', () {
        final message = ImageFormatUtils.getUnsupportedFormatMessage(null);
        expect(message, contains('Unable to detect'));
      });

      test('returns specific message for unsupported format', () {
        final message = ImageFormatUtils.getUnsupportedFormatMessage('tiff');
        expect(message, contains('tiff'));
        expect(message, contains('not supported'));
      });
    });

    group('getSupportedFormatsDisplay', () {
      test('returns formatted list of supported formats', () {
        final display = ImageFormatUtils.getSupportedFormatsDisplay();
        expect(display, contains('JPG'));
        expect(display, contains('JPEG'));
        expect(display, contains('PNG'));
        expect(display, contains('WEBP'));
        expect(display, contains('BMP'));
        expect(display, contains('GIF'));
      });
    });
  });
}

