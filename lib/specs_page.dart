// specs_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:fai_assistant/help_screen.dart';
import 'package:fai_assistant/help_text_screen.dart';

// NEW: use your app's standard Notes pages/types
import 'package:fai_assistant/note_page.dart'; // NoteCreatePage, NoteTypes

class SpecEntry {
  String number;
  String revision;
  String description;

  SpecEntry({
    required this.number,
    required this.revision,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'revision': revision,
        'description': description,
      };

  factory SpecEntry.fromJson(Map<String, dynamic> json) => SpecEntry(
        number: json['number'] as String,
        revision: json['revision'] as String,
        description: json['description'] as String,
      );
}

class SpecsPage extends StatefulWidget {
  const SpecsPage({Key? key}) : super(key: key);

  @override
  State<SpecsPage> createState() => _SpecsPageState();
}

class _SpecsPageState extends State<SpecsPage> {
  static const _prefsKey = 'saved_specs';
  List<SpecEntry> specs = [];

  @override
  void initState() {
    super.initState();
    _loadSpecs();
  }

  Future<void> _loadSpecs() async {
    final prefs = await sp.SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);

    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      setState(() {
        specs = decoded
            .map((e) => SpecEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } else {
      _resetToDefaults();
    }
  }

  Future<void> _saveSpecs() async {
    final prefs = await sp.SharedPreferences.getInstance();
    final encoded = specs.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, json.encode(encoded));
  }

  Future<void> _resetToDefaults() async {
    setState(() {
      specs = [
        SpecEntry(
          number: 'AS9102',
          revision: 'C',
          description: 'Aerospace First Article Inspection Requirements',
        ),
        SpecEntry(
          number: 'MIL-STD-1234',
          revision: 'A',
          description: 'Military Standard Example Description',
        ),
        SpecEntry(
          number: 'ISO 9001',
          revision: '2015',
          description: 'Quality Management Systems Requirements',
        ),
      ];
    });
    await _saveSpecs();
  }

  void _confirmResetDefaults() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will delete all specifications and reload the 3 default sample specs. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _addOrEditSpec({SpecEntry? existing, int? index}) {
    final numberController =
        TextEditingController(text: existing?.number ?? '');
    final revisionController =
        TextEditingController(text: existing?.revision ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text(existing == null ? 'Add Specification' : 'Edit Specification'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Spec Number'),
              ),
              TextField(
                controller: revisionController,
                decoration: const InputDecoration(labelText: 'Revision'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (numberController.text.trim().isEmpty ||
                  revisionController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Missing Fields'),
                    content: const Text(
                      'All fields must be filled out.\n\nPlease enter Spec Number, Revision, and Description.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }

              final newSpec = SpecEntry(
                number: numberController.text.trim(),
                revision: revisionController.text.trim(),
                description: descriptionController.text.trim(),
              );
              setState(() {
                if (existing != null && index != null) {
                  specs[index] = newSpec;
                } else {
                  specs.add(newSpec);
                }
              });
              _saveSpecs();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteSpec(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Specification'),
        content:
            const Text('Are you sure you want to delete this specification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                specs.removeAt(index);
              });
              _saveSpecs();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // === NEW: open the standard full-screen NoteCreatePage, pre-selecting Specification Notes ===
  Future<void> _createSpecNote(String specNumber) async {
    final fieldKey = 'Spec:$specNumber';
    final fieldTitle = 'Specification – $specNumber';

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteCreatePage(
          fieldKey: fieldKey,
          fieldTitle: fieldTitle,
          // requires the tiny change in note_page.dart below
          initialNoteType: NoteTypes.spec,
        ),
      ),
    );
    // No further action needed; NoteStore handles persistence globally.
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
                builder: (_) => const HelpScreen(helpKey: HelpKeys.specsPage),
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
        title: const Text('Specifications'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FixedColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FixedColumnWidth(1),
                4: FlexColumnWidth(4),
              },
              children: const [
                TableRow(children: [
                  Text('Spec #',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ColoredBox(color: Color(0x42000000), child: SizedBox(height: 20)),
                  Text('Rev.', style: TextStyle(fontWeight: FontWeight.bold)),
                  ColoredBox(color: Color(0x42000000), child: SizedBox(height: 20)),
                  Text('Description',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
          ),
          Expanded(
            child: specs.isEmpty
                ? const Center(child: Text('No specifications added yet.'))
                : ListView.builder(
                    itemCount: specs.length,
                    itemBuilder: (_, index) {
                      final spec = specs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FixedColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FixedColumnWidth(1),
                            4: FlexColumnWidth(4),
                          },
                          children: [
                            TableRow(children: [
                              // Spec # — link style; LONG-PRESS opens full-screen NoteCreatePage
                              GestureDetector(
                                onLongPress: () => _createSpecNote(spec.number),
                                child: Text(
                                  spec.number,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(color: Colors.black26, height: 20),
                              Text(spec.revision),
                              Container(color: Colors.black26, height: 20),
                              Row(
                                children: [
                                  Expanded(child: Text(spec.description)),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _addOrEditSpec(
                                      existing: spec,
                                      index: index,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteSpec(index),
                                  ),
                                ],
                              ),
                            ]),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 64, left: 12, right: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                  ElevatedButton(
                    onPressed: _confirmResetDefaults,
                    child: const Text('Reset to Defaults'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditSpec(),
        tooltip: 'Add Spec',
        child: const Icon(Icons.add),
      ),
    );
  }
}