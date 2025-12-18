/// Perceived intensity of a contraction as reported by the user.
/// 
/// This subjective measure helps track changes in contraction patterns
/// which may indicate labor progression.
enum ContractionIntensity {
  /// Mild discomfort, easily manageable
  mild,
  
  /// Moderate discomfort, requires focus
  moderate,
  
  /// Strong, intense contractions
  strong;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ContractionIntensity.mild:
        return 'Mild';
      case ContractionIntensity.moderate:
        return 'Moderate';
      case ContractionIntensity.strong:
        return 'Strong';
    }
  }
}

