import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class InspectionDetailScreen extends StatelessWidget {
  final Inspection inspection;

  const InspectionDetailScreen({super.key, required this.inspection});

  void _confirmDelete(
      BuildContext context, InspectionStore store, Inspection current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(context),
        title: Text('Delete Inspection',
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600)),
        content: Text(
            'This will permanently delete "${current.name}". This cannot be undone.',
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
                      color: AppColors.error,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      store.deleteInspection(current.id);
      if (context.mounted) {
        AppToast.show(context, 'Inspection deleted');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = InspectionStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final current =
            store.findById(inspection.id) ?? store.ensureInspection(inspection);
        final totalQuestions = current.sections
            .fold<int>(0, (sum, section) => sum + section.questionCount);
        final completedQuestions =
            current.sections.fold<int>(0, (sum, section) {
          final liveCompleted = store.sectionCompletedCount(
            inspectionId: current.id,
            sectionId: section.id,
          );
          final completed = liveCompleted > section.completedCount
              ? liveCompleted
              : section.completedCount;
          return sum + completed;
        });
        final progress =
            totalQuestions == 0 ? 0.0 : completedQuestions / totalQuestions;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: current.name,
                  subtitle: current.siteName,
                  showBackButton: true,
                  actions: [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz,
                          color: AppColors.textSecondary(context)),
                      color: AppColors.surfaceColor(context),
                      onSelected: (value) {
                        if (value == 'archive') {
                          store.archiveInspection(current.id);
                          AppToast.show(context, 'Inspection archived');
                          Navigator.pop(context);
                        } else if (value == 'delete') {
                          _confirmDelete(context, store, current);
                        }
                      },
                      itemBuilder: (_) => [
                        if (current.status != InspectionStatus.archived)
                          PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(Icons.archive_outlined,
                                    size: 18,
                                    color: AppColors.textSecondary(context)),
                                const SizedBox(width: 10),
                                Text('Archive',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.error),
                              const SizedBox(width: 10),
                              Text('Delete',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
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
                          SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current.statusText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: current.statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.x1),
                                Text(
                                  '$completedQuestions of $totalQuestions checks completed',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.x1),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    minHeight: 8,
                                    value: progress,
                                    backgroundColor:
                                        AppColors.borderColor(context),
                                    valueColor: const AlwaysStoppedAnimation(
                                        AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x1),

                          // Meta info
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 14,
                                    color: AppColors.textTertiary(context)),
                                const SizedBox(width: 6),
                                Text(
                                  '${current.date.day}/${current.date.month}/${current.date.year}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary(context),
                                      ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.person_outline,
                                    size: 14,
                                    color: AppColors.textTertiary(context)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    current.inspectorName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary(context),
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.x2),
                          Text(
                            'Sections',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          ...current.sections.map(
                            (section) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.x1),
                              child: Builder(builder: (context) {
                                final liveCompleted =
                                    store.sectionCompletedCount(
                                  inspectionId: current.id,
                                  sectionId: section.id,
                                );
                                final completed =
                                    liveCompleted > section.completedCount
                                        ? liveCompleted
                                        : section.completedCount;
                                return SurfaceCard(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    Routes.sectionDetail,
                                    arguments: {
                                      'section': section,
                                      'inspectionName': current.name,
                                      'inspection': current,
                                    },
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              section.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$completed/${section.questionCount} completed',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.textSecondary(
                                                            context),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        completed >= section.questionCount
                                            ? Icons.check_circle
                                            : Icons.chevron_right,
                                        color: completed >=
                                                section.questionCount
                                            ? AppColors.success
                                            : AppColors.textSecondary(context),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          PrimaryButton(
                            text: current.status ==
                                        InspectionStatus.completed ||
                                    current.status == InspectionStatus.submitted
                                ? 'Open summary'
                                : 'Continue inspection',
                            width: double.infinity,
                            onPressed: () {
                              if (current.status ==
                                      InspectionStatus.completed ||
                                  current.status ==
                                      InspectionStatus.submitted) {
                                Navigator.pushNamed(
                                  context,
                                  Routes.inspectionSummary,
                                  arguments: current,
                                );
                                return;
                              }
                              final nextSection = current.sections.firstWhere(
                                (section) {
                                  final liveCompleted =
                                      store.sectionCompletedCount(
                                    inspectionId: current.id,
                                    sectionId: section.id,
                                  );
                                  final completed =
                                      liveCompleted > section.completedCount
                                          ? liveCompleted
                                          : section.completedCount;
                                  return completed < section.questionCount;
                                },
                                orElse: () => current.sections.first,
                              );
                              Navigator.pushNamed(
                                context,
                                Routes.sectionDetail,
                                arguments: {
                                  'section': nextSection,
                                  'inspectionName': current.name,
                                  'inspection': current,
                                },
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
