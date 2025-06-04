import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:uuid/uuid.dart';
import 'dart:math'; // For Random.secure()

import '../helpers/crypto_utils.dart'; // Import crypto utils
import './database_helper.dart'; // Import DatabaseHelper
import './file_system_operations.dart'; // Import the new abstraction

class SecureFileStorageService {
  final FlutterSecureStorage _secureStorage;
  final Uuid _uuid;
  final Logger _logger;
  final DatabaseHelper _dbHelper;
  final FileSystemOperations _fileSystemOps;

  SecureFileStorageService({
    FlutterSecureStorage? secureStorage,
    DatabaseHelper? dbHelper,
    Uuid? uuid,
    Logger? logger,
    FileSystemOperations? fileSystemOps,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _dbHelper = dbHelper ?? DatabaseHelper(),
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

  Future<String> _getSecureStorageDirectory() async {
    // PathProvider is still used here, as it's a higher-level abstraction for platform paths.
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String secureDirPath = '${appDir.path}/$_encryptedFilesDirName';

    // Use injected _fileSystemOps
    if (!await _fileSystemOps.directoryExists(secureDirPath)) {
      await _fileSystemOps.createDirectory(secureDirPath, recursive: true);
    }
    return secureDirPath;
  }

  Future<PlatformFile?> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );
      if (result != null && result.files.single.path != null) {
        return result.files.single;
      } else {
        // User canceled the picker or path is null
        return null;
      }
    } catch (e, s) {
      _logger.e('Error picking file: $e', error: e, stackTrace: s);
      return null;
    }
  }

  // Public method to orchestrate picking and storing
  Future<Map<String, String>?> pickAndSecureFile() async {
    final PlatformFile? pickedFile = await _pickFile();
    if (pickedFile == null) {
      _logger.i('File picking cancelled by user or failed.');
      return null; // User cancelled or error occurred
    }
    _logger.i('File picked: ${pickedFile.name}');
    return await _encryptAndStoreFile(pickedFile);
  }

  Future<Map<String, String>?> _encryptAndStoreFile(PlatformFile platformFile) async {
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
      final String secureDir = await _getSecureStorageDirectory();
      encryptedFilePathForCleanup = '$secureDir/$encryptedFileName';
      
      await _fileSystemOps.writeFileAsBytes(encryptedFilePathForCleanup, encryptedBytes, flush: true);

      // 7. Save Metadata to Database
      final Map<String, dynamic> fileMetadata = {
        DatabaseHelper.colId: fileId,
        DatabaseHelper.colOriginalFilename: originalFileName,
        DatabaseHelper.colFileType: fileExtension ?? 'unknown',
        DatabaseHelper.colDateAdded: DateTime.now().millisecondsSinceEpoch,
        DatabaseHelper.colEncryptedPath: encryptedFilePathForCleanup,
        DatabaseHelper.colFileSize: originalFileSize,
      };
      
      // Critical point: if this fails, we need to attempt cleanup
      await _dbHelper.saveMedicalFileMetadata(fileMetadata);
      
      _logger.i('Successfully encrypted and stored file: $originalFileName (ID: $fileId)');

      // 8. Return fileId and path
      return {
        'fileId': fileId,
        'path': encryptedFilePathForCleanup,
      };
    } catch (e, s) {
      _logger.e('Error encrypting and storing file ${platformFile.name}: $e', error: e, stackTrace: s);

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
      return null;
    }
  }

  Future<Uint8List?> decryptFile(String fileId) async {
    try {
      // 1. Retrieve Key and IV from secure storage
      final String? keyAndIvStorageValue = await _secureStorage.read(key: fileId);
      if (keyAndIvStorageValue == null) {
        _logger.e('Error: No key/IV found for fileId: $fileId');
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

      final Map<String, dynamic>? fileMetadata = await _dbHelper.getMedicalFileMetadataById(fileId);
      final String? encryptedPathFromDb = fileMetadata?[DatabaseHelper.colEncryptedPath] as String?;

      if (fileMetadata == null || encryptedPathFromDb == null || encryptedPathFromDb.isEmpty) {
        _logger.e('Error: No metadata, or encrypted path is null/empty in DB for fileId: $fileId');
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
      _logger.i('Successfully decrypted file with ID: $fileId');

      // 6. Return decrypted bytes
      return decryptedBytes;
    } on FormatException catch (e, s) {
      _logger.e('Error decrypting file (Malformed hex data for key/IV) for fileId $fileId: $e', error: e, stackTrace: s);
      return null;
    } on pc.InvalidCipherTextException catch (e, s) {
      _logger.e('Error decrypting file (Data integrity check failed - GCM tag mismatch) for fileId $fileId: $e', error: e, stackTrace: s);
      return null;
    } on ArgumentError catch (e, s) { 
      _logger.e('Error decrypting file (Invalid argument during cipher initialization, possibly key/IV related) for fileId $fileId: $e', error: e, stackTrace: s);
      return null;
    } catch (e, s) {
      _logger.e('Generic error decrypting file with fileId $fileId: $e', error: e, stackTrace: s);
      return null;
    }
  }

  // Test wrappers
  Future<String> getSecureStorageDirectoryForTest() {
    return _getSecureStorageDirectory();
  }

  Future<Map<String, String>?> encryptAndStoreFileForTest(PlatformFile platformFile) {
    return _encryptAndStoreFile(platformFile);
  }

  Future<PlatformFile?> pickFileForTest() {
     return _pickFile();
  }
} 