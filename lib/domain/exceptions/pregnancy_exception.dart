/// Exception thrown by pregnancy operations.
class PregnancyException implements Exception {
  final String message;
  final PregnancyErrorType type;

  const PregnancyException(this.message, this.type);

  @override
  String toString() => 'PregnancyException: $message (type: $type)';
}

/// Types of pregnancy errors
enum PregnancyErrorType {
  /// Pregnancy not found
  notFound,

  /// Start date is in the future
  invalidStartDate,

  /// Due date is before start date
  invalidDueDate,

  /// Date range is unrealistic (outside 38-42 weeks)
  unrealisticDateRange,

  /// Cannot delete pregnancy with associated data
  hasAssociatedData,

  /// No active pregnancy exists
  noActivePregnancy,

  /// Multiple active pregnancies found (data integrity issue)
  multipleActivePregnancies,
}
