// lib/screens/position_and_bonus_page.dart
// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fai_assistant/help_screen.dart';
import 'package:fai_assistant/help_text_screen.dart';
import 'package:fai_assistant/reports/positional_report.dart' as report;

class PositionAndBonusPage extends StatefulWidget {
  const PositionAndBonusPage({super.key});

  @override
  State<PositionAndBonusPage> createState() => _PositionAndBonusPageState();
}

enum FeatureType { hole, pin }
enum SizeMode { mmcDirect, deriveMmc }
enum LocationMode { xy, measuredTp }

class _PositionAndBonusPageState extends State<PositionAndBonusPage> {
  String _unit = 'in'; // 'in' or 'mm'
  FeatureType _featureType = FeatureType.hole;
  SizeMode _sizeMode = SizeMode.mmcDirect;
  LocationMode _locationMode = LocationMode.xy;

  // Inputs
  final _mmcCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();
  final _tolUpperCtrl = TextEditingController();
  final _tolLowerCtrl = TextEditingController();
  final _actualSizeCtrl = TextEditingController();
  final _fcfTolCtrl = TextEditingController();
  final _xDevCtrl = TextEditingController();
  final _yDevCtrl = TextEditingController();
  final _measuredTpCtrl = TextEditingController();

  // Z option
  final _zDevCtrl = TextEditingController();
  bool _includeZ = true; // default ON to match many CMM reports
  double? _zUsed;

  // Results
  double? _derivedMmc;
  double? _bonus;
  double? _availableTp;
  double? _measuredTp;
  bool? _pass;
  double? _margin;

  // Breakdown values
  double? _nominalUsed;
  double? _tolUpperUsed;
  double? _tolLowerUsed;
  double? _xUsed;
  double? _yUsed;
  double? _radialOffset;

  double? _parse(String s) {
    if (s.trim().isEmpty) return null;
    return double.tryParse(s.trim());
  }

  // ENFORCE sign conventions when deriving MMC:
  // - Hole: lower tolerance must be negative
  // - Pin : upper tolerance must be positive
  double? _computeMmc() {
    if (_sizeMode == SizeMode.mmcDirect) {
      return _parse(_mmcCtrl.text);
    } else {
      final nominal = _parse(_nominalCtrl.text);
      final tuRaw = _parse(_tolUpperCtrl.text);
      final tlRaw = _parse(_tolLowerCtrl.text);
      if (nominal == null || tuRaw == null || tlRaw == null) {
        _nominalUsed = nominal;
        _tolUpperUsed = tuRaw;
        _tolLowerUsed = tlRaw;
        return null;
      }

      // Coerce signs
      final tu = tuRaw.abs();   // upper always positive
      final tl = -tlRaw.abs();  // lower always negative

      _nominalUsed = nominal;
      _tolUpperUsed = tu;
      _tolLowerUsed = tl;

      // Hole MMC = nominal + lower tol (negative)
      // Pin  MMC = nominal + upper tol (positive)
      if (_featureType == FeatureType.hole) {
        return nominal + tl;
      } else {
        return nominal + tu;
      }
    }
  }

  void _calculate() {
    setState(() {
      _derivedMmc = _computeMmc();
      final mmc = _derivedMmc;
      final actual = _parse(_actualSizeCtrl.text);
      final fcf = _parse(_fcfTolCtrl.text);

      _bonus = null;
      _availableTp = null;
      _measuredTp = null;
      _pass = null;
      _margin = null;

      _xUsed = null;
      _yUsed = null;
      _zUsed = null;
      _radialOffset = null;

      if (mmc == null || actual == null || fcf == null) return;

      // Bonus: Hole => actual - mmc ; Pin => mmc - actual
      double bonus = (_featureType == FeatureType.hole)
          ? (actual - mmc)
          : (mmc - actual);
      if (bonus < 0) bonus = 0.0;
      _bonus = bonus;

      // Available positional tolerance
      final available = fcf + bonus;
      _availableTp = available;

      // Measured TP
      if (_locationMode == LocationMode.xy) {
        final x = _parse(_xDevCtrl.text) ?? 0.0;
        final y = _parse(_yDevCtrl.text) ?? 0.0;
        final z = _includeZ ? (_parse(_zDevCtrl.text) ?? 0.0) : 0.0;

        _xUsed = x;
        _yUsed = y;
        _zUsed = _includeZ ? z : null;

        final r = math.sqrt(x * x + y * y + z * z);
        _radialOffset = r;
        _measuredTp = 2.0 * r; // diameter
      } else {
        _measuredTp = _parse(_measuredTpCtrl.text);
      }

      if (_measuredTp != null) {
        _pass = _measuredTp! <= available + 1e-12; // tiny epsilon
        _margin = available - _measuredTp!;
      }
    });
  }

