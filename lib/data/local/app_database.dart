import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/kick_counter_dao.dart';
import 'models/kick_session_table.dart';
import 'models/kick_table.dart';

part 'app_database.g.dart';

/// Main database for the Zeyra app.
/// 
/// Uses Drift for type-safe SQL queries with automatic code generation.
/// Includes all app tables and DAOs for medical data tracking.
@DriftDatabase(
  tables: [
    // Kick counter feature
    KickSessions,
    Kicks,
  ],
  daos: [
    // Kick counter DAO
    KickCounterDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing with in-memory database
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // TODO: Add migration logic when schema changes
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Opens a connection to the database.
/// 
/// Stores database file in app documents directory.
/// File: zeyra_app.db
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'zeyra_app.db'));
    return NativeDatabase(file);
  });
}
