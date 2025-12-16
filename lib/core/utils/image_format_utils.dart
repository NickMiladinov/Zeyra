import 'dart:typed_data';

/// Utility for image format validation and detection.
///
/// Supports common image formats that work well with the `image` package:
/// - JPEG/JPG (most common, compressed)
/// - PNG (lossless, transparency support)
/// - WebP (modern format, good compression)
/// - BMP (basic bitmap)
/// - GIF (animated support)
class ImageFormatUtils {
  /// List of supported image format extensions
  static const List<String> supportedFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
    'gif',
  ];

  /// List of supported MIME types
  static const List<String> supportedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/bmp',
    'image/gif',
  ];

  /// Validate if a file extension is supported
  ///
  /// [extension] - File extension (with or without dot)
  ///
  /// Returns true if the format is supported
  static bool isFormatSupported(String extension) {
    final cleanExt = extension.toLowerCase().replaceAll('.', '');
    return supportedFormats.contains(cleanExt);
  }

  /// Validate if a MIME type is supported
  ///
  /// [mimeType] - MIME type string (e.g., 'image/jpeg')
  ///
  /// Returns true if the MIME type is supported
  static bool isMimeTypeSupported(String mimeType) {
    return supportedMimeTypes.contains(mimeType.toLowerCase());
  }

  /// Detect image format from file extension
  ///
  /// [fileName] - File name or path
  ///
  /// Returns the detected format or null if unsupported
  static String? detectFormatFromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return isFormatSupported(extension) ? extension : null;
  }

  /// Detect image format from raw bytes by reading file signature (magic numbers)
  ///
  /// [bytes] - Image data bytes
  ///
  /// Returns the detected format or null if unrecognized
  static String? detectFormatFromBytes(Uint8List bytes) {
    if (bytes.length < 4) return null;

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'jpeg';
    }

    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }

    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return 'gif';
    }

    // BMP: 42 4D
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return 'bmp';
    }

    // WebP: RIFF...WEBP (check for RIFF at start and WEBP at byte 8)
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'webp';
    }

    return null;
  }

  /// Validate image bytes against supported formats
  ///
  /// [bytes] - Image data bytes
  ///
  /// Returns true if the image format is supported
  /// Throws [UnsupportedImageFormatException] if format is not supported
  static bool validateImageBytes(Uint8List bytes) {
    final format = detectFormatFromBytes(bytes);
    if (format == null || !isFormatSupported(format)) {
      return false;
    }
    return true;
  }

  /// Get a user-friendly error message for unsupported formats
  static String getUnsupportedFormatMessage(String? detectedFormat) {
    if (detectedFormat == null) {
      return 'Unable to detect image format. Please select a valid image file.';
    }
    return 'The format "$detectedFormat" is not supported. '
        'Please use: ${supportedFormats.join(', ').toUpperCase()}';
  }

  /// Get supported formats as a formatted string for display
  static String getSupportedFormatsDisplay() {
    return supportedFormats.map((f) => f.toUpperCase()).join(', ');
  }
}

