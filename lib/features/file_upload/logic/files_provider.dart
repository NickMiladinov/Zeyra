import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core services and models
import '../../../core/services/database_helper.dart';
import '../../../core/services/secure_file_storage_service.dart';
import '../../../core/services/file_system_operations.dart'; // For FileSystemOperations
import '../../../core/helpers/exceptions.dart'; // Import custom exceptions
import '../data/models/medical_file_model.dart';

// --- Dependency Providers ---

// Provider for DatabaseHelper instance
// Assumes DatabaseHelper() provides the singleton via factory constructor
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Provider for Uuid
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// Provider for Logger
final loggerProvider = Provider<Logger>((ref) => Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 70,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
));

// Provider for FlutterSecureStorage
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

// Provider for FileSystemOperations
// Using DefaultFileSystemOperations as the concrete implementation
final fileSystemOperationsProvider = Provider<FileSystemOperations>((ref) {
  return DefaultFileSystemOperations();
});

// Provider for SecureFileStorageService instance
// Injects all its dependencies using the providers defined above
final secureFileStorageServiceProvider = Provider<SecureFileStorageService>((ref) {
  return SecureFileStorageService(
    secureStorage: ref.watch(flutterSecureStorageProvider),
    dbHelper: ref.watch(databaseHelperProvider),
    uuid: ref.watch(uuidProvider),
    logger: ref.watch(loggerProvider),
    fileSystemOps: ref.watch(fileSystemOperationsProvider),
  );
});


// --- StateNotifier for Medical Files Logic ---

class MedicalFilesNotifier extends StateNotifier<AsyncValue<List<MedicalFile>>> {
  final DatabaseHelper _dbHelper;
  final SecureFileStorageService _fileStorageService;
  final Logger _logger;

  MedicalFilesNotifier(this._dbHelper, this._fileStorageService, this._logger) 
      : super(const AsyncValue.loading()) {
    // Load files when the notifier is initialized
    _loadFiles();
  }

  // Fetches all medical file metadata from the database and updates the state.
  // Files are sorted by date_added in descending order (most recent first).
  Future<void> _loadFiles() async {
    _logger.d("Attempting to load medical files from database...");
    try {
      state = const AsyncValue.loading();
      // Fetch as List<Map<String, dynamic>> first
      final List<Map<String, dynamic>> fileMaps = await _dbHelper.getMedicalFilesMetadata();
      // Then map to List<MedicalFile>
      final List<MedicalFile> files = fileMaps.map((map) => MedicalFile.fromMap(map)).toList();
      
      files.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      state = AsyncValue.data(files);
      _logger.i("Successfully loaded and sorted ${files.length} medical files.");
    } catch (e, stackTrace) {
      _logger.e("Error loading medical files", error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Public method to refresh the list of files.
  Future<void> refreshFiles() async {
    await _loadFiles();
  }

  // Orchestrates picking a file, securing it, and then refreshing the file list.
  // Returns true if successful, false otherwise.
  Future<bool> pickAndSecureFile() async {
    _logger.d("Initiating pickAndSecureFile process...");
    try {
      // pickAndSecureFile in SecureFileStorageService now throws DuplicateFileException
      final Map<String, String>? secureResult = await _fileStorageService.pickAndSecureFile();

      if (secureResult != null && secureResult.containsKey('fileId')) {
        final String fileId = secureResult['fileId']!;
        _logger.i("File picked and secured successfully. File ID: $fileId. Path: ${secureResult['encryptedPath']}");
        await _loadFiles(); 
        return true;
      } else {
        _logger.w("File picking or securing was cancelled or failed. Secure result: $secureResult");
        // If secureResult is null, it might be due to cancellation or an error handled within SecureFileStorageService (other than DuplicateFileException which is thrown)
        // Consider if specific state update is needed here or if existing error handling in UI is sufficient.
        return false;
      }
    } on DuplicateFileException catch (e, stackTrace) {
      _logger.w("Duplicate file detected during pickAndSecureFile: ${e.message}");
      state = AsyncValue.error(e, stackTrace); // Use the exception itself for the error state
      return false;
    } catch (e, stackTrace) {
      _logger.e("Error during pickAndSecureFile flow", error: e, stackTrace: stackTrace);
      state = AsyncValue.error("Failed to add file: ${e.toString()}", stackTrace);
      return false;
    }
  }

  // Decrypts a file given its ID.
  // Returns the decrypted file content as Uint8List, or null on failure.
  Future<Uint8List?> decryptFile(String fileId) async {
    _logger.d("Attempting to decrypt file with ID: $fileId");
    try {
      final decryptedBytes = await _fileStorageService.decryptFile(fileId);
      if (decryptedBytes != null) {
        _logger.i("File decrypted successfully: $fileId, bytes: ${decryptedBytes.length}");
      } else {
         _logger.w("Decryption returned null for file ID: $fileId. File metadata/key might be missing or encrypted file not found.");
      }
      return decryptedBytes;
    } catch (e, stackTrace) {
      _logger.e("Error decrypting file $fileId", error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Deletes a medical file (metadata, encrypted file, and key).
  // Returns true if successful, false otherwise.
  Future<bool> deleteMedicalFile(MedicalFile fileToDelete) async {
    _logger.d("Attempting to delete medical file: ${fileToDelete.originalFilename} (ID: ${fileToDelete.id})");
    try {
      // 1. Delete encrypted file and its key from secure storage
      final bool secureDeletionSuccess = await _fileStorageService.deleteEncryptedFileAndKey(
        fileToDelete.id,
        fileToDelete.encryptedPath,
      );

      if (!secureDeletionSuccess) {
        _logger.w("Failed to delete encrypted file/key for ${fileToDelete.id}. Aborting metadata deletion.");
        // Optionally, update state to reflect partial failure if needed by UI
        // state = AsyncValue.error("Failed to delete file components for ${fileToDelete.originalFilename}", StackTrace.current);
        return false;
      }

      // 2. Delete metadata from the database
      await _dbHelper.deleteMedicalFileMetadata(fileToDelete.id);
      _logger.i("Successfully deleted metadata for file ID: ${fileToDelete.id}");

      // 3. Refresh the list of files in the state
      await _loadFiles(); // This will set state to data or error
      _logger.i("Successfully deleted and refreshed files list for ${fileToDelete.originalFilename}.");
      return true;

    } catch (e, stackTrace) {
      _logger.e("Error deleting medical file ${fileToDelete.id}", error: e, stackTrace: stackTrace);
      // Update state to reflect error, so UI can react
      state = AsyncValue.error("Failed to delete ${fileToDelete.originalFilename}: ${e.toString()}", stackTrace);
      return false;
    }
  }
}

// The StateNotifierProvider that UI will interact with.
// It provides an instance of MedicalFilesNotifier.
final medicalFilesProvider = StateNotifierProvider<MedicalFilesNotifier, AsyncValue<List<MedicalFile>>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  final fileStorageService = ref.watch(secureFileStorageServiceProvider);
  final logger = ref.watch(loggerProvider);
  return MedicalFilesNotifier(dbHelper, fileStorageService, logger);
}); 