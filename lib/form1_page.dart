import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../help_screen.dart'; // Adjust path if needed
import '../help_text_screen.dart'; // For HelpKeys, adjust if needed
import 'package:fai_assistant/screens/field1_detail_page.dart';

class Form1Page extends StatefulWidget {
  const Form1Page({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> form1Fields = const [
    {'fieldNumber': 1, 'label': 'Field 1 – Part Number'},
    {'fieldNumber': 2, 'label': 'Field 2 – Part Name'},
    {'fieldNumber': 3, 'label': 'Field 3 – Serial Number'},
    {'fieldNumber': 4, 'label': 'Field 4 – FAIR Identifier'},
    {'fieldNumber': 5, 'label': 'Field 5 – Part Revision Level'},
    {'fieldNumber': 6, 'label': 'Field 6 – Drawing Number'},
    {'fieldNumber': 7, 'label': 'Field 7 – Drawing Revision Level'},
    {'fieldNumber': 8, 'label': 'Field 8 – Additional Changes'},
    {'fieldNumber': 9, 'label': 'Field 9 – Manufacturing Process Reference'},
    {'fieldNumber': 10, 'label': 'Field 10 – Organization Name'},
    {'fieldNumber': 11, 'label': 'Field 11 – Supplier Code'},
    {'fieldNumber': 12, 'label': 'Field 12 – PO Number'},
    {'fieldNumber': 13, 'label': 'Field 13 – Detail or Assembly FAI'},
    {'fieldNumber': 14, 'label': 'Field 14 – Full or Partial FAI'},
    {'fieldNumber': 15, 'label': 'Field 15 – Part Number'},
    {'fieldNumber': 16, 'label': 'Field 16 – Part Name'},
    {'fieldNumber': 17, 'label': 'Field 17 – Part Type'},
    {'fieldNumber': 18, 'label': 'Field 18 – FAIR Identifier'},
    {'fieldNumber': 19, 'label': 'Field 19 – Documented Nonconformance'},
    {'fieldNumber': 20, 'label': 'Field 20 – FAIR Verified By'},
    {'fieldNumber': 21, 'label': 'Field 21 – Date'},
    {'fieldNumber': 22, 'label': 'Field 22 – Reviewed/Approved By'},
    {'fieldNumber': 23, 'label': 'Field 23 – Date'},
    {'fieldNumber': 24, 'label': 'Field 24 – Customer Approval'},
    {'fieldNumber': 25, 'label': 'Field 25 – Date'},
    {'fieldNumber': 26, 'label': 'Field 26 – Comments'},
  ];

  @override
  State<Form1Page> createState() => _Form1PageState();
}

class _Form1PageState extends State<Form1Page> {
  late List<bool> _hasNote;

  @override
  void initState() {
    super.initState();
    _hasNote = List<bool>.filled(widget.form1Fields.length, false);
    _loadNoteStatus();
  }

  Future<void> _loadNoteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < widget.form1Fields.length; i++) {
      final fieldNum = widget.form1Fields[i]['fieldNumber'];
      final key = 'notes_Form 1_Field$fieldNum';
      _hasNote[i] = (prefs.getString(key) ?? '').isNotEmpty;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        // fixed height for consistency
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HelpScreen(helpKey: HelpKeys.form1Page),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/fai_assistant_app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          'Form 1 - Part Number Accountability',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              itemCount: widget.form1Fields.length,
              itemBuilder: (context, index) {
                final field = widget.form1Fields[index];
                final label = '${field['label']}${_hasNote[index] ? ' *' : ''}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FieldDetailPage(
                            formName: 'Form 1',
                            fieldNumber: field['fieldNumber'],
                            fieldLabel: field['label'],
                          ),
                        ),
                      );
                      _loadNoteStatus();
                    },
                    child: Text(label),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            minimum:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            bottom: true,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16, // adjust as needed
//                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
