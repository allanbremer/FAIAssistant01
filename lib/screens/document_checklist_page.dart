import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentChecklistPage extends StatefulWidget {
  const DocumentChecklistPage({Key? key}) : super(key: key);

  @override
  State<DocumentChecklistPage> createState() => _DocumentChecklistPageState();
}

class _DocumentChecklistPageState extends State<DocumentChecklistPage> {
  static const _prefsKey = 'document_checklist_data';
  List<_ChecklistItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _items = list.map((e) => _ChecklistItem.fromMap(e as Map<String, dynamic>)).toList();
    } else {
      // default set
      _items = [
        _ChecklistItem('Purchase Order'),
        _ChecklistItem('Drawings'),
        _ChecklistItem('Parts List'),
        _ChecklistItem('SSP'),
        _ChecklistItem('Packing Lists'),
        _ChecklistItem('Traveler'),
        _ChecklistItem('Part Mark Photos'),
        _ChecklistItem('Processing Photos'),
        _ChecklistItem('Hole Plug Photos'),
        _ChecklistItem('CMM Program'),
        _ChecklistItem('Part Mark Photo'),
      ];
    }
    setState(() {});
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((i) => i.toMap()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  void _addItem(String title) {
    if (title.trim().isEmpty) return;
    setState(() => _items.add(_ChecklistItem(title.trim())));
    _saveItems();
  }

  void _removeItem(int idx) {
    setState(() => _items.removeAt(idx));
    _saveItems();
  }

  void _toggleDone(int idx) {
    setState(() => _items[idx].done = !_items[idx].done);
    _saveItems();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController ctl = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Document Checklist')),
      body: SafeArea(
        child: Column(
          children: [
            // Add‑new form
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctl,
                      decoration: const InputDecoration(hintText: 'New item…'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _addItem(ctl.text);
                      ctl.clear();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Checklist
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  return Dismissible(
                    key: ValueKey(item.title + i.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeItem(i),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_forever, color: Colors.white),
                    ),


child: CheckboxListTile(
  controlAffinity: ListTileControlAffinity.leading,  // ← puts the box on the left
  title: Text(item.title),
  value: item.done,
  onChanged: (_) => _toggleDone(i),
),


                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem {
  String title;
  bool done;
  _ChecklistItem(this.title, {this.done = false});
  Map<String, dynamic> toMap() => {'title': title, 'done': done};
  static _ChecklistItem fromMap(Map<String, dynamic> m) =>
      _ChecklistItem(m['title'] as String, done: m['done'] as bool);
}