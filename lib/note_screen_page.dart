import 'package:flutter/material.dart';
import 'package:fai_assistant/note_page.dart'; // NoteStore, NoteItem, NoteViewPage
import 'package:fai_assistant/icon_help_screen.dart';
import 'package:fai_assistant/form_field_labels.dart';

class NoteListScreen extends StatefulWidget {
  final String fieldKey;   // e.g., "Form1_Field3"
  final String fieldTitle; // e.g., "Form 1 / Field 3 – Serial Number"

  const NoteListScreen({
    Key? key,
    required this.fieldKey,
    required this.fieldTitle,
  }) : super(key: key);

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final _store = NoteStore();
  late Future<List<NoteItem>> _notesFuture;

  // ===== Parse helpers =====
  int get _formNum {
    final m = RegExp(r'Form(\d+)_Field(\d+)', caseSensitive: false).firstMatch(widget.fieldKey);
    return int.tryParse(m?.group(1) ?? '') ?? 0;
  }

  int get _fieldNum {
    final m = RegExp(r'Form(\d+)_Field(\d+)', caseSensitive: false).firstMatch(widget.fieldKey);
    return int.tryParse(m?.group(2) ?? '') ?? 0;
  }

  int get _maxField {
    switch (_formNum) {
      case 1:
        return 26;
      case 2:
        return 13;
      case 3:
        return 12;
      default:
        return 26; // fallback
    }
  }

  String get _defaultNoteTitle => 'Form $_formNum Field $_fieldNum Default Note';

  // ===== Title: "Form N: <Field Label>" =====
  String _deriveFieldLabelFromTitle() {
    // Extract label from "Form 1 / Field 3 – Part Name"
    String label = widget.fieldTitle;
    final dashIdx = label.indexOf('–'); // en dash
    if (dashIdx >= 0 && dashIdx + 1 < label.length) {
      label = label.substring(dashIdx + 1).trim();
    }
    // Remove any leading "Field <num>" prefix if present
    final fieldPrefix = RegExp(r'^Field\s*\d+\s*(?:[-:–]\s*)?', caseSensitive: false);
    label = label.replaceFirst(fieldPrefix, '').trim();

    // Fallback to official labels if label ends up empty
    if (label.isEmpty) {
      final formName = 'Form $_formNum';
      label = FormFieldLabels.getLabel(formName, _fieldNum) ?? '';
    }
    return label;
  }

  String _appBarTitle() => 'Form $_formNum: ${_deriveFieldLabelFromTitle()}';

  @override
  void initState() {
    super.initState();
    _notesFuture = _loadNotesEnsuringDefault();
  }

  Future<void> _ensureDefaultNote() async {
    final existing = await _store.listByField(widget.fieldKey, includeArchived: false);
    final hasDefault = existing.any((n) => n.title.trim().toLowerCase() == _defaultNoteTitle.toLowerCase());
    if (!hasDefault) {
      await _store.add(
        fieldKey: widget.fieldKey,
        title: _defaultNoteTitle,
        body:
            'Add your first note here. Add as many notes in any Form/Field position as you like. '
            'You may also use the Previous or Next arrow to go from one fields notes to another.\n\n'
            'Having additional instructions by way of company or aerospace requirements in these note sections '
            'can be a very valuable asset.',
      );
    }
  }

  bool _isDefault(NoteItem n) => n.title.trim().toLowerCase() == _defaultNoteTitle.toLowerCase();

  Future<List<NoteItem>> _loadNotesEnsuringDefault() async {
    await _ensureDefaultNote();
    final notes = await _store.listByField(widget.fieldKey, includeArchived: false);
    notes.sort((a, b) {
      final ad = _isDefault(a), bd = _isDefault(b);
      if (ad != bd) return ad ? -1 : 1; // default first
      final at = a.title.trim().toLowerCase();
      final bt = b.title.trim().toLowerCase();
      return at.compareTo(bt); // then alphabetical
    });
    return notes;
  }

  void _refresh() {
    setState(() {
      _notesFuture = _loadNotesEnsuringDefault();
    });
  }

