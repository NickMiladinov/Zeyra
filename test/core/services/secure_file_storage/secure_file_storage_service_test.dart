import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:pointycastle/export.dart' as pc;

import 'package:zeyra/core/services/secure_file_storage_service.dart';
import 'package:zeyra/core/services/database_helper.dart';
import 'package:zeyra/core/helpers/crypto_utils.dart';
import 'package:zeyra/core/services/file_system_operations.dart';
import 'package:zeyra/core/helpers/exceptions.dart';

import 'secure_file_storage_service_test.mocks.dart';

class MockPathProvider extends Mock with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => super.noSuchMethod(
        Invocation.method(#getApplicationDocumentsPath, []),
        returnValue: Future.value(''),
      );
}

@GenerateNiceMocks([
  MockSpec<FlutterSecureStorage>(),
  MockSpec<DatabaseHelper>(),
  MockSpec<Uuid>(),
  MockSpec<Logger>(),
  MockSpec<FileSystemOperations>(),
  MockSpec<PlatformFile>(),
  MockSpec<Directory>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureFileStorageService service;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockDatabaseHelper mockDbHelper;
  late MockUuid mockUuid;
  late MockLogger mockLogger;
  late MockFileSystemOperations mockFileSystemOps;
  late MockPlatformFile mockPlatformFile;
  late MockPathProvider mockPathProvider;
  
  const user1Id = 'user-a';
  const user2Id = 'user-b';
  const mockAppDocumentsPath = '/mock/documents';
  const encryptedFilesDirName = 'encrypted_medical_files';

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockDbHelper = MockDatabaseHelper();
    mockUuid = MockUuid();
    mockLogger = MockLogger();
    mockFileSystemOps = MockFileSystemOperations();
    mockPlatformFile = MockPlatformFile();
    mockPathProvider = MockPathProvider();
    
    PathProviderPlatform.instance = mockPathProvider;

    when(mockPathProvider.getApplicationDocumentsPath()).thenAnswer((_) async => mockAppDocumentsPath);
    when(mockFileSystemOps.directoryExists(any)).thenAnswer((_) async => true);
    when(mockFileSystemOps.createDirectory(any, recursive: anyNamed('recursive')))
        .thenAnswer((_) async => MockDirectory());
    when(mockDbHelper.getMedicalFileMetadataById(any)).thenAnswer((_) async => null);

    service = SecureFileStorageService(
      secureStorage: mockSecureStorage,
      uuid: mockUuid,
      logger: mockLogger,
      fileSystemOps: mockFileSystemOps,
      dbBuilder: (_) => mockDbHelper,
    );
  });

  group('getSecureStorageDirectory', () {
    final secureDirPath = '$mockAppDocumentsPath/$encryptedFilesDirName/$user1Id';

    test('Test 1 (Creates Directory): Creates directory if it does not exist', () async {
      when(mockFileSystemOps.directoryExists(secureDirPath)).thenAnswer((_) async => false);
      
      final path = await service.getSecureStorageDirectory(user1Id);
      
      expect(path, secureDirPath);
      verify(mockFileSystemOps.createDirectory(secureDirPath, recursive: true)).called(1);
    });

    test('Test 2 (Directory Exists): Does NOT create directory if it exists', () async {
      when(mockFileSystemOps.directoryExists(secureDirPath)).thenAnswer((_) async => true);
      final path = await service.getSecureStorageDirectory(user1Id);
      expect(path, secureDirPath);
      verifyNever(mockFileSystemOps.createDirectory(any, recursive: anyNamed('recursive')));
    });
  });

  group('pickAndSecureFile', () {
    late TestableSecureFileStorageService testableService;
    setUp(() {
       testableService = TestableSecureFileStorageService(
          secureStorage: mockSecureStorage,
          uuid: mockUuid,
          logger: mockLogger,
          fileSystemOps: mockFileSystemOps,
          dbBuilder: (_) => mockDbHelper,
        );
        final fileBytes = Uint8List.fromList(List.generate(100, (i) => i));
        when(mockPlatformFile.path).thenReturn('/path/to/test.pdf');
        when(mockPlatformFile.name).thenReturn('test.pdf');
        when(mockPlatformFile.size).thenReturn(100);
        when(mockFileSystemOps.readFileAsBytes(any)).thenAnswer((_) async => fileBytes);
        when(mockUuid.v4()).thenReturnInOrder(['file-id-A', 'encrypted-uuid-B']);
    });

    test('Test 1 (Happy Path): Encrypts and stores a successfully picked file', () async {
      testableService.mockPickFileResult = mockPlatformFile;
      when(mockDbHelper.getMedicalFileMetadataByFilenameAndSize(any, any)).thenAnswer((_) async => null);
      final result = await testableService.pickAndSecureFile(user1Id);
      expect(result, isNotNull);
      verify(mockDbHelper.saveMedicalFileMetadata(any)).called(1);
    });

    test('Test 2 (User Cancels): Returns null if file picking is cancelled', () async {
      testableService.mockPickFileResult = null;
      final result = await testableService.pickAndSecureFile(user1Id);
      expect(result, isNull);
      verifyNever(mockDbHelper.saveMedicalFileMetadata(any));
    });

    test('Test 3 (Duplicate File): Throws DuplicateFileException for existing file', () async {
       testableService.mockPickFileResult = mockPlatformFile;
       when(mockDbHelper.getMedicalFileMetadataByFilenameAndSize('test.pdf', 100)).thenAnswer((_) async => {'id': 'existing-id'});
       expect(() => testableService.pickAndSecureFile(user1Id), throwsA(isA<DuplicateFileException>()));
    });
  });
  
  group('encryptAndStoreFile', () {
    final fileId = 'file-id-123';
    final encryptedUuid = 'encrypted-uuid-456';
    final secureDirPath = '$mockAppDocumentsPath/$encryptedFilesDirName/$user1Id';
    final encryptedFilePath = '$secureDirPath/$encryptedUuid.enc';
    final fileBytes = Uint8List.fromList([1, 2, 3]);

    setUp(() {
      when(mockPlatformFile.path).thenReturn('/path/to/file.pdf');
      when(mockPlatformFile.name).thenReturn('file.pdf');
      when(mockPlatformFile.size).thenReturn(fileBytes.length);
      when(mockPlatformFile.extension).thenReturn('pdf');
      when(mockUuid.v4()).thenReturnInOrder([fileId, encryptedUuid]);
      when(mockFileSystemOps.readFileAsBytes(any)).thenAnswer((_) async => fileBytes);
      when(mockPathProvider.getApplicationDocumentsPath()).thenAnswer((_) async => mockAppDocumentsPath);
    });

    test('Test 1 (Happy Path): Successfully encrypts and stores a file', () async {
      final result = await service.encryptAndStoreFile(mockPlatformFile, user1Id);
      expect(result, isNotNull);
      expect(result!['fileId'], fileId);
      expect(result['path'], encryptedFilePath);
      verify(mockSecureStorage.write(key: fileId, value: anyNamed('value'))).called(1);
      verify(mockFileSystemOps.writeFileAsBytes(encryptedFilePath, any, flush: true)).called(1);
      verify(mockDbHelper.saveMedicalFileMetadata(any)).called(1);
    });

    test('Test 2 (Read Fails): Returns null and does not perform I/O', () async {
      when(mockFileSystemOps.readFileAsBytes(any)).thenThrow(Exception('Cannot read file'));
      final result = await service.encryptAndStoreFile(mockPlatformFile, user1Id);
      expect(result, isNull);
      verifyNever(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')));
      verifyNever(mockFileSystemOps.writeFileAsBytes(any, any));
      verifyNever(mockDbHelper.saveMedicalFileMetadata(any));
    });

    test('Test 3 (File Write Fails): Returns null and cleans up key', () async {
      when(mockFileSystemOps.writeFileAsBytes(encryptedFilePath, any, flush: anyNamed('flush')))
          .thenThrow(Exception('Cannot write file'));
      final result = await service.encryptAndStoreFile(mockPlatformFile, user1Id);
      expect(result, isNull);
      verify(mockSecureStorage.delete(key: fileId)).called(1);
      verifyNever(mockDbHelper.saveMedicalFileMetadata(any));
    });

    test('Test 4 (Key Storage Fails): Returns null and attempts key cleanup', () async {
      when(mockSecureStorage.write(key: fileId, value: anyNamed('value')))
          .thenThrow(Exception('Secure storage fail'));
      final result = await service.encryptAndStoreFile(mockPlatformFile, user1Id);
      expect(result, isNull);
      verify(mockSecureStorage.delete(key: fileId)).called(1);
      verifyNever(mockFileSystemOps.writeFileAsBytes(any, any));
    });

    test('Test 5 (DB Save Fails): Returns null and cleans up file and key', () async {
      when(mockDbHelper.saveMedicalFileMetadata(any)).thenThrow(Exception('DB fail'));
      when(mockFileSystemOps.fileExists(encryptedFilePath)).thenAnswer((_) async => true);
      final result = await service.encryptAndStoreFile(mockPlatformFile, user1Id);
      expect(result, isNull);
      verify(mockSecureStorage.delete(key: fileId)).called(1);
      verify(mockFileSystemOps.deleteFile(encryptedFilePath)).called(1);
    });

    test('Test 6 (Zero-Byte File): Correctly encrypts and stores an empty file', () async {
      final emptyFileBytes = Uint8List(0);
      when(mockPlatformFile.size).thenReturn(0);
      when(mockFileSystemOps.readFileAsBytes(any)).thenAnswer((_) async => emptyFileBytes);

      final result = await service.encryptAndStoreFile(mockPlatformFile, user1Id);

      expect(result, isNotNull);
      expect(result!['fileId'], fileId);
      verify(mockSecureStorage.write(key: fileId, value: anyNamed('value'))).called(1);
      final capturedBytes = verify(mockFileSystemOps.writeFileAsBytes(encryptedFilePath, captureAny, flush: true)).captured.single as Uint8List;
      expect(capturedBytes.isNotEmpty, isTrue);
      verify(mockDbHelper.saveMedicalFileMetadata(any)).called(1);
    });

    test('Test 7 (Invalid UserID): Throws ArgumentError if userId is empty', () {
        expect(() => service.encryptAndStoreFile(mockPlatformFile, ''), throwsA(isA<ArgumentError>()));
    });
  });

  group('decryptFile', () {
    final fileId = 'file-to-decrypt';
    final key = Uint8List.fromList(List.generate(32, (i) => i));
    final iv = Uint8List.fromList(List.generate(12, (i) => i + 32));
    final keyIvString = '${bytesToHex(key)}:${bytesToHex(iv)}';
    final secureDirPath = '$mockAppDocumentsPath/$encryptedFilesDirName/$user1Id';
    final encryptedFilePath = '$secureDirPath/some-encrypted-file.enc';
    late pc.GCMBlockCipher cipher;

    setUp(() {
      cipher = pc.GCMBlockCipher(pc.AESEngine());
      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => keyIvString);
      when(mockDbHelper.getMedicalFileMetadataById(fileId))
          .thenAnswer((_) async => {DatabaseHelper.colEncryptedPath: encryptedFilePath});
      when(mockFileSystemOps.fileExists(encryptedFilePath)).thenAnswer((_) async => true);
      final encryptedData = Uint8List.fromList([4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]);
      when(mockFileSystemOps.readFileAsBytes(encryptedFilePath)).thenAnswer((_) async => encryptedData);
    });
    
    test('Test 1 (Happy Path): Successfully decrypts a file', () async {
      final plainText = Uint8List.fromList([10, 20, 30, 40, 50]);
      final params = pc.ParametersWithIV<pc.KeyParameter>(pc.KeyParameter(key), iv);
      cipher.init(true, params);
      final encryptedData = cipher.process(plainText);
      when(mockFileSystemOps.readFileAsBytes(encryptedFilePath)).thenAnswer((_) async => encryptedData);
      
      final result = await service.decryptFile(fileId, user1Id);

      expect(result, isNotNull);
      expect(result, equals(plainText));
    });

    test('Test 2 (Critical Security Test - Wrong User): Returns null for other user', () async {
        final mockDbHelperUser2 = MockDatabaseHelper();
        when(mockDbHelperUser2.getMedicalFileMetadataById(fileId)).thenAnswer((_) async => null);
        
        final serviceForUser2 = SecureFileStorageService(
            secureStorage: mockSecureStorage,
            uuid: mockUuid,
            logger: mockLogger,
            fileSystemOps: mockFileSystemOps,
            dbBuilder: (userId) {
              if (userId == user2Id) return mockDbHelperUser2;
              return mockDbHelper;
            });

        final result = await serviceForUser2.decryptFile(fileId, user2Id);
        expect(result, isNull);
        verifyNever(mockSecureStorage.read(key: fileId));
    });

    test('Test 3 (File Not Found): Returns null if encrypted file does not exist', () async {
      when(mockFileSystemOps.fileExists(encryptedFilePath)).thenAnswer((_) async => false);
      
      final result = await service.decryptFile(fileId, user1Id);
      
      expect(result, isNull);
      verifyNever(mockFileSystemOps.readFileAsBytes(any));
    });

    test('Test 4 (Key Not Found): Returns null if key is not in secure storage', () async {
      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => null);
      final result = await service.decryptFile(fileId, user1Id);
      expect(result, isNull);
    });

    test('Test 5 (Data Integrity Failure): Returns null for tampered data', () async {
      // The mock data must be at least 16 bytes long to avoid a RangeError
      // before the GCM tag check can occur.
      final tamperedData = Uint8List.fromList(List.generate(20, (i) => i)); // Invalid ciphertext
      when(mockFileSystemOps.readFileAsBytes(encryptedFilePath)).thenAnswer((_) async => tamperedData);

      final result = await service.decryptFile(fileId, user1Id);

      expect(result, isNull);
      verify(mockLogger.e(any, error: isA<pc.InvalidCipherTextException>(), stackTrace: anyNamed('stackTrace'))).called(1);
    });

    test('Test 6 (Malformed Data): Returns null if key/IV data is corrupted', () async {
      when(mockDbHelper.getMedicalFileMetadataById(fileId))
          .thenAnswer((_) async => {DatabaseHelper.colEncryptedPath: encryptedFilePath});
      
      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => 'bad-format-no-colon');
      var result = await service.decryptFile(fileId, user1Id);
      expect(result, isNull);
      
      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => 'not-hex:not-hex');
      result = await service.decryptFile(fileId, user1Id);
      expect(result, isNull);

      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => '010203:040506');
      result = await service.decryptFile(fileId, user1Id);
      expect(result, isNull);
    });

    test('Test 7 (No Metadata): Returns null if metadata is not in DB', () async {
      when(mockDbHelper.getMedicalFileMetadataById(fileId)).thenAnswer((_) async => null);
      
      final result = await service.decryptFile(fileId, user1Id);
      
      expect(result, isNull);
      verifyNever(mockSecureStorage.read(key: fileId));
    });

    test('Test 8 (Read Fails): Returns null if reading file from disk fails', () async {
      when(mockFileSystemOps.readFileAsBytes(encryptedFilePath)).thenThrow(Exception('Disk read error'));
      final result = await service.decryptFile(fileId, user1Id);
      expect(result, isNull);
      verify(mockLogger.e(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace'))).called(1);
    });

    test('Test 9 (Bad DB Path): Returns null if path from DB is null or empty', () async {
       when(mockDbHelper.getMedicalFileMetadataById(fileId))
          .thenAnswer((_) async => {DatabaseHelper.colEncryptedPath: ''});
       var result = await service.decryptFile(fileId, user1Id);
       expect(result, isNull);
       when(mockDbHelper.getMedicalFileMetadataById(fileId))
          .thenAnswer((_) async => {DatabaseHelper.colEncryptedPath: null});
       result = await service.decryptFile(fileId, user1Id);
       expect(result, isNull);
    });
  });

  group('deleteEncryptedFileAndKey', () {
    final fileId = 'file-to-delete';
    final path = '/path/to/delete.enc';

    test('Test 1 (Happy Path): Deletes file and key', () async {
      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => 'some-key');
      when(mockFileSystemOps.fileExists(path)).thenAnswer((_) async => true);
      final result = await service.deleteEncryptedFileAndKey(fileId, path);
      expect(result, isTrue);
      verify(mockFileSystemOps.deleteFile(path)).called(1);
      verify(mockSecureStorage.delete(key: fileId)).called(1);
    });
    
    test('Test 2a (Resource Already Gone - Key Gone): Returns true', () async {
      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => null);
      when(mockFileSystemOps.fileExists(path)).thenAnswer((_) async => true);
      final result = await service.deleteEncryptedFileAndKey(fileId, path);
      expect(result, isTrue);
      verifyNever(mockSecureStorage.delete(key: fileId));
      verify(mockFileSystemOps.deleteFile(path)).called(1);
    });

    test('Test 2b (Resource Already Gone - File Gone): Returns true', () async {
      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => 'some-key');
      when(mockFileSystemOps.fileExists(path)).thenAnswer((_) async => false);
      final result = await service.deleteEncryptedFileAndKey(fileId, path);
      expect(result, isTrue);
      verify(mockSecureStorage.delete(key: fileId)).called(1);
      verifyNever(mockFileSystemOps.deleteFile(path));
    });

    test('Test 2c (Resource Already Gone - Both Gone): Returns true', () async {
      when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => null);
      when(mockFileSystemOps.fileExists(path)).thenAnswer((_) async => false);
      final result = await service.deleteEncryptedFileAndKey(fileId, path);
      expect(result, isTrue);
      verifyNever(mockSecureStorage.delete(key: fileId));
      verifyNever(mockFileSystemOps.deleteFile(path));
    });

    test('Test 3 (Partial Failure): Returns false if file deletion throws', () async {
        when(mockSecureStorage.read(key: fileId)).thenAnswer((_) async => 'some-key');
        when(mockFileSystemOps.fileExists(path)).thenAnswer((_) async => true);
        when(mockFileSystemOps.deleteFile(path)).thenThrow(Exception('Cannot delete'));
        final result = await service.deleteEncryptedFileAndKey(fileId, path);
        expect(result, isFalse);
    });
  });
}

class TestableSecureFileStorageService extends SecureFileStorageService {
  PlatformFile? mockPickFileResult;
  
  TestableSecureFileStorageService({
    required FlutterSecureStorage secureStorage,
    required Uuid uuid,
    required Logger logger,
    required FileSystemOperations fileSystemOps,
    required DatabaseBuilder dbBuilder,
  }) : super(
          secureStorage: secureStorage,
          uuid: uuid,
          logger: logger,
          fileSystemOps: fileSystemOps,
          dbBuilder: dbBuilder,
        );

  @override
  Future<PlatformFile?> pickFile() async {
    return mockPickFileResult;
  }
} 