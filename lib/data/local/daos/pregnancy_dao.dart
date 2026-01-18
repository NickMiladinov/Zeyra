import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/pregnancy_table.dart';

part 'pregnancy_dao.g.dart';

/// Data Access Object for pregnancy operations.
@DriftAccessor(tables: [Pregnancies])
class PregnancyDao extends DatabaseAccessor<AppDatabase>
    with _$PregnancyDaoMixin {
  PregnancyDao(super.db);

  /// Get the most recent pregnancy (by startDate).
  Future<PregnancyDto?> getActivePregnancy() {
    return (select(pregnancies)
          ..orderBy([(p) => OrderingTerm.desc(p.startDateMillis)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get a pregnancy by ID.
  Future<PregnancyDto?> getPregnancyById(String id) {
    return (select(pregnancies)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all pregnancies ordered by start date descending.
  Future<List<PregnancyDto>> getAllPregnancies() {
    return (select(pregnancies)
          ..orderBy([(p) => OrderingTerm.desc(p.startDateMillis)]))
        .get();
  }

  /// Insert a new pregnancy.
  Future<PregnancyDto> insertPregnancy(PregnancyDto pregnancy) {
    return into(pregnancies).insertReturning(pregnancy);
  }

  /// Update an existing pregnancy.
  Future<int> updatePregnancy(PregnancyDto pregnancy) {
    return (update(pregnancies)..where((p) => p.id.equals(pregnancy.id)))
        .write(pregnancy.toCompanion(false));
  }

  /// Delete a pregnancy.
  Future<int> deletePregnancy(String id) {
    return (delete(pregnancies)..where((p) => p.id.equals(id))).go();
  }

  /// Delete all pregnancies for a specific user.
  ///
  /// Used to clean up stale data when a different user logs in.
  Future<int> deletePregnanciesByUserId(String userId) {
    return (delete(pregnancies)..where((p) => p.userId.equals(userId))).go();
  }
}
