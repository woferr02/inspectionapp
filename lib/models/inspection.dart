import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';

enum InspectionStatus {
  draft,
  inProgress,
  completed,
  submitted,
  archived,
}

class Inspection {
  final String id;
  final String name;
  final String siteId;
  final String siteName;
  final String siteAddress;
  final DateTime date;
  final InspectionStatus status;
  final int? score;
  final String inspectorName;
  final String userId;
  final String templateId;
  final List<InspectionSection> sections;

  Inspection({
    required this.id,
    required this.name,
    this.siteId = '',
    required this.siteName,
    required this.siteAddress,
    required this.date,
    required this.status,
    this.score,
    required this.inspectorName,
    this.userId = '',
    this.templateId = '',
    required this.sections,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'siteId': siteId,
        'siteName': siteName,
        'siteAddress': siteAddress,
        'date': date.toIso8601String(),
        'status': status.name,
        'score': score,
        'inspectorName': inspectorName,
        'userId': userId,
        'templateId': templateId,
        'sections': sections.map((s) => s.toJson()).toList(),
      };

  factory Inspection.fromJson(Map<String, dynamic> json) => Inspection(
        id: json['id'] as String,
        name: json['name'] as String,
        siteId: json['siteId'] as String? ?? '',
        siteName: json['siteName'] as String? ?? '',
        siteAddress: json['siteAddress'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        status: InspectionStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'draft'),
          orElse: () => InspectionStatus.draft,
        ),
        score: json['score'] as int?,
        inspectorName: json['inspectorName'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        templateId: json['templateId'] as String? ?? '',
        sections: (json['sections'] as List<dynamic>? ?? [])
            .map((s) => InspectionSection.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  String get statusText {
    switch (status) {
      case InspectionStatus.draft:
        return 'Draft';
      case InspectionStatus.inProgress:
        return 'In Progress';
      case InspectionStatus.completed:
        return 'Completed';
      case InspectionStatus.submitted:
        return 'Submitted';
      case InspectionStatus.archived:
        return 'Archived';
    }
  }

  Color get statusColor {
    switch (status) {
      case InspectionStatus.draft:
        return AppColors.warning;
      case InspectionStatus.inProgress:
        return AppColors.primary;
      case InspectionStatus.completed:
        return AppColors.success;
      case InspectionStatus.submitted:
        return AppColors.success;
      case InspectionStatus.archived:
        return const Color(0xFF9CA3AF);
    }
  }
}

class InspectionSection {
  final String id;
  final String name;
  final int questionCount;
  final int completedCount;
  final int? score;

  InspectionSection({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.completedCount,
    this.score,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'questionCount': questionCount,
        'completedCount': completedCount,
        'score': score,
      };

  factory InspectionSection.fromJson(Map<String, dynamic> json) =>
      InspectionSection(
        id: json['id'] as String,
        name: json['name'] as String,
        questionCount: json['questionCount'] as int? ?? 0,
        completedCount: json['completedCount'] as int? ?? 0,
        score: json['score'] as int?,
      );

  double get progress => questionCount > 0 ? completedCount / questionCount : 0;
}
