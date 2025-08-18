// lib/reports/positional_report.dart
// Requires in pubspec.yaml:
// dependencies:
//   pdf: ^3.11.0
//   printing: ^5.12.0
//   intl: ^0.19.0
//
// Also add these assets (download the TTFs and place in assets/fonts):
// flutter:
//   assets:
//     - assets/fonts/DejaVuSans.ttf
//     - assets/fonts/DejaVuSans-Bold.ttf
//     - assets/fonts/NotoSansSymbols2-Regular.ttf
//
// Usage from a screen (after computing results):
//   final data = PositionalReportData(...);
//   await PositionalReport.preview(context, data);         // preview/print
//   // or:
//   await PositionalReport.generateAndShare(context, data); // share/save

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum FeatureType { hole, pin }

class PositionalReportData {
  // Header / identity
  final String title;            // e.g., "Positional Report"
  final DateTime timestamp;      // now by default

  // 4 meta fields + notes
  final String? fai;             // 1) FAI:
  final String? pn;              // 2) PN:
  final String? charNo;          // 3) Char. No.:
  final String? name;            // 4) Name:
  final String? notes;           // Free-form notes

  // Inputs
  final FeatureType featureType;
  final String unit;             // "in" or "mm"
  final double? nominal;         // if you used derive-MMC path
  final double? tolUpper;
  final double? tolLower;
  final double? mmc;             // derived or entered
  final double actualSize;
  final double fcfTol;
  final List<String>? datums;    // e.g., ["A","B","C"]
  final double? xDev;
  final double? yDev;
  final double? zDev;            // NEW: optional Z deviation when included
  final double? measuredTp;      // if provided directly (diameter)

  // Results
  final double bonus;
  final double availableTp;
  final double measuredTpOut;    // final measured TP (dia) used for decision
  final bool pass;
  final double margin;

  // Optional: app/logo asset bytes for header chip
  final Uint8List? logoBytes;

  PositionalReportData({
    this.title = 'Positional Report',
    DateTime? timestamp,

    // 4 meta fields + notes
    this.fai,
    this.pn,
    this.charNo,
    this.name,
    this.notes,

    // Inputs
    required this.featureType,
    required this.unit,
    this.nominal,
    this.tolUpper,
    this.tolLower,
    this.mmc,
    required this.actualSize,
    required this.fcfTol,
    this.datums,
    this.xDev,
    this.yDev,
    this.zDev,          // NEW
    this.measuredTp,

    // Results
    required this.bonus,
    required this.availableTp,
    required this.measuredTpOut,
    required this.pass,
    required this.margin,

    // Logo
    this.logoBytes,
  }) : timestamp = timestamp ?? DateTime.now();
}

class PositionalReport {
  // Cache fonts so we only load them once per app session.
  static pw.Font? _fontBase;
  static pw.Font? _fontBold;
  static pw.Font? _fontSymbols;

  static Future<void> _ensureFonts() async {
    if (_fontBase != null) return;
    _fontBase    = pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
    _fontBold    = pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf'));
    _fontSymbols = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansSymbols2-Regular.ttf'));
  }

  static Future<void> preview(BuildContext context, PositionalReportData data) async {
    await Printing.layoutPdf(
      onLayout: (format) async => await _buildPdf(data, format: format),
    );
  }

  static Future<void> generateAndShare(BuildContext context, PositionalReportData data) async {
    final bytes = await _buildPdf(data);
    await Printing.sharePdf(bytes: bytes, filename: _fileName(data));
  }

  static String _fileName(PositionalReportData data) {
    final ts = DateFormat('yyyyMMdd_HHmmss').format(data.timestamp);
    final pn = (data.pn ?? 'report').replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    return '${pn}_positional_$ts.pdf';
  }

