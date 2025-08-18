import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fai_assistant/as9102_paraphrased_data.dart';
import 'package:fai_assistant/as9102_viewer.dart';
import 'package:fai_assistant/as9102_info_page.dart';
import 'package:fai_assistant/ai_questions.dart';
import 'package:fai_assistant/ai_answer_page.dart';
import 'package:fai_assistant/form_field_labels.dart';
import 'package:fai_assistant/note_page.dart';           // NoteStore + NoteCreatePage
import 'package:fai_assistant/note_screen_page.dart';   // NoteListScreen
import 'package:fai_assistant/help_text_screen.dart';   // <-- import the map from here
import 'package:fai_assistant/icon_help_screen.dart';
import 'package:fai_assistant/as9102_field_text_page.dart';
import 'package:fai_assistant/get_as9102_page.dart';    // <-- new import

// Toggle this flag to switch AS9102 button behavior during development
const bool useNewAS9102TextScreen = true;

class FieldDetailPage extends StatefulWidget {
  final String formName;   // "Form 1", "Form 2", "Form 3"
  final int fieldNumber;   // 1–26, 1–13, 1–12
  final String fieldLabel;
  final bool fromChecklist;

  const FieldDetailPage({
    Key? key,
    required this.formName,
    required this.fieldNumber,
    required this.fieldLabel,
    this.fromChecklist = false,
  }) : super(key: key);

  @override
  State<FieldDetailPage> createState() => _FieldDetailPageState();
}

class _FieldDetailPageState extends State<FieldDetailPage> {
  bool _hasNote = false;

  // Build a stable storage key for notes per field.
  String get _fieldKey =>
      '${widget.formName.replaceAll(' ', '')}_Field${widget.fieldNumber}';

  @override
  void initState() {
    super.initState();
    _loadNoteStatus();
  }

  // reflect whether any notes exist for this field using NoteStore
  Future<void> _loadNoteStatus() async {
    final notes = await NoteStore().listByField(_fieldKey);
    if (!mounted) return;
    setState(() {
      _hasNote = notes.isNotEmpty;
    });
  }

  // Long-press flow — if no notes yet, go to create; else show list
  Future<void> _openNote() async {
    final store = NoteStore();
    final existing = await store.listByField(_fieldKey);

    if (!mounted) return;

    if (existing.isEmpty) {
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => NoteCreatePage(
            fieldKey: _fieldKey,
            fieldTitle:
                '${widget.formName} / Field ${widget.fieldNumber} – ${widget.fieldLabel}',
          ),
        ),
      );
      if (saved == true) {
        await _loadNoteStatus();
      }
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteListScreen(
            fieldKey: _fieldKey,
            fieldTitle:
                '${widget.formName} / Field ${widget.fieldNumber} – ${widget.fieldLabel}',
          ),
        ),
      );
      await _loadNoteStatus();
    }
  }

  // Always open the list (used by the new "View Notes" button)
  Future<void> _openNotesList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteListScreen(
          fieldKey: _fieldKey,
          fieldTitle:
              '${widget.formName} / Field ${widget.fieldNumber} – ${widget.fieldLabel}',
        ),
      ),
    );
    if (!mounted) return;
    await _loadNoteStatus();
  }

  String _getHelpKey() {
    return '${widget.formName.replaceAll(' ', '')}_Field${widget.fieldNumber}';
  }

  @override
  Widget build(BuildContext context) {
    int maxField;
    if (widget.formName == 'Form 1') {
      maxField = 26;
    } else if (widget.formName == 'Form 2') {
      maxField = 13;
    } else {
      maxField = 12;
    }

    const pdfPath =
        '/data/user/0/com.example.fai_assistant/app_flutter/as9102.pdf';
    final lookupKey =
        '${widget.formName.replaceAll(' ', '')}_Field${widget.fieldNumber}';
    final meaning = AS9102ParaphrasedData.content[lookupKey];
    final prevIndex = widget.fieldNumber > 1 ? widget.fieldNumber - 1 : null;
    final nextIndex =
        widget.fieldNumber < maxField ? widget.fieldNumber + 1 : null;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Colors.lightBlue[100],
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IconHelpScreen(
                    helpText: HelpText.texts[_getHelpKey()] ??
                        "No help available for this field.",
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
        title: GestureDetector(
          onLongPress: _openNote, // flow described above
          child: Text(
            widget.formName + (_hasNote ? ' *' : ''),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fieldLabel + (_hasNote ? ' *' : ''),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        meaning ?? 'NO DATA FOUND for this field.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (useNewAS9102TextScreen) {
                          final key =
                              '${widget.formName.replaceAll(' ', '')}_Field${widget.fieldNumber}';
                          final officialText = as9102OfficialFieldText[key];
                          if (officialText != null &&
                              officialText.trim().isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AS9102FieldTextPage(
                                  formName: widget.formName,
                                  fieldNumber: widget.fieldNumber,
                                  fieldLabel: widget.fieldLabel,
                                  officialText: officialText,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AS9102InfoTextPage(),
                              ),
                            );
                          }
                        } else {
                          int targetPage;
                          if (widget.formName == 'Form 1') {
                            targetPage = (widget.fieldNumber <= 13) ? 15 : 16;
                          } else if (widget.formName == 'Form 2') {
                            targetPage = 18;
                          } else {
                            targetPage =
                                (widget.fieldNumber <= 9) ? 20 : 21;
                          }
                          const pdfPath =
                              '/data/user/0/com.example.fai_assistant/app_flutter/as9102.pdf';
                          final file = File(pdfPath);
                          final exists = await file.exists();
                          if (!mounted) return;
                          if (exists) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AS9102ViewerPage(
                                  pdfPath: pdfPath,
                                  initialPage: targetPage,
                                  fieldNumber: widget.fieldNumber,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AS9102InfoPage(
                                  onFileCheckComplete: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('AS9102'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final key =
                            '${widget.formName.replaceAll(' ', '')}_Field${widget.fieldNumber}';
                        final question =
                            aiQuestions[key] ?? 'No AI question defined.';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AIAnswerPage(
                              formName: widget.formName,
                              fieldNumber: widget.fieldNumber,
                              fieldLabel: widget.fieldLabel,
                              question: question,
                            ),
                          ),
                        );
                      },
                      child: const Text('Ask AI'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Previous',
                          onPressed: prevIndex != null
                              ? () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FieldDetailPage(
                                        formName: widget.formName,
                                        fieldNumber: prevIndex,
                                        fieldLabel: FormFieldLabels.getLabel(
                                            widget.formName, prevIndex),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: 'Next',
                          onPressed: nextIndex != null
                              ? () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FieldDetailPage(
                                        formName: widget.formName,
                                        fieldNumber: nextIndex,
                                        fieldLabel: FormFieldLabels.getLabel(
                                            widget.formName, nextIndex),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bottom buttons side-by-side: Go Back | View Notes
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Go Back',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _openNotesList,
                      child: const Text(
                        'View Notes',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}