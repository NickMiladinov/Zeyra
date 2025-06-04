import 'dart:io';
import 'dart:typed_data';

/// Abstract class defining the contract for file system operations.
/// This allows for swapping out implementations, e.g., for testing.
abstract class FileSystemOperations {
  /// Checks if a file exists at the given [path].
  Future<bool> fileExists(String path);

  /// Reads the entire file contents as a list of bytes from the given [path].
  Future<Uint8List> readFileAsBytes(String path);

  /// Writes the given [bytes] to a file at the specified [path].
  /// If [flush] is true, the data will be flushed to the disk immediately.
  Future<void> writeFileAsBytes(String path, Uint8List bytes, {bool flush = false});

  /// Checks if a directory exists at the given [path].
  Future<bool> directoryExists(String path);

  /// Creates a directory at the given [path].
  /// If [recursive] is true, it also creates all non-existing parent directories.
  /// Returns a [Directory] object representing the created directory.
  Future<Directory> createDirectory(String path, {bool recursive = false});

  /// Deletes the file at the given [path].
  /// If the file does not exist, the operation should complete without error.
  /// If [recursive] is true and the path is a directory, its contents will be deleted.
  /// However, for this abstraction, we'll assume it's for files primarily.
  /// For directory deletion, a separate method or clear intent would be better.
  Future<void> deleteFile(String path);
}

/// Default implementation of [FileSystemOperations] using `dart:io`.
class DefaultFileSystemOperations implements FileSystemOperations {
  const DefaultFileSystemOperations();

  @override
  Future<bool> fileExists(String path) {
    return File(path).exists();
  }

  @override
  Future<Uint8List> readFileAsBytes(String path) {
    return File(path).readAsBytes();
  }

  @override
  Future<void> writeFileAsBytes(String path, Uint8List bytes, {bool flush = false}) async {
    // File(path).writeAsBytes returns a Future<File>, we adapt to Future<void>
    await File(path).writeAsBytes(bytes, flush: flush);
  }

  @override
  Future<bool> directoryExists(String path) {
    return Directory(path).exists();
  }

  @override
  Future<Directory> createDirectory(String path, {bool recursive = false}) {
    return Directory(path).create(recursive: recursive);
  }

  @override
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    // Completes normally if file doesn't exist, aligning with dart:io's delete behavior.
  }
} 