import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class AS9102ViewerPage extends StatefulWidget {
  final String pdfPath;
  final int initialPage;
  final VoidCallback? onClose;
  final int? fieldNumber; // Made optional

  const AS9102ViewerPage({
    Key? key,
    required this.pdfPath,
    this.initialPage = 0,
    this.onClose,
    this.fieldNumber,
  }) : super(key: key);

  @override
  AS9102ViewerPageState createState() => AS9102ViewerPageState();
}

class AS9102ViewerPageState extends State<AS9102ViewerPage> {
  late PDFViewController _pdfViewController;
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fieldNumber != null
              ? "AS9102 Viewer – Field ${widget.fieldNumber}"
              : "AS9102 Viewer",
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[100],
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onClose != null) widget.onClose!();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              setState(() {
                _isReady = true;
              });
              if (widget.initialPage > 0) {
                _pdfViewController.setPage(widget.initialPage);
              }
            },
            onViewCreated: (PDFViewController vc) {
              _pdfViewController = vc;
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error loading PDF: \$error')),
              );
            },
          ),
          if (!_isReady)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}