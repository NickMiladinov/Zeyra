import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core services and models
import '../../../core/services/database_helper.dart';
import '../../../core/services/secure_file_storage_service.dart';
import '../../../core/services/file_system_operations.dart'; // For FileSystemOperations
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
      // Expecting Map<String, String>? based on linter feedback if pickAndSecureFile was not updated
      // to only return fileId after db storage.
      // If SecureFileStorageService.pickAndSecureFile() *has* been updated to return String? fileId directly,
      // then this part would be simpler: final String? fileId = await _fileStorageService.pickAndSecureFile();
      final Map<String, String>? secureResult = await _fileStorageService.pickAndSecureFile();

      if (secureResult != null && secureResult.containsKey('fileId')) {
        final String fileId = secureResult['fileId']!;
        _logger.i("File picked and secured successfully. File ID: $fileId. Path: ${secureResult['encryptedPath']}");
        await _loadFiles(); 
        return true;
      } else {
        _logger.w("File picking or securing was cancelled or failed. Secure result: $secureResult");
        return false;
      }
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
}

// The StateNotifierProvider that UI will interact with.
// It provides an instance of MedicalFilesNotifier.
final medicalFilesProvider = StateNotifierProvider<MedicalFilesNotifier, AsyncValue<List<MedicalFile>>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  final fileStorageService = ref.watch(secureFileStorageServiceProvider);
  final logger = ref.watch(loggerProvider);
  return MedicalFilesNotifier(dbHelper, fileStorageService, logger);
}); 