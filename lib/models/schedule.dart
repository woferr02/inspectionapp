class InspectionSchedule {
  final String id;
  final String templateId;
  final String templateName;
  final String siteId;
  final String siteName;
  final ScheduleFrequency frequency;
  final String? assigneeId;
  final String assigneeName;
  final DateTime nextDue;
  final DateTime? lastCompleted;
  final bool isActive;

  InspectionSchedule({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.siteId,
    required this.siteName,
    required this.frequency,
    this.assigneeId,
    this.assigneeName = '',
    required this.nextDue,
    this.lastCompleted,
    this.isActive = true,
  });

  InspectionSchedule copyWith({
    ScheduleFrequency? frequency,
    String? assigneeId,
    String? assigneeName,
    DateTime? nextDue,
    DateTime? lastCompleted,
    bool? isActive,
  }) =>
      InspectionSchedule(
        id: id,
        templateId: templateId,
        templateName: templateName,
        siteId: siteId,
        siteName: siteName,
        frequency: frequency ?? this.frequency,
        assigneeId: assigneeId ?? this.assigneeId,
        assigneeName: assigneeName ?? this.assigneeName,
        nextDue: nextDue ?? this.nextDue,
        lastCompleted: lastCompleted ?? this.lastCompleted,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateId': templateId,
        'templateName': templateName,
        'siteId': siteId,
        'siteName': siteName,
        'frequency': frequency.name,
        'assigneeId': assigneeId,
        'assigneeName': assigneeName,
        'nextDue': nextDue.toIso8601String(),
        'lastCompleted': lastCompleted?.toIso8601String(),
        'isActive': isActive,
      };

  factory InspectionSchedule.fromJson(Map<String, dynamic> json) =>
      InspectionSchedule(
        id: json['id'] as String,
        templateId: json['templateId'] as String,
        templateName: json['templateName'] as String? ?? '',
        siteId: json['siteId'] as String,
        siteName: json['siteName'] as String? ?? '',
        frequency: ScheduleFrequency.values.firstWhere(
          (e) => e.name == (json['frequency'] as String? ?? 'monthly'),
          orElse: () => ScheduleFrequency.monthly,
        ),
        assigneeId: json['assigneeId'] as String?,
        assigneeName: json['assigneeName'] as String? ?? '',
        nextDue: DateTime.tryParse(json['nextDue'] as String? ?? '') ??
            DateTime.now(),
        lastCompleted: json['lastCompleted'] != null
            ? DateTime.tryParse(json['lastCompleted'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );

  bool get isOverdue => isActive && nextDue.isBefore(DateTime.now());

  int get daysUntilDue => nextDue.difference(DateTime.now()).inDays;

  String get frequencyLabel {
    switch (frequency) {
      case ScheduleFrequency.daily:
        return 'Daily';
      case ScheduleFrequency.weekly:
        return 'Weekly';
      case ScheduleFrequency.biweekly:
        return 'Every 2 weeks';
      case ScheduleFrequency.monthly:
        return 'Monthly';
      case ScheduleFrequency.quarterly:
        return 'Quarterly';
      case ScheduleFrequency.biannual:
        return 'Every 6 months';
      case ScheduleFrequency.annual:
        return 'Annually';
    }
  }

  /// Calculates the next due date from a given completion date.
  DateTime computeNextDue(DateTime fromDate) {
    switch (frequency) {
      case ScheduleFrequency.daily:
        return fromDate.add(const Duration(days: 1));
      case ScheduleFrequency.weekly:
        return fromDate.add(const Duration(days: 7));
      case ScheduleFrequency.biweekly:
        return fromDate.add(const Duration(days: 14));
      case ScheduleFrequency.monthly:
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      case ScheduleFrequency.quarterly:
        return DateTime(fromDate.year, fromDate.month + 3, fromDate.day);
      case ScheduleFrequency.biannual:
        return DateTime(fromDate.year, fromDate.month + 6, fromDate.day);
      case ScheduleFrequency.annual:
        return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
    }
  }
}

enum ScheduleFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  biannual,
  annual,
}
