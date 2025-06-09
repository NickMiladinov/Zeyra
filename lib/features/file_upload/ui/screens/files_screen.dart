import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:logger/logger.dart'; // Import for Logger type

import 'package:zeyra/core/helpers/exceptions.dart'; // Use package-relative import
import '../../logic/files_provider.dart';
import '../../data/models/medical_file_model.dart';
// import '../widgets/file_list_item.dart'; // To be created
import '../widgets/file_view_dialog.dart'; // To be created

class FilesScreen extends ConsumerWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicalFilesAsyncValue = ref.watch(medicalFilesProvider);
    final logger = ref.watch(loggerProvider); // Get logger from files_provider

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Medical Files"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh list",
            onPressed: () {
              ref.read(medicalFilesProvider.notifier).refreshFiles();
            },
          ),
        ],
      ),
      body: medicalFilesAsyncValue.when(
        data: (files) {
          if (files.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No medical files found.\nTap the '+' button to add your first file.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              ),
            );
          }
          // TODO: Replace ListTile with a custom FileListItem widget for better UI/UX
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  leading: Icon(_getIconForFileType(file.fileType), size: 40, color: Theme.of(context).primaryColor),
                  title: Text(file.originalFilename, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "Added: ${DateFormat.yMMMd().add_jm().format(file.createdAt)}\n"
                      "Type: ${file.fileType?.toUpperCase() ?? 'UNKNOWN'}${file.fileSize != null ? ' - ${_formatFileSize(file.fileSize!)}' : ''}",
                      style: TextStyle(color: Colors.grey[700])),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                    tooltip: 'Delete File',
                    onPressed: () {
                      _confirmDeleteFileDialog(context, ref, file, logger);
                    },
                  ),
                  onTap: () {
                    _showFileViewDialog(context, ref, file, logger);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 50),
                const SizedBox(height: 16),
                Text("Error loading files: $error", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  onPressed: () {
                    ref.read(medicalFilesProvider.notifier).refreshFiles();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final notifier = ref.read(medicalFilesProvider.notifier);
          final bool success = await notifier.pickAndSecureFile();
          
          if (context.mounted) { // Check if the widget is still in the tree
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("File added successfully!"), backgroundColor: Colors.green),
              );
            } else {
              final currentState = ref.read(medicalFilesProvider);
              String errorMessage = "File addition cancelled or failed."; // Default message

              if (currentState.hasError && currentState.error != null) {
                final error = currentState.error;
                if (error is DuplicateFileException) {
                  errorMessage = error.message; // Use message from DuplicateFileException
                } else {
                  // Attempt to give a cleaner error message for other types
                  String specificError = error.toString();
                  if (specificError.contains("FileSystemException")) {
                      errorMessage = "Storage permission denied or error accessing file system.";
                  } else if (specificError.length > 100) { // Avoid overly long technical errors
                      errorMessage = "An unexpected error occurred while adding the file.";
                  } else {
                      errorMessage = "Failed to add file: $specificError";
                  }
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
              );
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add File"),
        tooltip: "Add new medical file",
      ),
    );
  }

  IconData _getIconForFileType(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file_outlined;
    final type = fileType.toLowerCase();
    if (type == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif'].contains(type)) return Icons.image_outlined;
    if (['txt', 'csv'].contains(type)) return Icons.text_snippet_outlined;
    if (['json', 'xml', 'hl7'].contains(type)) return Icons.code_outlined;
    if (type == 'dcm') return Icons.medical_information_outlined; // Specific for DICOM
    return Icons.insert_drive_file_outlined;
  }

  String _formatFileSize(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    final kb = bytes / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(decimals)} KB";
    final mb = kb / 1024;
    if (mb < 1024) return "${mb.toStringAsFixed(decimals)} MB";
    final gb = mb / 1024;
    return "${gb.toStringAsFixed(decimals)} GB";
  }
  
  // Method to show the file view dialog
  void _showFileViewDialog(BuildContext context, WidgetRef ref, MedicalFile file, Logger logger) {
    logger.i("Tapped on file: ${file.originalFilename}. ID: ${file.id}. Attempting to show dialog.");
    
    // Use the actual FileViewDialog widget
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Pass the medicalFile to the FileViewDialog.
        // FileViewDialog is a ConsumerStatefulWidget and will handle its own state and provider interactions.
        return FileViewDialog(medicalFile: file);
      },
    );
  }

  // Method to show a confirmation dialog before deleting a file
  void _confirmDeleteFileDialog(BuildContext context, WidgetRef ref, MedicalFile file, Logger logger) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete '${file.originalFilename}'?\n\nThis action cannot be undone and will permanently delete the file and its metadata."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
              child: const Text("Delete"),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                logger.i("Deletion confirmed for file: ${file.originalFilename} (ID: ${file.id})");
                
                final bool success = await ref.read(medicalFilesProvider.notifier).deleteMedicalFile(file);
                
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("'${file.originalFilename}' deleted successfully!"), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete '${file.originalFilename}'. Check logs for details."), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
} 