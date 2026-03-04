import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_safety_inspection/data/mock_data.dart';
import 'package:health_safety_inspection/models/schedule.dart';
import 'package:health_safety_inspection/services/schedule_store.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/empty_state.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => const _CreateScheduleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ScheduleStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final overdue = store.overdueSchedules;
        final upcoming = store.activeSchedules
            .where((s) => !s.isOverdue)
            .toList()
          ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
        final inactive =
            store.schedules.where((s) => !s.isActive).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: 'Schedules',
                  showBackButton: true,
                  actions: [
                    PrimaryButton(
                      text: 'New schedule',
                      height: 40,
                      onPressed: _showCreateSheet,
                    ),
                  ],
                ),
                Expanded(
                  child: (store.schedules.isEmpty)
                      ? AppViewport(
                          child: EmptyState(
                            icon: Icons.event_repeat,
                            title: 'No schedules yet',
                            description: 'Create recurring inspection schedules to stay on track',
                          ),
                        )
                      : SingleChildScrollView(
                          child: AppViewport(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.x3,
                              AppSpacing.x2,
                              AppSpacing.x3,
                              AppSpacing.x4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (overdue.isNotEmpty) ...[
                                  _SectionLabel(
                                    text: 'Overdue',
                                    color: AppColors.error,
                                    count: overdue.length,
                                  ),
                                  const SizedBox(height: 8),
                                  ...overdue.map((s) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _ScheduleCard(
                                          schedule: s,
                                          isOverdue: true,
                                        ),
                                      )),
                                  const SizedBox(height: 16),
                                ],
                                if (upcoming.isNotEmpty) ...[
                                  _SectionLabel(
                                    text: 'Upcoming',
                                    count: upcoming.length,
                                  ),
                                  const SizedBox(height: 8),
                                  ...upcoming.map((s) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _ScheduleCard(schedule: s),
                                      )),
                                  const SizedBox(height: 16),
                                ],
                                if (inactive.isNotEmpty) ...[
                                  _SectionLabel(
                                    text: 'Paused',
                                    count: inactive.length,
                                  ),
                                  const SizedBox(height: 8),
                                  ...inactive.map((s) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _ScheduleCard(
                                          schedule: s,
                                          dimmed: true,
                                        ),
                                      )),
                                ],
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final int? count;

  const _SectionLabel({required this.text, this.color, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textSecondary(context),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: (color ?? AppColors.textSecondary(context))
                  .withValues(alpha: 0.12),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final InspectionSchedule schedule;
  final bool isOverdue;
  final bool dimmed;

  const _ScheduleCard({
    required this.schedule,
    this.isOverdue = false,
    this.dimmed = false,
  });

  Future<void> _confirmDelete(BuildContext context, InspectionSchedule s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(context),
        title: Text('Delete Schedule',
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600)),
        content: Text(
            'This will permanently delete this schedule. This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary(context))),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context, false),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Cancel',
                  style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w500)),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Delete',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ScheduleStore.instance.deleteSchedule(s.id);
      if (context.mounted) AppToast.show(context, 'Schedule deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ScheduleStore.instance;
    final dueStr = DateFormat('d MMM yyyy').format(schedule.nextDue);
    final daysText = schedule.isOverdue
        ? '${-schedule.daysUntilDue}d overdue'
        : schedule.daysUntilDue == 0
            ? 'Due today'
            : 'in ${schedule.daysUntilDue}d';

    return Opacity(
      opacity: dimmed ? 0.5 : 1.0,
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule.templateName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    schedule.frequencyLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              schedule.siteName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 14,
                  color: isOverdue
                      ? AppColors.error
                      : AppColors.textTertiary(context),
                ),
                const SizedBox(width: 4),
                Text(
                  '$dueStr ($daysText)',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isOverdue
                        ? AppColors.error
                        : AppColors.textSecondary(context),
                    fontWeight:
                        isOverdue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                if (schedule.isActive) ...[
                  Tappable(
                    onTap: () => store.markCompleted(schedule.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        color: AppColors.success.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        'Complete',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Tappable(
                  onTap: () => store.toggleActive(schedule.id),
                  child: Icon(
                    schedule.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 20,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 8),
                Tappable(
                  onTap: () => _confirmDelete(context, schedule),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateScheduleSheet extends StatefulWidget {
  const _CreateScheduleSheet();

  @override
  State<_CreateScheduleSheet> createState() => _CreateScheduleSheetState();
}

class _CreateScheduleSheetState extends State<_CreateScheduleSheet> {
  String? _selectedTemplateId;
  String? _selectedSiteId;
  ScheduleFrequency _frequency = ScheduleFrequency.monthly;

  @override
  Widget build(BuildContext context) {
    final templates = MockData.templates;
    final sites = SiteStore.instance.sites;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Schedule',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 20),

          // Template picker
          Text('Template',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              )),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderColor(context)),
              color: AppColors.surfaceColor(context),
            ),
            child: DropdownButton<String>(
              value: _selectedTemplateId,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Text('Select template',
                  style: TextStyle(color: AppColors.textTertiary(context))),
              items: templates
                  .map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.name,
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTemplateId = v),
            ),
          ),
          const SizedBox(height: 14),

          // Site picker
          Text('Site',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              )),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderColor(context)),
              color: AppColors.surfaceColor(context),
            ),
            child: DropdownButton<String>(
              value: _selectedSiteId,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Text('Select site',
                  style: TextStyle(color: AppColors.textTertiary(context))),
              items: sites
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name,
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSiteId = v),
            ),
          ),
          const SizedBox(height: 14),

          // Frequency picker
          Text('Frequency',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              )),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderColor(context)),
              color: AppColors.surfaceColor(context),
            ),
            child: DropdownButton<ScheduleFrequency>(
              value: _frequency,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: ScheduleFrequency.values
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(_freqLabel(f)),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _frequency = v ?? ScheduleFrequency.monthly),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Create schedule',
            width: double.infinity,
            onPressed: () {
              if (_selectedTemplateId == null || _selectedSiteId == null) return;
              final template =
                  templates.firstWhere((t) => t.id == _selectedTemplateId);
              final site =
                  sites.firstWhere((s) => s.id == _selectedSiteId);
              ScheduleStore.instance.addSchedule(
                templateId: template.id,
                templateName: template.name,
                siteId: site.id,
                siteName: site.name,
                frequency: _frequency,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String _freqLabel(ScheduleFrequency f) {
    switch (f) {
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
}
