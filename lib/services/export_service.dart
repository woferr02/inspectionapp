import 'dart:convert';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Exports inspection data to CSV or JSON for sharing.
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  /// Export a single inspection as JSON string.
  String toJson(Inspection inspection) {
    final store = InspectionStore.instance;
    final data = inspection.toJson();

    // Embed section answers & notes
    final sections = <Map<String, dynamic>>[];
    for (final section in inspection.sections) {
      sections.add({
        ...section.toJson(),
        'answers': store.sectionAnswers(
          inspectionId: inspection.id,
          sectionId: section.id,
        ),
        'notes': store.sectionNotes(
          inspectionId: inspection.id,
          sectionId: section.id,
        ),
      });
    }
    data['sections'] = sections;

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Export a single inspection as CSV string.
  String toCsv(Inspection inspection) {
    final store = InspectionStore.instance;
    final buf = StringBuffer();

    // Header
    buf.writeln('Section,Question,Result,Notes');

    for (final section in inspection.sections) {
      final answers = store.sectionAnswers(
        inspectionId: inspection.id,
        sectionId: section.id,
      );
      final notes = store.sectionNotes(
        inspectionId: inspection.id,
        sectionId: section.id,
      );

      if (answers.isEmpty) {
        buf.writeln('"${_esc(section.name)}","No responses","",""');
      } else {
        for (final entry in answers.entries) {
          buf.writeln(
            '"${_esc(section.name)}","${_esc(entry.key)}","${_esc(entry.value)}","${_esc(notes[entry.key] ?? '')}"',
          );
        }
      }
    }

    return buf.toString();
  }

  /// Export all inspections as CSV.
  String allToCsv(List<Inspection> inspections) {
    final buf = StringBuffer();
    buf.writeln('Inspection,Site,Date,Status,Score,Inspector');
    for (final i in inspections) {
      buf.writeln(
        '"${_esc(i.name)}","${_esc(i.siteName)}","${i.date.toIso8601String()}","${i.statusText}","${i.score ?? ''}","${_esc(i.inspectorName)}"',
      );
    }
    return buf.toString();
  }

  /// Share inspection data as a file.
  Future<void> shareJson(Inspection inspection) async {
    final content = toJson(inspection);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/${inspection.name.replaceAll(' ', '_')}_export.json');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)],
        text: '${inspection.name} — Inspection Data');
  }

  /// Share inspection data as CSV.
  Future<void> shareCsv(Inspection inspection) async {
    final content = toCsv(inspection);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/${inspection.name.replaceAll(' ', '_')}_export.csv');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)],
        text: '${inspection.name} — Inspection CSV');
  }

  /// Share all inspections as CSV.
  Future<void> shareAllCsv(List<Inspection> inspections) async {
    final content = allToCsv(inspections);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/all_inspections_export.csv');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)],
        text: 'All Inspections — CSV Export');
  }

  String _esc(String value) => value.replaceAll('"', '""');
}
