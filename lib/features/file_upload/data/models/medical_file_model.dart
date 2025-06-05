// Defines the structure for a medical file's metadata.
class MedicalFile {
  final String id; // Corresponds to fileId, Primary Key
  final String originalFilename;
  final String? fileType; // Mime type or extension (e.g., 'pdf', 'jpg')
  final DateTime dateAdded; // Timestamp of when the file was added
  final String encryptedPath; // Path to the encrypted file on device
  final int? fileSize; // Size of the original file in bytes

  MedicalFile({
    required this.id,
    required this.originalFilename,
    this.fileType,
    required this.dateAdded,
    required this.encryptedPath,
    this.fileSize,
  });

  // Factory constructor to create a MedicalFile from a map (e.g., from SQLite).
  // This is useful when reading data from the database.
  factory MedicalFile.fromMap(Map<String, dynamic> map) {
    return MedicalFile(
      id: map['id'] as String,
      originalFilename: map['original_filename'] as String,
      fileType: map['file_type'] as String?,
      // Convert timestamp from DB (INTEGER) to DateTime
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['date_added'] as int),
      encryptedPath: map['encrypted_path'] as String,
      fileSize: map['file_size_bytes'] as int?,
    );
  }

  // Method to convert a MedicalFile instance to a map.
  // This is useful when writing data to the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original_filename': originalFilename,
      'file_type': fileType,
      // Convert DateTime to timestamp (INTEGER) for DB storage
      'date_added': dateAdded.millisecondsSinceEpoch,
      'encrypted_path': encryptedPath,
      'file_size_bytes': fileSize,
    };
  }

  // Optional: Implement toString for easy debugging
  @override
  String toString() {
    return 'MedicalFile{id: \$id, originalFilename: \$originalFilename, fileType: \$fileType, dateAdded: \$dateAdded, encryptedPath: \$encryptedPath, fileSize: \$fileSize}';
  }

  // Optional: Implement copyWith if you need to create modified copies
  MedicalFile copyWith({
    String? id,
    String? originalFilename,
    String? fileType,
    DateTime? dateAdded,
    String? encryptedPath,
    int? fileSize,
  }) {
    return MedicalFile(
      id: id ?? this.id,
      originalFilename: originalFilename ?? this.originalFilename,
      fileType: fileType ?? this.fileType,
      dateAdded: dateAdded ?? this.dateAdded,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  // Optional: Implement equality and hashCode if you plan to store these in sets or use them as map keys
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalFile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          originalFilename == other.originalFilename &&
          fileType == other.fileType &&
          dateAdded == other.dateAdded &&
          encryptedPath == other.encryptedPath &&
          fileSize == other.fileSize;

  @override
  int get hashCode =>
      id.hashCode ^
      originalFilename.hashCode ^
      fileType.hashCode ^
      dateAdded.hashCode ^
      encryptedPath.hashCode ^
      fileSize.hashCode;
} 