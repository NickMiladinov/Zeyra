import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:uuid/uuid.dart';
import 'dart:math'; // For Random.secure()
import 'package:meta/meta.dart'; // Import for @visibleForTesting

import '../helpers/crypto_utils.dart'; // Import crypto utils
import '../helpers/exceptions.dart'; // Import custom exceptions
import './database_helper.dart'; // Import DatabaseHelper
import './file_system_operations.dart'; // Import the new abstraction

class SecureFileStorageService {
  final FlutterSecureStorage _secureStorage;
  final Uuid _uuid;
  final Logger _logger;
  final FileSystemOperations _fileSystemOps;

  SecureFileStorageService({
    FlutterSecureStorage? secureStorage,
    Uuid? uuid,
    Logger? logger,
    FileSystemOperations? fileSystemOps,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _uuid = uuid ?? const Uuid(),
        _logger = logger ?? Logger(),
        _fileSystemOps = fileSystemOps ?? const DefaultFileSystemOperations();

  static const String _encryptedFilesDirName = 'encrypted_medical_files';

  // Allowed file extensions
  static const List<String> _allowedExtensions = [
    'pdf', 'csv', 'txt', // Standard documents
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif', // Common images
    'hl7', // Health Level Seven
    'json', 'xml', // FHIR data formats
    'dcm', // DICOM images
  ];

  // Helper to generate secure random bytes for IV or Key
  Uint8List _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return Uint8List.fromList(values);
  }

  // Directory is now user-specific but visible for tests
  @visibleForTesting
  Future<String> getSecureStorageDirectory(String userId) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String secureDirPath = '${appDir.path}/$_encryptedFilesDirName/$userId';

    // Use injected _fileSystemOps
    if (!await _fileSystemOps.directoryExists(secureDirPath)) {
      await _fileSystemOps.createDirectory(secureDirPath, recursive: true);
    }
    return secureDirPath;
  }

