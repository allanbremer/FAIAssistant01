import 'package:flutter/material.dart';
import 'package:fai_assistant/icon_help_screen.dart';
import 'note_page.dart'; // for Note, NoteStore, NoteTypes, NoteViewPage
import 'package:fai_assistant/form_field_labels.dart';

/// Top-level "View Notes" screen:
/// - Pick a Type
/// - Back / View Notes actions
class ViewNotesPage extends StatefulWidget {
  const ViewNotesPage({super.key});

  @override
  State<ViewNotesPage> createState() => _ViewNotesPageState();
}

class _ViewNotesPageState extends State<ViewNotesPage> {
  final _store = NoteStore();

  /// Dropdown options (labels shown to user)
  static const String kAllField = 'All Field Notes';
  static const String kForm1Field = 'Form 1 Field Notes';
  static const String kForm2Field = 'Form 2 Field Notes';
  static const String kForm3Field = 'Form 3 Field Notes';
  static const String kChecklist = 'Checklist Notes';
  static const String kDocument = 'Document Notes';
  static const String kSpec = 'Specification Notes';
  static const String kCompany = 'Company Notes';
  static const String kCert = 'Certification Notes'; // NEW

  final List<String> _options = const [
    kAllField,
    kForm1Field,
    kForm2Field,
    kForm3Field,
    kChecklist,
    kDocument,
    kSpec,
    kCompany,
    kCert, // NEW
  ];

  String _selection = kAllField; // default selection

  Future<void> _onViewNotes() async {
    final loader = _notesLoaderForSelection(_selection);
    final notes = await loader();

    if (!mounted) return;

    if (notes.isEmpty) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No Notes'),
          content: Text('There are no notes saved under "$_selection".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotesListPage(
          titleLabel: _selection,
          loader: loader,
        ),
      ),
    );
  }

  /// Returns a function that when called loads the notes for the current selection.
  /// This allows us to keep NoteStore unchanged and filter here as needed.
  Future<List<Note>> Function() _notesLoaderForSelection(String selection) {
    switch (selection) {
      case kAllField:
        return () => _store.listByType(NoteTypes.field, includeArchived: false);

      case kForm1Field:
        return () async {
          final all = await _store.listByType(NoteTypes.field);
          return all.where((n) => _isFormMatch(n.fieldKey, 1)).toList();
        };

      case kForm2Field:
        return () async {
          final all = await _store.listByType(NoteTypes.field);
          return all.where((n) => _isFormMatch(n.fieldKey, 2)).toList();
        };

      case kForm3Field:
        return () async {
          final all = await _store.listByType(NoteTypes.field);
          return all.where((n) => _isFormMatch(n.fieldKey, 3)).toList();
        };

      case kChecklist:
        return () => _store.listByType(NoteTypes.checklist, includeArchived: false);

      case kDocument:
        return () => _store.listByType(NoteTypes.document, includeArchived: false);

      case kSpec:
        return () => _store.listByType(NoteTypes.spec, includeArchived: false);

      case kCompany:
        return () => _store.listByType(NoteTypes.company, includeArchived: false);

      case kCert: // Certification Notes (uses a literal key to avoid compile errors if NoteTypes lacks it)
        return () => _store.listByType('certification', includeArchived: false);

      default:
        return () async => <Note>[];
    }
  }

  /// Helper that checks if a fieldKey like "Form3_Field9" matches a form number.
  bool _isFormMatch(String fieldKey, int formNumber) {
    final re = RegExp(r'^Form(\d+)_Field', caseSensitive: false);
    final m = re.firstMatch(fieldKey);
    final num = int.tryParse(m?.group(1) ?? '');
    return num == formNumber;
  }

  @override
  Widget build(BuildContext context) {
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
                      'View Notes by Type.\n\n'
                      '• Choose a Type from the dropdown\n'
                      '• Tap "View Notes" to see notes in that Type\n'
                      '• Tap a note to open and read it',
                ),
              ),
            );
          },
        ),
        title: const Text('View Notes'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selection,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: _options
                    .map((label) => DropdownMenuItem<String>(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selection = v);
                },
              ),
              const SizedBox(height: 12),
              // Reserved space for future: counts/search/etc.
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _onViewNotes,
                child: const Text('View Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List page that shows the notes returned by [loader].
/// Tapping an item opens NoteViewPage (from note_page.dart).
class NotesListPage extends StatelessWidget {
  final String titleLabel;
  final Future<List<Note>> Function() loader;

  const NotesListPage({
    super.key,
    required this.titleLabel,
    required this.loader,
  });

  /// Detect Specification notes (works for both new and legacy items).
  bool _isSpec(Note n) =>
      n.fieldKey.startsWith('Spec:') || n.noteType == NoteTypes.spec;

  String _headerForNote(Note n) {
    // Handle non-form keys gracefully (e.g., Spec notes)
    final m = RegExp(r'Form(\d+)_Field(\d+)', caseSensitive: false)
        .firstMatch(n.fieldKey);
    if (m == null) return '';
    final formNum = int.tryParse(m.group(1) ?? '') ?? 0;
    final fieldNum = int.tryParse(m.group(2) ?? '') ?? 0;
    final formName = formNum > 0 ? 'Form $formNum' : 'Form ?';
    final label = FormFieldLabels.getLabel(formName, fieldNum) ?? '';
    if (label.isEmpty) return '$formName Field $fieldNum';
    return '$formName Field $fieldNum — $label';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: loader(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightBlue[100],
              title: Text('Notes — $titleLabel'),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final notes = snap.data!;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.lightBlue[100],
            centerTitle: true,
            title: Text('Notes — $titleLabel'),
          ),
          body: notes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'No notes found for "$titleLabel".',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final n = notes[i];
                    final bool isSpec = _isSpec(n);
                    final header = isSpec ? '' : _headerForNote(n);

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      title: Text(
                        n.title.isEmpty
                            ? (isSpec ? 'Specification Note' : '(No title)')
                            : n.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      // SPEC: show the note text preview (no Form/Field line)
                      // NON-SPEC: show the Form/Field header as before
                      subtitle: isSpec
                          ? Text(
                              n.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              header,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (n.pinned) const Icon(Icons.push_pin, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            _formatShort(n.updatedAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteViewPage(noteId: n.id),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  static String _formatShort(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }
}