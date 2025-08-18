// lib/note_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:fai_assistant/icon_help_screen.dart';
import 'package:fai_assistant/form_field_labels.dart';

/// ====== CONFIG ======
const int kNoteWordLimit = 400; // increased earlier

/// ====== NOTE TYPE DEFINITIONS ======
/// Storage keys for types (stable values you can use to filter/sort later).
class NoteTypes {
  static const field = 'field';
  static const checklist = 'checklist';
  static const document = 'document';
  static const spec = 'spec';
  static const company = 'company';

  /// List for dropdown (key + display).
  static const List<Map<String, String>> all = [
    {'key': field, 'label': 'Field Notes'},
    {'key': checklist, 'label': 'Checklist Notes'},
    {'key': document, 'label': 'Document Notes'},
    {'key': spec, 'label': 'Specification Notes'},
    {'key': company, 'label': 'Company Notes'},
  ];

  static String labelFor(String key) {
    return all.firstWhere(
      (m) => m['key'] == key,
      orElse: () => const {'key': field, 'label': 'Field Notes'},
    )['label']!;
  }
}

/// ====== MODEL ======
class Note {
  final String id;
  final String fieldKey; // e.g., "Form3_Field9" or "Spec:AS9102"
  String title;
  String body;
  DateTime createdAt;
  DateTime updatedAt;
  bool pinned;
  bool archived;

  /// NEW: Type key (see NoteTypes)
  String noteType;

  Note({
    required this.id,
    required this.fieldKey,
    required this.title,
    required this.body,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.pinned = false,
    this.archived = false,
    this.noteType = NoteTypes.field, // default for older notes or unspecified
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'fieldKey': fieldKey,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'pinned': pinned,
        'archived': archived,
        'noteType': noteType, // NEW
      };

  factory Note.fromMap(Map<String, dynamic> m) => Note(
        id: m['id'],
        fieldKey: m['fieldKey'],
        title: m['title'] ?? '',
        body: m['body'] ?? '',
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(m['updatedAt'] ?? '') ?? DateTime.now(),
        pinned: m['pinned'] ?? false,
        archived: m['archived'] ?? false,
        noteType: (m['noteType'] as String?) ?? NoteTypes.field, // default
      );
}

/// Alias so other files can refer to NoteItem and it maps to Note
typedef NoteItem = Note;

/// ====== LOCAL STORE (SharedPreferences) ======
class NoteStore {
  static const _key = 'notes_v1';
  static const _uuid = Uuid();

  Future<List<Note>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => Note.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> _saveAll(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(notes.map((n) => n.toMap()).toList()),
    );
  }

  Future<List<Note>> listByField(String fieldKey,
      {bool includeArchived = false}) async {
    final all = await _loadAll();
    final filtered = all.where(
      (n) => n.fieldKey == fieldKey && (includeArchived || !n.archived),
    );
    final list = filtered.toList();
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1; // pinned first
      return b.updatedAt.compareTo(a.updatedAt); // newest next
    });
    return list;
  }

  /// NEW: list notes by type (e.g., NoteTypes.field / checklist / document / spec / company)
  Future<List<Note>> listByType(String noteType, {bool includeArchived = false}) async {
    final all = await _loadAll();
    final filtered = all.where((n) =>
        n.noteType == noteType &&
        (includeArchived || !n.archived));
    final list = filtered.toList();
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1; // pinned first
      return b.updatedAt.compareTo(a.updatedAt); // newest next
    });
    return list;
  }

  Future<Note?> getById(String id) async {
    final all = await _loadAll();
    try {
      return all.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Note> add({
    required String fieldKey,
    required String title,
    required String body,
    String noteType = NoteTypes.field, // NEW
  }) async {
    final all = await _loadAll();
    final note = Note(
      id: _uuid.v4(),
      fieldKey: fieldKey,
      title: title,
      body: body,
      noteType: noteType,
    );
    all.insert(0, note);
    await _saveAll(all);
    return note;
  }

  Future<void> update(Note updated) async {
    final all = await _loadAll();
    final idx = all.indexWhere((n) => n.id == updated.id);
    if (idx >= 0) {
      updated.updatedAt = DateTime.now();
      all[idx] = updated;
      await _saveAll(all);
    }
  }

  Future<void> remove(String id) async {
    final all = await _loadAll();
    all.removeWhere((n) => n.id == id);
    await _saveAll(all);
  }

  Future<void> setPinned(String id, bool value) async {
    final all = await _loadAll();
    final idx = all.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      all[idx].pinned = value;
      all[idx].updatedAt = DateTime.now();
      await _saveAll(all);
    }
  }
}

