import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:intl/intl.dart';
import 'package:health_safety_inspection/data/mock_data.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/action_store.dart';
import 'package:health_safety_inspection/services/schedule_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/new_inspection_sheet.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _startInspection(BuildContext context) async {
    final inspection = await showNewInspectionSheet(context);
    if (inspection != null && context.mounted) {
      Navigator.pushNamed(
        context,
        Routes.inspectionDetail,
        arguments: inspection,
      );
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    final name = AuthService.instance.displayName;
    if (name.isEmpty) return '';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final store = InspectionStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final drafts = store.inspections
            .where((i) =>
                i.status == InspectionStatus.draft ||
                i.status == InspectionStatus.inProgress)
            .take(3)
            .toList();
        final recent = store.inspections
            .where((i) =>
                i.status == InspectionStatus.completed ||
                i.status == InspectionStatus.submitted)
            .take(3)
            .toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: 'Dashboard',
                  showMenuButton: true,
                  actions: [
                    PrimaryButton(
                      text: 'Start inspection',
                      height: 40,
                      onPressed: () => _startInspection(context),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: AppViewport(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x3,
                        AppSpacing.x3,
                        AppSpacing.x3,
                        AppSpacing.x4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting${_firstName.isNotEmpty ? ', $_firstName' : ''}',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary(context),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Run inspections, generate structured reports, and manage records in one workflow.',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary(context),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy')
                                .format(DateTime.now()),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textTertiary(context),
                                    ),
                          ),
                          const SizedBox(height: AppSpacing.x3),
                          // ── Stat summary row ──
                          _StatRow(),
                          const SizedBox(height: AppSpacing.x3),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 900;
                              final isMedium = constraints.maxWidth >= 620;
                              final count = isWide ? 3 : (isMedium ? 2 : 1);
                              return GridView.count(
                                crossAxisCount: count,
                                crossAxisSpacing: AppSpacing.x2,
                                mainAxisSpacing: AppSpacing.x2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: isWide ? 1.45 : 1.25,
                                children: [
                                  _DashboardCard(
                                    title: 'Start from template',
                                    subtitle:
                                        'Launch a new workflow with predefined sections and checks.',
                                    metadata:
                                        '${MockData.templates.length} templates available',
                                    actionText: 'Browse templates',
                                    onTap: () => Navigator.pushNamed(
                                        context, Routes.templates),
                                  ),
                                  _DashboardCard(
                                    title: 'Continue draft inspections',
                                    subtitle: drafts.isEmpty
                                        ? 'No drafts waiting. Start a new inspection to begin.'
                                        : drafts.first.name,
                                    metadata: drafts.isEmpty
                                        ? 'All caught up'
                                        : '${drafts.length} active draft${drafts.length == 1 ? '' : 's'}',
                                    actionText: drafts.isEmpty
                                        ? 'Start inspection'
                                        : 'Open draft',
                                    onTap: () => drafts.isEmpty
                                        ? _startInspection(context)
                                        : Navigator.pushNamed(
                                            context,
                                            Routes.inspectionDetail,
                                            arguments: drafts.first,
                                          ),
                                  ),
                                  _DashboardCard(
                                    title: 'Recent inspections',
                                    subtitle: recent.isEmpty
                                        ? 'No completed inspections yet.'
                                        : recent.first.name,
                                    metadata: recent.isEmpty
                                        ? '0 completed this period'
                                        : '${recent.length} recently completed',
                                    actionText: 'View records',
                                    onTap: () => Navigator.pushNamed(
                                        context, Routes.inspections),
                                  ),
                                ],
                              );
                            },
                          ),
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

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String metadata;
  final String actionText;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.metadata,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Expanded(
            child: Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                    height: 1.4,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            metadata,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary(context),
                ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            actionText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    final store = InspectionStore.instance;
    final actions = ActionStore.instance;
    final schedules = ScheduleStore.instance;

    final totalInsp = store.inspections.length;
    final completedInsp = store.inspections
        .where((i) =>
            i.status == InspectionStatus.completed ||
            i.status == InspectionStatus.submitted)
        .length;
    final openActions = actions.openActions.length;
    final overdueSchedules = schedules.overdueSchedules.length;

    return Row(
      children: [
        Expanded(child: _StatChip(label: 'Inspections', value: '$totalInsp', icon: Icons.assignment_outlined)),
        const SizedBox(width: 8),
        Expanded(child: _StatChip(label: 'Completed', value: '$completedInsp', icon: Icons.check_circle_outline, color: AppColors.success)),
        const SizedBox(width: 8),
        Expanded(
          child: Tappable(
            onTap: () => Navigator.pushNamed(context, Routes.correctiveActions),
            child: _StatChip(
              label: 'Open actions',
              value: '$openActions',
              icon: Icons.warning_amber_outlined,
              color: openActions > 0 ? AppColors.warning : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Tappable(
            onTap: () => Navigator.pushNamed(context, Routes.schedules),
            child: _StatChip(
              label: 'Overdue',
              value: '$overdueSchedules',
              icon: Icons.schedule_outlined,
              color: overdueSchedules > 0 ? AppColors.error : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surfaceColor(context),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: AppColors.textTertiary(context),
            ),
          ),
        ],
      ),
    );
  }
}
