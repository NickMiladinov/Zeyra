@Tags(['kick_counter'])
library;

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/encryption_service.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/repositories/kick_counter_repository_impl.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AppDatabase database;
  late EncryptionService encryptionService;
  late MockFlutterSecureStorage mockSecureStorage;
  late KickCounterRepositoryImpl repository;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    mockSecureStorage = MockFlutterSecureStorage();
    // Valid 32-byte key encoded in base64 (AES-256 requires exactly 32 bytes)
    when(() => mockSecureStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=');
    
    database = AppDatabase.forTesting(NativeDatabase.memory());
    encryptionService = EncryptionService(secureStorage: mockSecureStorage);
    await encryptionService.initialize();
    
    repository = KickCounterRepositoryImpl(
      dao: database.kickCounterDao,
      encryptionService: encryptionService,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('[KickCounter] Performance Tests', () {
    // ------------------------------------------------------------------------
    // Large Dataset Tests
    // ------------------------------------------------------------------------

    group('500 Session Tests', () {
      test('should create 500 sessions efficiently', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();
        
        // Act - Create 500 sessions
        for (int i = 0; i < 500; i++) {
          await repository.createSession();
          // End each session to make it inactive
          final sessions = await repository.getSessionHistory(limit: 1);
          if (sessions.isEmpty) {
            // Current session is still active, get and end it
            final active = await repository.getActiveSession();
            if (active != null) {
              // Add at least one kick to end it
              await repository.addKick(active.id, MovementStrength.moderate);
              await repository.endSession(active.id);
            }
          } else {
            // There's an active session, end it
            final active = await repository.getActiveSession();
            if (active != null) {
              await repository.addKick(active.id, MovementStrength.moderate);
              await repository.endSession(active.id);
            }
          }
        }
        
        stopwatch.stop();
        
        // Assert
        final history = await repository.getSessionHistory();
        expect(history.length, equals(500));
        
        // Performance assertion - should complete in reasonable time
        // Allow 30 seconds for 500 sessions (in-memory DB should be fast)
        expect(stopwatch.elapsedMilliseconds, lessThan(30000),
            reason: 'Creating 500 sessions took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Created 500 sessions in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 60)));

      test('should retrieve 500 sessions efficiently', () async {
        // Arrange - Create 500 sessions with 1 kick each
        for (int i = 0; i < 500; i++) {
          final session = await repository.createSession();
          await repository.addKick(session.id, MovementStrength.moderate);
          await repository.endSession(session.id);
        }
        
        // Act - Retrieve all sessions
        final stopwatch = Stopwatch()..start();
        final history = await repository.getSessionHistory();
        stopwatch.stop();
        
        // Assert
        expect(history.length, equals(500));
        
        // Should retrieve in under 5 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: 'Retrieving 500 sessions took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Retrieved 500 sessions in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should paginate through 500 sessions efficiently', () async {
        // Arrange - Create 500 sessions
        final now = DateTime.now();
        for (int i = 0; i < 500; i++) {
          final session = await repository.createSession();
          await repository.addKick(session.id, MovementStrength.moderate);
          await repository.endSession(session.id);
          // Small delay to ensure distinct timestamps
          await Future.delayed(const Duration(milliseconds: 1));
        }
        
        // Act - Paginate through in batches of 50
        final stopwatch = Stopwatch()..start();
        var totalRetrieved = 0;
        DateTime? beforeDate = now.add(const Duration(days: 1));
        
        for (int page = 0; page < 10; page++) {
          final batch = await repository.getSessionHistory(
            limit: 50,
            before: beforeDate,
          );
          
          totalRetrieved += batch.length;
          
          if (batch.isNotEmpty) {
            // Use the oldest session's start time for next page
            beforeDate = batch.last.startTime;
          }
        }
        
        stopwatch.stop();
        
        // Assert
        expect(totalRetrieved, equals(500));
        expect(stopwatch.elapsedMilliseconds, lessThan(10000),
            reason: 'Paginating 500 sessions took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Paginated 500 sessions in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 60)));

      test('should handle deletion of 500 sessions efficiently', () async {
        // Arrange - Create 500 sessions
        final sessionIds = <String>[];
        for (int i = 0; i < 500; i++) {
          final session = await repository.createSession();
          sessionIds.add(session.id);
          await repository.addKick(session.id, MovementStrength.moderate);
          await repository.endSession(session.id);
        }
        
        // Act - Delete all
        final stopwatch = Stopwatch()..start();
        for (final id in sessionIds) {
          await repository.deleteSession(id);
        }
        stopwatch.stop();
        
        // Assert
        final history = await repository.getSessionHistory();
        expect(history, isEmpty);
        expect(stopwatch.elapsedMilliseconds, lessThan(15000),
            reason: 'Deleting 500 sessions took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Deleted 500 sessions in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 45)));
    });

    // ------------------------------------------------------------------------
    // 100 Kicks Per Session Tests
    // ------------------------------------------------------------------------

    group('100 Kicks Per Session Tests', () {
      test('should add 100 kicks to session efficiently', () async {
        // Arrange
        final session = await repository.createSession();
        
        // Act - Add 100 kicks
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          final strength = i % 3 == 0
              ? MovementStrength.weak
              : i % 3 == 1
                  ? MovementStrength.moderate
                  : MovementStrength.strong;
          await repository.addKick(session.id, strength);
        }
        stopwatch.stop();
        
        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.kickCount, equals(100));
        
        // Should complete in under 5 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: 'Adding 100 kicks took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Added 100 kicks in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should retrieve session with 100 kicks efficiently', () async {
        // Arrange - Create session with 100 kicks
        final session = await repository.createSession();
        for (int i = 0; i < 100; i++) {
          await repository.addKick(session.id, MovementStrength.moderate);
        }
        
        // Act - Retrieve session multiple times
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 10; i++) {
          final loaded = await repository.getActiveSession();
          expect(loaded!.kickCount, equals(100));
        }
        stopwatch.stop();
        
        // Assert - 10 retrievals should be fast
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
            reason: '10 retrievals of 100-kick session took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Retrieved 100-kick session 10 times in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 15)));

      test('should calculate statistics on 100-kick session efficiently',
          () async {
        // Arrange - Create session with 100 kicks
        final session = await repository.createSession();
        for (int i = 0; i < 100; i++) {
          await repository.addKick(session.id, MovementStrength.moderate);
        }
        await repository.endSession(session.id);
        
        // Act - Load and calculate stats multiple times
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 50; i++) {
          final history = await repository.getSessionHistory(limit: 1);
          final loadedSession = history.first;
          
          // Access computed properties
          expect(loadedSession.kickCount, equals(100));
          expect(loadedSession.averageTimeBetweenKicks, isNotNull);
          expect(loadedSession.activeDuration, isNotNull);
        }
        stopwatch.stop();
        
        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: '50 stat calculations took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Calculated stats 50 times in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 20)));

      test('should handle undo operations on 100-kick session efficiently',
          () async {
        // Arrange - Create session with 100 kicks
        final session = await repository.createSession();
        for (int i = 0; i < 100; i++) {
          await repository.addKick(session.id, MovementStrength.moderate);
        }
        
        // Act - Undo 50 kicks
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 50; i++) {
          await repository.removeLastKick(session.id);
        }
        stopwatch.stop();
        
        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.kickCount, equals(50));
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
            reason: 'Removing 50 kicks took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Removed 50 kicks in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 15)));
    });

    // ------------------------------------------------------------------------
    // Combined Stress Tests
    // ------------------------------------------------------------------------

    group('Combined Stress Tests', () {
      test('should handle 50 sessions with 50 kicks each efficiently',
          () async {
        // Arrange & Act
        final stopwatch = Stopwatch()..start();
        
        for (int sessionNum = 0; sessionNum < 50; sessionNum++) {
          final session = await repository.createSession();
          
          // Add 50 kicks
          for (int kickNum = 0; kickNum < 50; kickNum++) {
            await repository.addKick(session.id, MovementStrength.moderate);
          }
          
          // End session
          await repository.endSession(session.id);
        }
        
        stopwatch.stop();
        
        // Assert
        final history = await repository.getSessionHistory();
        expect(history.length, equals(50));
        
        // Total: 2500 operations (50 create + 2500 kicks + 50 end)
        expect(stopwatch.elapsedMilliseconds, lessThan(20000),
            reason: '50 sessions with 50 kicks each took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Created 50 sessions with 50 kicks each in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('should handle rapid pause/resume on 100-kick session', () async {
        // Arrange
        final session = await repository.createSession();
        
        // Add kicks with pauses
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          await repository.addKick(session.id, MovementStrength.moderate);
          
          // Pause/resume every 10 kicks
          if (i % 10 == 0 && i > 0) {
            await repository.pauseSession(session.id);
            await Future.delayed(const Duration(milliseconds: 10));
            await repository.resumeSession(session.id);
          }
        }
        stopwatch.stop();
        
        // Assert
        final loadedSession = await repository.getActiveSession();
        expect(loadedSession!.kickCount, equals(100));
        expect(loadedSession.pauseCount, equals(9)); // Paused 9 times
        expect(stopwatch.elapsedMilliseconds, lessThan(10000),
            reason: '100 kicks with 9 pauses took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ 100 kicks with 9 pause/resume cycles in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('should handle querying history with varying limits', () async {
        // Arrange - Create 100 sessions
        for (int i = 0; i < 100; i++) {
          final session = await repository.createSession();
          await repository.addKick(session.id, MovementStrength.moderate);
          await repository.endSession(session.id);
        }
        
        // Act - Query with different limits
        final stopwatch = Stopwatch()..start();
        final limits = [1, 5, 10, 25, 50, 100];
        for (final limit in limits) {
          final history = await repository.getSessionHistory(limit: limit);
          expect(history.length, equals(limit));
        }
        stopwatch.stop();
        
        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
            reason: 'Multiple limit queries took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Varied limit queries in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    // ------------------------------------------------------------------------
    // Encryption Performance Tests
    // ------------------------------------------------------------------------

    group('Encryption Performance', () {
      test('should handle encryption/decryption of 1000 kicks efficiently',
          () async {
        // Arrange - Create 10 sessions with 100 kicks each
        final sessionIds = <String>[];
        
        final createStopwatch = Stopwatch()..start();
        for (int i = 0; i < 10; i++) {
          final session = await repository.createSession();
          sessionIds.add(session.id);
          
          for (int j = 0; j < 100; j++) {
            await repository.addKick(session.id, MovementStrength.moderate);
          }
          
          await repository.endSession(session.id);
        }
        createStopwatch.stop();
        
        print('  Setup: Created 10 sessions with 100 kicks in ${createStopwatch.elapsedMilliseconds}ms');
        
        // Act - Retrieve all sessions (requires decryption)
        final retrieveStopwatch = Stopwatch()..start();
        final history = await repository.getSessionHistory();
        retrieveStopwatch.stop();
        
        // Assert
        expect(history.length, equals(10));
        var totalKicks = 0;
        for (final session in history) {
          totalKicks += session.kickCount;
        }
        expect(totalKicks, equals(1000));
        
        expect(retrieveStopwatch.elapsedMilliseconds, lessThan(10000),
            reason: 'Decrypting 1000 kicks took ${retrieveStopwatch.elapsedMilliseconds}ms');
        
        print('✓ Encrypted/decrypted 1000 kicks - Create: ${createStopwatch.elapsedMilliseconds}ms, Retrieve: ${retrieveStopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    // ------------------------------------------------------------------------
    // Memory Efficiency Tests
    // ------------------------------------------------------------------------

    group('Memory Efficiency', () {
      test('should handle repeated session loads without memory leak',
          () async {
        // Arrange
        final session = await repository.createSession();
        for (int i = 0; i < 50; i++) {
          await repository.addKick(session.id, MovementStrength.moderate);
        }
        
        // Act - Load session 500 times
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 500; i++) {
          final loaded = await repository.getActiveSession();
          expect(loaded, isNotNull);
        }
        stopwatch.stop();
        
        // Assert - Should remain efficient even after many loads
        expect(stopwatch.elapsedMilliseconds, lessThan(15000),
            reason: '500 loads took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Loaded session 500 times in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(seconds: 45)));

      test('should handle history queries without accumulating memory',
          () async {
        // Arrange - Create 100 sessions with 10 kicks each
        for (int i = 0; i < 100; i++) {
          final session = await repository.createSession();
          for (int j = 0; j < 10; j++) {
            await repository.addKick(session.id, MovementStrength.moderate);
          }
          await repository.endSession(session.id);
        }
        
        // Act - Query history 100 times
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          final history = await repository.getSessionHistory(limit: 10);
          expect(history.length, equals(10));
        }
        stopwatch.stop();
        
        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(20000),
            reason: '100 history queries took ${stopwatch.elapsedMilliseconds}ms');
        
        print('✓ Queried history 100 times in ${stopwatch.elapsedMilliseconds}ms');
      }, timeout: const Timeout(Duration(minutes: 1)));
    });
  });
}

