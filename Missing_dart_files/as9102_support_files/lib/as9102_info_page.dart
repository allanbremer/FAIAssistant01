
import 'package:flutter/material.dart';
import 'utils/file_utils.dart';
import 'missing_file_page.dart';
import 'as9102_viewer.dart';

class AS9102InfoPage extends StatelessWidget {
  final VoidCallback onFileCheckComplete;

  const AS9102InfoPage({super.key, required this.onFileCheckComplete});

  void _retrieveAS9102(BuildContext context) async {
    bool exists = await checkAS9102FileExists();

    if (exists) {
      onFileCheckComplete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AS9102ViewerPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MissingFilePage(returnCallback: () => Navigator.pop(context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase AS9102")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "To view the AS9102 Specification, please purchase it from:\n\n"
              "https://www.sae.org/standards/content/as9102/\n\n"
              "Then download the file and place it in the Documents folder of your device with the filename 'as9102.pdf'.",
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _retrieveAS9102(context),
              child: const Text("Retrieve AS9102"),
            ),
          ],
        ),
      ),
    );
  }
}
