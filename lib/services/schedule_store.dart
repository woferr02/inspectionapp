import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:health_safety_inspection/models/schedule.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/audit_service.dart';
import 'package:health_safety_inspection/services/org_service.dart';
import 'package:health_safety_inspection/widgets/sync_indicator.dart';

/// Manages recurring inspection schedules.
class ScheduleStore extends ChangeNotifier {
  ScheduleStore._();
  static final ScheduleStore instance = ScheduleStore._();

  final List<InspectionSchedule> _schedules = [];

  UnmodifiableListView<InspectionSchedule> get schedules =>
      UnmodifiableListView(_schedules);

  List<InspectionSchedule> get overdueSchedules =>
      _schedules.where((s) => s.isOverdue).toList();

  List<InspectionSchedule> get activeSchedules =>
      _schedules.where((s) => s.isActive).toList();

  /// Load from Firestore (org-scoped when applicable).
  Future<void> loadForCurrentUser() async {
    _schedules.clear();
    final ref = AuthService.instance.schedulesRef;
    if (ref == null) {
      notifyListeners();
      return;
    }
    try {
      final snap = await ref
          .orderBy('nextDue')
          .get();
      for (final doc in snap.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          _schedules.add(InspectionSchedule.fromJson(data));
        } catch (_) {}
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Create a new schedule.
  InspectionSchedule addSchedule({
    required String templateId,
    required String templateName,
    required String siteId,
    required String siteName,
    required ScheduleFrequency frequency,
    String? assigneeId,
    String assigneeName = '',
    DateTime? startDate,
  }) {
    final start = startDate ?? DateTime.now();
    final schedule = InspectionSchedule(
      id: 'sch-${DateTime.now().millisecondsSinceEpoch}',
      templateId: templateId,
      templateName: templateName,
      siteId: siteId,
      siteName: siteName,
      frequency: frequency,
      assigneeId: assigneeId,
      assigneeName: assigneeName,
      nextDue: start,
    );
    _schedules.add(schedule);
    notifyListeners();
    _persist(schedule);
    AuditService.instance.log(
      action: AuditAction.scheduleCreated,
      targetId: schedule.id,
      description: 'Created schedule "${schedule.templateName}" for ${schedule.siteName}',
    );
    return schedule;
  }

  /// Mark a schedule as completed and advance the next due date.
  void markCompleted(String scheduleId) {
    final idx = _schedules.indexWhere((s) => s.id == scheduleId);
    if (idx == -1) return;
    final old = _schedules[idx];
    final now = DateTime.now();
    final updated = old.copyWith(
      lastCompleted: now,
      nextDue: old.computeNextDue(now),
    );
    _schedules[idx] = updated;
    notifyListeners();
    _persist(updated);
  }

  /// Toggle active state.
  void toggleActive(String scheduleId) {
    final idx = _schedules.indexWhere((s) => s.id == scheduleId);
    if (idx == -1) return;
    final old = _schedules[idx];
    final updated = old.copyWith(isActive: !old.isActive);
    _schedules[idx] = updated;
    notifyListeners();
    _persist(updated);
  }

  /// Delete a schedule. Requires admin or manager role.
  void deleteSchedule(String scheduleId) {
    final org = OrgService.instance;
    if (org.hasOrg && !org.isManager) return; // insufficient permissions
    _schedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();
    _deletePersisted(scheduleId);
    AuditService.instance.log(
      action: AuditAction.scheduleDeleted,
      targetId: scheduleId,
      description: 'Deleted schedule $scheduleId',
    );
  }

  Future<void> _persist(InspectionSchedule schedule) async {
    final ref = AuthService.instance.schedulesRef;
    if (ref == null) return;
    try {
      await ref.doc(schedule.id).set(schedule.toJson());
      SyncService.instance.markSynced();
    } catch (e) {
      debugPrint('[ScheduleStore] persist failed: $e');
    }
  }

  Future<void> _deletePersisted(String id) async {
    final ref = AuthService.instance.schedulesRef;
    if (ref == null) return;
    try {
      await ref.doc(id).delete();
    } catch (e) {
      debugPrint('[ScheduleStore] deletePersisted failed: $e');
    }
  }
}
