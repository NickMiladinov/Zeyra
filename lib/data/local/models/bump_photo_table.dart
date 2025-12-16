import 'package:drift/drift.dart';

/// Drift table for bump photos.
///
/// Stores bump photo metadata including file path, week number, and notes.
/// Photos are stored in the file system; only metadata is in the database.
///
/// **Unique constraint:** (pregnancyId, weekNumber) - one photo per week per pregnancy
@DataClassName('BumpPhotoDto')
class BumpPhotos extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Foreign key to Pregnancies table
  TextColumn get pregnancyId => text()();

  /// Pregnancy week number (1-44)
  IntColumn get weekNumber => integer()();

  /// Local file path to the photo (nullable to support notes without photos)
  TextColumn get filePath => text().nullable()();

  /// Optional user note about this week
  TextColumn get note => text().nullable()();

  /// When the photo was taken/added (stored as millis since epoch)
  IntColumn get photoDateMillis => integer()();

  /// Timestamp when record was created (stored as millis since epoch)
  IntColumn get createdAtMillis => integer()();

  /// Timestamp when record was last updated (stored as millis since epoch)
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {pregnancyId, weekNumber}, // One photo per week per pregnancy
      ];
}
