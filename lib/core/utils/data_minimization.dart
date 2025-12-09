/// Data minimization utilities for GDPR compliance.
///
/// Provides patterns and helpers for implementing the GDPR principle of
/// data minimization: "personal data shall be adequate, relevant and limited
/// to what is necessary in relation to the purposes for which they are processed."
///
/// **Key Strategies:**
/// - Pagination: Load data in chunks instead of all at once
/// - Field selection: Query only required fields
/// - History limits: Retain only necessary historical data
/// - Sensitive field exclusion: Never export/log certain fields
library;

/// Default pagination settings for data queries.
class DataMinimizationDefaults {
  /// Default page size for paginated queries.
  static const int defaultPageSize = 20;

  /// Maximum page size allowed for any query.
  static const int maxPageSize = 100;

  /// Maximum days of history to retain for medical data (per GDPR).
  /// After this period, data should be archived or deleted.
  static const int maxHistoryDays = 365;

  /// Maximum number of sessions to load in history views.
  static const int maxHistorySessions = 50;

  /// Fields that should NEVER be included in exports or analytics.
  static const List<String> sensitiveFields = [
    'note',
    'notes',
    'comment',
    'comments',
    'description',
    'perceivedStrength',
    'perceived_strength',
    'symptoms',
    'diagnosis',
    'medical_notes',
    'personal_notes',
  ];

  /// Fields that can be included in analytics (anonymized).
  static const List<String> analyticsAllowedFields = [
    'count',
    'duration',
    'timestamp',
    'created_at',
    'is_active',
    'status',
    'type',
    'category',
  ];
}

/// Helper for implementing paginated data loading.
class PaginationHelper {
  /// Calculate offset for a given page number.
  ///
  /// [page] - Zero-indexed page number
  /// [pageSize] - Number of items per page
  static int calculateOffset(int page, [int pageSize = DataMinimizationDefaults.defaultPageSize]) {
    return page * pageSize;
  }

  /// Validate and constrain page size to allowed limits.
  ///
  /// Returns [pageSize] if within limits, otherwise returns the closest valid value.
  static int constrainPageSize(int pageSize) {
    if (pageSize < 1) return 1;
    if (pageSize > DataMinimizationDefaults.maxPageSize) {
      return DataMinimizationDefaults.maxPageSize;
    }
    return pageSize;
  }

  /// Check if there are more pages available.
  ///
  /// [totalItems] - Total number of items in the dataset
  /// [currentPage] - Current zero-indexed page number
  /// [pageSize] - Number of items per page
  static bool hasMorePages(int totalItems, int currentPage, int pageSize) {
    final totalPages = (totalItems / pageSize).ceil();
    return currentPage < totalPages - 1;
  }

  /// Calculate total number of pages.
  static int totalPages(int totalItems, int pageSize) {
    return (totalItems / pageSize).ceil();
  }
}

/// Helper for date-based data retention.
class DataRetentionHelper {
  /// Calculate the cutoff date for data retention.
  ///
  /// Data older than this date may be archived or deleted.
  static DateTime retentionCutoffDate([int? maxDays]) {
    final days = maxDays ?? DataMinimizationDefaults.maxHistoryDays;
    return DateTime.now().subtract(Duration(days: days));
  }

  /// Check if a date is within the retention period.
  static bool isWithinRetentionPeriod(DateTime date, [int? maxDays]) {
    return date.isAfter(retentionCutoffDate(maxDays));
  }

  /// Filter a list of items to only include those within retention period.
  ///
  /// [items] - List of items to filter
  /// [getDate] - Function to extract date from each item
  static List<T> filterByRetention<T>(
    List<T> items,
    DateTime Function(T) getDate, [
    int? maxDays,
  ]) {
    final cutoff = retentionCutoffDate(maxDays);
    return items.where((item) => getDate(item).isAfter(cutoff)).toList();
  }
}

/// Helper for field selection and projection.
class FieldSelectionHelper {
  /// Check if a field should be excluded from exports.
  static bool isSensitiveField(String fieldName) {
    final lowerName = fieldName.toLowerCase();
    return DataMinimizationDefaults.sensitiveFields.any(
      (sensitive) => lowerName.contains(sensitive.toLowerCase()),
    );
  }

  /// Check if a field is allowed in analytics.
  static bool isAnalyticsAllowed(String fieldName) {
    final lowerName = fieldName.toLowerCase();
    return DataMinimizationDefaults.analyticsAllowedFields.any(
      (allowed) => lowerName.contains(allowed.toLowerCase()),
    );
  }

  /// Filter a map to remove sensitive fields.
  ///
  /// Returns a new map with sensitive fields removed.
  static Map<String, dynamic> removeSensitiveFields(Map<String, dynamic> data) {
    return Map.fromEntries(
      data.entries.where((entry) => !isSensitiveField(entry.key)),
    );
  }

  /// Filter a map to only include analytics-safe fields.
  ///
  /// Returns a new map with only analytics-allowed fields.
  static Map<String, dynamic> filterForAnalytics(Map<String, dynamic> data) {
    return Map.fromEntries(
      data.entries.where((entry) => isAnalyticsAllowed(entry.key)),
    );
  }
}

/// Query builder helper for implementing data minimization in database queries.
///
/// Use these methods when building Drift queries to ensure data minimization.
class QueryMinimizationHelper {
  /// Build a date range filter for the retention period.
  ///
  /// Returns a tuple of (startDate, endDate) for query filtering.
  static (DateTime, DateTime) buildRetentionDateRange([int? maxDays]) {
    final endDate = DateTime.now();
    final startDate = DataRetentionHelper.retentionCutoffDate(maxDays);
    return (startDate, endDate);
  }

  /// Suggested LIMIT clause value for history queries.
  static int suggestedHistoryLimit([int? customLimit]) {
    if (customLimit != null && customLimit > 0) {
      return customLimit.clamp(1, DataMinimizationDefaults.maxHistorySessions);
    }
    return DataMinimizationDefaults.maxHistorySessions;
  }
}

/// Extension methods for applying data minimization to lists.
extension DataMinimizationListExtension<T> on List<T> {
  /// Take only the first [n] items, respecting maximum limits.
  List<T> takeWithLimit([int? n]) {
    final limit = n ?? DataMinimizationDefaults.defaultPageSize;
    final constrainedLimit = limit.clamp(1, DataMinimizationDefaults.maxPageSize);
    return take(constrainedLimit).toList();
  }

  /// Paginate the list.
  List<T> paginate(int page, [int pageSize = DataMinimizationDefaults.defaultPageSize]) {
    final constrainedPageSize = PaginationHelper.constrainPageSize(pageSize);
    final offset = PaginationHelper.calculateOffset(page, constrainedPageSize);
    if (offset >= length) return [];
    return skip(offset).take(constrainedPageSize).toList();
  }
}
