import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zeyra/core/services/database_helper.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// --- Mocking for path_provider ---
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.'; // Use a temporary directory for tests
  }
}

Future<void> executeTableCreation(Database db) async {
  await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableName} (
        ${DatabaseHelper.colId} TEXT PRIMARY KEY,
        ${DatabaseHelper.colUserId} TEXT NOT NULL,
        ${DatabaseHelper.colOriginalFilename} TEXT NOT NULL,
        ${DatabaseHelper.colFileType} TEXT,
        ${DatabaseHelper.colCreatedAt} TEXT NOT NULL,
        ${DatabaseHelper.colEncryptedPath} TEXT NOT NULL UNIQUE,
        ${DatabaseHelper.colFileSize} INTEGER,
        ${DatabaseHelper.colLastModifiedAt} TEXT NOT NULL,
        ${DatabaseHelper.colVersion} INTEGER NOT NULL DEFAULT 1,
        ${DatabaseHelper.colDeletedAt} TEXT NULL
      )
    ''');
}

// Helper to generate mock metadata for tests
Map<String, dynamic> _generateMockMetadata({
  String? id,
  required String userId,
  String originalFilename = 'test_file.pdf',
  String fileType = 'pdf',
  String? createdAt,
  String? encryptedPath,
  int fileSize = 1024,
  int? version, // Nullable to test db default
  String? lastModifiedAt,
  String? deletedAt,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  final fileId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  return {
    DatabaseHelper.colId: fileId,
    DatabaseHelper.colUserId: userId,
    DatabaseHelper.colOriginalFilename: originalFilename,
    DatabaseHelper.colFileType: fileType,
    DatabaseHelper.colCreatedAt: createdAt ?? now,
    DatabaseHelper.colEncryptedPath: encryptedPath ?? '/secure/path/to/$fileId.enc',
    DatabaseHelper.colFileSize: fileSize,
    if (version != null) DatabaseHelper.colVersion: version,
    DatabaseHelper.colLastModifiedAt: lastModifiedAt ?? now,
    DatabaseHelper.colDeletedAt: deletedAt,
  };
}

void main() {
  // Initialize FFI for sqflite
  sqfliteFfiInit();
  // Use the FFI database factory
  databaseFactory = databaseFactoryFfi;

  // Use a mock path provider for all tests
  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  group('DatabaseHelper Initialization & Structure', () {
    test('Test 1 (Creates User-Specific Database)', () async {
      final dbHelper = DatabaseHelper('user-a');
      final db = await dbHelper.database;
      // Use path.join to create an OS-agnostic path segment
      final expectedPathSegment = path.join('user_databases', 'user-a', 'medical_files.db');
      expect(db.path, contains(expectedPathSegment));
      await dbHelper.close(); // Clean up using the new method
    });

    test('Test 2 (Table Creation on _onCreate)', () async {
      final helper = DatabaseHelper('test-user');
      // Getting the database triggers _initDatabase and _onCreate
      final freshDb = await helper.database;
      
      final List<Map<String, dynamic>> tableInfo =
          await freshDb.rawQuery("PRAGMA table_info(${DatabaseHelper.tableName})");

      final columnNames = tableInfo.map((c) => c['name']).toList();
      expect(columnNames, containsAll([
        'id', 'user_id', 'original_filename', 'file_type', 'created_at',
        'encrypted_path', 'file_size_bytes', 'last_modified_at', 'version', 'deleted_at'
      ]));
      expect(tableInfo.firstWhere((c) => c['name'] == 'version')['dflt_value'], '1');
      await helper.close();
    });
  });

  group('saveMedicalFileMetadata Tests', () {
    late Database db;
    late DatabaseHelper dbHelper;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await executeTableCreation(db);
      dbHelper = DatabaseHelper('user-a', testDb: db);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Test 1 (Successful Insert)', () async {
      final metadata = _generateMockMetadata(id: 'file1', userId: 'user-a');
      await dbHelper.saveMedicalFileMetadata(metadata);
      final result = await db.query(DatabaseHelper.tableName);
      
      expect(result.length, 1);
      expect(result.first[DatabaseHelper.colId], 'file1');
      expect(result.first[DatabaseHelper.colVersion], 1, reason: "Initial version should be 1");
      expect(result.first[DatabaseHelper.colCreatedAt], isNotNull);
      expect(result.first[DatabaseHelper.colLastModifiedAt], isNotNull);
    });

    test('Test 2 (Successful Update)', () async {
      final metadata1 = _generateMockMetadata(id: 'file1', userId: 'user-a', version: 1);
      await db.insert(DatabaseHelper.tableName, metadata1);
      
      final firstSave = (await db.query(DatabaseHelper.tableName)).first;
      final versionBefore = firstSave[DatabaseHelper.colVersion] as int;
      expect(versionBefore, 1);

      final metadata2 = _generateMockMetadata(id: 'file1', userId: 'user-a', originalFilename: 'updated.pdf');
      metadata2[DatabaseHelper.colVersion] = versionBefore;
      
      await Future.delayed(const Duration(milliseconds: 10));
      await dbHelper.saveMedicalFileMetadata(metadata2);
      
      final result = (await db.query(DatabaseHelper.tableName)).first;
      expect(result[DatabaseHelper.colOriginalFilename], 'updated.pdf');
      expect(result[DatabaseHelper.colVersion], versionBefore + 1, reason: "Version should increment on update");
      expect(result[DatabaseHelper.colLastModifiedAt], isNot(firstSave[DatabaseHelper.colLastModifiedAt]));
    });

    test('Test 3 (Constraint Violation)', () async {
      final metadata = _generateMockMetadata(id: 'file1', userId: 'user-a');
      metadata.remove(DatabaseHelper.colUserId);
      
      expect(
        () => dbHelper.saveMedicalFileMetadata(metadata),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('getMedicalFileMetadata Tests', () {
     late Database db;
     late DatabaseHelper dbHelper;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await executeTableCreation(db);
      dbHelper = DatabaseHelper('user-a', testDb: db);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Test 1 (Empty Database)', () async {
      var result = await dbHelper.getMedicalFilesMetadata();
      expect(result, isEmpty);

      final metadata = _generateMockMetadata(id: 'file1', userId: 'user-a');
      await dbHelper.saveMedicalFileMetadata(metadata);
      await dbHelper.deleteMedicalFileMetadata('file1');

      result = await dbHelper.getMedicalFilesMetadata();
      expect(result, isEmpty);
    });

    test('Test 2 (Correct Ordering)', () async {
      await dbHelper.saveMedicalFileMetadata(_generateMockMetadata(id: 'f1', userId: 'user-a', createdAt: '2023-01-01T10:00:00Z'));
      await dbHelper.saveMedicalFileMetadata(_generateMockMetadata(id: 'f2', userId: 'user-a', createdAt: '2023-01-01T12:00:00Z'));
      await dbHelper.saveMedicalFileMetadata(_generateMockMetadata(id: 'f3', userId: 'user-a', createdAt: '2023-01-01T11:00:00Z'));

      final result = await dbHelper.getMedicalFilesMetadata();
      expect(result.map((r) => r[DatabaseHelper.colId]).toList(), ['f2', 'f3', 'f1']);
    });
    
    test('Test 3 (Excludes Soft-Deleted Files)', () async {
      await dbHelper.saveMedicalFileMetadata(_generateMockMetadata(id: 'f1', userId: 'user-a'));
      await dbHelper.saveMedicalFileMetadata(_generateMockMetadata(id: 'f2', userId: 'user-a'));
      await dbHelper.saveMedicalFileMetadata(_generateMockMetadata(id: 'f3', userId: 'user-a'));
      
      await dbHelper.deleteMedicalFileMetadata('f2');

      final allFiles = await dbHelper.getMedicalFilesMetadata();
      expect(allFiles.length, 2);
      expect(allFiles.any((f) => f[DatabaseHelper.colId] == 'f2'), isFalse);

      final singleFile = await dbHelper.getMedicalFileMetadataById('f2');
      expect(singleFile, isNull);
    });
  });

  group('deleteMedicalFileMetadata (Soft Delete) Tests', () {
    late Database db;
    late DatabaseHelper dbHelper;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await executeTableCreation(db);
      dbHelper = DatabaseHelper('user-a', testDb: db);
      await dbHelper.saveMedicalFileMetadata(_generateMockMetadata(id: 'file1', userId: 'user-a'));
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Test 1 (Successful Soft Delete)', () async {
      final recordBefore = (await db.query(DatabaseHelper.tableName, where: "id = 'file1'")).first;
      final versionBefore = recordBefore[DatabaseHelper.colVersion] as int;
      final modifiedAtBefore = recordBefore[DatabaseHelper.colLastModifiedAt] as String;

      await dbHelper.deleteMedicalFileMetadata('file1');
      
      final recordAfter = (await db.query(DatabaseHelper.tableName, where: "id = 'file1'")).first;
      expect(recordAfter[DatabaseHelper.colDeletedAt], isNotNull);
      expect(recordAfter[DatabaseHelper.colVersion], versionBefore + 1);
      expect(recordAfter[DatabaseHelper.colLastModifiedAt], isNot(modifiedAtBefore));
    });

    test('Test 2 (Non-Existent ID)', () async {
      final recordCountBefore = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.tableName}'));
      await expectLater(dbHelper.deleteMedicalFileMetadata('non-existent-id'), completes);
      final recordCountAfter = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.tableName}'));
      expect(recordCountAfter, recordCountBefore);
    });

    test('Test 3 (Idempotent)', () async {
      await dbHelper.deleteMedicalFileMetadata('file1');
      final recordAfterFirstDelete = (await db.query(DatabaseHelper.tableName, where: "id = 'file1'")).first;
      final deletedAt1 = recordAfterFirstDelete[DatabaseHelper.colDeletedAt];
      final version1 = recordAfterFirstDelete[DatabaseHelper.colVersion];

      await dbHelper.deleteMedicalFileMetadata('file1');
      final recordAfterSecondDelete = (await db.query(DatabaseHelper.tableName, where: "id = 'file1'")).first;
      final deletedAt2 = recordAfterSecondDelete[DatabaseHelper.colDeletedAt];
      final version2 = recordAfterSecondDelete[DatabaseHelper.colVersion];

      expect(deletedAt2, deletedAt1);
      expect(version2, version1);
    });
  });

  group('User Data Isolation Tests', () {
    late Database db;
    late DatabaseHelper dbHelperUserA;
    late DatabaseHelper dbHelperUserB;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await executeTableCreation(db);
      dbHelperUserA = DatabaseHelper('user-a', testDb: db);
      dbHelperUserB = DatabaseHelper('user-b', testDb: db);

      await dbHelperUserA.saveMedicalFileMetadata(_generateMockMetadata(id: 'file-a1', userId: 'user-a'));
      await dbHelperUserA.saveMedicalFileMetadata(_generateMockMetadata(id: 'file-a2', userId: 'user-a'));
      await dbHelperUserB.saveMedicalFileMetadata(_generateMockMetadata(id: 'file-b1', userId: 'user-b'));
    });

    tearDown(() async {
      // Closing one helper will close the shared db instance.
      await dbHelperUserA.close();
    });

    test('Test 1 (Get All Files)', () async {
      final filesA = await dbHelperUserA.getMedicalFilesMetadata();
      expect(filesA.length, 2);
      expect(filesA.every((f) => f[DatabaseHelper.colUserId] == 'user-a'), isTrue);

      final filesB = await dbHelperUserB.getMedicalFilesMetadata();
      expect(filesB.length, 1);
      expect(filesB.first[DatabaseHelper.colUserId], 'user-b');
    });

    test('Test 2 (Get File by ID)', () async {
      var fileA = await dbHelperUserA.getMedicalFileMetadataById('file-a1');
      expect(fileA, isNotNull);
      
      fileA = await dbHelperUserA.getMedicalFileMetadataById('file-b1');
      expect(fileA, isNull);
    });

    test('Test 3 (Delete File)', () async {
      await dbHelperUserA.deleteMedicalFileMetadata('file-b1');
      
      final fileB = await dbHelperUserB.getMedicalFileMetadataById('file-b1');
      expect(fileB, isNotNull);
      expect(fileB![DatabaseHelper.colDeletedAt], isNull);
    });

    test('Test 4 (Duplicate Check)', () async {
      await dbHelperUserA.saveMedicalFileMetadata(_generateMockMetadata(id: 'dup-a', userId: 'user-a', originalFilename: 'report.pdf', fileSize: 500));
      await dbHelperUserB.saveMedicalFileMetadata(_generateMockMetadata(id: 'dup-b', userId: 'user-b', originalFilename: 'report.pdf', fileSize: 500));
       
      var duplicateA = await dbHelperUserA.getMedicalFileMetadataByFilenameAndSize('report.pdf', 500);
      expect(duplicateA, isNotNull);
      expect(duplicateA![DatabaseHelper.colId], 'dup-a');
      
      final dbHelperUserC = DatabaseHelper('user-c', testDb: db);
      var duplicateC = await dbHelperUserC.getMedicalFileMetadataByFilenameAndSize('report.pdf', 500);
      expect(duplicateC, isNull);
    });
  });
}

// A simple way to allow DatabaseHelper's static _database to be overridden for tests.
// Add this static setter to your DatabaseHelper class:
/*
  static set database(Database? db) {
    _database = db;
  }
*/ 