import 'package:flutter/material.dart';
import 'package:fai_assistant/note_page.dart';        // NoteStore, NoteCreatePage
import 'package:fai_assistant/note_screen_page.dart'; // NoteListScreen
import 'package:fai_assistant/main.dart'; // for openAS9102, if needed
import 'package:fai_assistant/ai_questions.dart';
import 'package:fai_assistant/ai_answer_page.dart';
import 'package:fai_assistant/help_screen.dart';
import 'package:fai_assistant/help_text_screen.dart';

// These lists should match in order and count!
const List<String> certTitles = [
  'Material Certifications',
  'Process Certifications',
  'Ink Certifications',
  'Fastener Certifications',
  'Paint/Primer Certifications',
  'Coating Certifications',
  'Heat Treat Certifications',
  'Hardness/Conductivity Certs.',
  'Surface Treatment Certifications',
  'Test Certifications',
  'Plating Certifications',
  'Hole Plugging Certifications',
  'Epoxy/Bonding Certifications',
];

// These keys must correspond 1-to-1 by index with the titles above!
const List<String> certHelpKeys = [
  HelpKeys.certMaterial,
  HelpKeys.certProcess,
  HelpKeys.certInk,
  HelpKeys.certFastener,
  HelpKeys.certPaintPrimer,
  HelpKeys.certCoating,
  HelpKeys.certHeatTreat,
  HelpKeys.certHardnessConductivity,
  HelpKeys.certSurfaceTreatment,
  HelpKeys.certTest,
  HelpKeys.certPlating,
  HelpKeys.certPlug,
  HelpKeys.certEpoxyBonding,
];

/// Shows a scrollable list of certification buttons, with note indicators
class CertificationListPage extends StatefulWidget {
  const CertificationListPage({Key? key}) : super(key: key);

  @override
  State<CertificationListPage> createState() => _CertificationListPageState();
}

class _CertificationListPageState extends State<CertificationListPage> {
  late final List<String> _titles;
  late final List<bool> _hasNote;

  @override
  void initState() {
    super.initState();
    _titles = certTitles;
    _hasNote = List<bool>.filled(_titles.length, false);
    _loadNoteStatus();
  }

  Future<void> _loadNoteStatus() async {
    final store = NoteStore();
    for (int i = 0; i < _titles.length; i++) {
      final fieldKey = 'Certifications_Field${i + 1}';
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
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HelpScreen(helpKey: 'certHelp'),
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
        title: const Text('Certificates of Conformance'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _titles.length,
              itemBuilder: (context, index) {
                final label = _titles[index] + (_hasNote[index] ? ' *' : '');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CertificationDetailPage(index: index),
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
            minimum: const EdgeInsets.only(
                left: 16, right: 16, top: 8, bottom: 16),
            bottom: true,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
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

/// Displays details for a single certification, with actions and notes
class CertificationDetailPage extends StatefulWidget {
  final int index;
  const CertificationDetailPage({Key? key, required this.index})
      : super(key: key);

  @override
  State<CertificationDetailPage> createState() =>
      _CertificationDetailPageState();
}

class _CertificationDetailPageState extends State<CertificationDetailPage> {
  late final String _title;
  late final String _description;
  bool _hasNote = false;

  @override
  void initState() {
    super.initState();
    _title = certTitles[widget.index];
    _description = HelpText.texts[certHelpKeys[widget.index]] ?? '';
    _loadNoteStatus();
  }

  Future<void> _loadNoteStatus() async {
    final fieldKey = 'Certifications_Field${widget.index + 1}';
    final notes = await NoteStore().listByField(fieldKey);
    if (!mounted) return;
    setState(() {
      _hasNote = notes.isNotEmpty;
    });
  }

  Future<void> _openNotes() async {
    final fieldKey = 'Certifications_Field${widget.index + 1}';
    final fieldTitle = 'Certifications / Field ${widget.index + 1} – $_title';
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
        widget.index < certTitles.length - 1 ? widget.index + 1 : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 96,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Help icon
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpScreen(helpKey: 'certHelp'),
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
            // Go back arrow
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Go Back',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        title: const Text('Certificates of Conformance'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => openAS9102(context),
                    child: const Text('AS9102'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final key = 'certifications_Field${widget.index + 1}';
                      final question = aiQuestions[key];
                      if (question != null && question.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AIAnswerPage(
                              formName: 'Certifications',
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
                                  'No AI prompt configured for this certification.')),
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
                                    CertificationDetailPage(index: prevIndex),
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
                                    CertificationDetailPage(index: nextIndex),
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