/// Custom exception for when a file to be added already exists.
class DuplicateFileException implements Exception {
  final String message;

  DuplicateFileException(this.message);

  @override
  String toString() => 'DuplicateFileException: $message';
}

/// Custom exception for when file system operations fail due to permissions.
class FileSystemPermissionException implements Exception {
  final String message;
  final String? path;

  FileSystemPermissionException(this.message, {this.path});

  @override
  String toString() => 'FileSystemPermissionException: $message ${path != null ? "Path: $path" : ""}'.trim();
}

/// Custom exception for general file system errors not related to permissions.
class FileSystemOperationException implements Exception {
  final String message;
  final String? path;
  final Object? underlyingError;

  FileSystemOperationException(this.message, {this.path, this.underlyingError});

  @override
  String toString() {
    String result = 'FileSystemOperationException: $message';
    if (path != null) result += ' Path: $path';
    if (underlyingError != null) result += ' Underlying error: ${underlyingError.toString()}';
    return result.trim();
  }
} 