  void _clear() {
    setState(() {
      _unit = 'in';
      _featureType = FeatureType.hole;
      _sizeMode = SizeMode.mmcDirect;
      _locationMode = LocationMode.xy;

      _mmcCtrl.clear();
      _nominalCtrl.clear();
      _tolUpperCtrl.clear();
      _tolLowerCtrl.clear();
      _actualSizeCtrl.clear();
      _fcfTolCtrl.clear();
      _xDevCtrl.clear();
      _yDevCtrl.clear();
      _zDevCtrl.clear();
      _measuredTpCtrl.clear();

      _includeZ = true;
      _derivedMmc = null;
      _bonus = null;
      _availableTp = null;
      _measuredTp = null;
      _pass = null;
      _margin = null;

      _nominalUsed = null;
      _tolUpperUsed = null;
      _tolLowerUsed = null;
      _xUsed = null;
      _yUsed = null;
      _zUsed = null;
      _radialOffset = null;
    });
  }

  // ========= Export flow =========

  Future<void> _collectReportInfoAndExport() async {
    // Recalculate to ensure the PDF uses the latest values
    _calculate();

    if (_bonus == null || _availableTp == null || _measuredTp == null || _pass == null || _margin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete inputs and calculate first.')),
      );
      return;
    }

    final faiCtrl = TextEditingController();
    final pnCtrl = TextEditingController();
    final charCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final inset = MediaQuery.of(ctx).viewInsets.bottom; // keyboard height in sheet
        return FractionallySizedBox(
          heightFactor: 0.95, // nearly full-screen
          child: Material(
            color: Theme.of(ctx).canvasColor,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, inset + 12),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Report Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(controller: faiCtrl, decoration: const InputDecoration(labelText: 'FAI')),
                  const SizedBox(height: 8),
                  TextField(controller: pnCtrl, decoration: const InputDecoration(labelText: 'PN')),
                  const SizedBox(height: 8),
                  TextField(controller: charCtrl, decoration: const InputDecoration(labelText: 'Char. No.')),
                  const SizedBox(height: 8),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Comments',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Generate PDF'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (ok == true) {
      await _exportReportWithMeta(
        fai: faiCtrl.text,
        pn: pnCtrl.text,
        charNo: charCtrl.text,
        name: nameCtrl.text,
        notes: notesCtrl.text,
      );
    }
  }

  Future<void> _exportReportWithMeta({
    String? fai, String? pn, String? charNo, String? name, String? notes,
  }) async {
    final rptFeature =
        (_featureType == FeatureType.hole) ? report.FeatureType.hole : report.FeatureType.pin;

    // Optional logo in the PDF header
    Uint8List? logoBytes;
    try {
      final bytes = await rootBundle.load('assets/images/fai_assistant_app_icon.png');
      logoBytes = bytes.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    final data = report.PositionalReportData(
      title: 'Positional Report',
      fai: (fai?.trim().isEmpty ?? true) ? null : fai!.trim(),
      pn: (pn?.trim().isEmpty ?? true) ? null : pn!.trim(),
      charNo: (charNo?.trim().isEmpty ?? true) ? null : charNo!.trim(),
      name: (name?.trim().isEmpty ?? true) ? null : name!.trim(),
      notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),

      featureType: rptFeature,
      unit: _unit,
      nominal: _sizeMode == SizeMode.deriveMmc ? _nominalUsed : null,
      tolUpper: _sizeMode == SizeMode.deriveMmc ? _tolUpperUsed : null,
      tolLower: _sizeMode == SizeMode.deriveMmc ? _tolLowerUsed : null,
      mmc: _derivedMmc,
      actualSize: _parse(_actualSizeCtrl.text)!,
      fcfTol: _parse(_fcfTolCtrl.text)!,
      datums: null,

      // Location inputs (now including Z)
      xDev: _locationMode == LocationMode.xy ? _xUsed : null,
      yDev: _locationMode == LocationMode.xy ? _yUsed : null,
      zDev: _locationMode == LocationMode.xy ? _zUsed : null, // <-- NEW
      measuredTp: _locationMode == LocationMode.measuredTp ? _parse(_measuredTpCtrl.text) : null,

      // Results
      bonus: _bonus!,
      availableTp: _availableTp!,
      measuredTpOut: _measuredTp!,
      pass: _pass!,
      margin: _margin!,

      logoBytes: logoBytes,
    );

    await report.PositionalReport.preview(context, data);
  }

