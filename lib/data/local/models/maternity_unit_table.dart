import 'package:drift/drift.dart';

/// Drift table for maternity units from CQC database.
///
/// Stores all maternity location data synced from Supabase, including
/// location details, CQC ratings, and contact information.
@DataClassName('MaternityUnitDto')
class MaternityUnits extends Table {
  /// UUID primary key (local).
  TextColumn get id => text()();

  /// CQC unique location identifier.
  TextColumn get cqcLocationId => text().unique()();

  /// CQC provider ID.
  TextColumn get cqcProviderId => text().nullable()();

  /// NHS ODS code.
  TextColumn get odsCode => text().nullable()();

  /// Name of the maternity unit.
  TextColumn get name => text()();

  /// Provider/Trust name.
  TextColumn get providerName => text().nullable()();

  /// Type: "nhs_hospital" or "independent_hospital".
  TextColumn get unitType => text()();

  /// Whether this is an NHS facility.
  BoolColumn get isNhs => boolean().withDefault(const Constant(true))();

  // Address fields
  TextColumn get addressLine1 => text().nullable()();
  TextColumn get addressLine2 => text().nullable()();
  TextColumn get townCity => text().nullable()();
  TextColumn get county => text().nullable()();
  TextColumn get postcode => text().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get localAuthority => text().nullable()();

  // Geolocation (stored as REAL for efficient queries)
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  // Contact
  TextColumn get phone => text().nullable()();
  TextColumn get website => text().nullable()();

  // CQC Ratings
  TextColumn get overallRating => text().nullable()();
  TextColumn get ratingSafe => text().nullable()();
  TextColumn get ratingEffective => text().nullable()();
  TextColumn get ratingCaring => text().nullable()();
  TextColumn get ratingResponsive => text().nullable()();
  TextColumn get ratingWellLed => text().nullable()();
  TextColumn get maternityRating => text().nullable()();
  TextColumn get maternityRatingDate => text().nullable()();

  // CQC Metadata
  TextColumn get lastInspectionDate => text().nullable()();
  TextColumn get cqcReportUrl => text().nullable()();
  TextColumn get registrationStatus => text().nullable()();

  // PLACE Ratings (Patient-Led Assessments of the Care Environment)
  // Values are percentages (0-100), null if no PLACE data available
  RealColumn get placeCleanliness => real().nullable()();
  RealColumn get placeFood => real().nullable()();
  RealColumn get placePrivacyDignityWellbeing => real().nullable()();
  RealColumn get placeConditionAppearance => real().nullable()();
  IntColumn get placeSyncedAtMillis => integer().nullable()();

  // Manual curation fields (stored as JSON strings)
  TextColumn get birthingOptions => text().nullable()(); // JSON array
  TextColumn get facilities => text().nullable()(); // JSON object
  TextColumn get birthStatistics => text().nullable()(); // JSON object
  TextColumn get notes => text().nullable()();

  // Status
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Timestamps (stored as millis since epoch)
  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();
  IntColumn get cqcSyncedAtMillis => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
