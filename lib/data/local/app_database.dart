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
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          // Create all tables from scratch
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migration strategy for future schema versions
          // Add migrations here as schema evolves
          // Example:
          // if (from == 1 && to == 2) {
          //   await m.addColumn(kicks, kicks.newColumn);
          // }
          // if (from <= 2 && to == 3) {
          //   await m.createTable(newTable);
          // }
        },
        beforeOpen: (details) async {
          // Enable foreign key constraints
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
