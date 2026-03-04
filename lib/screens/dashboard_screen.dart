import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:intl/intl.dart';
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
            .toList();
        final recent = store.inspections
            .where((i) =>
                i.status == InspectionStatus.completed ||
                i.status == InspectionStatus.submitted)
            .take(5)
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
                      text: 'New inspection',
                      height: 36,
                      onPressed: () => _startInspection(context),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: AppViewport(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x2,
                        AppSpacing.x2,
                        AppSpacing.x2,
                        AppSpacing.x3,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Compact greeting row ──
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  '$_greeting${_firstName.isNotEmpty ? ', $_firstName' : ''}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat('d MMM yyyy').format(DateTime.now()),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x2),

                          // ── KPI stat chips ──
                          const _StatRow(),
                          const SizedBox(height: AppSpacing.x2),

                          // ── Drafts / in-progress section ──
                          if (drafts.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'In progress',
                              trailing: '${drafts.length}',
                            ),
                            const SizedBox(height: 8),
                            ...drafts.take(3).map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _CompactInspectionTile(
                                inspection: d,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  Routes.inspectionDetail,
                                  arguments: d,
                                ),
                              ),
                            )),
                            if (drafts.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 4),
                                child: Tappable(
                                  onTap: () => Navigator.pushNamed(context, Routes.inspections),
                                  child: Text(
                                    'View all ${drafts.length} drafts',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.x2),
                          ],

                          // ── Quick actions row ──
                          _SectionHeader(title: 'Quick actions'),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 600;
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _QuickActionChip(
                                    icon: Icons.add_circle_outline,
                                    label: 'New inspection',
                                    onTap: () => _startInspection(context),
                                    width: isWide ? null : (constraints.maxWidth - 8) / 2,
                                  ),
                                  _QuickActionChip(
                                    icon: Icons.description_outlined,
                                    label: 'Templates',
                                    onTap: () => Navigator.pushNamed(context, Routes.templates),
                                    width: isWide ? null : (constraints.maxWidth - 8) / 2,
                                  ),
                                  _QuickActionChip(
                                    icon: Icons.qr_code_scanner_outlined,
                                    label: 'QR check-in',
                                    onTap: () => Navigator.pushNamed(context, Routes.qrScanner),
                                    width: isWide ? null : (constraints.maxWidth - 8) / 2,
                                  ),
                                  _QuickActionChip(
                                    icon: Icons.checklist_outlined,
                                    label: 'Actions',
                                    badge: ActionStore.instance.openActions.isNotEmpty,
                                    onTap: () => Navigator.pushNamed(context, Routes.correctiveActions),
                                    width: isWide ? null : (constraints.maxWidth - 8) / 2,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.x2),

                          // ── Recent completions ──
                          _SectionHeader(
                            title: 'Recent',
                            trailing: recent.isEmpty ? null : 'View all',
                            onTrailingTap: recent.isEmpty ? null : () => Navigator.pushNamed(context, Routes.inspections),
                          ),
                          const SizedBox(height: 8),
                          if (recent.isEmpty)
                            SurfaceCard(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              child: Center(
                                child: Text(
                                  'No completed inspections yet',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textTertiary(context),
                                  ),
                                ),
                              ),
                            )
                          else
                            SurfaceCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: recent.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return Column(
                                    children: [
                                      _CompactInspectionTile(
                                        inspection: item,
                                        showScore: true,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          Routes.inspectionDetail,
                                          arguments: item,
                                        ),
                                      ),
                                      if (index < recent.length - 1)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Container(height: 1, color: AppColors.dividerColor(context)),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
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

// ─── Section header with optional trailing link ───
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const _SectionHeader({required this.title, this.trailing, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Tappable(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Compact inspection row for dashboard lists ───
class _CompactInspectionTile extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onTap;
  final bool showScore;

  const _CompactInspectionTile({
    required this.inspection,
    required this.onTap,
    this.showScore = false,
  });

  @override
  Widget build(BuildContext context) {
    final date = '${inspection.date.day}/${inspection.date.month}/${inspection.date.year}';
    return Tappable(
      onTap: onTap,
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: inspection.statusColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                inspection.status == InspectionStatus.completed ||
                        inspection.status == InspectionStatus.submitted
                    ? Icons.check_circle_outline
                    : Icons.edit_outlined,
                size: 16,
                color: inspection.statusColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inspection.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${inspection.siteName} · $date',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showScore && inspection.score != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: inspection.statusColor.withValues(alpha: 0.1),
                ),
                child: Text(
                  '${inspection.score}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: inspection.statusColor,
                  ),
                ),
              ),
            ],
            if (!showScore)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textTertiary(context),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick action chip ───
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool badge;
  final double? width;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final child = Tappable(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.surfaceColor(context),
          border: Border.all(color: AppColors.borderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return child;
  }
}

// ─── KPI stat row ───
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
        Expanded(child: _StatChip(label: 'Total', value: '$totalInsp', icon: Icons.assignment_outlined)),
        const SizedBox(width: 6),
        Expanded(child: _StatChip(label: 'Done', value: '$completedInsp', icon: Icons.check_circle_outline, color: AppColors.success)),
        const SizedBox(width: 6),
        Expanded(
          child: Tappable(
            onTap: () => Navigator.pushNamed(context, Routes.correctiveActions),
            child: _StatChip(
              label: 'Actions',
              value: '$openActions',
              icon: Icons.warning_amber_outlined,
              color: openActions > 0 ? AppColors.warning : null,
            ),
          ),
        ),
        const SizedBox(width: 6),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.surfaceColor(context),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: c),
              const SizedBox(width: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c,
                ),
              ),
            ],
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
