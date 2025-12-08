import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/core/monitoring/pii_scrubber.dart';

void main() {
  group('PiiScrubber', () {
    group('scrubMessage', () {
      test('should scrub email addresses', () {
        const message = 'User email is test@example.com';
        final result = PiiScrubber.scrubMessage(message);
        
        expect(result, equals('User email is [EMAIL]'));
        expect(result, isNot(contains('@example.com')));
      });

      test('should scrub UUIDs', () {
        const message = 'Session ID: 550e8400-e29b-41d4-a716-446655440000';
        final result = PiiScrubber.scrubMessage(message);
        
        expect(result, equals('Session ID: [SESSION_ID]'));
        expect(result, isNot(contains('550e8400')));
      });

      test('should scrub auth tokens', () {
        const message = 'Authorization: Bearer abc123token456';
        final result = PiiScrubber.scrubMessage(message);
        
        expect(result, equals('Authorization: [TOKEN]'));
        expect(result, isNot(contains('abc123token456')));
      });

      test('should scrub base64 encoded data', () {
        const message = 'Encrypted data: SGVsbG8gV29ybGQhIFRoaXMgaXMgYSB0ZXN0IG1lc3NhZ2U=';
        final result = PiiScrubber.scrubMessage(message);
        
        expect(result, equals('Encrypted data: [ENCRYPTED_DATA]'));
        expect(result, isNot(contains('SGVsbG8gV29ybGQ')));
      });

      test('should scrub file paths', () {
        const message = 'File at /Users/test/Documents/file.txt';
        final result = PiiScrubber.scrubMessage(message);
        
        expect(result, equals('File at [FILE_PATH]'));
        expect(result, isNot(contains('/Users/test')));
      });

      test('should handle multiple PII types in one message', () {
        const message = 'User test@example.com has session 550e8400-e29b-41d4-a716-446655440000';
        final result = PiiScrubber.scrubMessage(message);
        
        expect(result, equals('User [EMAIL] has session [SESSION_ID]'));
      });

      test('should return empty string for empty input', () {
        final result = PiiScrubber.scrubMessage('');
        expect(result, equals(''));
      });

      test('should not modify messages without PII', () {
        const message = 'This is a safe message without PII';
        final result = PiiScrubber.scrubMessage(message);
        
        expect(result, equals(message));
      });
    });

    group('scrubData', () {
      test('should scrub session IDs from data', () {
        final data = {
          'sessionId': '550e8400-e29b-41d4-a716-446655440000',
          'userId': '12345',
          'count': 10,
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['sessionId'], equals('[SESSION_ID]'));
        expect(result['userId'], equals('[SESSION_ID]'));
        expect(result['count'], equals(10)); // Non-PII preserved
      });

      test('should scrub email addresses from data', () {
        final data = {
          'email': 'user@example.com',
          'userEmail': 'test@test.com',
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['email'], equals('[EMAIL]'));
        expect(result['userEmail'], equals('[EMAIL]'));
      });

      test('should scrub names from data', () {
        final data = {
          'name': 'John Doe',
          'userName': 'johndoe',
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['name'], equals('[NAME]'));
        expect(result['userName'], equals('[NAME]'));
      });

      test('should scrub secrets from data', () {
        final data = {
          'token': 'abc123',
          'apiKey': 'secret_key_123',
          'password': 'mypassword',
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['token'], equals('[REDACTED]'));
        expect(result['apiKey'], equals('[REDACTED]'));
        expect(result['password'], equals('[REDACTED]'));
      });

      test('should scrub medical data from data', () {
        final data = {
          'kickCount': 10,
          'bloodPressure': '120/80',
          'weight': 70.5,
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['kickCount'], equals('[MEDICAL_DATA]'));
        expect(result['bloodPressure'], equals('[MEDICAL_DATA]'));
        expect(result['weight'], equals('[MEDICAL_DATA]'));
      });

      test('should remove notes and comments entirely', () {
        final data = {
          'note': 'This is a sensitive note',
          'comment': 'User comment here',
          'description': 'Some description',
          'count': 5,
        };

        final result = PiiScrubber.scrubData(data);

        expect(result.containsKey('note'), isFalse);
        expect(result.containsKey('comment'), isFalse);
        expect(result.containsKey('description'), isFalse);
        expect(result['count'], equals(5)); // Non-PII preserved
      });

      test('should recursively scrub nested maps', () {
        final data = {
          'user': {
            'id': '12345',
            'email': 'test@example.com',
            'profile': {
              'name': 'John Doe',
            },
          },
          'count': 5,
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['user']['id'], equals('[SESSION_ID]'));
        expect(result['user']['email'], equals('[EMAIL]'));
        expect(result['user']['profile']['name'], equals('[NAME]'));
        expect(result['count'], equals(5));
      });

      test('should scrub arrays', () {
        final data = {
          'emails': ['test1@example.com', 'test2@example.com'],
          'counts': [1, 2, 3],
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['emails'], equals(['[EMAIL]', '[EMAIL]']));
        expect(result['counts'], equals([1, 2, 3]));
      });

      test('should scrub arrays of maps', () {
        final data = {
          'users': [
            {'id': '123', 'email': 'test1@example.com'},
            {'id': '456', 'email': 'test2@example.com'},
          ],
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['users'][0]['id'], equals('[SESSION_ID]'));
        expect(result['users'][0]['email'], equals('[EMAIL]'));
        expect(result['users'][1]['id'], equals('[SESSION_ID]'));
        expect(result['users'][1]['email'], equals('[EMAIL]'));
      });

      test('should preserve non-sensitive data types', () {
        final data = {
          'count': 42,
          'isActive': true,
          'ratio': 3.14,
          'items': [1, 2, 3],
        };

        final result = PiiScrubber.scrubData(data);

        expect(result['count'], equals(42));
        expect(result['isActive'], equals(true));
        expect(result['ratio'], equals(3.14));
        expect(result['items'], equals([1, 2, 3]));
      });
    });

    group('scrubError', () {
      test('should scrub PII from error messages', () {
        final error = Exception('Failed for user test@example.com');
        final result = PiiScrubber.scrubError(error);
        
        expect(result, contains('[EMAIL]'));
        expect(result, isNot(contains('test@example.com')));
      });

      test('should handle null errors', () {
        final result = PiiScrubber.scrubError(null);
        expect(result, equals(''));
      });
    });

    group('scrubStackTrace', () {
      test('should scrub file paths from stack traces', () {
        final stackTrace = StackTrace.fromString(
          '#0      main (file:///Users/test/app/lib/main.dart:10:5)\n'
          '#1      _runMainZoned.<anonymous closure>.<anonymous closure> (dart:ui/hooks.dart:142:25)',
        );

        final result = PiiScrubber.scrubStackTrace(stackTrace);

        expect(result, contains('[FILE_PATH]'));
        expect(result, isNot(contains('/Users/test')));
      });

      test('should handle null stack traces', () {
        final result = PiiScrubber.scrubStackTrace(null);
        expect(result, equals(''));
      });
    });

    group('createSafeContext', () {
      test('should create safe context with non-sensitive data', () {
        final context = PiiScrubber.createSafeContext(
          feature: 'kick_counter',
          operation: 'create_session',
          itemCount: 5,
          errorType: 'DatabaseException',
        );

        expect(context['feature'], equals('kick_counter'));
        expect(context['operation'], equals('create_session'));
        expect(context['item_count'], equals(5));
        expect(context['error_type'], equals('DatabaseException'));
      });

      test('should scrub additional data', () {
        final context = PiiScrubber.createSafeContext(
          feature: 'kick_counter',
          additionalData: {
            'userId': '12345',
            'email': 'test@example.com',
            'count': 10,
          },
        );

        expect(context['userId'], equals('[SESSION_ID]'));
        expect(context['email'], equals('[EMAIL]'));
        expect(context['count'], equals(10));
      });

      test('should handle null values', () {
        final context = PiiScrubber.createSafeContext();

        expect(context, isEmpty);
      });
    });

    group('shouldScrubPii', () {
      test('should always scrub in release builds', () {
        expect(PiiScrubber.shouldScrubPii(true), isTrue);
      });

      test('should optionally scrub in debug builds', () {
        // Currently returns false for debug, but configurable
        expect(PiiScrubber.shouldScrubPii(false), isFalse);
      });
    });
  });
}

