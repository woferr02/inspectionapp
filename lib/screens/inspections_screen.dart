import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/services/feature_gate.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/new_inspection_sheet.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class InspectionsScreen extends StatefulWidget {
  const InspectionsScreen({super.key});

  @override
  State<InspectionsScreen> createState() => _InspectionsScreenState();
}

class _InspectionsScreenState extends State<InspectionsScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'All';
  String _siteFilter = 'All';
  String _sortBy = 'Newest';

  void _showToast(String message) {
    AppToast.show(context, message);
  }

  void _startInspection() async {
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
    if (inspection != null && mounted) {
      Navigator.pushNamed(
        context,
        Routes.inspectionDetail,
        arguments: inspection,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = InspectionStore.instance;
    final statusOptions = <String>[
      'All',
      'Draft',
      'In Progress',
      'Completed',
      'Submitted',
      'Archived'
    ];
    final sortOptions = <String>['Newest', 'Oldest', 'Score'];
    final siteOptions = <String>[
      'All',
      ...SiteStore.instance.sites.map((site) => site.name)
    ];

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final results = store.inspections.where((item) {
          final query = _searchController.text.toLowerCase();
          final matchesSearch = query.isEmpty ||
              item.name.toLowerCase().contains(query) ||
              item.siteName.toLowerCase().contains(query);
          final matchesStatus =
              _statusFilter == 'All' || item.statusText == _statusFilter;
          final matchesSite =
              _siteFilter == 'All' || item.siteName == _siteFilter;
          return matchesSearch && matchesStatus && matchesSite;
        }).toList()
          ..sort((a, b) {
            switch (_sortBy) {
              case 'Oldest':
                return a.date.compareTo(b.date);
              case 'Score':
                return (b.score ?? -1).compareTo(a.score ?? -1);
              case 'Newest':
              default:
                return b.date.compareTo(a.date);
            }
          });

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: 'Inspection Records',
                  showMenuButton: true,
                  actions: [
                    PrimaryButton(
                      text: 'New',
                      height: 40,
                      onPressed: _startInspection,
                    ),
                  ],
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
                        children: [
                          InputField(
                            label: 'Search records',
                            hintText: 'Inspection, site, or keyword',
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            suffixIcon: Icon(
                              Icons.search,
                              size: 18,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 720) {
                                return Column(
                                  children: [
                                    _FilterField(
                                      label: 'Status',
                                      value: _statusFilter,
                                      items: statusOptions,
                                      onChanged: (value) =>
                                          setState(() => _statusFilter = value),
                                    ),
                                    const SizedBox(height: AppSpacing.x2),
                                    _FilterField(
                                      label: 'Site',
                                      value: _siteFilter,
                                      items: siteOptions,
                                      onChanged: (value) =>
                                          setState(() => _siteFilter = value),
                                    ),
                                    const SizedBox(height: AppSpacing.x2),
                                    _FilterField(
                                      label: 'Sort',
                                      value: _sortBy,
                                      items: sortOptions,
                                      onChanged: (value) =>
                                          setState(() => _sortBy = value),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: _FilterField(
                                      label: 'Status',
                                      value: _statusFilter,
                                      items: statusOptions,
                                      onChanged: (value) =>
                                          setState(() => _statusFilter = value),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.x2),
                                  Expanded(
                                    child: _FilterField(
                                      label: 'Site',
                                      value: _siteFilter,
                                      items: siteOptions,
                                      onChanged: (value) =>
                                          setState(() => _siteFilter = value),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.x2),
                                  Expanded(
                                    child: _FilterField(
                                      label: 'Sort',
                                      value: _sortBy,
                                      items: sortOptions,
                                      onChanged: (value) =>
                                          setState(() => _sortBy = value),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          SurfaceCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.x2,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${results.length} records',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary(
                                                    context),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        'Quick actions',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textTertiary(
                                                  context),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    height: 1,
                                    color: AppColors.dividerColor(context)),
                                if (results.isEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.x4),
                                    child: Text(
                                      'No records match current filters.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary(
                                                context),
                                          ),
                                    ),
                                  )
                                else
                                  ...results.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return Column(
                                      children: [
                                        _RecordRow(
                                          inspection: item,
                                          onViewReport: () =>
                                              Navigator.pushNamed(
                                            context,
                                            Routes.inspectionSummary,
                                            arguments: item,
                                          ),
                                          onShare: () {
                                            _showToast('Share link copied');
                                          },
                                          onDelete: () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                backgroundColor: AppColors.surfaceColor(context),
                                                title: Text('Delete Inspection',
                                                    style: TextStyle(
                                                        color: AppColors.textPrimary(context),
                                                        fontWeight: FontWeight.w600)),
                                                content: Text(
                                                    'This will permanently delete this inspection and all its data. This cannot be undone.',
                                                    style: TextStyle(
                                                        color: AppColors.textSecondary(context))),
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
                                              InspectionStore.instance
                                                  .deleteInspection(item.id);
                                              if (context.mounted) {
                                                AppToast.show(context,
                                                    'Inspection deleted');
                                              }
                                            }
                                          },
                                        ),
                                        if (index < results.length - 1)
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: AppSpacing.x2),
                                            height: 1,
                                            color:
                                                AppColors.dividerColor(context),
                                          ),
                                      ],
                                    );
                                  }),
                              ],
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

class _FilterField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _FilterField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderColor(context)),
            color: AppColors.surfaceColor(context),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceColor(context),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textSecondary(context),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary(context),
              ),
              items: items
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (next) {
                if (next != null) onChanged(next);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordRow extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onViewReport;
  final VoidCallback onShare;
  final VoidCallback? onDelete;

  const _RecordRow({
    required this.inspection,
    required this.onViewReport,
    required this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        '${inspection.date.day}/${inspection.date.month}/${inspection.date.year}';

    return Tappable(
      onTap: () => Navigator.pushNamed(
        context,
        Routes.inspectionDetail,
        arguments: inspection,
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inspection.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${inspection.siteName} · $date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    inspection.score == null ? '—' : '${inspection.score}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: inspection.score == null
                              ? AppColors.textTertiary(context)
                              : inspection.statusColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(inspection: inspection),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuickAction(
                        icon: Icons.description_outlined, onTap: onViewReport),
                    const SizedBox(width: 8),
                    _QuickAction(icon: Icons.share_outlined, onTap: onShare),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      _QuickAction(
                        icon: Icons.delete_outline,
                        onTap: onDelete!,
                        color: AppColors.error,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _QuickAction({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor(context)),
        ),
        child: Icon(icon, size: 18, color: color ?? AppColors.textSecondary(context)),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Inspection inspection;

  const _StatusBadge({required this.inspection});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: inspection.statusColor.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        inspection.statusText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: inspection.statusColor,
            ),
      ),
    );
  }
}