  static Future<Uint8List> _buildPdf(PositionalReportData data, {PdfPageFormat? format}) async {
    await _ensureFonts();

    final doc = pw.Document();

    // Default fonts for compatibility + symbols fallback
    final pageTheme = pw.PageTheme(
      margin: const pw.EdgeInsets.all(24),
      theme: pw.ThemeData.withFont(
        base: _fontBase!,
        bold: _fontBold!,
      ),
    );

    final green = PdfColors.green600;
    final red = PdfColors.red600;

    String fmt(double? v) => v == null ? 'N/A' : v.toStringAsFixed(6);

    // Header with title, timestamp, pass/fail chip + optional logo
    final header = pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (data.logoBytes != null)
          pw.Container(
            width: 48, height: 48,
            margin: const pw.EdgeInsets.only(right: 12),
            child: pw.Image(pw.MemoryImage(data.logoBytes!)),
          ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              data.title,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, fontFallback: [_fontSymbols!]),
            ),
            pw.Text(
              DateFormat('yyyy-MM-dd HH:mm').format(data.timestamp),
              style: pw.TextStyle(fontFallback: [_fontSymbols!]),
            ),
          ],
        ),
        pw.Spacer(),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: data.pass ? green : red,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            data.pass ? 'PASS' : 'FAIL',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              fontFallback: [_fontSymbols!],
            ),
          ),
        ),
      ],
    );

    // The four meta boxes row (FAI / PN / Char. No. / Name)
    final meta = pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: _metaBlock('FAI', _orNA(data.fai))),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _metaBlock('PN', _orNA(data.pn))),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _metaBlock('Char. No.', _orNA(data.charNo))),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _metaBlock('Name', _orNA(data.name))),
      ],
    );

    // Inputs table
    final inputsTable = pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cellHeader('Input'),
            _cellHeader('Value'),
            _cellHeader('Input'),
            _cellHeader('Value'),
          ],
        ),
        _row('Feature Type', data.featureType == FeatureType.hole ? 'Hole' : 'Pin', 'Units', data.unit),
        _row('Nominal', fmt(data.nominal), 'Tol (+ / −)', '${fmt(data.tolUpper)} / ${fmt(data.tolLower)}'),
        _row('MMC', fmt(data.mmc), 'Actual Size', fmt(data.actualSize)),
        _row('FCF Pos Tol', fmt(data.fcfTol), 'Datums',
            (data.datums != null && data.datums!.isNotEmpty) ? data.datums!.join(', ') : 'N/A'),
        _row('X dev', fmt(data.xDev), 'Y dev', fmt(data.yDev)),
        // NEW: show Z dev when provided, otherwise "N/A"
        _row('Z dev', fmt(data.zDev), 'Measured TP (⌀)', fmt(data.measuredTp)),
      ],
    );

    // Results table
    final results = pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(3),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cellHeader('Result metric'),
            _cellHeader('Value (${data.unit})'),
            _cellHeader('Result metric'),
            _cellHeader('Value (${data.unit})'),
          ],
        ),
        _row('Bonus', fmt(data.bonus), 'Available TP', fmt(data.availableTp)),
        _row('Measured TP (⌀)', fmt(data.measuredTpOut), 'Margin', fmt(data.margin)),
      ],
    );

    // Notes section (bottom) + dynamic formula line
    final is3D = data.zDev != null;
    final notes = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 8),
        pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontFallback: [_fontSymbols!])),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            _orNA(data.notes),
            style: pw.TextStyle(fontSize: 11, fontFallback: [_fontSymbols!]),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          is3D
              ? 'Formulas: Bonus = max(0, size departure from MMC);  '
                'Available TP = FCF tol + Bonus;  '
                'TP(⌀) = 2 × √(X² + Y² + Z²).  RFS → Bonus = 0.'
              : 'Formulas: Bonus = max(0, size departure from MMC);  '
                'Available TP = FCF tol + Bonus;  '
                'TP(⌀) = 2 × √(X² + Y²).  RFS → Bonus = 0.',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700, fontFallback: [_fontSymbols!]),
        ),
      ],
    );

    doc.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (context) {
          return pw.DefaultTextStyle(
            style: pw.TextStyle(fontFallback: [_fontSymbols!]),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                header,
                pw.SizedBox(height: 12),
                meta,
                pw.SizedBox(height: 12),
                inputsTable,
                pw.SizedBox(height: 12),
                results,
                pw.SizedBox(height: 12),
                notes,
                pw.Spacer(),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Generated by FAI Assistant',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontFallback: [_fontSymbols!]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  // Helpers

  static String _orNA(String? v) => (v == null || v.trim().isEmpty) ? 'N/A' : v.trim();

  static pw.TableRow _row(String k1, String v1, String k2, String v2) {
    return pw.TableRow(
      children: [
        _cellKey(k1), _cellVal(v1),
        _cellKey(k2), _cellVal(v2),
      ],
    );
  }

  static pw.Widget _cellHeader(String text) =>
      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));

  static pw.Widget _cellKey(String text) =>
      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text));

  static pw.Widget _cellVal(String text) =>
      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text));

  static pw.Widget _metaBlock(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}