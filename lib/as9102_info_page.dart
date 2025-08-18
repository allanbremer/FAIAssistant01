import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'as9102_viewer.dart';
import 'missing_file_page.dart';
// Import your help_text_screen.dart file:
import 'help_text_screen.dart';

class AS9102InfoPage extends StatelessWidget {
  final VoidCallback onFileCheckComplete;

  const AS9102InfoPage({Key? key, required this.onFileCheckComplete})
      : super(key: key);

  void _retrieveAS9102(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final pickedPath = result.files.single.path!;
      final pickedName = result.files.single.name;

      // Enforce file name check with dialog
      if (pickedName.toLowerCase() != 'as9102.pdf') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid File"),
            content: const Text(
              "Only the official, purchased file named as9102.pdf can be accepted.\n\n"
              "Please make sure your file is purchased from SAE, validated, and named exactly as9102.pdf before trying again."
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return; // Abort import
      }

      final documentsDir = await getApplicationDocumentsDirectory();
      final permanentPath = '${documentsDir.path}/as9102.pdf';

      // Copy the file to the known internal location
      await File(pickedPath).copy(permanentPath);

      // Notify that file now exists
      onFileCheckComplete();

      // Push the viewer page and return to this info page on back
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AS9102ViewerPage(pdfPath: permanentPath),
        ),
      );
    } else {
      // No file selected, go to missing file screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MissingFilePage(
            returnCallback: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase AS9102"),
        centerTitle: true,                      // Center the title
        backgroundColor: Colors.lightBlue[100], // Blue background
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The help text is now linkified for clickable URLs!
            Linkify(
              text: HelpText.texts[HelpKeys.as9102InfoPage] ?? '',
              style: const TextStyle(fontSize: 16),
              linkStyle: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              onOpen: (link) async {
                final url = Uri.parse(link.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _retrieveAS9102(context),
                    child: const Text("Retrieve AS9102"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}