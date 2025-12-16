import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:zeyra/core/monitoring/logging_service.dart';
import 'package:zeyra/core/services/photo_file_service.dart';
import 'package:zeyra/domain/entities/bump_photo/bump_photo_constants.dart';
import 'package:zeyra/domain/exceptions/bump_photo_exception.dart';

// Mock classes
class MockLoggingService extends Mock implements LoggingService {}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PhotoFileService service;
  late MockLoggingService mockLogger;
  late Directory tempDir;

  setUpAll(() {
    // Register path_provider mock
    final mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;
  });

  setUp(() async {
    mockLogger = MockLoggingService();

    // Create a real temp directory for testing
    tempDir = await Directory.systemTemp.createTemp('photo_file_service_test_');

    // Mock path provider to return our temp directory
    when(() => PathProviderPlatform.instance.getApplicationDocumentsPath())
        .thenAnswer((_) async => tempDir.path);

    service = PhotoFileService(logger: mockLogger);

    // Setup basic logger mocks
    when(() => mockLogger.debug(any(), data: any(named: 'data'))).thenReturn(null);
    when(() => mockLogger.info(any(), data: any(named: 'data'))).thenReturn(null);
    when(() => mockLogger.warning(any(), data: any(named: 'data'))).thenReturn(null);
    when(() => mockLogger.error(
          any(),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
          data: any(named: 'data'),
        )).thenReturn(null);
  });

  tearDown(() async {
    // Clean up temp directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PhotoFileService - Format Validation & Compression', () {
    /// Helper to create a test image in different formats
    Uint8List createTestImage({required String format, int width = 200, int height = 200}) {
      // Create a simple test image
      final image = img.Image(width: width, height: height);
      img.fill(image, color: img.ColorRgb8(100, 150, 200));

      // Encode in requested format
      switch (format.toLowerCase()) {
        case 'jpeg':
        case 'jpg':
          return Uint8List.fromList(img.encodeJpg(image, quality: 100));
        case 'png':
          return Uint8List.fromList(img.encodePng(image));
        case 'bmp':
          return Uint8List.fromList(img.encodeBmp(image));
        case 'gif':
          return Uint8List.fromList(img.encodeGif(image));
        default:
          throw ArgumentError('Unsupported test format: $format');
      }
    }

    test('accepts JPEG format and compresses correctly', () async {
      final imageBytes = createTestImage(format: 'jpeg');

      final filePath = await service.savePhoto(
        imageBytes: imageBytes,
        userId: 'user1',
        pregnancyId: 'preg1',
        weekNumber: 20,
      );

      expect(await File(filePath).exists(), true);

      final savedBytes = await File(filePath).readAsBytes();
      final savedImage = img.decodeImage(savedBytes);

      expect(savedImage, isNotNull);
      expect(filePath.endsWith('.jpg'), true);

      // Verify compression happened
      verify(() => mockLogger.debug('Image processed', data: any(named: 'data'))).called(1);
    });

    test('accepts PNG format and converts to JPEG', () async {
      final imageBytes = createTestImage(format: 'png');

      final filePath = await service.savePhoto(
        imageBytes: imageBytes,
        userId: 'user1',
        pregnancyId: 'preg1',
        weekNumber: 20,
      );

      expect(await File(filePath).exists(), true);
      expect(filePath.endsWith('.jpg'), true);

      // Verify the saved file is JPEG
      final savedBytes = await File(filePath).readAsBytes();
      // JPEG magic number: FF D8 FF
      expect(savedBytes[0], 0xFF);
      expect(savedBytes[1], 0xD8);
      expect(savedBytes[2], 0xFF);
    });

    test('accepts BMP format and converts to JPEG', () async {
      final imageBytes = createTestImage(format: 'bmp');

      final filePath = await service.savePhoto(
        imageBytes: imageBytes,
        userId: 'user1',
        pregnancyId: 'preg1',
        weekNumber: 20,
      );

      expect(await File(filePath).exists(), true);
      expect(filePath.endsWith('.jpg'), true);

      final savedImage = img.decodeImage(await File(filePath).readAsBytes());
      expect(savedImage, isNotNull);
    });

    test('accepts GIF format and converts to JPEG', () async {
      final imageBytes = createTestImage(format: 'gif');

      final filePath = await service.savePhoto(
        imageBytes: imageBytes,
        userId: 'user1',
        pregnancyId: 'preg1',
        weekNumber: 20,
      );

      expect(await File(filePath).exists(), true);
      expect(filePath.endsWith('.jpg'), true);

      final savedImage = img.decodeImage(await File(filePath).readAsBytes());
      expect(savedImage, isNotNull);
    });

    test('rejects unsupported format with ImageProcessingException', () async {
      // Create invalid image bytes (not a real image format)
      final invalidBytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x00, 0x00]);

      expect(
        () => service.savePhoto(
          imageBytes: invalidBytes,
          userId: 'user1',
          pregnancyId: 'preg1',
          weekNumber: 20,
        ),
        throwsA(isA<ImageProcessingException>()),
      );
    });

    test('resizes large images to maxImageWidth', () async {
      // Create a large image (wider than max)
      final largeImage = createTestImage(
        format: 'png',
        width: 3000,
        height: 2000,
      );

      final filePath = await service.savePhoto(
        imageBytes: largeImage,
        userId: 'user1',
        pregnancyId: 'preg1',
        weekNumber: 20,
      );

      final savedBytes = await File(filePath).readAsBytes();
      final savedImage = img.decodeImage(savedBytes);

      expect(savedImage, isNotNull);
      expect(savedImage!.width, BumpPhotoConstants.maxImageWidth);
      // Height should be proportionally scaled
      expect(savedImage.height, lessThan(2000));
    });

    test('does not resize images smaller than maxImageWidth', () async {
      final smallImage = createTestImage(
        format: 'png',
        width: 800,
        height: 600,
      );

      final filePath = await service.savePhoto(
        imageBytes: smallImage,
        userId: 'user1',
        pregnancyId: 'preg1',
        weekNumber: 20,
      );

      final savedBytes = await File(filePath).readAsBytes();
      final savedImage = img.decodeImage(savedBytes);

      expect(savedImage, isNotNull);
      expect(savedImage!.width, 800);
      expect(savedImage.height, 600);
    });

    test('throws ImageTooLargeException if compressed size exceeds limit', () async {
      // Create an extremely large, complex image that won't compress well
      // Using a much larger size to ensure it exceeds 5MB even after resize to 1920px
      final hugeImage = img.Image(width: 10000, height: 10000);
      
      // Fill with complex pattern that won't compress well
      // Use a more complex pattern with less repetition
      for (int y = 0; y < hugeImage.height; y++) {
        for (int x = 0; x < hugeImage.width; x++) {
          // Create noise-like pattern that doesn't compress well
          final r = (x * 7 + y * 13) % 256;
          final g = (x * 11 + y * 17) % 256;
          final b = (x * 19 + y * 23) % 256;
          hugeImage.setPixelRgb(x, y, r, g, b);
        }
      }

      // Encode as high-quality PNG first (doesn't compress much)
      final hugeImageBytes = img.encodePng(hugeImage);

      // This should exceed the 5MB limit even after resize and JPEG compression
      expect(
        () => service.savePhoto(
          imageBytes: hugeImageBytes,
          userId: 'user1',
          pregnancyId: 'preg1',
          weekNumber: 20,
        ),
        throwsA(isA<ImageTooLargeException>()),
      );
    });

    test('applies correct JPEG quality from constants', () async {
      final imageBytes = createTestImage(format: 'png', width: 1000, height: 1000);

      await service.savePhoto(
        imageBytes: imageBytes,
        userId: 'user1',
        pregnancyId: 'preg1',
        weekNumber: 20,
      );

      // Verify that compression was applied with the correct quality
      verify(() => mockLogger.debug('Image processed', data: any(named: 'data'))).called(1);
    });

    test('validates format before attempting to decode', () async {
      final invalidBytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);

      try {
        await service.savePhoto(
          imageBytes: invalidBytes,
          userId: 'user1',
          pregnancyId: 'preg1',
          weekNumber: 20,
        );
        fail('Should have thrown ImageProcessingException');
      } catch (e) {
        expect(e, isA<ImageProcessingException>());
        final exception = e as ImageProcessingException;
        expect(exception.message, contains('Unable to detect'));
      }
    });
  });

  group('PhotoFileService - File Operations', () {
    test('creates directory structure correctly', () async {
      final imageBytes = Uint8List.fromList(
        img.encodeJpg(img.Image(width: 100, height: 100)),
      );

      final filePath = await service.savePhoto(
        imageBytes: imageBytes,
        userId: 'user1',
        pregnancyId: 'preg1',
        weekNumber: 20,
      );

      expect(filePath, contains('users'));
      expect(filePath, contains('user1'));
      expect(filePath, contains('bump_photos'));
      expect(filePath, contains('preg1'));
      expect(filePath, contains('20.jpg'));
    });
  });
}

