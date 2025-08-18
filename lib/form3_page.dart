import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../help_screen.dart'; // <-- Adjust path if needed
import '../help_text_screen.dart'; // <-- For HelpKeys, adjust if needed
import 'package:fai_assistant/screens/field1_detail_page.dart';

class Form3Page extends StatefulWidget {
  const Form3Page({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> form3Fields = const [
    {'fieldNumber': 1, 'label': 'Field 1 – Part Number'},
    {'fieldNumber': 2, 'label': 'Field 2 – Part Name'},
    {'fieldNumber': 3, 'label': 'Field 3 – Serial Number'},
    {'fieldNumber': 4, 'label': 'Field 4 – FAI Identifier'},
    {'fieldNumber': 5, 'label': 'Field 5 – Char. No.'},
    {'fieldNumber': 6, 'label': 'Field 6 – Reference Location'},
    {'fieldNumber': 7, 'label': 'Field 7 – Characteristic Designator'},
    {'fieldNumber': 8, 'label': 'Field 8 – Requirement'},
    {'fieldNumber': 9, 'label': 'Field 9 – Results'},
    {'fieldNumber': 10, 'label': 'Field 10 – Designated/Qualified Tooling'},
    {'fieldNumber': 11, 'label': 'Field 11 – Nonconformance Number'},
    {'fieldNumber': 12, 'label': 'Field 12 – Additional Data/Comments'},
  ];

  @override
  State<Form3Page> createState() => _Form3PageState();
}

class _Form3PageState extends State<Form3Page> {
  late List<bool> _hasNote;

  @override
  void initState() {
    super.initState();
    _hasNote = List<bool>.filled(widget.form3Fields.length, false);
    _loadNoteStatus();
  }

  Future<void> _loadNoteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < widget.form3Fields.length; i++) {
      final fieldNum = widget.form3Fields[i]['fieldNumber'];
      final key = 'notes_Form 3_Field$fieldNum';
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
                builder: (_) => const HelpScreen(helpKey: HelpKeys.form3Page),
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
          'Form 3 – Characteristic Accountability',
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
              itemCount: widget.form3Fields.length,
              itemBuilder: (context, index) {
                final field = widget.form3Fields[index];
                final label = '${field['label']}${_hasNote[index] ? ' *' : ''}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FieldDetailPage(
                            formName: 'Form 3',
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
//    fontWeight: FontWeight.bold,
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
