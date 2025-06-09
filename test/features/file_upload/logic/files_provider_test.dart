import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zeyra/core/helpers/exceptions.dart';
import 'package:zeyra/core/services/database_helper.dart';
import 'package:zeyra/core/services/secure_file_storage_service.dart';
import 'package:zeyra/features/file_upload/data/models/medical_file_model.dart';
import 'package:zeyra/features/file_upload/logic/files_provider.dart';

import 'files_provider_test.mocks.dart';

// Helper to create a mock MedicalFile instance for tests
MedicalFile createMockMedicalFile({
  String id = 'file1',
  String userId = 'user1',
  String filename = 'test.pdf',
}) {
  return MedicalFile(
    id: id,
    userId: userId,
    originalFilename: filename,
    createdAt: DateTime.now(),
    version: 1,
    lastModifiedAt: DateTime.now(),
    encryptedPath: '/secure/path/$id.enc',
  );
}

// Generate mocks for all dependencies
@GenerateNiceMocks([
  MockSpec<DatabaseHelper>(),
  MockSpec<SecureFileStorageService>(),
])
void main() {
  // --- Test Setup ---
  late MockDatabaseHelper mockDbHelper;
  late MockSecureFileStorageService mockSecureStorageService;
  const testUserId = 'test-user-id';

  // Helper to create a ProviderContainer with overrides
  ProviderContainer createContainer({
    required DatabaseHelper? dbHelper,
    String? userId,
  }) {
    final container = ProviderContainer(
      overrides: [
        // Override the providers our main provider depends on
        userSpecificDatabaseHelperProvider.overrideWithValue(dbHelper),
        secureFileStorageServiceProvider.overrideWithValue(mockSecureStorageService),
        // Override the main provider itself to inject the userId
        medicalFilesProvider.overrideWith(
          (ref) => MedicalFilesNotifier(
            dbHelper,
            mockSecureStorageService,
            ref.watch(loggerProvider),
            userId,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockSecureStorageService = MockSecureFileStorageService();
  });

  group('Initialization and State Loading', () {
    test('Test 1 (Initial State - No User)', () async {
      // Scenario: The dbHelper provider returns null (simulating no user)
      final container = createContainer(dbHelper: null, userId: null);
      // Wait for the initialization logic in the constructor to complete.
      await container.read(medicalFilesProvider.notifier).initializationDone;

      final state = container.read(medicalFilesProvider);

      // Assert: State is AsyncData with an empty list
      expect(state, isA<AsyncData<List<MedicalFile>>>());
      expect(state.asData!.value, isEmpty);
    });

    test('Test 2 (Initial State - With User)', () async {
      // Scenario: A user is logged in and the DB returns two files
      when(mockDbHelper.getMedicalFilesMetadata()).thenAnswer(
        (_) async =>
            [createMockMedicalFile(id: 'f1').toMap(), createMockMedicalFile(id: 'f2').toMap()],
      );
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);

      // Wait for the initialization logic to complete.
      await container.read(medicalFilesProvider.notifier).initializationDone;

      // Assert: State is AsyncData with the list of files
      final state = container.read(medicalFilesProvider);
      expect(state, isA<AsyncData<List<MedicalFile>>>());
      expect(state.asData!.value.length, 2);
    });

    test('Test 3 (Initial State - DB Error)', () async {
      // Scenario: The database throws an error on load
      final dbError = Exception('Database connection failed');
      when(mockDbHelper.getMedicalFilesMetadata()).thenThrow(dbError);
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);

      // Wait for the initialization logic to complete.
      await container.read(medicalFilesProvider.notifier).initializationDone;

      // Assert: State becomes an AsyncError
      final state = container.read(medicalFilesProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, dbError);
    });

    test('Test 4 (refreshFiles)', () async {
      // Scenario: Successful initial load, then refresh is called
      when(mockDbHelper.getMedicalFilesMetadata()).thenAnswer((_) async => []);
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);

      await container.read(medicalFilesProvider.notifier).initializationDone; // Initial load
      await container.read(medicalFilesProvider.notifier).refreshFiles();

      // Assert: The getMedicalFilesMetadata method was called twice
      verify(mockDbHelper.getMedicalFilesMetadata()).called(2);
    });
  });

  group('pickAndSecureFile Method', () {
    test('Test 1 (Success Flow)', () async {
      when(mockDbHelper.getMedicalFilesMetadata()).thenAnswer((_) async => []);
      when(mockSecureStorageService.pickAndSecureFile(testUserId))
          .thenAnswer((_) async => {'fileId': 'new-file', 'path': '/new/path'});

      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      await container.read(medicalFilesProvider.notifier).initializationDone; // Wait for initial load

      final notifier = container.read(medicalFilesProvider.notifier);
      final result = await notifier.pickAndSecureFile();

      expect(result, isTrue);
      verify(mockDbHelper.getMedicalFilesMetadata()).called(2); // Initial load + refresh
    });

    test('Test 2 (User Cancellation)', () async {
      when(mockDbHelper.getMedicalFilesMetadata()).thenAnswer((_) async => []);
      when(mockSecureStorageService.pickAndSecureFile(testUserId)).thenAnswer((_) async => null);

      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      await container.read(medicalFilesProvider.notifier).initializationDone;
      final originalState = container.read(medicalFilesProvider);

      final notifier = container.read(medicalFilesProvider.notifier);
      final result = await notifier.pickAndSecureFile();

      expect(result, isFalse);
      verify(mockDbHelper.getMedicalFilesMetadata()).called(1); // Called once on init, but not again
      expect(container.read(medicalFilesProvider), originalState); // State does not change
    });

    test('Test 3 (Duplicate File Exception)', () async {
      when(mockSecureStorageService.pickAndSecureFile(testUserId))
          .thenThrow(DuplicateFileException('Exists'));
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      await container.read(medicalFilesProvider.notifier).initializationDone;

      final result = await container.read(medicalFilesProvider.notifier).pickAndSecureFile();

      expect(result, isFalse);
      expect(container.read(medicalFilesProvider), isA<AsyncError>());
      expect(container.read(medicalFilesProvider).error, isA<DuplicateFileException>());
    });

    test('Test 4 (Generic Exception)', () async {
      when(mockSecureStorageService.pickAndSecureFile(testUserId))
          .thenThrow(Exception('Storage fail'));
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      await container.read(medicalFilesProvider.notifier).initializationDone;

      final result = await container.read(medicalFilesProvider.notifier).pickAndSecureFile();

      expect(result, isFalse);
      expect(container.read(medicalFilesProvider), isA<AsyncError>());
    });

    test('Test 5 (No User Logged In)', () async {
      final container = createContainer(dbHelper: null, userId: null);
      await container.read(medicalFilesProvider.notifier).initializationDone;

      final result = await container.read(medicalFilesProvider.notifier).pickAndSecureFile();

      expect(result, isFalse);
      verifyNever(mockSecureStorageService.pickAndSecureFile(any));
      expect(container.read(medicalFilesProvider), isA<AsyncError>());
    });
  });

  group('decryptFile Method', () {
     final decryptedData = Uint8List.fromList([1, 2, 3]);

    test('Test 1 (Success Flow)', () async {
      when(mockSecureStorageService.decryptFile(any, any)).thenAnswer((_) async => decryptedData);
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      
      final result = await container.read(medicalFilesProvider.notifier).decryptFile('file1');

      expect(result, equals(decryptedData));
    });

    test('Test 2 (Decryption Failure)', () async {
      when(mockSecureStorageService.decryptFile(any, any)).thenAnswer((_) async => null);
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      
      final result = await container.read(medicalFilesProvider.notifier).decryptFile('file1');

      expect(result, isNull);
    });

    test('Test 3 (Generic Exception)', () async {
      when(mockSecureStorageService.decryptFile(any, any)).thenThrow(Exception('Decrypt fail'));
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      
      final result = await container.read(medicalFilesProvider.notifier).decryptFile('file1');

      expect(result, isNull);
    });

    test('Test 4 (No User Logged In)', () async {
      final container = createContainer(dbHelper: null, userId: null);
      
      final result = await container.read(medicalFilesProvider.notifier).decryptFile('file1');

      expect(result, isNull);
      verifyNever(mockSecureStorageService.decryptFile(any, any));
    });
  });

  group('deleteMedicalFile Method', () {
    final fileToDelete = createMockMedicalFile(id: 'del_id');

    test('Test 1 (Success Flow)', () async {
      when(mockSecureStorageService.deleteEncryptedFileAndKey(any, any))
          .thenAnswer((_) async => true);
      when(mockDbHelper.deleteMedicalFileMetadata(any)).thenAnswer((_) async {});
      when(mockDbHelper.getMedicalFilesMetadata()).thenAnswer((_) async => []);

      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      await container.read(medicalFilesProvider.notifier).initializationDone;

      final result = await container.read(medicalFilesProvider.notifier).deleteMedicalFile(fileToDelete);

      expect(result, isTrue);
      verify(mockDbHelper.getMedicalFilesMetadata()).called(2);
    });
    
    test('Test 2 (Secure Storage Fails)', () async {
      when(mockSecureStorageService.deleteEncryptedFileAndKey(any, any))
          .thenAnswer((_) async => false);
      
      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      await container.read(medicalFilesProvider.notifier).initializationDone;
      
      final result = await container.read(medicalFilesProvider.notifier).deleteMedicalFile(fileToDelete);

      expect(result, isFalse);
      verifyNever(mockDbHelper.deleteMedicalFileMetadata(any));
    });

    test('Test 3 (Database Fails)', () async {
      when(mockSecureStorageService.deleteEncryptedFileAndKey(any, any))
          .thenAnswer((_) async => true);
      when(mockDbHelper.deleteMedicalFileMetadata(any)).thenThrow(Exception('DB delete fail'));

      final container = createContainer(dbHelper: mockDbHelper, userId: testUserId);
      await container.read(medicalFilesProvider.notifier).initializationDone;
      
      final result = await container.read(medicalFilesProvider.notifier).deleteMedicalFile(fileToDelete);
      
      expect(result, isFalse);
      expect(container.read(medicalFilesProvider), isA<AsyncError>());
    });

    test('Test 4 (No User Logged In)', () async {
      final container = createContainer(dbHelper: null, userId: null);
      
      final result = await container.read(medicalFilesProvider.notifier).deleteMedicalFile(fileToDelete);

      expect(result, isFalse);
      verifyNever(mockSecureStorageService.deleteEncryptedFileAndKey(any, any));
      verifyNever(mockDbHelper.deleteMedicalFileMetadata(any));
    });
  });
} 