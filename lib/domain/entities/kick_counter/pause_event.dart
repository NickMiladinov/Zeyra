/// Represents a single pause/resume cycle within a kick counting session.
/// 
/// Each pause event tracks when a session was paused and resumed,
/// along with the number of kicks that had been recorded at the time
/// of pausing. This information is critical for accurately calculating
/// the time to reach 10 kicks by excluding pause durations that occurred
/// before the 10th kick.
class PauseEvent {
  /// Unique identifier for this pause event
  final String id;
  
  /// ID of the session this pause belongs to
  final String sessionId;
  
  /// Timestamp when the session was paused
  final DateTime pausedAt;
  
  /// Timestamp when the session was resumed (null if still paused or session ended while paused)
  final DateTime? resumedAt;
  
  /// Number of kicks recorded BEFORE this pause started
  /// 
  /// Used to determine if this pause should be excluded from time-to-10 calculation.
  /// For example, if kickCountAtPause < 10, this pause happened before the 10th
  /// kick and should be subtracted from the duration.
  final int kickCountAtPause;

  const PauseEvent({
    required this.id,
    required this.sessionId,
    required this.pausedAt,
    this.resumedAt,
    required this.kickCountAtPause,
  });

  /// Duration of this pause
  /// 
  /// If resumedAt is null (pause never resumed), returns duration from
  /// pausedAt to now.
  Duration get duration => (resumedAt ?? DateTime.now()).difference(pausedAt);

  /// Whether this pause occurred before the 10th kick
  /// 
  /// Used to determine if this pause should be excluded from time-to-10 calculation.
  bool get isBeforeTenthKick => kickCountAtPause < 10;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PauseEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionId == other.sessionId &&
          pausedAt == other.pausedAt &&
          resumedAt == other.resumedAt &&
          kickCountAtPause == other.kickCountAtPause;

  @override
  int get hashCode =>
      id.hashCode ^
      sessionId.hashCode ^
      pausedAt.hashCode ^
      resumedAt.hashCode ^
      kickCountAtPause.hashCode;

  @override
  String toString() =>
      'PauseEvent(id: $id, sessionId: $sessionId, pausedAt: $pausedAt, '
      'resumedAt: $resumedAt, kickCountAtPause: $kickCountAtPause)';
}

