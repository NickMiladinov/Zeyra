/// Represents a single kick recorded during a kick counting session.
/// 
/// Each kick captures the moment of fetal movement with metadata including
/// timestamp, sequence within the session, and perceived movement strength.
class Kick {
  /// Unique identifier for this kick
  final String id;
  
  /// ID of the session this kick belongs to
  final String sessionId;
  
  /// Timestamp when the kick was recorded
  final DateTime timestamp;
  
  /// Sequential number of this kick within the session (1-indexed)
  final int sequenceNumber;
  
  /// User's perception of movement strength
  final MovementStrength perceivedStrength;

  const Kick({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.sequenceNumber,
    required this.perceivedStrength,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Kick &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          timestamp == other.timestamp &&
          sequenceNumber == other.sequenceNumber &&
          perceivedStrength == other.perceivedStrength;

  @override
  int get hashCode =>
      id.hashCode ^
      sessionId.hashCode ^
      timestamp.hashCode ^
      sequenceNumber.hashCode ^
      perceivedStrength.hashCode;

  @override
  String toString() =>
      'Kick(id: $id, sessionId: $sessionId, timestamp: $timestamp, '
      'sequenceNumber: $sequenceNumber, strength: $perceivedStrength)';
}

/// Perceived strength of fetal movement as reported by the user.
/// 
/// This subjective measure helps track changes in movement patterns
/// which may indicate changes in fetal wellbeing.
enum MovementStrength {
  /// Barely noticeable, subtle movements
  weak,
  
  /// Clearly felt but not strong movements
  moderate,
  
  /// Strong, vigorous movements
  strong;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case MovementStrength.weak:
        return 'Weak';
      case MovementStrength.moderate:
        return 'Moderate';
      case MovementStrength.strong:
        return 'Strong';
    }
  }
}

