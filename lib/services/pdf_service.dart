import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/data/question_bank.dart';
import 'package:health_safety_inspection/services/action_store.dart';

class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  /// Generate a full inspection report PDF.
  Future<Uint8List> generateReport({
    required Inspection inspection,
    Uint8List? inspectorSignature,
    Uint8List? siteManagerSignature,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.interRegular(),
        bold: await PdfGoogleFonts.interBold(),
        italic: await PdfGoogleFonts.interItalic(),
      ),
    );

    final store = InspectionStore.instance;
    final actionStore = ActionStore.instance;
    final actions = actionStore.forInspection(inspection.id);
    final dateStr = DateFormat('d MMMM yyyy').format(inspection.date);
    final timeStr = DateFormat('HH:mm').format(DateTime.now());
    final reportRef = 'SI-${inspection.id.hashCode.abs().toRadixString(36).toUpperCase().padLeft(6, '0')}';

    // ── Page 1: Cover + Summary ──
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(inspection, dateStr, reportRef),
        footer: (context) => _buildFooter(context, reportRef),
        build: (context) => [
          // Status badge
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              inspection.statusText.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
          ),
          pw.SizedBox(height: 12),

          // Report reference
          pw.Text(
            'Report Reference: $reportRef  |  Generated: $dateStr $timeStr',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 16),

          // Metadata table
          _buildMetaTable(inspection, dateStr),
          pw.SizedBox(height: 24),

          // ── MOT-Style Grade Card ──
          if (inspection.score != null) ...[
            _buildMotGradeCard(inspection),
            pw.SizedBox(height: 24),
          ],

          // Section summary table
          pw.Text('Section Summary',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          _buildSectionTable(inspection),
          pw.SizedBox(height: 24),

          // Section details with photos
          ...inspection.sections.expand((section) {
            final answers = store.sectionAnswers(
                inspectionId: inspection.id, sectionId: section.id);
            final notes = store.sectionNotes(
                inspectionId: inspection.id, sectionId: section.id);
            final photos = store.sectionPhotos(
                inspectionId: inspection.id, sectionId: section.id);

            // Resolve question IDs → human-readable titles
            final questions = QuestionBank.forSection(
              section.name, section.questionCount);
            final titleMap = <String, String>{};
            for (final q in questions) {
              titleMap[q['id']!] = q['title']!;
            }

            return [
              pw.Header(
                level: 2,
                text: section.name,
                textStyle:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              if (section.score != null)
                pw.Row(
                  children: [
                    pw.Text('Score: ${section.score}%  ',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: _verdictBgColor(section.score!),
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        _verdictLabel(section.score!),
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: _verdictFgColor(section.score!),
                        ),
                      ),
                    ),
                  ],
                ),
              pw.SizedBox(height: 8),
              if (answers.isNotEmpty)
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        _cell('Check Item', bold: true),
                        _cell('Result', bold: true),
                        _cell('Notes', bold: true),
                      ],
                    ),
                    ...answers.entries.map((entry) {
                      final label = titleMap[entry.key] ?? entry.key;
                      return pw.TableRow(
                        decoration: entry.value == 'fail'
                            ? const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF3F3))
                            : null,
                        children: [
                          _cell(label),
                          _resultCell(entry.value),
                          _cell(notes[entry.key] ?? '—'),
                        ],
                      );
                    }),
                  ],
                )
              else
                pw.Text('No responses recorded.',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey500)),
              // Photo evidence
              ..._buildPhotoWidgets(photos, titleMap),
              pw.SizedBox(height: 16),
            ];
          }),

          // Corrective Actions
          if (actions.isNotEmpty) ...[
            pw.Header(
              level: 2,
              text: 'Corrective Actions (${actions.length})',
              textStyle:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _cell('Action', bold: true),
                    _cell('Severity', bold: true),
                    _cell('Status', bold: true),
                    _cell('Due', bold: true),
                  ],
                ),
                ...actions.map((a) => pw.TableRow(children: [
                      _cell(a.title),
                      _cell(a.severityLabel),
                      _cell(a.statusLabel),
                      _cell(a.dueDate != null
                          ? DateFormat('d MMM yyyy').format(a.dueDate!)
                          : '—'),
                    ])),
              ],
            ),
            pw.SizedBox(height: 24),
          ],

          // Signatures
          pw.SizedBox(height: 20),
          pw.Text('Signatures',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Inspector',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    if (inspectorSignature != null)
                      pw.Image(pw.MemoryImage(inspectorSignature),
                          height: 60)
                    else
                      pw.Container(
                        height: 60,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                                bottom: pw.BorderSide(
                                    color: PdfColors.grey400))),
                      ),
                    pw.SizedBox(height: 4),
                    pw.Text(inspection.inspectorName,
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(dateStr,
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey500)),
                  ],
                ),
              ),
              pw.SizedBox(width: 40),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Site Manager',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    if (siteManagerSignature != null)
                      pw.Image(pw.MemoryImage(siteManagerSignature),
                          height: 60)
                    else
                      pw.Container(
                        height: 60,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                                bottom: pw.BorderSide(
                                    color: PdfColors.grey400))),
                      ),
                    pw.SizedBox(height: 4),
                    pw.Text('________________________',
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey400)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Launch the system print / share dialog.
  Future<void> printReport({
    required Inspection inspection,
    Uint8List? inspectorSignature,
    Uint8List? siteManagerSignature,
  }) async {
    final bytes = await generateReport(
      inspection: inspection,
      inspectorSignature: inspectorSignature,
      siteManagerSignature: siteManagerSignature,
    );
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: '${inspection.name} - Report',
    );
  }

  /// Share PDF via the system share sheet.
  Future<void> shareReport({
    required Inspection inspection,
    Uint8List? inspectorSignature,
    Uint8List? siteManagerSignature,
  }) async {
    final bytes = await generateReport(
      inspection: inspection,
      inspectorSignature: inspectorSignature,
      siteManagerSignature: siteManagerSignature,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${inspection.name.replaceAll(' ', '_')}_Report.pdf',
    );
  }

  // ── Private helpers ──

  pw.Widget _buildHeader(Inspection inspection, String dateStr, String reportRef) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SafeInspect Pro',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Inspection Report',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(dateStr,
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey600)),
              pw.Text('Ref: $reportRef',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, String reportRef) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey200)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by SafeInspect Pro  |  $reportRef',
            style:
                const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style:
                const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetaTable(Inspection inspection, String dateStr) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        _metaRow('Inspection', inspection.name),
        _metaRow('Site', inspection.siteName),
        _metaRow('Address', inspection.siteAddress),
        _metaRow('Inspector', inspection.inspectorName),
        _metaRow('Date', dateStr),
        _metaRow('Status', inspection.statusText),
      ],
    );
  }

  pw.TableRow _metaRow(String label, String value) {
    return pw.TableRow(children: [
      pw.Container(
        padding: const pw.EdgeInsets.all(6),
        color: PdfColors.grey100,
        child: pw.Text(label,
            style: pw.TextStyle(
                fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
      ),
    ]);
  }

  pw.Widget _buildSectionTable(Inspection inspection) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _cell('Section', bold: true),
            _cell('Completed', bold: true),
            _cell('Score', bold: true),
          ],
        ),
        ...inspection.sections.map((s) => pw.TableRow(children: [
              _cell(s.name),
              _cell('${s.completedCount}/${s.questionCount}'),
              _cell(s.score != null ? '${s.score}%' : '—'),
            ])),
      ],
    );
  }

  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  PdfColor _scoreColor(int score) {
    if (score >= 80) return PdfColors.green700;
    if (score >= 60) return PdfColors.orange700;
    return PdfColors.red700;
  }

  // ── MOT-style Grade Card ──

  static String _grade(int score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  static String _gradeLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Satisfactory';
    if (score >= 60) return 'Below Standard';
    return 'Fail';
  }

  String _verdictLabel(int score) {
    if (score >= 80) return 'PASS';
    if (score >= 60) return 'ADVISORY';
    return 'FAIL';
  }

  PdfColor _verdictFgColor(int score) {
    if (score >= 80) return PdfColors.green800;
    if (score >= 60) return PdfColors.orange800;
    return PdfColors.red800;
  }

  PdfColor _verdictBgColor(int score) {
    if (score >= 80) return PdfColors.green50;
    if (score >= 60) return PdfColors.orange50;
    return PdfColors.red50;
  }

  pw.Widget _buildMotGradeCard(Inspection inspection) {
    final score = inspection.score!;
    final gradeColor = _scoreColor(score);
    final scored = inspection.sections.where((s) => s.score != null).toList();
    final passCount = scored.where((s) => s.score! >= 80).length;
    final advisoryCount = scored.where((s) => s.score! >= 60 && s.score! < 80).length;
    final failCount = scored.where((s) => s.score! < 60).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Inspection Grade',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          // Grade + score row
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Grade circle
              pw.Container(
                width: 50,
                height: 50,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: gradeColor, width: 3),
                ),
                child: pw.Center(
                  child: pw.Text(
                    _grade(score),
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$score% — ${_gradeLabel(score)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '$passCount passed  |  $advisoryCount advisory  |  $failCount failed',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Section traffic-light table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _cell('Section', bold: true),
                  _cell('Score', bold: true),
                  _cell('Result', bold: true),
                ],
              ),
              ...inspection.sections.map((s) => pw.TableRow(
                decoration: s.score != null && s.score! < 60
                    ? const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF3F3))
                    : null,
                children: [
                  _cell(s.name),
                  _cell(s.score != null ? '${s.score}%' : '—'),
                  s.score != null
                      ? pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: pw.BoxDecoration(
                              color: _verdictBgColor(s.score!),
                              borderRadius: pw.BorderRadius.circular(2),
                            ),
                            child: pw.Text(
                              _verdictLabel(s.score!),
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: _verdictFgColor(s.score!),
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        )
                      : _cell('—'),
                ],
              )),
            ],
          ),

          // Advisory/fail lists
          if (advisoryCount > 0 || failCount > 0) ...[
            pw.SizedBox(height: 12),
            if (failCount > 0) ...[
              pw.Text('Sections Requiring Immediate Attention:',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
              pw.SizedBox(height: 4),
              ...scored.where((s) => s.score! < 60).map((s) =>
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                    child: pw.Text('• ${s.name} — ${s.score}%',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.red700)),
                  )),
              pw.SizedBox(height: 8),
            ],
            if (advisoryCount > 0) ...[
              pw.Text('Sections Needing Improvement:',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.orange700)),
              pw.SizedBox(height: 4),
              ...scored.where((s) => s.score! >= 60 && s.score! < 80).map((s) =>
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                    child: pw.Text('• ${s.name} — ${s.score}%',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange700)),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  // ── Colour-coded result cell ──
  pw.Widget _resultCell(String result) {
    PdfColor fg;
    PdfColor bg;
    switch (result.toLowerCase()) {
      case 'pass':
        fg = PdfColors.green800;
        bg = PdfColors.green50;
        break;
      case 'fail':
        fg = PdfColors.red800;
        bg = PdfColors.red50;
        break;
      default:
        fg = PdfColors.grey600;
        bg = PdfColors.grey100;
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(2),
        ),
        child: pw.Text(
          result.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: fg,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  // ── Photo evidence widgets ──
  List<pw.Widget> _buildPhotoWidgets(
      Map<String, List<String>> photos, Map<String, String> titleMap) {
    final widgets = <pw.Widget>[];
    for (final entry in photos.entries) {
      if (entry.value.isEmpty) continue;
      final questionLabel = titleMap[entry.key] ?? entry.key;
      final imageWidgets = <pw.Widget>[];
      for (final path in entry.value) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            imageWidgets.add(
              pw.Container(
                width: 120,
                height: 90,
                margin: const pw.EdgeInsets.only(right: 8, bottom: 4),
                child: pw.ClipRRect(
                  horizontalRadius: 4,
                  verticalRadius: 4,
                  child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.cover),
                ),
              ),
            );
          }
        } catch (_) {}
      }
      if (imageWidgets.isNotEmpty) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Evidence: $questionLabel',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: imageWidgets,
                ),
              ],
            ),
          ),
        );
      }
    }
    return widgets;
  }
}
