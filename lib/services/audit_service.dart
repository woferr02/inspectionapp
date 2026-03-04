import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_safety_inspection/services/auth_service.dart';

enum AuditAction {
  inspectionCreated,
  inspectionDeleted,
  inspectionSubmitted,
  inspectionArchived,
  actionCreated,
  actionResolved,
  actionClosed,
  siteCreated,
  siteUpdated,
  siteDeleted,
  scheduleCreated,
  scheduleDeleted,
  memberInvited,
  memberRemoved,
  memberRoleChanged,
}

class AuditEntry {
  final String id;
  final AuditAction action;
  final String userId;
  final String userEmail;
  final String targetId;
  final String description;
  final DateTime timestamp;

  AuditEntry({
    required this.id,
    required this.action,
    required this.userId,
    required this.userEmail,
    required this.targetId,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action.name,
        'userId': userId,
        'userEmail': userEmail,
        'targetId': targetId,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        id: json['id'] as String,
        action: AuditAction.values.firstWhere(
          (e) => e.name == (json['action'] as String? ?? ''),
          orElse: () => AuditAction.inspectionCreated,
        ),
        userId: json['userId'] as String? ?? '',
        userEmail: json['userEmail'] as String? ?? '',
        targetId: json['targetId'] as String? ?? '',
        description: json['description'] as String? ?? '',
        timestamp:
            DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Fire-and-forget audit logging to Firestore.
class AuditService {
  AuditService._();
  static final AuditService instance = AuditService._();

  /// Write an audit entry (non-blocking, best-effort).
  void log({
    required AuditAction action,
    required String targetId,
    required String description,
  }) {
    final auth = AuthService.instance;
    if (!auth.isAvailable) return;

    final entry = AuditEntry(
      id: 'audit-${DateTime.now().millisecondsSinceEpoch}',
      action: action,
      userId: auth.currentUser?.uid ?? '',
      userEmail: auth.email,
      targetId: targetId,
      description: description,
      timestamp: DateTime.now(),
    );

    _persist(entry);
  }

  Future<void> _persist(AuditEntry entry) async {
    final auth = AuthService.instance;
    // Write to the org or user audit_log sub-collection.
    final root = auth.orgId.isNotEmpty
        ? FirebaseFirestore.instance.collection('organizations').doc(auth.orgId)
        : auth.userDoc;
    if (root == null) return;

    try {
      await root.collection('audit_log').doc(entry.id).set(entry.toJson());
    } catch (_) {}
  }
}
