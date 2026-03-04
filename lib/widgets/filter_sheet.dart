import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class FilterSheet extends StatefulWidget {
  final String? selectedStatus;
  final String? selectedSite;
  final ValueChanged<Map<String, String?>> onApply;

  const FilterSheet({
    super.key,
    this.selectedStatus,
    this.selectedSite,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? _status;
  late String? _site;

  static const _statuses = [
    'All',
    'Draft',
    'In Progress',
    'Completed',
    'Submitted'
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _site = widget.selectedSite;
  }

  @override
  Widget build(BuildContext context) {
    final sites = SiteStore.instance.sites.map((s) => s.name).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(color: AppColors.borderColor(context), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor(context),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "Filter inspections",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  Tappable(
                    onTap: () => setState(() {
                      _status = null;
                      _site = null;
                    }),
                    child: Text(
                      "Reset",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "STATUS",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statuses.map((status) {
                  final isSelected =
                      _status == status || (_status == null && status == 'All');
                  return Tappable(
                    onTap: () => setState(() {
                      _status = status == 'All' ? null : status;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderColor(context),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                "SITE",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSiteChip(context, 'All sites', null),
                  ...sites.map((site) => _buildSiteChip(context, site, site)),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: "Apply filters",
                onPressed: () {
                  widget.onApply({'status': _status, 'site': _site});
                },
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                text: "Cancel",
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteChip(BuildContext context, String label, String? value) {
    final isSelected = _site == value;
    return Tappable(
      onTap: () => setState(() => _site = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color:
                isSelected ? AppColors.primary : AppColors.borderColor(context),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}
