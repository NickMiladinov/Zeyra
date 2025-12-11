import '../entities/pregnancy/pregnancy.dart';

/// Repository interface for pregnancy operations.
///
/// Manages pregnancy records for the authenticated user.
/// Supports multiple pregnancies over time.
abstract class PregnancyRepository {
  /// Get the currently active pregnancy.
  ///
  /// "Active" is defined as the most recent pregnancy (by startDate).
  /// Returns null if no pregnancies exist.
  Future<Pregnancy?> getActivePregnancy();

  /// Get a specific pregnancy by ID.
  ///
  /// Returns null if not found.
  Future<Pregnancy?> getPregnancyById(String id);

  /// Get all pregnancies for the user.
  ///
  /// Returns pregnancies ordered by startDate descending (most recent first).
  Future<List<Pregnancy>> getAllPregnancies();

  /// Create a new pregnancy.
  ///
  /// [pregnancy] - The pregnancy to create
  ///
  /// Validates date ranges before creation.
  /// Throws [PregnancyException] for invalid dates.
  Future<Pregnancy> createPregnancy(Pregnancy pregnancy);

  /// Update an existing pregnancy.
  ///
  /// [pregnancy] - The updated pregnancy
  ///
  /// Validates date ranges before update.
  /// Updates the updatedAt timestamp automatically.
  Future<Pregnancy> updatePregnancy(Pregnancy pregnancy);

  /// Delete a pregnancy.
  ///
  /// [pregnancyId] - ID of the pregnancy to delete
  Future<void> deletePregnancy(String pregnancyId);
}
