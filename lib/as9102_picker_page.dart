import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'as9102_viewer.dart';

class AS9102PickerPage extends StatelessWidget {
  const AS9102PickerPage({super.key});

  Future<void> _pickAndStorePDF(BuildContext context) async {
    // Request storage permissions
    if (!await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    // Let user pick a PDF
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      final pickedName = result.files.single.name;

      // Only allow file named as9102.pdf (case-insensitive)
      if (pickedName.toLowerCase() != 'as9102.pdf') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a file named 'as9102.pdf'."),
          ),
        );
        return; // Abort if not correct file name
      }

      // Copy to app's private storage
      final appDir = await getApplicationDocumentsDirectory();
      final destination = File('${appDir.path}/as9102.pdf');
      await pickedFile.copy(destination.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('as9102.pdf saved to app storage')),
      );

      // Open the viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AS9102ViewerPage(pdfPath: destination.path),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select as9102.pdf')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Centered pick button
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () => _pickAndStorePDF(context),
                child: const Text('Pick as9102.pdf'),
              ),
            ),
          ),
          // Go Back button at the bottom
          SafeArea(
            minimum: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}