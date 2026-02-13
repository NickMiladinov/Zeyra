/// Domain entity representing a user's shortlisted hospital.
///
/// Users can shortlist multiple hospitals and eventually select one
/// as their final choice for the birth.
class HospitalShortlist {
  /// UUID primary key.
  final String id;

  /// Reference to the maternity unit.
  final String maternityUnitId;

  /// When this hospital was added to the shortlist.
  final DateTime addedAt;

  /// Whether this is the final selected hospital.
  final bool isSelected;

  /// Optional user notes about this hospital.
  final String? notes;

  const HospitalShortlist({
    required this.id,
    required this.maternityUnitId,
    required this.addedAt,
    required this.isSelected,
    this.notes,
  });

  HospitalShortlist copyWith({
    String? id,
    String? maternityUnitId,
    DateTime? addedAt,
    bool? isSelected,
    String? notes,
  }) {
    return HospitalShortlist(
      id: id ?? this.id,
      maternityUnitId: maternityUnitId ?? this.maternityUnitId,
      addedAt: addedAt ?? this.addedAt,
      isSelected: isSelected ?? this.isSelected,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalShortlist &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'HospitalShortlist(id: $id, maternityUnitId: $maternityUnitId, isSelected: $isSelected)';
}
