import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/models/site.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/section_block.dart';
import 'package:health_safety_inspection/widgets/inspection_row.dart';
import 'package:health_safety_inspection/widgets/empty_state.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';
import 'package:health_safety_inspection/widgets/site_form_sheet.dart';
import 'package:health_safety_inspection/routes.dart';

class SiteDetailScreen extends StatefulWidget {
  final Site site;

  const SiteDetailScreen({super.key, required this.site});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  late Site _site;

  @override
  void initState() {
    super.initState();
    _site = widget.site;
  }

  void _openEdit() async {
    final result = await showModalBottomSheet<Site>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SiteFormSheet(site: _site),
    );
    if (result != null && mounted) {
      setState(() => _site = result);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(ctx),
        title: Text('Delete site?',
            style: Theme.of(ctx)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently remove "${_site.name}" and cannot be undone.',
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary(ctx))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              SiteStore.instance.deleteSite(_site.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = InspectionStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final allSiteInspections = store.inspectionsForSite(_site.name);
        final siteInspections = allSiteInspections.take(3).toList();
        final inspectionCount = allSiteInspections.length;
        final latestInspectionDate = allSiteInspections.isEmpty
            ? null
            : (allSiteInspections..sort((a, b) => b.date.compareTo(a.date)))
                .first
                .date;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: _site.name,
                  showBackButton: true,
                  actions: [
                    Tappable(
                      onTap: _confirmDelete,
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.delete_outline,
                            size: 20, color: AppColors.error),
                      ),
                    ),
                    Tappable(
                      onTap: _openEdit,
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Edit",
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                        ),
                      ),
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
                          // Site info card
                          SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(
                                    context, "Address", _site.address),
                                const SizedBox(height: 8),
                                _buildDetailRow(context, "Contact",
                                    _site.contactName ?? "—"),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                    context, "Phone", _site.contactPhone ?? "—"),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                    context, "Inspections", '$inspectionCount'),
                                if (latestInspectionDate != null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    context,
                                    "Last inspection",
                                    "${latestInspectionDate.day}/${latestInspectionDate.month}/${latestInspectionDate.year}",
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          // Recent inspections
                          SectionBlock(
                            title: "RECENT INSPECTIONS",
                            margin: EdgeInsets.zero,
                            child: siteInspections.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: EmptyState(
                                      icon: Icons.assignment_outlined,
                                      title: "No inspections yet",
                                      description:
                                          "Start an inspection for this site",
                                    ),
                                  )
                                : Column(
                                    children: siteInspections
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final inspection = entry.value;
                                      return InspectionRow(
                                        inspection: inspection,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          Routes.inspectionDetail,
                                          arguments: inspection,
                                        ),
                                        showDivider:
                                            index < siteInspections.length - 1,
                                      );
                                    }).toList(),
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          // Notes section
                          SectionBlock(
                            title: "NOTES",
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                width: double.infinity,
                                constraints:
                                    const BoxConstraints(minHeight: 80),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColor(context),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: AppColors.borderColor(context),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _site.notes.isNotEmpty
                                      ? _site.notes
                                      : "No notes — tap Edit to add.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: _site.notes.isNotEmpty
                                            ? AppColors.textPrimary(context)
                                            : AppColors.textTertiary(context),
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x4),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}
