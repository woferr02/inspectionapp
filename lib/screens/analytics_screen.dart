import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/services/action_store.dart';
import 'package:health_safety_inspection/services/schedule_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = InspectionStore.instance;
    final actionStore = ActionStore.instance;
    final scheduleStore = ScheduleStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final all = store.inspections;
        final completed = all.where((i) =>
            i.status == InspectionStatus.completed ||
            i.status == InspectionStatus.submitted);
        final avgScore = completed.isNotEmpty
            ? (completed
                    .where((i) => i.score != null)
                    .map((i) => i.score!)
                    .fold(0, (a, b) => a + b) /
                completed.where((i) => i.score != null).length)
            : 0.0;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                const PageHeader(
                  title: 'Analytics',
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
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
                          // ── Stat cards row ──
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 600;
                              if (isMobile) {
                                return Column(
                                  children: [
                                    Row(children: [
                                      Expanded(child: _StatCard(
                                        title: 'Total Inspections',
                                        value: '${all.length}',
                                        icon: Icons.assignment_outlined,
                                        color: AppColors.primary,
                                      )),
                                      const SizedBox(width: 12),
                                      Expanded(child: _StatCard(
                                        title: 'Completed',
                                        value: '${completed.length}',
                                        icon: Icons.check_circle_outline,
                                        color: AppColors.success,
                                      )),
                                    ]),
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      Expanded(child: _StatCard(
                                        title: 'Avg Score',
                                        value: '${avgScore.round()}%',
                                        icon: Icons.speed_outlined,
                                        color: AppColors.warning,
                                      )),
                                      const SizedBox(width: 12),
                                      Expanded(child: AnimatedBuilder(
                                        animation: actionStore,
                                        builder: (ctx, _) => _StatCard(
                                          title: 'Open Actions',
                                          value: '${actionStore.openActions.length}',
                                          icon: Icons.warning_amber_outlined,
                                          color: AppColors.error,
                                        ),
                                      )),
                                    ]),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: _StatCard(
                                    title: 'Total Inspections',
                                    value: '${all.length}',
                                    icon: Icons.assignment_outlined,
                                    color: AppColors.primary,
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(child: _StatCard(
                                    title: 'Completed',
                                    value: '${completed.length}',
                                    icon: Icons.check_circle_outline,
                                    color: AppColors.success,
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(child: _StatCard(
                                    title: 'Avg Score',
                                    value: '${avgScore.round()}%',
                                    icon: Icons.speed_outlined,
                                    color: AppColors.warning,
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(child: AnimatedBuilder(
                                    animation: actionStore,
                                    builder: (ctx, _) => _StatCard(
                                      title: 'Open Actions',
                                      value: '${actionStore.openActions.length}',
                                      icon: Icons.warning_amber_outlined,
                                      color: AppColors.error,
                                    ),
                                  )),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // ── Compliance Trend ──
                          SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Compliance Score Trend',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Average score over recent inspections',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 200,
                                  child: _ComplianceChart(
                                    inspections: completed.toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Status Distribution ──
                          SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inspection Status',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 200,
                                  child: _StatusPieChart(
                                    inspections: all.toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Section Scores ──
                          SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Section Performance',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Average score by section across all inspections',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _SectionPerformance(
                                  inspections: completed.toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Upcoming Schedules ──
                          AnimatedBuilder(
                            animation: scheduleStore,
                            builder: (ctx, _) {
                              final overdue = scheduleStore.overdueSchedules;
                              final upcoming = scheduleStore.activeSchedules
                                  .where((s) => !s.isOverdue)
                                  .take(5)
                                  .toList();
                              if (overdue.isEmpty && upcoming.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SurfaceCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Schedule Overview',
                                      style: Theme.of(ctx)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 12),
                                    if (overdue.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded,
                                              size: 16, color: AppColors.error),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${overdue.length} overdue schedule${overdue.length == 1 ? '' : 's'}',
                                            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    ...upcoming.map((s) => Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${s.templateName} — ${s.siteName}',
                                                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                                    color: AppColors.textPrimary(ctx),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                'in ${s.daysUntilDue}d',
                                                style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                                                  color: AppColors.textSecondary(ctx),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
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

// ── Stat card widget ──
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: color.withValues(alpha: 0.1),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compliance trend line chart ──
class _ComplianceChart extends StatelessWidget {
  final List<Inspection> inspections;

  const _ComplianceChart({required this.inspections});

  @override
  Widget build(BuildContext context) {
    final scored =
        inspections.where((i) => i.score != null).toList().reversed.take(12).toList();
    if (scored.isEmpty) {
      return Center(
        child: Text(
          'No scored inspections yet',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary(context)),
        ),
      );
    }

    final spots = scored.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.score!.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.borderColor(context),
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 25,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: AppColors.textTertiary(context),
                ),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: AppColors.surfaceColor(context),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots
                .map((spot) => LineTooltipItem(
                      '${spot.y.toInt()}%',
                      Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ── Status pie chart ──
class _StatusPieChart extends StatelessWidget {
  final List<Inspection> inspections;

  const _StatusPieChart({required this.inspections});

  @override
  Widget build(BuildContext context) {
    if (inspections.isEmpty) {
      return Center(
        child: Text(
          'No inspections yet',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary(context)),
        ),
      );
    }

    final draft =
        inspections.where((i) => i.status == InspectionStatus.draft).length;
    final inProgress = inspections
        .where((i) => i.status == InspectionStatus.inProgress)
        .length;
    final completed = inspections
        .where((i) => i.status == InspectionStatus.completed)
        .length;
    final submitted = inspections
        .where((i) => i.status == InspectionStatus.submitted)
        .length;

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                if (draft > 0)
                  PieChartSectionData(
                    value: draft.toDouble(),
                    color: AppColors.warning,
                    radius: 24,
                    title: '',
                  ),
                if (inProgress > 0)
                  PieChartSectionData(
                    value: inProgress.toDouble(),
                    color: AppColors.primary,
                    radius: 24,
                    title: '',
                  ),
                if (completed > 0)
                  PieChartSectionData(
                    value: completed.toDouble(),
                    color: AppColors.success,
                    radius: 24,
                    title: '',
                  ),
                if (submitted > 0)
                  PieChartSectionData(
                    value: submitted.toDouble(),
                    color: AppColors.info,
                    radius: 24,
                    title: '',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(color: AppColors.warning, label: 'Draft', count: draft),
            const SizedBox(height: 6),
            _LegendItem(color: AppColors.primary, label: 'In Progress', count: inProgress),
            const SizedBox(height: 6),
            _LegendItem(color: AppColors.success, label: 'Completed', count: completed),
            const SizedBox(height: 6),
            _LegendItem(color: AppColors.info, label: 'Submitted', count: submitted),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

// ── Section performance bars ──
class _SectionPerformance extends StatelessWidget {
  final List<Inspection> inspections;

  const _SectionPerformance({required this.inspections});

  @override
  Widget build(BuildContext context) {
    // Collect average scores per section name
    final sectionMap = <String, List<int>>{};
    for (final inspection in inspections) {
      for (final section in inspection.sections) {
        if (section.score != null) {
          sectionMap.putIfAbsent(section.name, () => []).add(section.score!);
        }
      }
    }

    if (sectionMap.isEmpty) {
      return Text(
        'No section scores available yet',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary(context)),
      );
    }

    final entries = sectionMap.entries.toList()
      ..sort((a, b) {
        final avgA = a.value.reduce((x, y) => x + y) / a.value.length;
        final avgB = b.value.reduce((x, y) => x + y) / b.value.length;
        return avgA.compareTo(avgB);
      });

    return Column(
      children: entries.map((entry) {
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: avg / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.borderColor(context),
                    valueColor: AlwaysStoppedAnimation(
                      avg >= 80
                          ? AppColors.success
                          : avg >= 60
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  '${avg.round()}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
