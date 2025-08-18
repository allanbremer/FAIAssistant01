import 'package:flutter/material.dart';

import '../help_screen.dart'; // Keep your relative imports
import '../help_text_screen.dart'; // For HelpKeys

// Multi-note imports
import 'package:fai_assistant/note_page.dart';        // NoteStore, NoteCreatePage
import 'package:fai_assistant/note_screen_page.dart'; // NoteListScreen

// for openAS9102 & AI
import 'package:fai_assistant/ai_questions.dart';
import 'package:fai_assistant/ai_answer_page.dart';
import 'package:fai_assistant/screens/document_checklist_page.dart';
import 'package:fai_assistant/as9102_info_page.dart';

class DocumentTextData {
  static const List<String> titles = [
    'Purchase Orders',
    'Bubbled Drawings',
    'Parts lists',
    'CMM Reports',
    'Packing Lists',
    'Specifications',
    'Work Orders/Travelers/Routers',
    'Part Photos',
    'Hole Plugging Photos',
    'Part Marking Photos',
    'Processing Photos',
    'FAI Reviewers Report',
    'Fastener File',
  ];

  static const Map<String, String> descriptions = {
    'Purchase Orders': '— description for Purchase Orders ...',
    'Bubbled Drawings': '— description for Drawings ...',
    'Parts lists': '— description for Parts lists ...',
    'CMM Reports': '— description of CMM Reports ...',
    'Packing Lists': '— description for Packing Lists ...',
    'Specifications': '— description for Specifications ...',
    'Work Orders/Travelers/Routers': '— description for Work Orders/TR ...',
    'Part Photos': '— description for Part Photos ...',
    'Hole Plugging Photos': '— description for Hole Plugging Photos ...',
    'Part Marking Photos': '— description for Part Marking Photos ...',
    'Processing Photos': '— description for Processing Photos ...',
    'FAI Reviewers Report': '— description for FAI Reviewers Report ...',
    'Fastener File': '— description of Fastener File ...',
  };
}

class DocumentListPage extends StatefulWidget {
  const DocumentListPage({Key? key}) : super(key: key);

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  late final List<String> _titles;
  late final List<bool> _hasNote;

  @override
  void initState() {
    super.initState();
    _titles = DocumentTextData.titles;
    _hasNote = List<bool>.filled(_titles.length, false);
    _loadNoteStatus();
  }

  Future<void> _loadNoteStatus() async {
    final store = NoteStore();
    for (int i = 0; i < _titles.length; i++) {
      final fieldKey = 'Documents_Field${i + 1}';
      final notes = await store.listByField(fieldKey);
      _hasNote[i] = notes.isNotEmpty;
    }
    if (mounted) setState(() {});
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
                builder: (_) =>
                    const HelpScreen(helpKey: HelpKeys.documentsPage),
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
        title: const Text('Required Documents'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _titles.length + 1, // extra slot for checklist btn
              itemBuilder: (context, index) {
                // Extra “Document Checklist” slot:
                if (index == _titles.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DocumentChecklistPage(),
                          ),
                        );
                      },
                      child: const Text('Document Checklist'),
                    ),
                  );
                }

                // Regular documents
                final label = _titles[index] + (_hasNote[index] ? ' *' : '');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentDetailPage(index: index),
                        ),
                      );
                      _loadNoteStatus(); // refresh asterisks
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
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentDetailPage extends StatefulWidget {
  final int index;

  const DocumentDetailPage({Key? key, required this.index}) : super(key: key);

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  late final String _title;
  late final String _description;
  bool _hasNote = false;

  @override
  void initState() {
    super.initState();
    _title = DocumentTextData.titles[widget.index];
    _description = DocumentTextData.descriptions[_title] ?? '';
    _loadNoteStatus();
  }

  Future<void> _loadNoteStatus() async {
    final fieldKey = 'Documents_Field${widget.index + 1}';
    final notes = await NoteStore().listByField(fieldKey);
    if (!mounted) return;
    setState(() {
      _hasNote = notes.isNotEmpty;
    });
  }

  Future<void> _openNotes() async {
    final fieldKey = 'Documents_Field${widget.index + 1}';
    final fieldTitle = 'Documents / Field ${widget.index + 1} – $_title';
    final store = NoteStore();
    final existing = await store.listByField(fieldKey);

    if (!mounted) return;

    if (existing.isEmpty) {
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => NoteCreatePage(
            fieldKey: fieldKey,
            fieldTitle: fieldTitle,
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
            fieldKey: fieldKey,
            fieldTitle: fieldTitle,
          ),
        ),
      );
      await _loadNoteStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prevIndex = widget.index > 0 ? widget.index - 1 : null;
    final nextIndex =
        widget.index < DocumentTextData.titles.length - 1
            ? widget.index + 1
            : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
        leadingWidth: 96, // room for two icons
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Help icon
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const HelpScreen(helpKey: HelpKeys.documentsPage),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/fai_assistant_app_icon.png',
                  fit: BoxFit.contain,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            // Back arrow
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Go Back',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        title: const Text('Documents'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Long-pressable document title
            GestureDetector(
              onLongPress: _openNotes,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _title + (_hasNote ? ' *' : ''),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Description section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_description, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            // Action buttons: AS9102, Ask AI, Prev/Next
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    // onPressed: () => openAS9102(context),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AS9102InfoPage(
                            onFileCheckComplete: () {
                              // optional: pop/refresh
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('AS9102'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final key = 'documents_Field${widget.index + 1}';
                      final question = aiQuestions[key];
                      if (question != null && question.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AIAnswerPage(
                              formName: 'Documents',
                              fieldNumber: widget.index + 1,
                              fieldLabel: _title,
                              question: question,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'No AI prompt configured for this document.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Ask AI'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: prevIndex != null
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DocumentDetailPage(index: prevIndex),
                              ),
                            );
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: nextIndex != null
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DocumentDetailPage(index: nextIndex),
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
      ),
    );
  }
}