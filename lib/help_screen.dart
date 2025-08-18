import 'package:flutter/material.dart';
import 'package:fai_assistant/help_text_screen.dart';

class HelpScreen extends StatelessWidget {
  final String helpKey;

  const HelpScreen({Key? key, required this.helpKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final helpText = HelpText.texts[helpKey] ?? 'No help available for this topic.';

    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Text(
            helpText,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ),
      ),
    );
  }
}