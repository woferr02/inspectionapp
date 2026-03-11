import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/services/feature_gate.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/new_inspection_sheet.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _startInspection(BuildContext context) async {
    // Enforce free-tier inspection limit
    final limit = FeatureGate.maxInspections;
    if (limit != null) {
      final active = InspectionStore.instance.inspections
          .where((i) => i.status != InspectionStatus.archived)
          .length;
      if (active >= limit) {
        FeatureGate.guardOr(
            context, Feature.unlimitedInspections, () {});
        return;
      }
    }

    final inspection = await showNewInspectionSheet(context);
    if (inspection != null && context.mounted) {
      Navigator.pushNamed(
        context,
        Routes.inspectionDetail,
        arguments: inspection,
      );
    }
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
                const PageHeader(title: 'Home', showMenuButton: true),
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
                          // ── Primary CTA ──
                          PrimaryButton(
                            text: 'Start inspection',
                            width: double.infinity,
                            onPressed: () => _startInspection(context),
                          ),

                          // ── In-progress / drafts ──
                          if (drafts.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.x2),
                            _SectionLabel(
                              text: 'In progress',
                              trailing: '${drafts.length}',
                            ),
                            const SizedBox(height: 6),
                            SurfaceCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: drafts.take(5).toList().asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final d = entry.value;
                                  return Column(
                                    children: [
                                      _InspectionRow(
                                        inspection: d,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          Routes.inspectionDetail,
                                          arguments: d,
                                        ),
                                      ),
                                      if (index < drafts.take(5).length - 1)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          child: Container(height: 1, color: AppColors.dividerColor(context)),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            if (drafts.length > 5)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Tappable(
                                  onTap: () => Navigator.pushNamed(context, Routes.inspections),
                                  child: Text(
                                    'View all ${drafts.length}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],

                          // ── Recent completions ──
                          if (recent.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.x2),
                            _SectionLabel(
                              text: 'Recent',
                              trailing: 'All',
                              onTrailingTap: () => Navigator.pushNamed(context, Routes.inspections),
                            ),
                            const SizedBox(height: 6),
                            SurfaceCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: recent.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return Column(
                                    children: [
                                      _InspectionRow(
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
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          child: Container(height: 1, color: AppColors.dividerColor(context)),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          // ── Empty state ──
                          if (drafts.isEmpty && recent.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
                              child: Center(
                                child: Text(
                                  'No inspections yet — tap above to start.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textTertiary(context),
                                  ),
                                ),
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

// ─── Section label with optional trailing link ───
class _SectionLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const _SectionLabel({required this.text, this.trailing, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.textTertiary(context),
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Tappable(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Flat inspection row (no card wrapping) ───
class _InspectionRow extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onTap;
  final bool showScore;

  const _InspectionRow({
    required this.inspection,
    required this.onTap,
    this.showScore = false,
  });

  @override
  Widget build(BuildContext context) {
    final date = '${inspection.date.day}/${inspection.date.month}/${inspection.date.year}';
    return Tappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: inspection.statusColor,
              ),
            ),
            const SizedBox(width: 12),
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
              Text(
                '${inspection.score}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: inspection.statusColor,
                ),
              ),
            ] else
              Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textTertiary(context),
              ),
          ],
        ),
      ),
    );
  }
}
