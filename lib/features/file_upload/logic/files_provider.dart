import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core services and models
import '../../../core/services/database_helper.dart';
import '../../../core/services/secure_file_storage_service.dart';
import '../../../core/services/file_system_operations.dart'; // For FileSystemOperations
import '../../../core/helpers/exceptions.dart'; // Import custom exceptions
import '../data/models/medical_file_model.dart';

// --- Dependency Providers ---

final uuidProvider = Provider<Uuid>((ref) => const Uuid());
final loggerProvider = Provider<Logger>((ref) => Logger());
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
final fileSystemOperationsProvider = Provider<FileSystemOperations>((ref) => const DefaultFileSystemOperations());

/// Provider that exposes the Supabase authentication state stream.
///
/// This allows other providers to listen to authentication changes (login/logout).
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// This service is self-contained and handles its own dependencies.
final secureFileStorageServiceProvider = Provider<SecureFileStorageService>((ref) {
  return SecureFileStorageService(
    secureStorage: ref.watch(flutterSecureStorageProvider),
    uuid: ref.watch(uuidProvider),
    logger: ref.watch(loggerProvider),
    fileSystemOps: ref.watch(fileSystemOperationsProvider),
  );
});

// New provider for user-specific DatabaseHelper instance.
// Returns null if no user is logged in.
final userSpecificDatabaseHelperProvider = Provider<DatabaseHelper?>((ref) {
  // Depend on the auth state change stream. This will cause the provider
  // to be re-evaluated whenever the user logs in or out.
  final authState = ref.watch(authStateStreamProvider);

  // When the stream is loading or has an error, we have no user.
  return authState.when(
    data: (state) {
      final userId = state.session?.user.id;
      if (userId == null) {
        return null;
      }
      
      // Create a new DatabaseHelper for the current user.
      final dbHelper = DatabaseHelper(userId);

      // When the provider is disposed (e.g., user logs out), close the database connection.
      ref.onDispose(() {
        dbHelper.close();
        ref.read(loggerProvider).i('Closed database connection for user $userId on provider dispose.');
      });

      return dbHelper;
    },
    loading: () => null,
    error: (err, stack) {
      ref.read(loggerProvider).e('Error in authStateStreamProvider', error: err, stackTrace: stack);
      return null;
    },
  );
});

// --- StateNotifier for Medical Files Logic ---

class MedicalFilesNotifier extends StateNotifier<AsyncValue<List<MedicalFile>>> {
  final DatabaseHelper? _dbHelper;
  final SecureFileStorageService _fileStorageService;
  final Logger _logger;
  final String? _userId;

  /// A future that completes when the initial loading of files is finished.
  ///
  /// This can be awaited in tests to ensure the notifier is initialized.
  late final Future<void> initializationDone;

  MedicalFilesNotifier(this._dbHelper, this._fileStorageService, this._logger, this._userId) 
      : super(const AsyncValue.loading()) {
    initializationDone = _loadFiles();
  }

  Future<void> _loadFiles() async {
    if (_dbHelper == null) {
      _logger.w("No user logged in. Cannot load files.");
      state = const AsyncValue.data([]);
      return;
    }
    _logger.d("Attempting to load medical files for user $_userId...");
    try {
      state = const AsyncValue.loading();
      final List<Map<String, dynamic>> fileMaps = await _dbHelper.getMedicalFilesMetadata();
      final List<MedicalFile> files = fileMaps.map((map) => MedicalFile.fromMap(map)).toList();
      
      // The database query already sorts by created_at DESC, no client-side sort needed.
      state = AsyncValue.data(files);
      _logger.i("Successfully loaded ${files.length} medical files for user $_userId.");
    } catch (e, stackTrace) {
      _logger.e("Error loading medical files for user $_userId", error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshFiles() async {
    await _loadFiles();
  }

  Future<bool> pickAndSecureFile() async {
     if (_userId == null) {
      _logger.e("Cannot pick file, no user is logged in.");
      state = AsyncValue.error("User is not logged in.", StackTrace.current);
      return false;
    }

    try {
      final secureResult = await _fileStorageService.pickAndSecureFile(_userId);
      if (secureResult != null) {
        _logger.i("File picked and secured successfully for user $_userId. Refreshing list.");
        await _loadFiles(); 
        return true;
      } else {
        _logger.w("File picking or securing was cancelled or failed for user $_userId.");
        return false;
      }
    } on DuplicateFileException catch (e, stackTrace) {
      _logger.w("Duplicate file detected for user $_userId: ${e.message}");
      state = AsyncValue.error(e, stackTrace);
      return false;
    } catch (e, stackTrace) {
      _logger.e("Error during pickAndSecureFile flow for user $_userId", error: e, stackTrace: stackTrace);
      state = AsyncValue.error("Failed to add file: ${e.toString()}", stackTrace);
      return false;
    }
  }

  // Decrypts a file given its ID.
  // Returns the decrypted file content as Uint8List, or null on failure.
  Future<Uint8List?> decryptFile(String fileId) async {
    if (_userId == null) {
      _logger.e("Cannot decrypt file, no user is logged in.");
      return null;
    }
    try {
      final decryptedBytes = await _fileStorageService.decryptFile(fileId, _userId);
      if (decryptedBytes != null) {
        _logger.i("File decrypted successfully: $fileId");
      } else {
         _logger.w("Decryption returned null for file ID: $fileId.");
      }
      return decryptedBytes;
    } catch (e, stackTrace) {
      _logger.e("Error decrypting file $fileId for user $_userId", error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Deletes a medical file (metadata, encrypted file, and key).
  // Returns true if successful, false otherwise.
  Future<bool> deleteMedicalFile(MedicalFile fileToDelete) async {
    if (_dbHelper == null || _userId == null) {
      _logger.e("Cannot delete file, no user is logged in.");
      return false;
    }

    try {
      final secureDeletionSuccess = await _fileStorageService.deleteEncryptedFileAndKey(
        fileToDelete.id,
        fileToDelete.encryptedPath,
      );

      if (!secureDeletionSuccess) {
        _logger.w("Failed to delete encrypted file/key for ${fileToDelete.id}. Aborting.");
        return false;
      }

      await _dbHelper.deleteMedicalFileMetadata(fileToDelete.id);
      _logger.i("Successfully soft-deleted metadata for file ID: ${fileToDelete.id}");

      // 3. Refresh the list of files in the state
      await _loadFiles();
      _logger.i("Successfully deleted and refreshed files list.");
      return true;

    } catch (e, stackTrace) {
      _logger.e("Error deleting medical file ${fileToDelete.id} for user $_userId", error: e, stackTrace: stackTrace);
      state = AsyncValue.error("Failed to delete ${fileToDelete.originalFilename}", stackTrace);
      return false;
    }
  }
}

// The StateNotifierProvider that UI will interact with.
// It provides an instance of MedicalFilesNotifier.
final medicalFilesProvider = StateNotifierProvider<MedicalFilesNotifier, AsyncValue<List<MedicalFile>>>((ref) {
  final dbHelper = ref.watch(userSpecificDatabaseHelperProvider);
  final fileStorageService = ref.watch(secureFileStorageServiceProvider);
  final logger = ref.watch(loggerProvider);
  // The user ID now comes directly from the auth state, making it more reliable.
  final userId = ref.watch(authStateStreamProvider).value?.session?.user.id;
  
  return MedicalFilesNotifier(dbHelper, fileStorageService, logger, userId);
}); 