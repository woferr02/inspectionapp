import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';

enum ActionSeverity { low, medium, high, critical }

enum ActionStatus { open, inProgress, resolved, closed }

class CorrectiveAction {
  final String id;
  final String inspectionId;
  final String sectionId;
  final String questionId;
  final String title;
  final String description;
  final ActionSeverity severity;
  final ActionStatus status;
  final String assignee;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String> photoIds;

  CorrectiveAction({
    required this.id,
    required this.inspectionId,
    required this.sectionId,
    required this.questionId,
    required this.title,
    this.description = '',
    this.severity = ActionSeverity.medium,
    this.status = ActionStatus.open,
    this.assignee = '',
    this.dueDate,
    DateTime? createdAt,
    this.resolvedAt,
    this.photoIds = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  CorrectiveAction copyWith({
    String? title,
    String? description,
    ActionSeverity? severity,
    ActionStatus? status,
    String? assignee,
    DateTime? dueDate,
    DateTime? resolvedAt,
    List<String>? photoIds,
  }) =>
      CorrectiveAction(
        id: id,
        inspectionId: inspectionId,
        sectionId: sectionId,
        questionId: questionId,
        title: title ?? this.title,
        description: description ?? this.description,
        severity: severity ?? this.severity,
        status: status ?? this.status,
        assignee: assignee ?? this.assignee,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt,
        resolvedAt: resolvedAt ?? this.resolvedAt,
        photoIds: photoIds ?? this.photoIds,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'inspectionId': inspectionId,
        'sectionId': sectionId,
        'questionId': questionId,
        'title': title,
        'description': description,
        'severity': severity.name,
        'status': status.name,
        'assignee': assignee,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
        'photoIds': photoIds,
      };

  factory CorrectiveAction.fromJson(Map<String, dynamic> json) =>
      CorrectiveAction(
        id: json['id'] as String,
        inspectionId: json['inspectionId'] as String,
        sectionId: json['sectionId'] as String? ?? '',
        questionId: json['questionId'] as String? ?? '',
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        severity: ActionSeverity.values.firstWhere(
          (e) => e.name == (json['severity'] as String? ?? 'medium'),
          orElse: () => ActionSeverity.medium,
        ),
        status: ActionStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'open'),
          orElse: () => ActionStatus.open,
        ),
        assignee: json['assignee'] as String? ?? '',
        dueDate: json['dueDate'] != null
            ? DateTime.tryParse(json['dueDate'] as String)
            : null,
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        resolvedAt: json['resolvedAt'] != null
            ? DateTime.tryParse(json['resolvedAt'] as String)
            : null,
        photoIds: (json['photoIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  // ── Display helpers ──

  String get severityLabel {
    switch (severity) {
      case ActionSeverity.low:
        return 'Low';
      case ActionSeverity.medium:
        return 'Medium';
      case ActionSeverity.high:
        return 'High';
      case ActionSeverity.critical:
        return 'Critical';
    }
  }

  Color get severityColor {
    switch (severity) {
      case ActionSeverity.low:
        return AppColors.success;
      case ActionSeverity.medium:
        return AppColors.warning;
      case ActionSeverity.high:
        return const Color(0xFFEA580C);
      case ActionSeverity.critical:
        return AppColors.error;
    }
  }

  String get statusLabel {
    switch (status) {
      case ActionStatus.open:
        return 'Open';
      case ActionStatus.inProgress:
        return 'In Progress';
      case ActionStatus.resolved:
        return 'Resolved';
      case ActionStatus.closed:
        return 'Closed';
    }
  }

  Color get statusColor {
    switch (status) {
      case ActionStatus.open:
        return AppColors.error;
      case ActionStatus.inProgress:
        return AppColors.warning;
      case ActionStatus.resolved:
        return AppColors.success;
      case ActionStatus.closed:
        return const Color(0xFF6B7280);
    }
  }

  bool get isOverdue =>
      status == ActionStatus.open &&
      dueDate != null &&
      dueDate!.isBefore(DateTime.now());
}
