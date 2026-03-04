import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_factory.dart';
import 'package:health_safety_inspection/data/mock_data.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/models/site.dart';
import 'package:health_safety_inspection/models/template.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/audit_service.dart';
import 'package:health_safety_inspection/services/org_service.dart';
import 'package:health_safety_inspection/widgets/sync_indicator.dart';

class InspectionStore extends ChangeNotifier {
  InspectionStore._();

  static final InspectionStore instance = InspectionStore._();

  final List<Inspection> _inspections = [];
  final Map<String, Map<String, String>> _sectionAnswersByKey = {};
  final Map<String, Map<String, String>> _sectionNotesByKey = {};
  final Map<String, Map<String, List<String>>> _sectionPhotosByKey = {};

  /// Call after login to load the user's inspections from Firestore.
  /// Falls back to mock data when Firestore is unavailable.
  Future<void> loadForCurrentUser() async {
    _inspections.clear();
    _sectionAnswersByKey.clear();
    _sectionNotesByKey.clear();
    _sectionPhotosByKey.clear();

    final ref = AuthService.instance.inspectionsRef;
    if (ref != null) {
      try {
        final snapshot = await ref.orderBy('date', descending: true).get();
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            if (data is Map<String, dynamic>) {
              _inspections.add(Inspection.fromJson(data));
            }
          } catch (_) {
            // skip malformed docs
          }
        }

        // Load answers sub-collection for each inspection
        for (final inspection in _inspections) {
          try {
            final answersSnap = await ref
                .doc(inspection.id)
                .collection('answers')
                .get();
            for (final aDoc in answersSnap.docs) {
              final aData = aDoc.data();
              final sectionId = aData['sectionId'] as String?;
              if (sectionId == null) continue;
              final key = _sectionKey(
                inspectionId: inspection.id,
                sectionId: sectionId,
              );
              final answers = _sectionAnswersByKey.putIfAbsent(key, () => {});
              final notes = _sectionNotesByKey.putIfAbsent(key, () => {});
              (aData['answers'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
                answers[k] = v.toString();
              });
              (aData['notes'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
                notes[k] = v.toString();
              });
              // Load photo paths
              final photos = _sectionPhotosByKey.putIfAbsent(key, () => {});
              (aData['photos'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
                if (v is List) {
                  photos[k] = v.map((e) => e.toString()).toList();
                }
              });
            }
          } catch (_) {}
        }


      } catch (_) {
        // Firestore unavailable — fall through to mock data
      }
    }

    // Only seed mock data when user is not authenticated (demo mode).
    // Authenticated users start with an empty list until they create inspections.
    if (_inspections.isEmpty && AuthService.instance.currentUser == null) {
      _inspections.addAll(List<Inspection>.from(MockData.inspections));
    }

    notifyListeners();
  }

  /// Persist a single inspection document to Firestore (fire-and-forget).
  Future<void> _persist(Inspection inspection) async {
    final ref = AuthService.instance.inspectionsRef;
    if (ref == null) return;
    try {
      await ref.doc(inspection.id).set(inspection.toJson());
      SyncService.instance.markSynced();
    } catch (e) {
      debugPrint('[InspectionStore] persist failed: $e');
    }
  }

  /// Persist section answers + notes to Firestore.
  Future<void> _persistAnswers({
    required String inspectionId,
    required String sectionId,
  }) async {
    final ref = AuthService.instance.inspectionsRef;
    if (ref == null) return;
    final key = _sectionKey(inspectionId: inspectionId, sectionId: sectionId);
    try {
      await ref
          .doc(inspectionId)
          .collection('answers')
          .doc(sectionId)
          .set({
        'sectionId': sectionId,
        'answers': _sectionAnswersByKey[key] ?? {},
        'notes': _sectionNotesByKey[key] ?? {},
        'photos': _sectionPhotosByKey[key] ?? {},
      });
    } catch (e) {
      debugPrint('[InspectionStore] persistAnswers failed: $e');
    }
  }

  UnmodifiableListView<Inspection> get inspections =>
      UnmodifiableListView(_inspections);

  String _sectionKey(
      {required String inspectionId, required String sectionId}) {
    return '$inspectionId::$sectionId';
  }

  Inspection? findById(String id) {
    for (final inspection in _inspections) {
      if (inspection.id == id) return inspection;
    }
    return null;
  }

  Inspection ensureInspection(Inspection inspection) {
    final existing = findById(inspection.id);
    if (existing != null) return existing;
    _inspections.insert(0, inspection);
    notifyListeners();
    _persist(inspection);
    return inspection;
  }

  Inspection createFromTemplate(
    Template template, {
    Site? site,
    String? customName,
  }) {
    final inspection = InspectionFactory.fromTemplate(
      template,
      site: site,
      customName: customName,
    );
    _inspections.insert(0, inspection);
    notifyListeners();
    _persist(inspection);
    AuditService.instance.log(
      action: AuditAction.inspectionCreated,
      targetId: inspection.id,
      description: 'Created inspection "${inspection.name}"',
    );
    return inspection;
  }

  Map<String, String> sectionAnswers({
    required String inspectionId,
    required String sectionId,
  }) {
    final key = _sectionKey(inspectionId: inspectionId, sectionId: sectionId);
    final values = _sectionAnswersByKey[key];
    if (values == null) return const {};
    return Map<String, String>.from(values);
  }

  Map<String, String> sectionNotes({
    required String inspectionId,
    required String sectionId,
  }) {
    final key = _sectionKey(inspectionId: inspectionId, sectionId: sectionId);
    final values = _sectionNotesByKey[key];
    if (values == null) return const {};
    return Map<String, String>.from(values);
  }

  int sectionCompletedCount({
    required String inspectionId,
    required String sectionId,
  }) {
    final key = _sectionKey(inspectionId: inspectionId, sectionId: sectionId);
    return _sectionAnswersByKey[key]?.length ?? 0;
  }

  void setSectionAnswer({
    required String inspectionId,
    required String sectionId,
    required String questionId,
    required String answer,
  }) {
    final key = _sectionKey(inspectionId: inspectionId, sectionId: sectionId);
    final answers = _sectionAnswersByKey.putIfAbsent(key, () => {});
    answers[questionId] = answer;
    notifyListeners();
    _persistAnswers(inspectionId: inspectionId, sectionId: sectionId);
  }

  void setSectionNote({
    required String inspectionId,
    required String sectionId,
    required String questionId,
    required String note,
  }) {
    final key = _sectionKey(inspectionId: inspectionId, sectionId: sectionId);
    final notes = _sectionNotesByKey.putIfAbsent(key, () => {});
    notes[questionId] = note;
    notifyListeners();
    _persistAnswers(inspectionId: inspectionId, sectionId: sectionId);
  }

  /// Persist photo paths for a question.
  void setSectionPhotos({
    required String inspectionId,
    required String sectionId,
    required String questionId,
    required List<String> paths,
  }) {
    final key = _sectionKey(inspectionId: inspectionId, sectionId: sectionId);
    final photos = _sectionPhotosByKey.putIfAbsent(key, () => {});
    photos[questionId] = paths;
    notifyListeners();
    _persistAnswers(inspectionId: inspectionId, sectionId: sectionId);
  }

  /// Retrieve photo paths for a section.
  Map<String, List<String>> sectionPhotos({
    required String inspectionId,
    required String sectionId,
  }) {
    final key = _sectionKey(inspectionId: inspectionId, sectionId: sectionId);
    final values = _sectionPhotosByKey[key];
    if (values == null) return const {};
    return Map<String, List<String>>.from(values);
  }

  /// Calculate section score from answers. Handles N/A correctly:
  /// - N/A questions are excluded from scoring
  /// - If ALL questions are N/A, section scores null (not 100)
  /// - Score = (pass count / (pass + fail count)) * 100
  /// - yes_no questions: 'yes' = pass, 'no' = fail
  /// - numeric/text/scale/multi answers are counted as pass (completed)
  static int? calculateSectionScore(Map<String, String> answers) {
    int passCount = 0;
    int failCount = 0;
    for (final v in answers.values) {
      switch (v) {
        case 'pass':
        case 'yes':
          passCount++;
          break;
        case 'fail':
        case 'no':
          failCount++;
          break;
        case 'na':
          // Excluded from scoring
          break;
        default:
          // Numeric, text, scale, multi — treat as completed/pass
          if (v.isNotEmpty) passCount++;
          break;
      }
    }
    final scoredChecks = passCount + failCount;
    // If nothing was actually scored (all N/A), return null
    if (scoredChecks == 0) return null;
    return ((passCount / scoredChecks) * 100).round();
  }

  Inspection updateSectionCompletion({
    required String inspectionId,
    required String sectionId,
    required int completedCount,
    int? score,
  }) {
    final inspection = findById(inspectionId);
    if (inspection == null) {
      throw StateError('Inspection not found: $inspectionId');
    }

    final updatedSections = inspection.sections.map((section) {
      if (section.id != sectionId) return section;
      final liveCompleted = sectionCompletedCount(
        inspectionId: inspectionId,
        sectionId: sectionId,
      );
      return InspectionSection(
        id: section.id,
        name: section.name,
        questionCount: section.questionCount,
        completedCount:
            (liveCompleted > completedCount ? liveCompleted : completedCount)
                .clamp(0, section.questionCount),
        score: score,
      );
    }).toList();

    final allComplete = updatedSections.every(
      (section) => section.completedCount >= section.questionCount,
    );

    final scoredSections =
        updatedSections.where((section) => section.score != null).toList();
    // Weighted average: sections with more questions count more.
    int? overallScore;
    if (scoredSections.isNotEmpty) {
      final totalWeight =
          scoredSections.fold<int>(0, (sum, s) => sum + s.questionCount);
      if (totalWeight > 0) {
        final weighted = scoredSections.fold<double>(
          0,
          (sum, s) => sum + (s.score! * s.questionCount),
        );
        overallScore = (weighted / totalWeight).round();
      } else {
        overallScore = (scoredSections
                    .map((section) => section.score!)
                    .reduce((a, b) => a + b) /
                scoredSections.length)
            .round();
      }
    }

    final updatedInspection = Inspection(
      id: inspection.id,
      name: inspection.name,
      siteName: inspection.siteName,
      siteAddress: inspection.siteAddress,
      date: DateTime.now(),
      status: allComplete
          ? InspectionStatus.completed
          : InspectionStatus.inProgress,
      score: allComplete ? (overallScore ?? 100) : inspection.score,
      inspectorName: inspection.inspectorName,
      sections: updatedSections,
    );

    _replace(updatedInspection);
    return updatedInspection;
  }

  /// Returns the overall completion fraction (0.0 – 1.0) for an inspection.
  double inspectionCompletion(String inspectionId) {
    final inspection = findById(inspectionId);
    if (inspection == null) return 0;
    final totalQuestions =
        inspection.sections.fold<int>(0, (sum, s) => sum + s.questionCount);
    if (totalQuestions == 0) return 1;
    final totalAnswered = inspection.sections.fold<int>(0, (sum, s) {
      return sum +
          sectionCompletedCount(
            inspectionId: inspectionId,
            sectionId: s.id,
          );
    });
    return totalAnswered / totalQuestions;
  }

  /// Whether the inspection has enough completion to be submitted (≥ 50 %).
  bool canSubmit(String inspectionId) => inspectionCompletion(inspectionId) >= 0.5;

  Inspection generateReport(String inspectionId) {
    final inspection = findById(inspectionId);
    if (inspection == null) {
      throw StateError('Inspection not found: $inspectionId');
    }
    if (!canSubmit(inspectionId)) {
      throw StateError('Inspection must be at least 50 % complete to submit.');
    }

    final updated = Inspection(
      id: inspection.id,
      name: inspection.name,
      siteName: inspection.siteName,
      siteAddress: inspection.siteAddress,
      date: DateTime.now(),
      status: InspectionStatus.submitted,
      score: inspection.score,
      inspectorName: inspection.inspectorName,
      sections: inspection.sections,
    );

    _replace(updated);
    AuditService.instance.log(
      action: AuditAction.inspectionSubmitted,
      targetId: inspectionId,
      description: 'Submitted inspection "${inspection.name}"',
    );
    return updated;
  }

  Inspection duplicateInspection(String inspectionId) {
    final inspection = findById(inspectionId);
    if (inspection == null) {
      throw StateError('Inspection not found: $inspectionId');
    }

    final duplicated = Inspection(
      id: 'dup-${DateTime.now().millisecondsSinceEpoch}',
      name: '${inspection.name} (Copy)',
      siteName: inspection.siteName,
      siteAddress: inspection.siteAddress,
      date: DateTime.now(),
      status: InspectionStatus.draft,
      score: null,
      inspectorName: inspection.inspectorName,
      sections: inspection.sections
          .map(
            (section) => InspectionSection(
              id: '${section.id}-copy',
              name: section.name,
              questionCount: section.questionCount,
              completedCount: 0,
            ),
          )
          .toList(),
    );

    _inspections.insert(0, duplicated);
    notifyListeners();
    _persist(duplicated);
    return duplicated;
  }

  List<Inspection> inspectionsForSite(String siteName) {
    return _inspections
        .where((inspection) => inspection.siteName == siteName)
        .toList();
  }

  /// Delete an inspection and its Firestore data.
  /// In an org context, requires admin or manager role.
  Future<void> deleteInspection(String inspectionId) async {
    final org = OrgService.instance;
    if (org.hasOrg && !org.isManager) return; // RBAC guard

    _inspections.removeWhere((i) => i.id == inspectionId);
    // Remove cached answers
    _sectionAnswersByKey
        .removeWhere((key, _) => key.startsWith('$inspectionId::'));
    _sectionNotesByKey
        .removeWhere((key, _) => key.startsWith('$inspectionId::'));
    notifyListeners();

    final ref = AuthService.instance.inspectionsRef;
    if (ref == null) return;
    try {
      // Delete answers sub-collection first
      final answersSnap =
          await ref.doc(inspectionId).collection('answers').get();
      for (final doc in answersSnap.docs) {
        await doc.reference.delete();
      }
      await ref.doc(inspectionId).delete();
    } catch (e) {
      debugPrint('[InspectionStore] deleteInspection failed: $e');
    }

    AuditService.instance.log(
      action: AuditAction.inspectionDeleted,
      targetId: inspectionId,
      description: 'Deleted inspection $inspectionId',
    );
  }

  /// Archive an inspection (sets status to archived and persists).
  Inspection archiveInspection(String inspectionId) {
    final inspection = findById(inspectionId);
    if (inspection == null) {
      throw StateError('Inspection not found: $inspectionId');
    }
    final archived = Inspection(
      id: inspection.id,
      name: inspection.name,
      siteName: inspection.siteName,
      siteAddress: inspection.siteAddress,
      date: inspection.date,
      status: InspectionStatus.archived,
      score: inspection.score,
      inspectorName: inspection.inspectorName,
      sections: inspection.sections,
    );
    _replace(archived);
    AuditService.instance.log(
      action: AuditAction.inspectionSubmitted,
      targetId: inspectionId,
      description: 'Archived inspection "${inspection.name}"',
    );
    return archived;
  }

  void _replace(Inspection inspection) {
    final index = _inspections.indexWhere((item) => item.id == inspection.id);
    if (index == -1) {
      _inspections.insert(0, inspection);
    } else {
      _inspections[index] = inspection;
    }
    notifyListeners();
    _persist(inspection);
  }
}
