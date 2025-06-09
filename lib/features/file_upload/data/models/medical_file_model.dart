/// Defines the structure for a medical file's metadata.
class MedicalFile {
  final String id; // Corresponds to fileId, Primary Key
  final String userId; // Foreign key to the user
  final String originalFilename;
  final String? fileType; // Mime type or extension (e.g., 'pdf', 'jpg')
  final DateTime createdAt; // Timestamp of when the file was added
  final String encryptedPath; // Path to the encrypted file on device
  final int? fileSize; // Size of the original file in bytes
  final int version;
  final DateTime lastModifiedAt;
  final DateTime? deletedAt;

  MedicalFile({
    required this.id,
    required this.userId,
    required this.originalFilename,
    this.fileType,
    required this.createdAt,
    required this.encryptedPath,
    this.fileSize,
    required this.version,
    required this.lastModifiedAt,
    this.deletedAt,
  });

  // Factory constructor to create a MedicalFile from a map (e.g., from SQLite).
  // This is useful when reading data from the database.
  factory MedicalFile.fromMap(Map<String, dynamic> map) {
    return MedicalFile(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      originalFilename: map['original_filename'] as String,
      fileType: map['file_type'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      encryptedPath: map['encrypted_path'] as String,
      fileSize: map['file_size_bytes'] as int?,
      version: map['version'] as int,
      lastModifiedAt: DateTime.parse(map['last_modified_at'] as String),
      deletedAt: map['deleted_at'] == null ? null : DateTime.parse(map['deleted_at'] as String),
    );
  }

  // Method to convert a MedicalFile instance to a map.
  // This is useful when writing data to the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'original_filename': originalFilename,
      'file_type': fileType,
      'created_at': createdAt.toUtc().toIso8601String(),
      'encrypted_path': encryptedPath,
      'file_size_bytes': fileSize,
      'version': version,
      'last_modified_at': lastModifiedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  // Optional: Implement toString for easy debugging
  @override
  String toString() {
    return 'MedicalFile{id: $id, userId: $userId, originalFilename: $originalFilename, fileType: $fileType, createdAt: $createdAt, encryptedPath: $encryptedPath, fileSize: $fileSize}';
  }

  // Optional: Implement copyWith if you need to create modified copies
  MedicalFile copyWith({
    String? id,
    String? userId,
    String? originalFilename,
    String? fileType,
    DateTime? createdAt,
    String? encryptedPath,
    int? fileSize,
    int? version,
    DateTime? lastModifiedAt,
    DateTime? deletedAt,
  }) {
    return MedicalFile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originalFilename: originalFilename ?? this.originalFilename,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      fileSize: fileSize ?? this.fileSize,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Optional: Implement equality and hashCode if you plan to store these in sets or use them as map keys
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalFile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          originalFilename == other.originalFilename &&
          fileType == other.fileType &&
          createdAt == other.createdAt &&
          encryptedPath == other.encryptedPath &&
          fileSize == other.fileSize;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      originalFilename.hashCode ^
      fileType.hashCode ^
      createdAt.hashCode ^
      encryptedPath.hashCode ^
      fileSize.hashCode;

  String get fileSizeFormatted {
    if (fileSize == null) return 'N/A';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1048576) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / 1048576).toStringAsFixed(1)} MB';
  }
  
  bool get isImage {
    final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif'];
    return imageTypes.contains(fileType?.toLowerCase());
  }
} 