  Future<void> _confirmDelete(NoteItem note) async {
    if (_isDefault(note)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default Note Must Exist.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete note?'),
            content: Text('Delete “${note.title.isEmpty ? '(No title)' : note.title}”? This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    await _store.remove(note.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted.')));
    _refresh();
  }

  Future<void> _editNote(NoteItem note) async {
    if (_isDefault(note)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default Note Must Exist.')),
      );
      return;
    }

    final titleCtrl = TextEditingController(text: note.title);
    final bodyCtrl = TextEditingController(text: note.body);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Note'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: bodyCtrl,
                        minLines: 6,
                        maxLines: 12,
                        decoration: const InputDecoration(
                          labelText: 'Note',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) return 'Note text is required';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final updated = Note(
                      id: note.id,
                      fieldKey: note.fieldKey,
                      title: titleCtrl.text.trim(),
                      body: bodyCtrl.text.trim(),
                      createdAt: note.createdAt,
                      updatedAt: DateTime.now(),
                      pinned: note.pinned,
                      archived: note.archived,
                    );
                    await _store.update(updated);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    _refresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note updated.')));
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _goPrevField() {
    final prev = _fieldNum - 1;
    if (prev < 1) return;
    final newKey = 'Form${_formNum}_Field$prev';
    final formName = 'Form $_formNum';
    final label = FormFieldLabels.getLabel(formName, prev) ?? 'Field $prev';
    final newTitle = '$formName / Field $prev – $label';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NoteListScreen(
          fieldKey: newKey,
          fieldTitle: newTitle,
        ),
      ),
    );
  }

  void _goNextField() {
    final next = _fieldNum + 1;
    if (next > _maxField) return; // stop at max
    final newKey = 'Form${_formNum}_Field$next';
    final formName = 'Form $_formNum';
    final label = FormFieldLabels.getLabel(formName, next) ?? 'Field $next';
    final newTitle = '$formName / Field $next – $label';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NoteListScreen(
          fieldKey: newKey,
          fieldTitle: newTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _appBarTitle();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canGoPrev = _fieldNum > 1;
    final canGoNext = _fieldNum < _maxField;

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
                      'This screen lists all notes for the selected Form/Field.\n\n'
                      '• The first item is a non-editable Default Note that must exist.\n'
                      '• Tap any other title to view it.\n'
                      '• Use ✎ to edit or 🗑 to delete a note.\n'
                      '• Use New Note to add a note.\n'
                      '• Use the arrows to jump to the previous/next field.',
                ),
              ),
            );
          },
        ),
        title: Text(
          title, // e.g., "Form 1: Part Number"
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<NoteItem>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data ?? const <NoteItem>[];
          if (notes.isEmpty) {
            return const Center(child: Text('No notes for this field yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 120), // room for bottom bar
            itemCount: notes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = notes[index];
              final isDefault = _isDefault(note);

              final row = ListTile(
                title: Text(
                  note.title.isEmpty ? '(No title)' : note.title,
                  style: TextStyle(
                    color: Colors.blue.withOpacity(isDefault ? 0.7 : 1.0),
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteViewPage(noteId: note.id),
                    ),
                  );
                  _refresh();
                },
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: isDefault ? 'Default Note Must Exist.' : 'Edit',
                      icon: Icon(Icons.edit, color: isDefault ? Colors.grey : null),
                      onPressed: isDefault
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Default Note Must Exist.')),
                              );
                            }
                          : () => _editNote(note),
                    ),
                    IconButton(
                      tooltip: isDefault ? 'Default Note Must Exist.' : 'Delete',
                      icon: Icon(Icons.delete, color: isDefault ? Colors.grey : null),
                      onPressed: isDefault
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Default Note Must Exist.')),
                              );
                            }
                          : () => _confirmDelete(note),
                    ),
                  ],
                ),
              );

              if (isDefault) {
                // No swipe-to-delete for default
                return row;
              }

              return Dismissible(
                key: ValueKey(note.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  await _confirmDelete(note);
                  // Prevent framework auto-removal; we refresh manually:
                  return false;
                },
                child: row,
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: bottomInset > 0 ? bottomInset + 8 : 16,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Give New Note a bit more width via flex
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Go Back'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6, // slightly larger to fit full text
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () async {
                      final saved = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteCreatePage(
                            fieldKey: widget.fieldKey,
                            fieldTitle: widget.fieldTitle,
                          ),
                        ),
                      );
                      if (saved == true) _refresh();
                    },
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('New Note'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: _fieldNum > 1 ? 'Previous Field' : 'No previous field',
                  onPressed: _fieldNum > 1 ? _goPrevField : null,
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  tooltip: _fieldNum < _maxField ? 'Next Field' : 'No next field',
                  onPressed: _fieldNum < _maxField ? _goNextField : null,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}