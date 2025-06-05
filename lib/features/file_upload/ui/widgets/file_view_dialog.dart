import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../data/models/medical_file_model.dart';
import '../../logic/files_provider.dart'; // To access decryptFile and loggerProvider

class FileViewDialog extends ConsumerStatefulWidget {
  final MedicalFile medicalFile;

  const FileViewDialog({super.key, required this.medicalFile});

  @override
  FileViewDialogState createState() => FileViewDialogState();
}

class FileViewDialogState extends ConsumerState<FileViewDialog> {
  Future<Uint8List?>? _decryptionFuture;
  // State variables to hold the outcome of the decryption
  Uint8List? _decryptedBytes;
  String? _errorMessage;
  late Logger _logger; // Initialize in initState or didChangeDependencies

  @override
  void initState() {
    super.initState();
    _logger = ref.read(loggerProvider);
    _startDecryption();
  }

  void _startDecryption() {
    _logger.i("FileViewDialog: Initializing decryption for ${widget.medicalFile.originalFilename} (ID: ${widget.medicalFile.id})");
    setState(() {
      // Reset state for potential retries or sequential dialog opens
      _decryptedBytes = null;
      _errorMessage = null;
      _decryptionFuture = ref.read(medicalFilesProvider.notifier).decryptFile(widget.medicalFile.id)
        ..then((bytes) {
          if (!mounted) return; // Widget was disposed
          if (bytes != null) {
            setState(() {
              _decryptedBytes = bytes;
            });
            _logger.i("FileViewDialog: Decryption successful for ${widget.medicalFile.originalFilename}, ${bytes.lengthInBytes} bytes.");
          } else {
            setState(() {
              _errorMessage = "Decryption failed. File may be corrupt, key missing, or file not found.";
            });
            _logger.w("FileViewDialog: Decryption returned null for ${widget.medicalFile.originalFilename}");
          }
        }).catchError((e, stackTrace) {
          if (!mounted) return;
          setState(() {
            _errorMessage = "Error during decryption: ${e.toString()}";
          });
          _logger.e("FileViewDialog: Decryption error for ${widget.medicalFile.originalFilename}", error: e, stackTrace: stackTrace);
        });
    });
  }

  Widget _buildContent(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 40),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry Decryption"),
                onPressed: _startDecryption, 
              )
            ],
          )
        ),
      );
    }

    // _decryptedBytes will be set by the future completion, so FutureBuilder handles the loading state
    // If _decryptedBytes is not null, it means decryption was successful.
    if (_decryptedBytes != null) {
      final fileType = widget.medicalFile.fileType?.toLowerCase() ?? '';
      _logger.d("FileViewDialog: Building content for type '$fileType'");

      if (['txt', 'csv', 'json', 'xml', 'hl7'].contains(fileType)) {
        String content = "Error: Could not decode text content.";
        try {
          content = String.fromCharCodes(_decryptedBytes!); // Assumes UTF-8 or compatible
          _logger.d("FileViewDialog: Text content decoded (length: ${content.length})");
        } catch (e) {
           _logger.e("FileViewDialog: Error decoding text content for ${widget.medicalFile.originalFilename}", error: e);
        }
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(content, style: const TextStyle(fontSize: 14)),
          ),
        );
      } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(fileType)) {
         _logger.d("FileViewDialog: Displaying image (${_decryptedBytes!.lengthInBytes} bytes)");
        return InteractiveViewer(
            panEnabled: true, 
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.memory(_decryptedBytes!, fit: BoxFit.contain),
        );
      } else if (fileType == 'pdf') {
        _logger.i("FileViewDialog: PDF viewer not yet supported for ${widget.medicalFile.originalFilename}.");
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "PDF Viewer not yet supported.\nFile content is available but cannot be rendered in-app yet.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      } else {
         _logger.i("FileViewDialog: Unsupported file type '$fileType' for direct viewing.");
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Unsupported file type: ${widget.medicalFile.fileType?.toUpperCase() ?? 'UNKNOWN'}.\nCannot display content directly.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      }
    }
    // This should not be reached if FutureBuilder handles connection states correctly,
    // but as a fallback if _decryptionFuture is null before FutureBuilder runs.
    return const Center(child: Text("Initializing decryption..."));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medicalFile.originalFilename, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // Use more width
        height: MediaQuery.of(context).size.height * 0.7, // Use more height
        child: FutureBuilder<Uint8List?>(
          future: _decryptionFuture, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              _logger.d("FileViewDialog: FutureBuilder waiting for decryption...");
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Decrypting file, please wait..."),
                  ],
                ),
              );
            }
            // At this point, the future has completed (either with data or error handled by .then/.catchError)
            // So we rely on _decryptedBytes and _errorMessage to build the UI.
            return _buildContent(context);
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      titlePadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    );
  }
} 