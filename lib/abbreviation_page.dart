import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fai_assistant/help_screen.dart';
import 'package:fai_assistant/help_text_screen.dart';

class AbbreviationPage extends StatefulWidget {
  const AbbreviationPage({Key? key}) : super(key: key);

  @override
  State<AbbreviationPage> createState() => _AbbreviationPageState();
}

class _AbbreviationPageState extends State<AbbreviationPage> {
  List<Map<String, String>> _abbreviations = [];
  final TextEditingController _abbreviationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  static const String _prefsKey = 'abbreviations_list';

  final List<Map<String, String>> _defaultAbbreviations = [
    // ... your full abbreviation list here ...
    {'abbreviation': 'ADCN', 'description': 'Advanced Drawing Change Notice'},
    {'abbreviation': 'ADP', 'description': 'Acceptance Data Package'},
    {'abbreviation': 'ANSI', 'description': 'American National Standards Institute'},
    {'abbreviation': 'APL', 'description': 'Approved Processor List'},
    {'abbreviation': 'APTS', 'description': 'Advanced Pilot Training Systems'},
    {'abbreviation': 'AQS', 'description': 'Aerospace Quality Systems'},
    {'abbreviation': 'ARP', 'description': 'Aerospace Recommended Practice'},
    {'abbreviation': 'ASSIST', 'description': 'Acquisition Streamlining and Standaardization Information System'},
    {'abbreviation': 'ASSY', 'description': 'Assembly'},
    {'abbreviation': 'ATP', 'description': 'Acceptance Test Procedure'},
    {'abbreviation': 'BASN', 'description': 'Boeing Aggregated Standards Network'},
    {'abbreviation': 'BCA', 'description': 'Boeing Commercial Airplanes'},
    {'abbreviation': 'BDI', 'description': 'Boeing Distribution Inc.'},
    {'abbreviation': 'BDS', 'description': 'Boeing Defense, Space & Security'},
    {'abbreviation': 'BDSI', 'description': 'Boeing Distribution Services Inc.'},
    {'abbreviation': 'BH', 'description': 'Boeing Helicopter'},
    {'abbreviation': 'BOM', 'description': 'Bill of Materials'},
    {'abbreviation': 'BPD', 'description': 'Blank and Pierce Die'},
    {'abbreviation': 'BPS', 'description': 'Boeing Part Specifications'},
    {'abbreviation': 'CA', 'description': 'Corrective Action'},
    {'abbreviation': 'CAD', 'description': 'Computer Aided Design'},
    {'abbreviation': 'CAGE', 'description': '(CAGE Code) Commercial and Government Entity'},
    {'abbreviation': 'CAR', 'description': 'Corrective Action Request'},
    {'abbreviation': 'CIS', 'description': 'Conventional Inspection Sheet'},
    {'abbreviation': 'CMM', 'description': 'Coordinate Measuring Machine'},
    {'abbreviation': 'CMS', 'description': 'Coordiante Measuring System'},
    {'abbreviation': 'CMS', 'description': 'Coordinate Measurement System'},
    {'abbreviation': 'COC', 'description': 'Certificate of Conformity'},
    {'abbreviation': 'COMP', 'description': 'Composites'},
    {'abbreviation': 'COTS', 'description': 'Commercial Over the Shelf'},
    {'abbreviation': 'CP', 'description': 'Chemical Processing or Chemical Processor'},
    {'abbreviation': 'CPTS', 'description': 'Critical Part Tracking System'},
    {'abbreviation': 'CR', 'description': 'Conditionally Required'},
    {'abbreviation': 'CSDT', 'description': 'Customer and Supplier Data Transmittal'},
    {'abbreviation': 'CSYS', 'description': 'Coordinate System'},
    {'abbreviation': 'CTL', 'description': 'Certified Tool List'},
    {'abbreviation': 'DADT', 'description': 'Durability and Damage Tolerance Control Plan'},
    {'abbreviation': 'DAL', 'description': 'Data Accenssion List'},
    {'abbreviation': 'DC', 'description': 'Durability Critical'},
    {'abbreviation': 'DCMA', 'description': 'Defence Contract Management Agency/Government Source Inspection'},
    {'abbreviation': 'DPD', 'description': 'Digital Product Definition'},
    {'abbreviation': 'E-SIR', 'description': 'E - Screening Information Request'},
    {'abbreviation': 'EAR', 'description': 'Export Administration Restrictions'},
    {'abbreviation': 'ECO', 'description': 'Engineering Change Order'},
    {'abbreviation': 'ECS', 'description': 'Environmental Control System'},
    {'abbreviation': 'EHS', 'description': 'Environment Health and Safety'},
    {'abbreviation': 'EMD', 'description': 'Engineering Manufacturing and Developing'},
    {'abbreviation': 'EOP', 'description': 'End of Part'},
    {'abbreviation': 'EPD', 'description': 'Engineering Product Definition'},
    {'abbreviation': 'EPDM', 'description': 'Enterprise Product Data Manager'},
    {'abbreviation': 'ERP', 'description': 'Enterprise Resource Planning'},
    {'abbreviation': 'ESD', 'description': 'Electro Static Discharge'},
    {'abbreviation': 'ESDS', 'description': 'Electro Static Discharge Sensitive'},
    {'abbreviation': 'FAA', 'description': 'Federal Aviation Administration'},
    {'abbreviation': 'FAIR', 'description': 'First Article Inspection Report'},
    {'abbreviation': 'FC', 'description': 'Fracture Critical'},
    {'abbreviation': 'FCF', 'description': 'Feature Control Frame'},
    {'abbreviation': 'FCT', 'description': 'Fracture Critical Traceable'},
    {'abbreviation': 'FOD', 'description': 'Foreign Object Debris'},
    {'abbreviation': 'FSDA', 'description': 'Full Size Determinate Assembly'},
    {'abbreviation': 'FTG', 'description': 'Fitting'},
    {'abbreviation': 'GAMPS', 'description': 'Gulfstream Material Process Specifications'},
    {'abbreviation': 'GOM', 'description': 'Gesellschaft für Optische Messtechnik: GERMAN: Society for Optical Metrology'},
    {'abbreviation': 'IAQG', 'description': 'International Aaerospace Quality Group'},
    {'abbreviation': 'INSP', 'description': 'Inseparable'},
    {'abbreviation': 'ITAR', 'description': 'International Traffic and Arms Restrictions'},
    {'abbreviation': 'L', 'description': 'Length'},
    {'abbreviation': 'LSE', 'description': 'Lead Strength Engineer'},
    {'abbreviation': 'LT', 'description': 'Width'},
    {'abbreviation': 'MCD', 'description': 'Master Control Drawing'},
    {'abbreviation': 'ME', 'description': 'Mechanical Engineer'},
    {'abbreviation': 'MRB', 'description': 'Material Review Board'},
    {'abbreviation': 'MRD', 'description': 'Material Review Document'},
    {'abbreviation': 'MRO', 'description': 'Maintenance, Repair & Overhaul'},
    {'abbreviation': 'MRZP', 'description': 'Machine Rotory Zero Point'},
    {'abbreviation': 'MSDS', 'description': 'Material Safety Data Sheet'},
    {'abbreviation': 'MSE', 'description': 'Manufacturing Self Examination'},
    {'abbreviation': 'MTO', 'description': 'Make to Order / Made to Order'},
    {'abbreviation': 'NADCAP', 'description': 'National Aerospace Defense Contractors Accreditation'},
    {'abbreviation': 'NANDTB', 'description': 'National Aerospace NDT Board'},
    {'abbreviation': 'NAS', 'description': 'National Aerospace Standard'},
    {'abbreviation': 'NCFR', 'description': 'No Cause for Rejection'},
    {'abbreviation': 'NDI', 'description': 'Non -Destructive Inspection'},
    {'abbreviation': 'NDT', 'description': 'Nondestructive Testing'},
    {'abbreviation': 'NFC', 'description': 'Non Fracture Critical'},
    {'abbreviation': 'NI', 'description': 'NetInspect'},
    {'abbreviation': 'NIST', 'description': 'National Institute of Standards'},
    {'abbreviation': 'PCMS', 'description': 'Portable/Fixed Coordinate Measurement System'},
    {'abbreviation': 'PDD', 'description': 'Product Data Definition'},
    {'abbreviation': 'PDP', 'description': 'Power Distribution Panel'},
    {'abbreviation': 'PL', 'description': 'Parts List'},
    {'abbreviation': 'PLM', 'description': 'Product Lifecycle Management'},
    {'abbreviation': 'PMA', 'description': 'Parts Manufacturer Approval'},
    {'abbreviation': 'PMF', 'description': 'Pre Mixed Frozen'},
    {'abbreviation': 'PMI', 'description': 'Product and Manufacturing Information'},
    {'abbreviation': 'POCP', 'description': 'Point of Contact Platform'},
    {'abbreviation': 'PSD', 'description': 'Process Specification Departure'},
    {'abbreviation': 'PTI', 'description': 'Periodic Tool Inspection'},
    {'abbreviation': 'PVS', 'description': 'Prototype Verification System'},
    {'abbreviation': 'QMS', 'description': 'Quality Management System'},
    {'abbreviation': 'QPL', 'description': 'Qualified Processor List'},
    {'abbreviation': 'RAA', 'description': 'Responsibility Authority and Accountability'},
    {'abbreviation': 'RCCA', 'description': 'Root Cause Corrective Action'},
    {'abbreviation': 'RDD', 'description': 'Reduced Dimension Drawing'},
    {'abbreviation': 'RDS', 'description': 'Reduced Dimensional Sketch'},
    {'abbreviation': 'RFD', 'description': 'Request for Deployment'},
    {'abbreviation': 'RMS', 'description': 'Rotary Mission Systems'},
    {'abbreviation': 'RNC', 'description': 'Rejection Notice Change'},
    {'abbreviation': 'SAE', 'description': 'Society of Automotive Engineers'},
    {'abbreviation': 'SAP', 'description': 'Systems, Applications, and Products'},
    {'abbreviation': 'SCAR', 'description': 'Supplier Corrective Action Request'},
    {'abbreviation': 'SCD', 'description': 'Specification Control Document/Source Control Document'},
    {'abbreviation': 'SDS', 'description': 'Safety Data Sheet'},
    {'abbreviation': 'SE', 'description': 'Surface Enhancement (Shot Peening)'},
    {'abbreviation': 'SER', 'description': 'Supplier Evaluation Reports'},
    {'abbreviation': 'SI', 'description': 'Source Inspector'},
    {'abbreviation': 'SIR', 'description': 'Supplier Informaton Request'},
    {'abbreviation': 'SKCFD', 'description': 'Supplier Key Characteristics Flow Down Diagram'},
    {'abbreviation': 'SMPP', 'description': 'Supplier Material Processing Procedure'},
    {'abbreviation': 'SOJT', 'description': 'Structured on the Job Training'},
    {'abbreviation': 'SOW', 'description': 'Statement of Work'},
    {'abbreviation': 'SPT', 'description': 'Support'},
    {'abbreviation': 'SQ', 'description': 'Supplier Quality'},
    {'abbreviation': 'SQAM', 'description': 'Supplier Quality Assurance Manual'},
    {'abbreviation': 'SQAR', 'description': 'Supplier Quality Assurance Requirements'},
    {'abbreviation': 'SQE', 'description': 'Senior Quality Engineer'},
    {'abbreviation': 'SQR', 'description': 'Supplier Quality Surveillance Report'},
    {'abbreviation': 'SRO', 'description': 'Suppliers Repair or Overhaul facilities'},
    {'abbreviation': 'SSD', 'description': 'Support Specification Departure'},
    {'abbreviation': 'ST', 'description': 'Short Transverse'},
    {'abbreviation': 'ST', 'description': 'Special Tooling'},
    {'abbreviation': 'STE', 'description': 'Special Test Equipment'},
    {'abbreviation': 'STM', 'description': 'Supplier Tooling Manual'},
    {'abbreviation': 'TDP', 'description': 'Technical Data Package'},
    {'abbreviation': 'TIR', 'description': 'Total Indicator Reading'},
    {'abbreviation': 'TRT', 'description': 'Tooling Rejection Tag'},
    {'abbreviation': 'TSO', 'description': 'Technical Standard Order'},
    {'abbreviation': 'UOM', 'description': 'Unit of Measure'},
    {'abbreviation': 'VAD', 'description': 'Vought Aircraft Division'},
    {'abbreviation': 'WIP', 'description': 'Work in Process'},
    {'abbreviation': 'WLD', 'description': 'Weld'},
  ];

