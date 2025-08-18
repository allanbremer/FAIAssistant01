
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class AS9102ViewerPage extends StatelessWidget {
  const AS9102ViewerPage({super.key});

  Future<String> _getPDFPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '\${dir.path}/as9102.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getPDFPath(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("AS9102 Viewer")),
            body: PDFView(filePath: snapshot.data!),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Error loading PDF")));
        } else {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