  @override
  void dispose() {
    _mmcCtrl.dispose();
    _nominalCtrl.dispose();
    _tolUpperCtrl.dispose();
    _tolLowerCtrl.dispose();
    _actualSizeCtrl.dispose();
    _fcfTolCtrl.dispose();
    _xDevCtrl.dispose();
    _yDevCtrl.dispose();
    _zDevCtrl.dispose();
    _measuredTpCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: '$label (${_unit})',
        border: const OutlineInputBorder(),
        isDense: true,
      );

  Widget _sizeInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size specification', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<SizeMode>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enter MMC size directly'),
                value: SizeMode.mmcDirect,
                groupValue: _sizeMode,
                onChanged: (v) => setState(() => _sizeMode = v!),
              ),
            ),
            Expanded(
              child: RadioListTile<SizeMode>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Derive MMC from Nominal ± Tols'),
                value: SizeMode.deriveMmc,
                groupValue: _sizeMode,
                onChanged: (v) => setState(() => _sizeMode = v!),
              ),
            ),
          ],
        ),
        if (_sizeMode == SizeMode.mmcDirect) ...[
          TextField(
            controller: _mmcCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('MMC size'),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nominalCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _dec('Nominal size'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _tolUpperCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _dec('Upper tol (+)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tolLowerCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('Lower tol (−)  e.g. enter 0.001 for −0.001'),
          ),
          const SizedBox(height: 6),
          if (_derivedMmc != null)
            Text(
              'Derived MMC: ${_derivedMmc!.toStringAsFixed(6)} ${_unit}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _actualSizeCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _dec('Actual measured size'),
        ),
      ],
    );
  }

  Widget _locationInputs() {
    final twoDFormula = 'TP(⌀) = 2 × √(X² + Y²)';
    final threeDFormula = 'TP(⌀) = 2 × √(X² + Y² + Z²)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location input', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<LocationMode>(
                contentPadding: EdgeInsets.zero,
                title: const Text('X/Y deviations'),
                value: LocationMode.xy,
                groupValue: _locationMode,
                onChanged: (v) => setState(() => _locationMode = v!),
              ),
            ),
            Expanded(
              child: RadioListTile<LocationMode>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Measured TP (diameter)'),
                value: LocationMode.measuredTp,
                groupValue: _locationMode,
                onChanged: (v) => setState(() => _locationMode = v!),
              ),
            ),
          ],
        ),
        if (_locationMode == LocationMode.xy) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _xDevCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _dec('X deviation'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _yDevCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _dec('Y deviation'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include Z in TP (3D)'),
            value: _includeZ,
            onChanged: (v) => setState(() => _includeZ = v),
          ),
          if (_includeZ) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _zDevCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _dec('Z deviation'),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            _includeZ
                ? '$threeDFormula. Sign does not affect TP (values are squared).'
                : '$twoDFormula. Sign does not affect TP (values are squared).',
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ] else ...[
          TextField(
            controller: _measuredTpCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('Measured true position (⌀)'),
          ),
        ],
      ],
    );
  }

  Widget _resultsCard() {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Results', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_bonus != null)
              Text('Bonus tolerance: ${_bonus!.toStringAsFixed(6)} ${_unit}', style: textStyle),
            if (_availableTp != null)
              Text('Available positional tolerance: ${_availableTp!.toStringAsFixed(6)} ${_unit}', style: textStyle),
            if (_measuredTp != null)
              Text('Measured true position (⌀): ${_measuredTp!.toStringAsFixed(6)} ${_unit}', style: textStyle),
            if (_pass != null)
              Text(
                'Result: ${_pass! ? 'PASS' : 'FAIL'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _pass! ? Colors.green : Colors.red,
                ),
              ),
            if (_margin != null)
              Text('Margin: ${_margin!.toStringAsFixed(6)} ${_unit}', style: textStyle),
            const SizedBox(height: 8),
            if (_availableTp != null)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Calculation breakdown'),
                children: [
                  if (_sizeMode == SizeMode.mmcDirect && _derivedMmc != null)
                    Text('MMC (entered): ${_derivedMmc!.toStringAsFixed(6)} ${_unit}', style: textStyle),
                  if (_sizeMode == SizeMode.deriveMmc && _derivedMmc != null)
                    Text('MMC (derived): ${_derivedMmc!.toStringAsFixed(6)} ${_unit}', style: textStyle),
                  if (_sizeMode == SizeMode.deriveMmc && _nominalUsed != null)
                    Text('Nominal: ${_nominalUsed!.toStringAsFixed(6)} ${_unit}', style: textStyle),
                  if (_sizeMode == SizeMode.deriveMmc && _tolUpperUsed != null && _tolLowerUsed != null)
                    Text('Tolerances: +${_tolUpperUsed!.toStringAsFixed(6)} / ${_tolLowerUsed!.toStringAsFixed(6)} ${_unit}', style: textStyle),
                  if (_bonus != null)
                    Text('Bonus = max(0, size departure from MMC) = ${_bonus!.toStringAsFixed(6)} ${_unit}', style: textStyle),
                  if (_availableTp != null)
                    Text('Available TP = FCF tol + Bonus = ${_availableTp!.toStringAsFixed(6)} ${_unit}', style: textStyle),
                  if (_locationMode == LocationMode.xy && _xUsed != null && _yUsed != null) ...[
                    Text(
                      'Radial offset r = √(X² + Y²${_zUsed != null ? ' + Z²' : ''}) = ${_radialOffset!.toStringAsFixed(6)} ${_unit}',
                      style: textStyle,
                    ),
                    Text('Measured TP (⌀) = 2 × r = ${_measuredTp?.toStringAsFixed(6)} ${_unit}', style: textStyle),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canExport = _bonus != null && _availableTp != null && _measuredTp != null && _pass != null && _margin != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // keyboard height

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue[100],
        leadingWidth: 120,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Help button with app icon
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              icon: Image.asset(
                'assets/images/fai_assistant_app_icon.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              tooltip: 'Help',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpScreen(helpKey: HelpKeys.positionAndBonus),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        title: const Text('Calculator'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset), // push content above keyboard
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Unit + feature type
              Row(
                children: [
                  DropdownButton<String>(
                    value: _unit,
                    items: const [
                      DropdownMenuItem(value: 'in', child: Text('in')),
                      DropdownMenuItem(value: 'mm', child: Text('mm')),
                    ],
                    onChanged: (v) => setState(() => _unit = v!),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<FeatureType>(
                    value: _featureType,
                    items: const [
                      DropdownMenuItem(value: FeatureType.hole, child: Text('Hole')),
                      DropdownMenuItem(value: FeatureType.pin, child: Text('Pin')),
                    ],
                    onChanged: (v) => setState(() => _featureType = v!),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Size inputs
              _sizeInputs(),
              const SizedBox(height: 12),

              // FCF positional tolerance
              TextField(
                controller: _fcfTolCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _dec('FCF positional tolerance @ MMC'),
              ),
              const SizedBox(height: 12),

              // Location inputs
              _locationInputs(),
              const SizedBox(height: 16),

              // Calculate / Clear
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Results
              _resultsCard(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // Pinned action bar that lifts with the keyboard
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: (bottomInset > 0 ? bottomInset : 0) + 12, // float above keyboard
            top: 12,
          ),
          child: Row(
            children: [
              // Back on the left
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              // Export on the right
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export Report (PDF)'),
                  onPressed: canExport ? _collectReportInfoAndExport : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}