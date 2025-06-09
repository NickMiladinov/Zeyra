import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

/// Manages a user-specific SQLite database for storing medical file metadata.
/// Each user gets their own database file, ensuring complete data isolation.
class DatabaseHelper {
  final String userId;
  Database? _database;

  /// Creates an instance of DatabaseHelper for a specific user.
  ///
  /// For testing purposes, an existing database connection can be supplied.
  DatabaseHelper(this.userId, {Database? testDb}) : _database = testDb;

  static const String _dbName = 'medical_files.db';
  static const int _dbVersion = 1; // Start with version 1 for the new schema
  static const String tableName = 'medical_files';

  // Column names
  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colOriginalFilename = 'original_filename';
  static const String colFileType = 'file_type';
  static const String colCreatedAt = 'created_at';
  static const String colEncryptedPath = 'encrypted_path';
  static const String colFileSize = 'file_size_bytes';
  static const String colLastModifiedAt = 'last_modified_at';
  static const String colVersion = 'version';
  static const String colDeletedAt = 'deleted_at'; // for soft deletes

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // Create a user-specific directory to store the database file.
    String userDbDir = join(documentsDirectory.path, 'user_databases', userId);
    await Directory(userDbDir).create(recursive: true);
    String path = join(userDbDir, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $colId TEXT PRIMARY KEY,
        $colUserId TEXT NOT NULL,
        $colOriginalFilename TEXT NOT NULL,
        $colFileType TEXT,
        $colCreatedAt TEXT NOT NULL,
        $colEncryptedPath TEXT NOT NULL UNIQUE,
        $colFileSize INTEGER,
        $colLastModifiedAt TEXT NOT NULL,
        $colVersion INTEGER NOT NULL DEFAULT 1,
        $colDeletedAt TEXT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // In a real app, you would have a more robust migration strategy.
    // For now, we just drop and recreate.
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await _onCreate(db, newVersion);
  }

  /// Inserts or replaces metadata for a medical file.
  Future<void> saveMedicalFileMetadata(Map<String, dynamic> metadata) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();

    // Ensure system-managed fields are set correctly.
    metadata[colCreatedAt] = metadata[colCreatedAt] ?? now;
    metadata[colLastModifiedAt] = now;
    metadata[colVersion] = (metadata[colVersion] ?? 0) + 1; // Ensure version is handled

    await db.insert(
      tableName,
      metadata,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves metadata for all non-deleted medical files for the current user.
  Future<List<Map<String, dynamic>>> getMedicalFilesMetadata() async {
    final db = await database;
    return await db.query(
      tableName,
      where: '$colUserId = ? AND $colDeletedAt IS NULL',
      whereArgs: [userId],
      orderBy: '$colCreatedAt DESC',
    );
  }

  /// Retrieves metadata for a single non-deleted medical file by its ID.
  Future<Map<String, dynamic>?> getMedicalFileMetadataById(String fileId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$colId = ? AND $colUserId = ? AND $colDeletedAt IS NULL',
      whereArgs: [fileId, userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  /// Checks for a non-deleted duplicate file by filename and size for the user.
  Future<Map<String, dynamic>?> getMedicalFileMetadataByFilenameAndSize(
      String originalFilename, int fileSize) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where:
          '$colOriginalFilename = ? AND $colFileSize = ? AND $colUserId = ? AND $colDeletedAt IS NULL',
      whereArgs: [originalFilename, fileSize, userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  /// Soft deletes metadata for a medical file by its ID.
  Future<void> deleteMedicalFileMetadata(String fileId) async {
    final db = await database;
    final record = await getMedicalFileMetadataById(fileId);
    if (record == null) return; // Record doesn't exist or is already deleted

    final now = DateTime.now().toUtc().toIso8601String();
    final currentVersion = record[colVersion] as int;

    await db.update(
      tableName,
      {
        colDeletedAt: now,
        colLastModifiedAt: now,
        colVersion: currentVersion + 1,
      },
      where: '$colId = ? AND $colUserId = ?',
      whereArgs: [fileId, userId],
    );
  }
} 