  @visibleForTesting
  Future<PlatformFile?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );
      return result?.files.single.path != null ? result!.files.single : null;
    } catch (e, s) {
      _logger.e('Error picking file: $e', error: e, stackTrace: s);
      return null;
    }
  }

  // Public method to orchestrate picking and storing
  // Throws DuplicateFileException if a file with the same name and size already exists.
  Future<Map<String, String>?> pickAndSecureFile(String userId) async {
    final PlatformFile? pickedFile = await pickFile();
    if (pickedFile == null) {
      _logger.i('File picking cancelled by user or failed.');
      return null; // User cancelled or error occurred
    }
    _logger.i('File picked: ${pickedFile.name}, Size: ${pickedFile.size}');

    // Check for duplicates for the current user
    final dbHelper = DatabaseHelper(userId);
    final existingFileMeta = await dbHelper.getMedicalFileMetadataByFilenameAndSize(
        pickedFile.name, pickedFile.size);

    if (existingFileMeta != null) {
      _logger.w('Duplicate file detected for user $userId: ${pickedFile.name}');
      throw DuplicateFileException("File '${pickedFile.name}' already exists.");
    }

    _logger.i('No duplicate found for user $userId. Proceeding with encryption.');
    return await encryptAndStoreFile(pickedFile, userId);
  }

  @visibleForTesting
  Future<Map<String, String>?> encryptAndStoreFile(PlatformFile platformFile, String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User ID cannot be empty.');
    }

    String? fileId; 
    String? encryptedFilePathForCleanup;

    try {
      // 1. Read File Content
      final String? filePath = platformFile.path;
      if (filePath == null) {
        _logger.e('Error: Picked file path is null for file: ${platformFile.name}');
        return null;
      }
      // Use injected _fileSystemOps
      final Uint8List fileBytes = await _fileSystemOps.readFileAsBytes(filePath);
      final int originalFileSize = platformFile.size;
      final String originalFileName = platformFile.name;
      final String? fileExtension = platformFile.extension?.toLowerCase();

      // 2. Generate Unique Key and IV
      final Uint8List encryptionKey = _generateSecureRandomBytes(32);
      final Uint8List iv = _generateSecureRandomBytes(12);

      // 3. Encrypt Content
      final pc.GCMBlockCipher cipher = pc.GCMBlockCipher(pc.AESEngine());
      final params = pc.ParametersWithIV<pc.KeyParameter>(pc.KeyParameter(encryptionKey), iv);
      cipher.init(true, params);
      final Uint8List encryptedBytes = cipher.process(fileBytes);

      // 4. Generate Unique File ID
      fileId = _uuid.v4();
      final String keyAndIvStorageValue = '${bytesToHex(encryptionKey)}:${bytesToHex(iv)}';
      await _secureStorage.write(key: fileId, value: keyAndIvStorageValue);

      // 5. Generate Unique Filename for encrypted file
      final String encryptedFileName = '${_uuid.v4()}.enc';

      // 6. Write Encrypted File
      final String secureDir = await getSecureStorageDirectory(userId);
      encryptedFilePathForCleanup = '$secureDir/$encryptedFileName';
      
      await _fileSystemOps.writeFileAsBytes(encryptedFilePathForCleanup, encryptedBytes, flush: true);

      // 7. Save Metadata to Database
      final dbHelper = DatabaseHelper(userId);
      final Map<String, dynamic> fileMetadata = {
        DatabaseHelper.colId: fileId,
        DatabaseHelper.colUserId: userId,
        DatabaseHelper.colOriginalFilename: originalFileName,
        DatabaseHelper.colFileType: fileExtension ?? 'unknown',
        DatabaseHelper.colCreatedAt: DateTime.now().toUtc().toIso8601String(),
        DatabaseHelper.colEncryptedPath: encryptedFilePathForCleanup,
        DatabaseHelper.colFileSize: originalFileSize,
      };
      
      // Critical point: if this fails, we need to attempt cleanup
      await dbHelper.saveMedicalFileMetadata(fileMetadata);
      
      _logger.i('Successfully stored file for user $userId: ${platformFile.name} (ID: $fileId)');

      // 8. Return fileId and path
      return {
        'fileId': fileId,
        'path': encryptedFilePathForCleanup,
      };
    } catch (e, s) {
      _logger.e('Error encrypting and storing file ${platformFile.name} for user $userId: $e', error: e, stackTrace: s);

      // Attempt cleanup if fileId was generated (meaning key might be stored) 
      // and/or encryptedFilePathForCleanup is set (meaning file might be written).
      // This is a best-effort cleanup.
      if (fileId != null) {
        _logger.w('Attempting to clean up due to failure during encryption/storage for fileId: $fileId');
        try {
          await _secureStorage.delete(key: fileId);
          _logger.i('Cleaned up key/IV from secure storage for fileId: $fileId');
        } catch (cleanupErr, cleanupST) {
          _logger.e('Failed to cleanup key/IV for fileId $fileId: $cleanupErr', error: cleanupErr, stackTrace: cleanupST);
        }
      }
      if (encryptedFilePathForCleanup != null) {
        try {
          if (await _fileSystemOps.fileExists(encryptedFilePathForCleanup)) {
             await _fileSystemOps.deleteFile(encryptedFilePathForCleanup);
             _logger.i('Cleaned up encrypted file: $encryptedFilePathForCleanup');
          }
        } catch (cleanupErr, cleanupST) {
          _logger.e('Failed to cleanup encrypted file $encryptedFilePathForCleanup: $cleanupErr', error: cleanupErr, stackTrace: cleanupST);
        }
      }
      // Re-throw the original error if it's not a DuplicateFileException, so it can be handled upstream.
      // DuplicateFileException is handled by the caller of pickAndSecureFile.
      if (e is! DuplicateFileException) {
        // If we want to pass it up as is:
        // throw e;
        // Or return null to indicate a general failure if pickAndSecureFile is expected to return null on error:
        return null; 
      }
      return null; // Should have been caught by specific exception if it was DuplicateFileException
    }
  }

  Future<Uint8List?> decryptFile(String fileId, String userId) async {
    try {
      // SECURITY-CRITICAL CHANGE: First, verify user has access to the file metadata.
      // This prevents any attempt to access a key for a file the user does not own.
      final Map<String, dynamic>? fileMetadata = await DatabaseHelper(userId).getMedicalFileMetadataById(fileId);
      final String? encryptedPathFromDb = fileMetadata?[DatabaseHelper.colEncryptedPath] as String?;

      if (fileMetadata == null || encryptedPathFromDb == null || encryptedPathFromDb.isEmpty) {
        _logger.e('Error: No metadata, or encrypted path is null/empty in DB for fileId: $fileId and userId: $userId');
        return null;
      }
      
      // 1. Retrieve Key and IV from secure storage
      final String? keyAndIvStorageValue = await _secureStorage.read(key: fileId);
      if (keyAndIvStorageValue == null) {
        _logger.e('Error: No key/IV found for fileId: $fileId (after confirming user access)');
        return null;
      }

      final List<String> parts = keyAndIvStorageValue.split(':');
      if (parts.length != 2) {
        _logger.e('Error: Invalid key/IV storage format (expected 2 parts, got ${parts.length}) for fileId: $fileId');
        return null;
      }
      
      // hexToBytes will throw FormatException if data is malformed.
      final Uint8List encryptionKey = hexToBytes(parts[0]);
      final Uint8List iv = hexToBytes(parts[1]);

      // Explicit length checks after decoding
      if (encryptionKey.length != 32) {
        _logger.e('Error: Invalid encryption key length (${encryptionKey.length} bytes, expected 32) for fileId: $fileId');
        return null;
      }
      if (iv.length != 12) {
        _logger.e('Error: Invalid IV length (${iv.length} bytes, expected 12) for fileId: $fileId');
        return null;
      }
      
      // encryptedPathFromDb is now confirmed not null and not empty
      if (!await _fileSystemOps.fileExists(encryptedPathFromDb)) {
        _logger.e('Error: Encrypted file not found at path: $encryptedPathFromDb (ID: $fileId)');
        return null;
      }

      final Uint8List encryptedBytes = await _fileSystemOps.readFileAsBytes(encryptedPathFromDb);

      final pc.GCMBlockCipher cipher = pc.GCMBlockCipher(pc.AESEngine());
      // PointyCastle's KeyParameter and ParametersWithIV will throw ArgumentError for incorrect lengths
      // if not caught by our manual checks earlier, or for other invalid parameter issues.
      final params = pc.ParametersWithIV<pc.KeyParameter>(pc.KeyParameter(encryptionKey), iv);
      cipher.init(false, params); 
      
      // This will throw InvalidCipherTextException if GCM tag check fails (tampered data/wrong key)
      final Uint8List decryptedBytes = cipher.process(encryptedBytes);
      _logger.i('Successfully decrypted file ID: $fileId for user: $userId');

      return decryptedBytes;
    } catch (e, s) {
      _logger.e('Error decrypting file $fileId for user $userId: $e', error: e, stackTrace: s);
      return null;
    }
  }

  /// Deletes the encrypted file from disk and its corresponding key/IV from secure storage.
  ///
  /// Returns `true` if all deletion steps were successful or resources were already gone.
  /// Returns `false` if an error occurs during deletion of an existing resource.
  Future<bool> deleteEncryptedFileAndKey(String fileId, String encryptedFilePath) async {
    bool keyDeletionSuccess = false;
    bool fileDeletionSuccess = false;
    String? operationFailed;

    _logger.i("Attempting to delete file and key for ID: $fileId, Path: $encryptedFilePath");

    // 1. Delete Key and IV from secure storage
    try {
      final String? keyExists = await _secureStorage.read(key: fileId);
      if (keyExists != null) {
        await _secureStorage.delete(key: fileId);
        _logger.i("Successfully deleted key/IV from secure storage for fileId: $fileId");
        keyDeletionSuccess = true;
      } else {
        _logger.i("Key/IV for fileId: $fileId not found in secure storage (already deleted or never existed).");
        keyDeletionSuccess = true; // Considered success if not found
      }
    } catch (e, s) {
      _logger.e('Error deleting key/IV for fileId $fileId: $e', error: e, stackTrace: s);
      operationFailed = "key deletion";
      keyDeletionSuccess = false;
    }

    // 2. Delete Encrypted File from disk
    try {
      if (await _fileSystemOps.fileExists(encryptedFilePath)) {
        await _fileSystemOps.deleteFile(encryptedFilePath);
        _logger.i('Successfully deleted encrypted file: $encryptedFilePath');
        fileDeletionSuccess = true;
      } else {
        _logger.i('Encrypted file not found at path: $encryptedFilePath (already deleted or never existed).');
        fileDeletionSuccess = true; // Considered success if not found
      }
    } catch (e, s) {
      _logger.e('Error deleting encrypted file $encryptedFilePath: $e', error: e, stackTrace: s);
      operationFailed = operationFailed == null ? "file deletion" : "$operationFailed and file deletion";
      fileDeletionSuccess = false;
    }

    if (keyDeletionSuccess && fileDeletionSuccess) {
      _logger.i("Successfully completed deletion process for file ID: $fileId.");
      return true;
    } else {
      _logger.w("Deletion process for file ID: $fileId encountered issues. Key deleted: $keyDeletionSuccess, File deleted: $fileDeletionSuccess. Operation(s) failed: ${operationFailed ?? 'none'}.");
      return false;
    }
  }

  // Test wrappers
  Future<String> getSecureStorageDirectoryForTest() {
    return getSecureStorageDirectory('testUserId');
  }

  Future<Map<String, String>?> encryptAndStoreFileForTest(PlatformFile platformFile) {
    return encryptAndStoreFile(platformFile, 'testUserId');
  }

  Future<PlatformFile?> pickFileForTest() {
     return pickFile();
  }
} 