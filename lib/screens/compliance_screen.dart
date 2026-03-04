import 'package:flutter/material.dart';
import 'package:health_safety_inspection/models/regulation.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

/// Shows the regulatory framework reference library with filtering and detail views.
class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});

  @override
  State<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends State<ComplianceScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  static const _categories = [
    'All',
    'Workplace Safety',
    'Construction',
    'Environmental',
    'Quality',
    'Fire Safety',
    'Electrical',
    'Chemical',
    'Working at Height',
    'Equipment',
    'Mining',
    'Transportation',
    'Food Safety',
    'Recordkeeping',
  ];

  List<Regulation> get _filtered {
    var list = Regulations.all;
    if (_selectedCategory != 'All') {
      list = Regulations.forCategory(_selectedCategory);
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.code.toLowerCase().contains(q) ||
              r.description.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(
              title: 'Compliance',
              showBackButton: true,
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: AppViewport(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x3, AppSpacing.x2, AppSpacing.x3, AppSpacing.x4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search
                      InputField(
                        label: 'Search',
                        hintText: 'Search regulations…',
                        onChanged: (v) => setState(() => _searchQuery = v),
                        prefixIcon: Icon(Icons.search,
                            size: 18, color: AppColors.textTertiary(context)),
                      ),
                      const SizedBox(height: 10),

                      // Category chips
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemCount: _categories.length,
                          itemBuilder: (_, i) {
                            final cat = _categories[i];
                            final selected = cat == _selectedCategory;
                            return Tappable(
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.surfaceColor(context),
                                  border: selected
                                      ? null
                                      : Border.all(
                                          color: AppColors.borderColor(context)),
                                ),
                                child: Text(
                                  cat,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight:
                                        selected ? FontWeight.w600 : FontWeight.w400,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondary(context),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Results
                      if (filtered.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Text(
                              'No matching regulations',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary(context),
                              ),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((reg) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _RegulationCard(regulation: reg),
                            )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegulationCard extends StatelessWidget {
  final Regulation regulation;
  const _RegulationCard({required this.regulation});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => _showDetail(context, regulation),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    regulation.code,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    regulation.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textTertiary(context)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              regulation.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: regulation.categories.map((c) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.textTertiary(context).withValues(alpha: 0.08),
                  ),
                  child: Text(
                    c,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Regulation reg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceColor(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scroll) {
            return SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        color: AppColors.borderColor(ctx),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      reg.code,
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reg.name,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reg.authority,
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reg.description,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary(ctx),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Key requirements
                  Text(
                    'Key Requirements',
                    style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...reg.keyRequirements.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('•  ',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                            Expanded(
                              child: Text(
                                r,
                                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textPrimary(ctx),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Categories
                  Text(
                    'Applicable categories',
                    style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: reg.categories.map((c) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                        child: Text(
                          c,
                          style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
