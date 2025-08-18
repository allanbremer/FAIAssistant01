
import 'package:flutter/material.dart';

class MissingFilePage extends StatelessWidget {
  final VoidCallback returnCallback;

  const MissingFilePage({super.key, required this.returnCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("File Not Found")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "AS9102.pdf could not be found in your Documents folder.\n\n"
              "Make sure the file has been purchased and saved correctly.",
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: returnCallback,
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}
