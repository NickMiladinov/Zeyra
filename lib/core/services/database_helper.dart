import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Static setter for testing purposes
  static void setTestDatabase(Database? db) {
    _database = db;
  }

  static const String _dbName = 'medical_files.db';
  static const String tableName = 'medical_files'; // Made public for testing

  // Column names
  static const String colId = 'id';
  static const String colOriginalFilename = 'original_filename';
  static const String colFileType = 'file_type';
  static const String colDateAdded = 'date_added'; // Unix timestamp
  static const String colEncryptedPath = 'encrypted_path';
  static const String colFileSize = 'file_size_bytes';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // Placeholder for future schema migrations
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $colId TEXT PRIMARY KEY,
        $colOriginalFilename TEXT NOT NULL,
        $colFileType TEXT,
        $colDateAdded INTEGER NOT NULL,
        $colEncryptedPath TEXT NOT NULL UNIQUE,
        $colFileSize INTEGER
      )
    ''');
  }

  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   // For simplicity in MVP, drop and recreate. WARNING: THIS DELETES ALL EXISTING DATA.
  //   // In a production app, you'd implement proper migration logic.
  //   await db.execute("DROP TABLE IF EXISTS $tableName");
  //   await _onCreate(db, newVersion);
  // }

  /// Inserts metadata for a medical file into the database.
  Future<void> saveMedicalFileMetadata(Map<String, dynamic> metadata) async {
    final db = await database;
    await db.insert(
      tableName,
      metadata,
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if ID already exists
    );
  }

  /// Retrieves metadata for all medical files, ordered by date_added descending.
  Future<List<Map<String, dynamic>>> getMedicalFilesMetadata() async {
    final db = await database;
    return await db.query(
      tableName,
      orderBy: '$colDateAdded DESC',
    );
  }

  /// Retrieves metadata for a single medical file by its ID.
  Future<Map<String, dynamic>?> getMedicalFileMetadataById(String fileId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$colId = ?',
      whereArgs: [fileId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  /// Retrieves metadata for a single medical file by its original filename and size.
  /// Returns a Map if found, null otherwise.
  Future<Map<String, dynamic>?> getMedicalFileMetadataByFilenameAndSize(
      String originalFilename, int fileSize) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$colOriginalFilename = ? AND $colFileSize = ?',
      whereArgs: [originalFilename, fileSize],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  /// Deletes metadata for a medical file from the database by its ID.
  Future<void> deleteMedicalFileMetadata(String fileId) async {
    final db = await database;
    await db.delete(
      tableName,
      where: '$colId = ?',
      whereArgs: [fileId],
    );
  }

  // Close the database (optional, as sqflite handles this, but good for explicit resource management if needed)
  // Future<void> close() async {
  //   final db = await database;
  //   db.close();
  //   _database = null;
  // }
} 