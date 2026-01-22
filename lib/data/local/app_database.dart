import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import 'daos/bump_photo_dao.dart';
import 'daos/contraction_timer_dao.dart';
import 'daos/hospital_shortlist_dao.dart';
import 'daos/kick_counter_dao.dart';
import 'daos/maternity_unit_dao.dart';
import 'daos/pregnancy_dao.dart';
import 'daos/sync_metadata_dao.dart';
import 'daos/user_profile_dao.dart';
import 'models/bump_photo_table.dart';
import 'models/contraction_session_table.dart';
import 'models/contraction_table.dart';
import 'models/hospital_shortlist_table.dart';
import 'models/kick_session_table.dart';
import 'models/kick_table.dart';
import 'models/maternity_unit_table.dart';
import 'models/pause_event_table.dart';
import 'models/pregnancy_table.dart';
import 'models/sync_metadata_table.dart';
import 'models/user_profile_table.dart';

part 'app_database.g.dart';

/// Main database for the Zeyra app.
///
/// Uses Drift for type-safe SQL queries with automatic code generation.
/// Includes all app tables and DAOs for medical data tracking.
///
/// **Encryption:** Uses SQLCipher for full database encryption with AES-256.
/// Each user has a dedicated database file: `zeyra_<authId>.db`
///
/// **Security Settings (HIPAA/GDPR compliant):**
/// - `cipher_page_size`: 4096 bytes
/// - `kdf_iter`: 256000 iterations (PBKDF2)
/// - `cipher_hmac_algorithm`: HMAC_SHA512
/// - `cipher_memory_security`: ON (clears sensitive data from memory)
@DriftDatabase(
  tables: [
    // User & Pregnancy
    UserProfiles,
    Pregnancies,

    // Kick counter feature
    KickSessions,
    Kicks,
    PauseEvents,

    // Contraction timer feature
    ContractionSessions,
    Contractions,

    // Bump photo feature
    BumpPhotos,

    // Hospital chooser feature
    MaternityUnits,
    HospitalShortlists,
    SyncMetadatas,
  ],
  daos: [
    // User & Pregnancy DAOs
    UserProfileDao,
    PregnancyDao,

    // Kick counter DAO
    KickCounterDao,

    // Contraction timer DAO
    ContractionTimerDao,

    // Bump photo DAO
    BumpPhotoDao,

    // Hospital chooser DAOs
    MaternityUnitDao,
    HospitalShortlistDao,
    SyncMetadataDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an encrypted database for a specific user.
  ///
  /// [userId] - The Supabase auth ID (used in filename)
  /// [encryptionKey] - The hex-encoded 256-bit encryption key
  AppDatabase.encrypted({
    required String userId,
    required String encryptionKey,
  }) : super(_openEncryptedConnection(userId, encryptionKey));

  // For testing with in-memory database (unencrypted)
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

        },
        beforeOpen: (details) async {
          // Enable foreign key constraints
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Verify that SQLCipher is active and properly configured.
  ///
  /// Returns the SQLCipher version string if active, null otherwise.
  /// Use this for verification during testing/debugging.
  Future<String?> verifySqlCipherActive() async {
    try {
      final result = await customSelect('PRAGMA cipher_version').getSingle();
      return result.data['cipher_version'] as String?;
    } catch (e) {
      return null;
    }
  }
}

/// Flag to track if SQLCipher has been set up
bool _sqlCipherSetupComplete = false;

/// Set up SQLCipher native libraries.
///
/// Must be called once before opening any encrypted database.
/// This is handled automatically by _openEncryptedConnection.
Future<void> _setupSqlCipher() async {
  if (_sqlCipherSetupComplete) return;

  // Configure sqlite3 to use SQLCipher libraries
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

  // iOS uses the bundled SQLCipher from CocoaPods automatically
  // No explicit override needed for iOS

  _sqlCipherSetupComplete = true;
}

/// Opens an encrypted SQLCipher database connection.
///
/// [userId] - Used to create per-user database file: `zeyra_<userId>.db`
/// [encryptionKey] - Hex-encoded 256-bit key for SQLCipher
///
/// **Security Configuration:**
/// - AES-256-CBC encryption with HMAC-SHA512 authentication
/// - 256,000 PBKDF2 iterations for key derivation
/// - Memory security enabled to clear sensitive data
LazyDatabase _openEncryptedConnection(String userId, String encryptionKey) {
  return LazyDatabase(() async {
    // Set up SQLCipher libraries (idempotent)
    await _setupSqlCipher();

    // Get database file path
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'zeyra_$userId.db'));

    return NativeDatabase(
      file,
      setup: (db) {
        // Set the encryption key (hex format with x'' prefix)
        db.execute("PRAGMA key = \"x'$encryptionKey'\";");

        // Configure SQLCipher security settings (HIPAA/GDPR compliant)
        db.execute('PRAGMA cipher_page_size = 4096;');
        db.execute('PRAGMA kdf_iter = 256000;');
        db.execute('PRAGMA cipher_hmac_algorithm = HMAC_SHA512;');
        db.execute('PRAGMA cipher_kdf_algorithm = PBKDF2_HMAC_SHA512;');
        db.execute('PRAGMA cipher_memory_security = ON;');
      },
    );
  });
}
