import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zeyra/core/services/database_helper.dart'; // Adjust path as needed

// Mock data generator
Map<String, dynamic> _generateMockMetadata({
  String? id,
  String originalFilename = 'test_file.pdf',
  String fileType = 'pdf',
  int? dateAdded,
  String encryptedPath = '/secure/path/to/encrypted_file.enc',
  int fileSize = 1024,
}) {
  return {
    DatabaseHelper.colId: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    DatabaseHelper.colOriginalFilename: originalFilename,
    DatabaseHelper.colFileType: fileType,
    DatabaseHelper.colDateAdded: dateAdded ?? DateTime.now().millisecondsSinceEpoch,
    DatabaseHelper.colEncryptedPath: encryptedPath,
    DatabaseHelper.colFileSize: fileSize,
  };
}

void main() {
  sqfliteFfiInit();

  Database? db;
  late DatabaseHelper databaseHelper;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db!.execute('''
      CREATE TABLE ${DatabaseHelper.tableName} (
        ${DatabaseHelper.colId} TEXT PRIMARY KEY,
        ${DatabaseHelper.colOriginalFilename} TEXT NOT NULL,
        ${DatabaseHelper.colFileType} TEXT,
        ${DatabaseHelper.colDateAdded} INTEGER NOT NULL,
        ${DatabaseHelper.colEncryptedPath} TEXT NOT NULL UNIQUE,
        ${DatabaseHelper.colFileSize} INTEGER
      )
    ''');
    databaseHelper = DatabaseHelper();
    DatabaseHelper.setTestDatabase(db);
  });

  tearDown(() async {
    await db!.close();
    DatabaseHelper.setTestDatabase(null);
  });

  group('DatabaseHelper Initialization & Structure', () {
    test('Table is created with correct columns', () async {
      final List<Map<String, dynamic>> tableInfo = await db!.rawQuery(
        "PRAGMA table_info(${DatabaseHelper.tableName})",
      );
      expect(tableInfo.length, 6);
      expect(tableInfo.any((col) => col['name'] == DatabaseHelper.colId && col['pk'] == 1), isTrue);
      expect(tableInfo.any((col) => col['name'] == DatabaseHelper.colOriginalFilename && col['notnull'] == 1), isTrue);
      expect(tableInfo.any((col) => col['name'] == DatabaseHelper.colFileType), isTrue);
      expect(tableInfo.any((col) => col['name'] == DatabaseHelper.colDateAdded && col['notnull'] == 1), isTrue);
      expect(tableInfo.any((col) => col['name'] == DatabaseHelper.colEncryptedPath && col['notnull'] == 1), isTrue);
      expect(tableInfo.any((col) => col['name'] == DatabaseHelper.colFileSize), isTrue);
    });
  });

  group('saveMedicalFileMetadata Tests', () {
    test('Successfully inserts a single valid metadata entry', () async {
      final metadata = _generateMockMetadata(id: 'file1');
      await databaseHelper.saveMedicalFileMetadata(metadata);
      final List<Map<String, dynamic>> result = await db!.query(DatabaseHelper.tableName);
      expect(result.length, 1);
      expect(result.first[DatabaseHelper.colId], 'file1');
    });

    test('Successfully inserts multiple metadata entries', () async {
      final metadata1 = _generateMockMetadata(
        id: 'file1',
        encryptedPath: '/secure/path/to/encrypted_file1.enc' // Unique path
      );
      final metadata2 = _generateMockMetadata(
        id: 'file2',
        originalFilename: 'report.txt',
        encryptedPath: '/secure/path/to/encrypted_file2.enc' // Unique path
      );
      await databaseHelper.saveMedicalFileMetadata(metadata1);
      await databaseHelper.saveMedicalFileMetadata(metadata2);
      final List<Map<String, dynamic>> result = await databaseHelper.getMedicalFilesMetadata();
      expect(result.length, 2);
    });

    test('Replaces entry on duplicate ID (due to ConflictAlgorithm.replace)', () async {
      final metadata1 = _generateMockMetadata(id: 'file1', originalFilename: 'first.pdf');
      await databaseHelper.saveMedicalFileMetadata(metadata1);
      final metadata2 = _generateMockMetadata(id: 'file1', originalFilename: 'updated_first.pdf');
      await databaseHelper.saveMedicalFileMetadata(metadata2);
      final List<Map<String, dynamic>> result = await db!.query(DatabaseHelper.tableName, where: '${DatabaseHelper.colId} = ?', whereArgs: ['file1']);
      expect(result.length, 1);
      expect(result.first[DatabaseHelper.colOriginalFilename], 'updated_first.pdf');
    });

    test('Throws error if NOT NULL constraint is violated (original_filename)', () async {
      final Map<String, Object?> invalidMetadata = {
         DatabaseHelper.colId: 'some_id',
         DatabaseHelper.colOriginalFilename: null,
         DatabaseHelper.colFileType: 'txt',
         DatabaseHelper.colDateAdded: DateTime.now().millisecondsSinceEpoch,
         DatabaseHelper.colEncryptedPath: '/path/to/file.enc',
         DatabaseHelper.colFileSize: 100,
      };
      expect(
        () async => await databaseHelper.saveMedicalFileMetadata(invalidMetadata),
        throwsA(isA<DatabaseException>().having(
              (e) => e.isNotNullConstraintError() || (e.toString().contains('NOT NULL constraint failed') && e.toString().contains(DatabaseHelper.colOriginalFilename)),
              'isNotNullConstraintError for original_filename',
              isTrue
        )),
      );
    });
  });

  group('getMedicalFilesMetadata Tests', () {
    test('Returns empty list when database is empty', () async {
      final List<Map<String, dynamic>> result = await databaseHelper.getMedicalFilesMetadata();
      expect(result, isEmpty);
    });

    test('Returns entries ordered by date_added descending', () async {
      final metadata1 = _generateMockMetadata(
        id: 'file1', 
        dateAdded: DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
        encryptedPath: '/secure/path/to/encrypted_file1.enc' 
      );
      final metadata2 = _generateMockMetadata(
        id: 'file2', 
        dateAdded: DateTime.now().millisecondsSinceEpoch,
        encryptedPath: '/secure/path/to/encrypted_file2.enc'
      );
      final metadata3 = _generateMockMetadata(
        id: 'file3', 
        dateAdded: DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch,
        encryptedPath: '/secure/path/to/encrypted_file3.enc'
      );

      await databaseHelper.saveMedicalFileMetadata(metadata1);
      await databaseHelper.saveMedicalFileMetadata(metadata2);
      await databaseHelper.saveMedicalFileMetadata(metadata3);

      final List<Map<String, dynamic>> result = await databaseHelper.getMedicalFilesMetadata();
      expect(result.length, 3);
      expect(result[0][DatabaseHelper.colId], 'file2');
      expect(result[1][DatabaseHelper.colId], 'file3');
      expect(result[2][DatabaseHelper.colId], 'file1');
    });

    test('Retrieves all fields correctly', () async {
      final metadata = _generateMockMetadata(
        id: 'fileFull',
        originalFilename: 'medical_report.hl7',
        fileType: 'hl7',
        dateAdded: 1678886400000,
        encryptedPath: '/secure/medical_report.enc',
        fileSize: 2048
      );
      await databaseHelper.saveMedicalFileMetadata(metadata);

      final List<Map<String, dynamic>> result = await databaseHelper.getMedicalFilesMetadata();
      expect(result.length, 1);
      final Map<String,dynamic> retrieved = result.first;

      expect(retrieved[DatabaseHelper.colId], 'fileFull');
      expect(retrieved[DatabaseHelper.colOriginalFilename], 'medical_report.hl7');
      expect(retrieved[DatabaseHelper.colFileType], 'hl7');
      expect(retrieved[DatabaseHelper.colDateAdded], 1678886400000);
      expect(retrieved[DatabaseHelper.colEncryptedPath], '/secure/medical_report.enc');
      expect(retrieved[DatabaseHelper.colFileSize], 2048);
    });
  });

  group('deleteMedicalFileMetadata Tests', () {
    test('Successfully deletes an existing entry', () async {
      final metadata = _generateMockMetadata(id: 'fileToDelete');
      await databaseHelper.saveMedicalFileMetadata(metadata);
      await databaseHelper.deleteMedicalFileMetadata('fileToDelete');
      final List<Map<String, dynamic>> result = await databaseHelper.getMedicalFilesMetadata();
      expect(result, isEmpty);
    });

    test('Deleting non-existent ID does not error and DB is unchanged', () async {
      final metadata = _generateMockMetadata(id: 'fileToKeep');
      await databaseHelper.saveMedicalFileMetadata(metadata);
      await databaseHelper.deleteMedicalFileMetadata('nonExistentId');
      final List<Map<String, dynamic>> result = await databaseHelper.getMedicalFilesMetadata();
      expect(result.length, 1);
      expect(result.first[DatabaseHelper.colId], 'fileToKeep');
    });
  });

  group('Integrated Flow Tests', () {
    test('Add-Retrieve-Delete cycle', () async {
      final String testId = 'cycleTestId';
      final metadata = _generateMockMetadata(id: testId, originalFilename: 'cycle_doc.txt');
      await databaseHelper.saveMedicalFileMetadata(metadata);
      Map<String, dynamic>? retrieved = await databaseHelper.getMedicalFileMetadataById(testId);
      expect(retrieved, isNotNull);
      expect(retrieved![DatabaseHelper.colOriginalFilename], 'cycle_doc.txt');
      await databaseHelper.deleteMedicalFileMetadata(testId);
      retrieved = await databaseHelper.getMedicalFileMetadataById(testId);
      expect(retrieved, isNull);
      final List<Map<String, dynamic>> allFiles = await databaseHelper.getMedicalFilesMetadata();
      expect(allFiles, isEmpty);
    });

    test('Multiple operations: Add, Delete some, Add more, Retrieve all', () async {
      final m1 = _generateMockMetadata(id: 'multi1', dateAdded: 100, encryptedPath: '/secure/multi1.enc');
      final m2 = _generateMockMetadata(id: 'multi2', dateAdded: 200, encryptedPath: '/secure/multi2.enc');
      final m3 = _generateMockMetadata(id: 'multi3', dateAdded: 300, encryptedPath: '/secure/multi3.enc');

      await databaseHelper.saveMedicalFileMetadata(m1);
      await databaseHelper.saveMedicalFileMetadata(m2);
      await databaseHelper.saveMedicalFileMetadata(m3);
      expect((await databaseHelper.getMedicalFilesMetadata()).length, 3);

      // Delete some
      await databaseHelper.deleteMedicalFileMetadata('multi2');
      expect((await databaseHelper.getMedicalFilesMetadata()).length, 2);

      // Add more
      final m4 = _generateMockMetadata(id: 'multi4', dateAdded: 50, encryptedPath: '/secure/multi4.enc'); // oldest
      final m5 = _generateMockMetadata(id: 'multi5', dateAdded: 400, encryptedPath: '/secure/multi5.enc'); // newest
      await databaseHelper.saveMedicalFileMetadata(m4);
      await databaseHelper.saveMedicalFileMetadata(m5);
      
      final List<Map<String, dynamic>> finalResult = await databaseHelper.getMedicalFilesMetadata();
      expect(finalResult.length, 4);
      expect(finalResult[0][DatabaseHelper.colId], 'multi5'); // newest
      expect(finalResult[1][DatabaseHelper.colId], 'multi3');
      expect(finalResult[2][DatabaseHelper.colId], 'multi1');
      expect(finalResult[3][DatabaseHelper.colId], 'multi4'); // oldest
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