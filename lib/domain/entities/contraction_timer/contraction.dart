import 'contraction_intensity.dart';

/// Represents a single contraction recorded during a contraction timing session.
/// 
/// Each contraction captures the start time, optional end time (null if active),
/// and the user's perceived intensity. Duration is computed from timestamps.
class Contraction {
  /// Unique identifier for this contraction
  final String id;
  
  /// ID of the session this contraction belongs to
  final String sessionId;
  
  /// Timestamp when the contraction started
  final DateTime startTime;
  
  /// Timestamp when the contraction ended (null if currently active)
  final DateTime? endTime;
  
  /// User's perception of contraction intensity
  final ContractionIntensity intensity;

  const Contraction({
    required this.id,
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.intensity,
  });

  /// Whether this contraction is currently active (being timed)
  bool get isActive => endTime == null;

  /// Calculate the duration of this contraction.
  /// 
  /// Returns null if the contraction is still active.
  /// For active contractions, use DateTime.now().difference(startTime) in UI.
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Create a copy with updated fields
  Contraction copyWith({
    String? id,
    String? sessionId,
    DateTime? startTime,
    DateTime? endTime,
    ContractionIntensity? intensity,
  }) {
    return Contraction(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      intensity: intensity ?? this.intensity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contraction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          intensity == other.intensity;

  @override
  int get hashCode =>
      id.hashCode ^
      sessionId.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      intensity.hashCode;

  @override
  String toString() =>
      'Contraction(id: $id, sessionId: $sessionId, startTime: $startTime, '
      'endTime: $endTime, intensity: $intensity, isActive: $isActive)';
}

