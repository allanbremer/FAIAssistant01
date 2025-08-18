import 'package:flutter/material.dart';
import 'package:fai_assistant/icon_help_screen.dart'; // Import your help screen

class AS9102FieldTextPage extends StatelessWidget {
  final String formName;
  final int fieldNumber;
  final String fieldLabel;
  final String officialText;

  const AS9102FieldTextPage({
    super.key,
    required this.formName,
    required this.fieldNumber,
    required this.fieldLabel,
    required this.officialText,
  });

  String _getShortTitle() {
    // Extracts the number from "Form 2" -> "2"
    String formNum = formName.replaceAll(RegExp(r'[^0-9]'), '');
    return 'F$formNum/F$fieldNumber: $fieldLabel';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Remove default back arrow
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue[100],
        toolbarHeight: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const IconHelpScreen(
                    helpText: 'This screen displays the official AS9102 text for the selected field. Tap Go Back to return.',
                  ),
                ),
              );
            },
            child: Image.asset(
              'assets/images/fai_assistant_app_icon.png',
              width: 36,
              height: 36,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          _getShortTitle(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            // No underline, no decoration!
          ),
        ),
      ),
      backgroundColor: Colors.indigo.shade50,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Text(
                  officialText,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}