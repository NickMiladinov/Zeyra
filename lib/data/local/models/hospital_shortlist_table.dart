import 'package:drift/drift.dart';

import 'maternity_unit_table.dart';

/// Drift table for user's shortlisted hospitals.
///
/// Tracks hospitals the user has saved for consideration and their
/// final selection for birth.
@DataClassName('HospitalShortlistDto')
class HospitalShortlists extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Reference to the maternity unit.
  TextColumn get maternityUnitId =>
      text().references(MaternityUnits, #id)();

  /// When this hospital was added to the shortlist (millis since epoch).
  IntColumn get addedAtMillis => integer()();

  /// Whether this is the final selected hospital.
  BoolColumn get isSelected => boolean().withDefault(const Constant(false))();

  /// Optional user notes about this hospital.
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
