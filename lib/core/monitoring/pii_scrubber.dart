/// PII (Personally Identifiable Information) scrubber for medical data compliance.
///
/// Removes or masks sensitive information before it's sent to remote logging services.
/// This is critical for GDPR, HIPAA, and NHS Digital Standards compliance.
///
/// **Categories of protected data:**
/// - Personal identifiers (email, name, UUID)
/// - Authentication data (tokens, keys, passwords)
/// - Medical/health data (symptoms, biomarkers, kick counts)
/// - Pregnancy-specific data (gestational age, due dates, LMP)
/// - Database encryption keys (SQLCipher keys)
class PiiScrubber {
  /// Patterns for detecting PII in text.
  static final RegExp _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
  );

  static final RegExp _uuidPattern = RegExp(
    r'\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b',
    caseSensitive: false,
  );

  static final RegExp _authTokenPattern = RegExp(
    r'(Bearer |token[=:]|authorization[=:]|api[_-]?key[=:])[\w\-\.]+',
    caseSensitive: false,
  );

  static final RegExp _base64Pattern = RegExp(
    r'\b[A-Za-z0-9+/]{40,}={0,2}',
  );

  static final RegExp _filePathPattern = RegExp(
    r'(/[a-zA-Z0-9_\-\.]+)+|([A-Z]:\\[a-zA-Z0-9_\-\\\.]+)',
  );

  /// Pattern for hex-encoded encryption keys (32+ hex chars)
  static final RegExp _hexKeyPattern = RegExp(
    r'\b[0-9a-fA-F]{32,}\b',
  );

  /// Pattern for SQLCipher PRAGMA key statements
  static final RegExp _sqlCipherKeyPattern = RegExp(
    r'''PRAGMA\s+key\s*=\s*['"][^'"]+['"]''',
    caseSensitive: false,
  );

  /// Pattern for database key storage identifiers
  static final RegExp _dbKeyIdPattern = RegExp(
    r'zeyra_db_key_[a-zA-Z0-9\-]+',
    caseSensitive: false,
  );

  // Medical data keywords that should never appear in logs
  static final List<String> _medicalDataKeywords = [
    'kick',
    'biomarker',
    'blood',
    'pressure',
    'weight',
    'heartbeat',
    'symptom',
    'medication',
    'prescription',
    'diagnosis',
    'movement_strength',
    'perceived_strength',
    'health_data',
    'medical_record',
  ];

  // Pregnancy-specific keywords (GDPR special category data)
  static final List<String> _pregnancyKeywords = [
    'gestational',
    'trimester',
    'due_date',
    'duedate',
    'lmp',
    'edd',
    'pregnancy',
    'pregnant',
    'fetal',
    'fetus',
    'baby',
    'contraction',
    'labor',
    'labour',
    'birth',
    'delivery',
    'midwife',
    'antenatal',
    'prenatal',
    'postnatal',
  ];

  // Database/encryption keywords that indicate sensitive operations
  static final List<String> _encryptionKeywords = [
    'db_key',
    'cipher_key',
    'encryption_key',
    'secret_key',
    'cipher',
    'encrypt',
    'decrypt',
    'pragma key',
    'sqlcipher',
  ];

  /// Scrubs PII from a message string.
  ///
  /// Replaces:
  /// - Email addresses → [EMAIL]
  /// - UUIDs/Session IDs → [SESSION_ID]
  /// - Auth tokens → [TOKEN]
  /// - Base64 strings (likely encrypted data) → [ENCRYPTED_DATA]
  /// - File paths → [FILE_PATH]
  /// - Hex encryption keys → [DB_KEY]
  /// - SQLCipher PRAGMA statements → [DB_PRAGMA]
  /// - Database key IDs → [DB_KEY_ID]
  ///
  /// Returns the scrubbed message safe for remote logging.
  static String scrubMessage(String message) {
    if (message.isEmpty) return message;

    String scrubbed = message;

    // Scrub SQLCipher PRAGMA key statements first (most specific)
    scrubbed = scrubbed.replaceAll(_sqlCipherKeyPattern, '[DB_PRAGMA]');

    // Scrub database key storage identifiers
    scrubbed = scrubbed.replaceAll(_dbKeyIdPattern, '[DB_KEY_ID]');

    // Scrub email addresses
    scrubbed = scrubbed.replaceAll(_emailPattern, '[EMAIL]');

    // Scrub UUIDs and session IDs
    scrubbed = scrubbed.replaceAll(_uuidPattern, '[SESSION_ID]');

    // Scrub auth tokens
    scrubbed = scrubbed.replaceAll(_authTokenPattern, '[TOKEN]');

    // Scrub hex-encoded keys (after UUIDs to avoid double-matching)
    scrubbed = scrubbed.replaceAll(_hexKeyPattern, '[DB_KEY]');

    // Scrub base64 encoded data (likely encrypted values)
    scrubbed = scrubbed.replaceAll(_base64Pattern, '[ENCRYPTED_DATA]');

    // Scrub file paths
    scrubbed = scrubbed.replaceAll(_filePathPattern, '[FILE_PATH]');

    return scrubbed;
  }

  /// Scrubs PII from a data map.
  ///
  /// Creates a new map with sensitive values removed or masked.
  ///
  /// Rules:
  /// - Keys containing 'id', 'uuid', 'session' → value replaced with [ID]
  /// - Keys containing 'email' → value replaced with [EMAIL]
  /// - Keys containing 'name' → value replaced with [NAME]
  /// - Keys containing 'token', 'key', 'password' → value replaced with [REDACTED]
  /// - Keys containing medical keywords → value replaced with [MEDICAL_DATA]
  /// - Keys containing pregnancy keywords → value replaced with [PREGNANCY_DATA]
  /// - Keys containing encryption keywords → value replaced with [ENCRYPTION_DATA]
  /// - Keys containing 'note', 'comment', 'description' → value removed entirely
  /// - Nested maps are recursively scrubbed
  ///
  /// Returns a new map safe for remote logging.
  static Map<String, dynamic> scrubData(Map<String, dynamic> data) {
    final scrubbed = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      // Remove notes and comments entirely
      if (_shouldRemoveField(key)) {
        continue;
      }

      // Handle complex types first (maps and lists)
      if (value is Map<String, dynamic>) {
        // Recursively scrub nested maps
        scrubbed[entry.key] = scrubData(value);
      } else if (value is List) {
        // Scrub lists
        scrubbed[entry.key] = _scrubList(value);
      }
      // Then check if field name indicates sensitive data
      else if (_isIdField(key)) {
        scrubbed[entry.key] = '[SESSION_ID]';
      } else if (_isEmailField(key)) {
        scrubbed[entry.key] = '[EMAIL]';
      } else if (_isNameField(key)) {
        scrubbed[entry.key] = '[NAME]';
      } else if (_isEncryptionField(key)) {
        scrubbed[entry.key] = '[ENCRYPTION_DATA]';
      } else if (_isSecretField(key)) {
        scrubbed[entry.key] = '[REDACTED]';
      } else if (_isPregnancyField(key)) {
        scrubbed[entry.key] = '[PREGNANCY_DATA]';
      } else if (_isMedicalField(key)) {
        scrubbed[entry.key] = '[MEDICAL_DATA]';
      } else if (value is String) {
        // Scrub string values
        scrubbed[entry.key] = scrubMessage(value);
      } else {
        // Keep other types as-is (numbers, bools, etc.)
        scrubbed[entry.key] = value;
      }
    }

    return scrubbed;
  }

  /// Scrubs a list of values.
  static List<dynamic> _scrubList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return scrubData(item);
      } else if (item is String) {
        return scrubMessage(item);
      } else if (item is List) {
        return _scrubList(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// Returns true if the field should be removed entirely.
  static bool _shouldRemoveField(String key) {
    return key.contains('note') ||
        key.contains('comment') ||
        key.contains('description') ||
        key.contains('body') ||
        key.contains('symptoms') ||
        key.contains('diagnosis');
  }

  /// Returns true if the field contains an ID or session identifier.
  static bool _isIdField(String key) {
    return key.contains('id') ||
        key.contains('uuid') ||
        key.contains('session') ||
        key.endsWith('_id');
  }

  /// Returns true if the field contains an email address.
  static bool _isEmailField(String key) {
    return key.contains('email') || key.contains('mail');
  }

  /// Returns true if the field contains a name.
  static bool _isNameField(String key) {
    return key.contains('name') && !key.contains('filename');
  }

  /// Returns true if the field contains secret data.
  static bool _isSecretField(String key) {
    return key.contains('token') ||
        key.contains('key') ||
        key.contains('password') ||
        key.contains('secret') ||
        key.contains('auth') ||
        key.contains('credential');
  }

  /// Returns true if the field contains encryption-related data.
  static bool _isEncryptionField(String key) {
    for (final keyword in _encryptionKeywords) {
      if (key.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Returns true if the field contains medical data.
  static bool _isMedicalField(String key) {
    for (final keyword in _medicalDataKeywords) {
      if (key.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Returns true if the field contains pregnancy-specific data.
  static bool _isPregnancyField(String key) {
    for (final keyword in _pregnancyKeywords) {
      if (key.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Scrubs an error object.
  ///
  /// Returns a scrubbed string representation of the error.
  static String scrubError(dynamic error) {
    if (error == null) return '';
    return scrubMessage(error.toString());
  }

  /// Scrubs a stack trace.
  ///
  /// Removes file paths but keeps line numbers and method names.
  static String scrubStackTrace(StackTrace? stackTrace) {
    if (stackTrace == null) return '';

    final trace = stackTrace.toString();
    // Keep line numbers and method names but remove file paths
    return trace.split('\n').map((line) {
      return line.replaceAll(_filePathPattern, '[FILE_PATH]');
    }).join('\n');
  }

  /// Returns true if the environment allows PII in logs (debug mode only).
  ///
  /// In release builds, PII should ALWAYS be scrubbed.
  static bool shouldScrubPii(bool isReleaseBuild) {
    // Always scrub in release builds
    if (isReleaseBuild) return true;

    // In debug builds, can optionally disable scrubbing for local debugging
    // but remote logging should still always scrub
    return false; // Can be made configurable via environment variable
  }

  /// Creates a safe context object for error reporting.
  ///
  /// Includes only non-sensitive information useful for debugging.
  static Map<String, dynamic> createSafeContext({
    String? feature,
    String? operation,
    int? itemCount,
    String? errorType,
    Map<String, dynamic>? additionalData,
  }) {
    final context = <String, dynamic>{};

    if (feature != null) context['feature'] = feature;
    if (operation != null) context['operation'] = operation;
    if (itemCount != null) context['item_count'] = itemCount;
    if (errorType != null) context['error_type'] = errorType;

    if (additionalData != null) {
      context.addAll(scrubData(additionalData));
    }

    return context;
  }

  /// Scrub all sensitive fields from an object before analytics/export.
  ///
  /// Use this for data minimization when preparing data for analytics
  /// or external export where PII should not be included.
  ///
  /// Returns a new map with sensitive fields removed (not just masked).
  static Map<String, dynamic> minimizeForAnalytics(Map<String, dynamic> data) {
    final minimized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      // Skip all sensitive fields entirely
      if (_shouldRemoveField(key) ||
          _isEmailField(key) ||
          _isNameField(key) ||
          _isSecretField(key) ||
          _isEncryptionField(key) ||
          _isMedicalField(key) ||
          _isPregnancyField(key)) {
        continue;
      }

      // Recursively minimize nested maps
      if (value is Map<String, dynamic>) {
        final nestedMinimized = minimizeForAnalytics(value);
        if (nestedMinimized.isNotEmpty) {
          minimized[entry.key] = nestedMinimized;
        }
      } else if (value is List) {
        minimized[entry.key] = _minimizeList(value);
      } else if (_isIdField(key)) {
        // Keep ID fields but anonymize them
        minimized[entry.key] = '[ANONYMIZED]';
      } else {
        // Keep non-sensitive primitive values
        minimized[entry.key] = value;
      }
    }

    return minimized;
  }

  /// Minimize a list for analytics.
  static List<dynamic> _minimizeList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return minimizeForAnalytics(item);
      } else if (item is List) {
        return _minimizeList(item);
      } else {
        return item;
      }
    }).toList();
  }
}
