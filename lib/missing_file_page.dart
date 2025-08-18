
import 'package:flutter/material.dart';

class MissingFilePage extends StatelessWidget {
  final VoidCallback returnCallback;

  const MissingFilePage({super.key, required this.returnCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("File Not Found")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AS9102.pdf could not be found in your Documents folder.\n\n"
                  "Make sure the file has been purchased and saved correctly.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: returnCallback,
                child: const Text("Go Back"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}