/// ====== CREATE NOTE PAGE ======
class NoteCreatePage extends StatefulWidget {
  final String fieldKey;   // e.g. "Form3_Field9" or "Spec:AS9102"
  final String fieldTitle; // e.g. "Form 3 / Field 9 – Serial Number" or "Specification – AS9102"

  /// NEW: allow callers to seed the initial dropdown selection (e.g., NoteTypes.spec)
  final String? initialNoteType;

  const NoteCreatePage({
    super.key,
    required this.fieldKey,
    required this.fieldTitle,
    this.initialNoteType, // NEW
  });

  @override
  State<NoteCreatePage> createState() => _NoteCreatePageState();
}

class _NoteCreatePageState extends State<NoteCreatePage> {
  final _store = NoteStore();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _wordCount = 0;

  /// NEW: currently selected note type (storage key)
  String _noteTypeKey = NoteTypes.field;

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(_calcWords);

    // Prefer caller-provided type; fallback to field, and auto-spec if fieldKey starts with "Spec:"
    _noteTypeKey = widget.initialNoteType ??
        (widget.fieldKey.startsWith('Spec:') ? NoteTypes.spec : NoteTypes.field);
  }

  void _calcWords() {
    final words = _bodyCtrl.text.trim().split(RegExp(r'\s+'));
    setState(() {
      _wordCount = _bodyCtrl.text.trim().isEmpty ? 0 : words.length;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _store.add(
      fieldKey: widget.fieldKey,
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      noteType: _noteTypeKey, // NEW
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String _shortHeader() {
    // Friendly header for spec keys like "Spec:AS9102"
    if (widget.fieldKey.startsWith('Spec:')) {
      final specNum = widget.fieldKey.split(':').last;
      // Prefer text after an en dash if present in fieldTitle
      String label = widget.fieldTitle;
      final dashIdx = label.indexOf('–');
      if (dashIdx >= 0 && dashIdx + 1 < label.length) {
        label = label.substring(dashIdx + 1).trim();
      }
      return 'Spec: $specNum${label.isNotEmpty ? ' – $label' : ''}';
    }

    // Original behavior for FormX_FieldY
    final re = RegExp(r'Form(\d+)_Field(\d+)', caseSensitive: false);
    final m = re.firstMatch(widget.fieldKey);
    final formNum = m != null ? m.group(1) ?? '?' : '?';
    final fieldNum = m != null ? m.group(2) ?? '?' : '?';

    // Prefer text after an en dash if present
    String label = widget.fieldTitle;
    final dashIdx = label.indexOf('–');
    if (dashIdx >= 0 && dashIdx + 1 < label.length) {
      label = label.substring(dashIdx + 1).trim();
    }

    // Remove any leading "Field <num>" (+ optional separator)
    final fieldPrefix =
        RegExp(r'^Field\s*\d+\s*(?:[-:–]\s*)?', caseSensitive: false);
    label = label.replaceFirst(fieldPrefix, '').trim();

    return '$formNum/$fieldNum: $label';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = _shortHeader();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/fai_assistant_app_icon.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          tooltip: 'Help',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const IconHelpScreen(
                  helpText:
                      'Create a note.\n\n'
                      '• Choose a Note Type\n'
                      '• Give the note a clear Title (required)\n'
                      '• Type the note body (up to $kNoteWordLimit words)\n'
                      '• Use Save to store it, or Cancel/Go Back to discard.\n',
                ),
              ),
            );
          },
        ),
        title: Text(header),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                /// Note Type dropdown (standardized, matches other pages)
                DropdownButtonFormField<String>(
                  value: _noteTypeKey,
                  decoration: const InputDecoration(
                    labelText: 'Note Type',
                    border: OutlineInputBorder(),
                  ),
                  items: NoteTypes.all
                      .map((m) => DropdownMenuItem<String>(
                            value: m['key'],
                            child: Text(m['label']!),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _noteTypeKey = v;
                    });
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _bodyCtrl,
                  minLines: 6,
                  maxLines: 12,
                  decoration: InputDecoration(
                    labelText: 'Note (max $kNoteWordLimit words)',
                    border: const OutlineInputBorder(),
                    helperText: '$_wordCount / $kNoteWordLimit words',
                  ),
                  validator: (v) {
                    final text = (v ?? '').trim();
                    if (text.isEmpty) return 'Note text is required';
                    final words = text.split(RegExp(r'\s+')).length;
                    if (words > kNoteWordLimit) {
                      return 'Please keep it to $kNoteWordLimit words or less';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: bottomInset > 0 ? bottomInset + 8 : 16,
        ),
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ====== VIEW NOTE PAGE ======
class NoteViewPage extends StatelessWidget {
  final String noteId;

  const NoteViewPage({super.key, required this.noteId});

  // Parse "FormN_FieldM" -> (N, M)
  (int, int) _parseFormField(String fieldKey) {
    final m = RegExp(r'Form(\d+)_Field(\d+)', caseSensitive: false).firstMatch(fieldKey);
    final formNum = int.tryParse(m?.group(1) ?? '') ?? 0;
    final fieldNum = int.tryParse(m?.group(2) ?? '') ?? 0;
    return (formNum, fieldNum);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Note?>(
      future: NoteStore().getById(noteId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final note = snap.data;
        if (note == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightBlue[100],
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Image.asset(
                  'assets/images/fai_assistant_app_icon.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
                tooltip: 'Help',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IconHelpScreen(
                        helpText:
                            'This note could not be found. It may have been removed.',
                      ),
                    ),
                  );
                },
              ),
              title: const Text('Note'),
            ),
            body: const Center(child: Text('Note not found')),
          );
        }

        // Treat as SPEC if the key starts with "Spec:" OR noteType == spec (handles legacy items)
        final bool isSpec = note.fieldKey.startsWith('Spec:') || note.noteType == NoteTypes.spec;

        // Build a header:
        // SPEC: single-line "Spec: <num>" (no second line)
        // FORM: "Form N Field M" + "<Field Label>"
        Widget headerTitle;
        if (isSpec) {
          String specNum = '';
          if (note.fieldKey.startsWith('Spec:')) {
            specNum = note.fieldKey.split(':').last.trim();
          }
          final titleText = (specNum.isNotEmpty) ? 'Spec: $specNum' : 'Specification Note';
          headerTitle = Text(
            titleText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          );
        } else {
          final (formNum, fieldNum) = _parseFormField(note.fieldKey);
          final formName = formNum > 0 ? 'Form $formNum' : 'Form ?';
          final topLine = '$formName Field $fieldNum';
          final subLine = FormFieldLabels.getLabel(formName, fieldNum) ?? '';
          headerTitle = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topLine,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (subLine.isNotEmpty)
                Text(
                  subLine,
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.lightBlue[100],
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Image.asset(
                'assets/images/fai_assistant_app_icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              tooltip: 'Help',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IconHelpScreen(
                      helpText:
                          'Viewing a note.\n\n'
                          '• The top shows the context (Form/Field or Spec).\n'
                          '• The note title is centered above the text.\n'
                          '• Use the button below to go back.',
                    ),
                  ),
                );
              },
            ),
            title: headerTitle,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NEW: show note type as a Chip
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Chip(
                          label: Text(NoteTypes.labelFor(note.noteType)),
                        ),
                      ),
                    ),
                    // Centered note title
                    Text(
                      note.title.isEmpty ? '(No title)' : note.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Note body — FULL TEXT
                    Text(
                      note.body,
                      style: const TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ),
          ),
        );
      },
    );
  }
}