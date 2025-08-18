import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../help_screen.dart'; // <-- Adjust path if needed
import '../help_text_screen.dart'; // <-- For HelpKeys, adjust if needed
import 'package:fai_assistant/screens/field1_detail_page.dart';

class Form2Page extends StatefulWidget {
  const Form2Page({Key? key}) : super(key: key);

  // List of Form 2 fields
  final List<Map<String, dynamic>> form2Fields = const [
    {'fieldNumber': 1, 'label': 'Field 1 – Part Number'},
    {'fieldNumber': 2, 'label': 'Field 2 – Part Name'},
    {'fieldNumber': 3, 'label': 'Field 3 – Serial Number'},
    {'fieldNumber': 4, 'label': 'Field 4 – FAI Identifier'},
    {'fieldNumber': 5, 'label': 'Field 5 – Material or Process Name'},
    {'fieldNumber': 6, 'label': 'Field 6 – Specification Number'},
    {'fieldNumber': 7, 'label': 'Field 7 – Code'},
    {'fieldNumber': 8, 'label': 'Field 8 – Supplier'},
    {'fieldNumber': 9, 'label': 'Field 9 – Customer Approval Verification'},
    {
      'fieldNumber': 10,
      'label': 'Field 10 – Certificate of Conformance Number'
    },
    {'fieldNumber': 11, 'label': 'Field 11 – Functional Test Procedure Number'},
    {'fieldNumber': 12, 'label': 'Field 12 – Acceptance Report Number'},
    {'fieldNumber': 13, 'label': 'Field 13 – Comments'},
  ];

  @override
  State<Form2Page> createState() => _Form2PageState();
}

class _Form2PageState extends State<Form2Page> {
  late List<bool> _hasNote;

  @override
  void initState() {
    super.initState();
    _hasNote = List<bool>.filled(widget.form2Fields.length, false);
    _loadNoteStatus();
  }

  Future<void> _loadNoteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < widget.form2Fields.length; i++) {
      final fieldNum = widget.form2Fields[i]['fieldNumber'];
      final key = 'notes_Form 2_Field$fieldNum';
      _hasNote[i] = (prefs.getString(key) ?? '').isNotEmpty;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HelpScreen(helpKey: HelpKeys.form2Page),
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
          'Form 2 – Product Accountability',
          style: TextStyle(
            fontSize: 16,
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
              itemCount: widget.form2Fields.length,
              itemBuilder: (context, index) {
                final field = widget.form2Fields[index];
                final label = '${field['label']}${_hasNote[index] ? ' *' : ''}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FieldDetailPage(
                            formName: 'Form 2',
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
//                child: const Text('Go Back'),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16, // Try 20 or 22 for larger, adjust as you like
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