  // Helper to alphabetize
  void _sortAbbreviations() {
    _abbreviations.sort((a, b) => (a['abbreviation'] ?? '')
        .toUpperCase()
        .compareTo((b['abbreviation'] ?? '').toUpperCase()));
  }

  @override
  void initState() {
    super.initState();
    _loadAbbreviations();
  }

  Future<void> _loadAbbreviations() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      setState(() {
        _abbreviations = List<Map<String, String>>.from(decoded);
        _sortAbbreviations();
      });
    } else {
      setState(() {
        _abbreviations = List<Map<String, String>>.from(_defaultAbbreviations);
        _sortAbbreviations();
      });
    }
  }

  Future<void> _saveAbbreviations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_abbreviations));
  }

  Future<void> _showBlankDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Missing Information'),
        content: const Text('Both Abbreviation and Meaning are required.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _addAbbreviation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Abbreviation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _abbreviationController,
                decoration: const InputDecoration(labelText: 'Abbreviation'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Meaning'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _abbreviationController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                final abbr = _abbreviationController.text.trim();
                final desc = _descriptionController.text.trim();
                if (abbr.isEmpty || desc.isEmpty) {
                  Navigator.of(context).pop();
                  _showBlankDialog();
                  return;
                }
                setState(() {
                  _abbreviations.add(
                      {'abbreviation': abbr, 'description': desc});
                  _sortAbbreviations();
                  _abbreviationController.clear();
                  _descriptionController.clear();
                });
                _saveAbbreviations();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAbbreviation(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Abbreviation?'),
        content: const Text(
            'Are you sure you want to delete this abbreviation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      setState(() {
        _abbreviations.removeAt(index);
        _sortAbbreviations();
      });
      _saveAbbreviations();
    }
  }

  Future<void> _resetToDefaults() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
            'Are you sure you want to reset all abbreviations to default values? This will delete your custom abbreviations.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text('Reset'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (shouldReset == true) {
      setState(() {
        _abbreviations = List<Map<String, String>>.from(_defaultAbbreviations);
        _sortAbbreviations();
      });
      _saveAbbreviations();
    }
  }

  @override
  void dispose() {
    _abbreviationController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                builder: (_) => const HelpScreen(helpKey: HelpKeys.abbrevPage),
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
        title: const Text('Abbreviations'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: _abbreviations.isEmpty
                ? const Center(child: Text('No abbreviations found.'))
                : ListView.builder(
              itemCount: _abbreviations.length,
              itemBuilder: (context, index) {
                final item = _abbreviations[index];
                return ListTile(
                  title: Text(item['abbreviation'] ?? ''),
                  subtitle: Text(item['description'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteAbbreviation(index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 64, left: 12, right: 12),
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
                    onPressed: _resetToDefaults,
                    child: const Text('Reset to Defaults'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAbbreviation,
        tooltip: 'Add Abbreviation',
        child: const Icon(Icons.add),
      ),
    );
  }
}