import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:health_safety_inspection/models/corrective_action.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/audit_service.dart';
import 'package:health_safety_inspection/widgets/sync_indicator.dart';

/// Manages corrective actions across all inspections.
class ActionStore extends ChangeNotifier {
  ActionStore._();
  static final ActionStore instance = ActionStore._();

  final List<CorrectiveAction> _actions = [];

  UnmodifiableListView<CorrectiveAction> get actions =>
      UnmodifiableListView(_actions);

  List<CorrectiveAction> get openActions =>
      _actions.where((a) => a.status == ActionStatus.open).toList();

  List<CorrectiveAction> get overdueActions =>
      _actions.where((a) => a.isOverdue).toList();

  List<CorrectiveAction> forInspection(String inspectionId) =>
      _actions.where((a) => a.inspectionId == inspectionId).toList();

  /// Load actions from Firestore for current user (org-scoped when applicable).
  Future<void> loadForCurrentUser() async {
    _actions.clear();
    final ref = AuthService.instance.actionsRef;
    if (ref == null) {
      notifyListeners();
      return;
    }
    try {
      final snap = await ref
          .orderBy('createdAt', descending: true)
          .get();
      for (final doc in snap.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          _actions.add(CorrectiveAction.fromJson(data));
        } catch (_) {}
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Add a new corrective action.
  CorrectiveAction addAction({
    required String inspectionId,
    required String sectionId,
    required String questionId,
    required String title,
    String description = '',
    ActionSeverity severity = ActionSeverity.medium,
    String assignee = '',
    DateTime? dueDate,
  }) {
    final action = CorrectiveAction(
      id: 'ca-${DateTime.now().millisecondsSinceEpoch}',
      inspectionId: inspectionId,
      sectionId: sectionId,
      questionId: questionId,
      title: title,
      description: description,
      severity: severity,
      assignee: assignee,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
    );
    _actions.insert(0, action);
    notifyListeners();
    _persist(action);
    AuditService.instance.log(
      action: AuditAction.actionCreated,
      targetId: action.id,
      description: 'Created corrective action "${action.title}"',
    );
    return action;
  }

  /// Update an existing action.
  void updateAction(CorrectiveAction updated) {
    final idx = _actions.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _actions[idx] = updated;
      notifyListeners();
      _persist(updated);
    }
  }

  /// Transition action status.
  void resolveAction(String actionId) {
    final idx = _actions.indexWhere((a) => a.id == actionId);
    if (idx == -1) return;
    final updated = _actions[idx].copyWith(
      status: ActionStatus.resolved,
      resolvedAt: DateTime.now(),
    );
    _actions[idx] = updated;
    notifyListeners();
    _persist(updated);
    AuditService.instance.log(
      action: AuditAction.actionResolved,
      targetId: actionId,
      description: 'Resolved corrective action "${updated.title}"',
    );
  }

  void closeAction(String actionId) {
    final idx = _actions.indexWhere((a) => a.id == actionId);
    if (idx == -1) return;
    final updated = _actions[idx].copyWith(status: ActionStatus.closed);
    _actions[idx] = updated;
    notifyListeners();
    _persist(updated);
    AuditService.instance.log(
      action: AuditAction.actionClosed,
      targetId: actionId,
      description: 'Closed corrective action "${updated.title}"',
    );
  }

  /// Delete a corrective action and remove from Firestore.
  Future<void> deleteAction(String actionId) async {
    final idx = _actions.indexWhere((a) => a.id == actionId);
    if (idx == -1) return;
    final title = _actions[idx].title;
    _actions.removeAt(idx);
    notifyListeners();

    final ref = AuthService.instance.actionsRef;
    if (ref != null) {
      try {
        await ref.doc(actionId).delete();
        SyncService.instance.markSynced();
      } catch (e) {
        debugPrint('[ActionStore] deleteAction failed: $e');
      }
    }

    AuditService.instance.log(
      action: AuditAction.actionClosed,
      targetId: actionId,
      description: 'Deleted corrective action "$title"',
    );
  }

  Future<void> _persist(CorrectiveAction action) async {
    final ref = AuthService.instance.actionsRef;
    if (ref == null) return;
    try {
      await ref.doc(action.id).set(action.toJson());
      SyncService.instance.markSynced();
    } catch (e) {
      debugPrint('[ActionStore] persist failed: $e');
    }
  }
}
