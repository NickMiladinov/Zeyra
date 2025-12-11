import 'package:drift/drift.dart';

import 'user_profile_table.dart';

/// Drift table for pregnancies.
///
/// Stores pregnancy dates and metadata.
/// Users can have multiple pregnancy records over time.
@DataClassName('PregnancyDto')
class Pregnancies extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Foreign key to UserProfiles
  TextColumn get userId =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  /// Last Menstrual Period date (millis since epoch)
  IntColumn get startDateMillis => integer()();

  /// Expected due date (millis since epoch)
  IntColumn get dueDateMillis => integer()();

  /// Selected hospital ID (nullable)
  TextColumn get selectedHospitalId => text().nullable()();

  /// When record was created (millis since epoch)
  IntColumn get createdAtMillis => integer()();

  /// When record was last updated (millis since epoch)
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
