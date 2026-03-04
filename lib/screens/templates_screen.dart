import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_safety_inspection/data/mock_data.dart';
import 'package:health_safety_inspection/models/template.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/new_inspection_sheet.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

// ─── Top-level: Templates landing (industry browser + recommended) ─────────

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _countryFilter = ''; // '' = user default, 'All' = show all

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // Default to user's country from onboarding
    final userCountry = AuthService.instance.country;
    _countryFilter = userCountry.isNotEmpty ? userCountry : 'All';
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _userIndustry => AuthService.instance.industry;

  /// Templates visible under the current country filter.
  List<Template> get _filteredTemplates {
    if (_countryFilter == 'All') return MockData.templates;
    return MockData.templates
        .where((t) => t.country == _countryFilter || t.country == 'Global')
        .toList();
  }

  List<Template> get _recommended {
    final base = _filteredTemplates;
    if (_userIndustry.isEmpty) return base.take(6).toList();
    return base
        .where((t) => t.industry == _userIndustry)
        .take(6)
        .toList();
  }

  static const _countryChips = [
    _CountryChip(code: 'All', label: 'All', flag: ''),
    _CountryChip(code: 'Global', label: 'Global', flag: '\ud83c\udf10'),
    _CountryChip(code: 'UK', label: 'UK', flag: '\ud83c\uddec\ud83c\udde7'),
    _CountryChip(code: 'US', label: 'US', flag: '\ud83c\uddfa\ud83c\uddf8'),
    _CountryChip(code: 'AU', label: 'AU', flag: '\ud83c\udde6\ud83c\uddfa'),
    _CountryChip(code: 'CA', label: 'CA', flag: '\ud83c\udde8\ud83c\udde6'),
    _CountryChip(code: 'NZ', label: 'NZ', flag: '\ud83c\uddf3\ud83c\uddff'),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final hasSearch = query.isNotEmpty;

    // If searching, show filtered results instead of browse view
    final searchResults = hasSearch
        ? _filteredTemplates.where((t) {
            return t.name.toLowerCase().contains(query) ||
                t.description.toLowerCase().contains(query) ||
                t.industry.toLowerCase().contains(query) ||
                t.category.toLowerCase().contains(query);
          }).toList()
        : <Template>[];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              const PageHeader(title: 'Templates', showBackButton: true),
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
                        // ── Search bar ──
                        InputField(
                          label: '',
                          hintText: 'Search templates...',
                          controller: _searchController,
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: AppColors.textSecondary(context),
                          ),
                          onChanged: (_) =>
                              setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.x2),

                        // ── Country filter chips ──
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _countryChips.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final chip = _countryChips[i];
                              final isActive = _countryFilter == chip.code;
                              return Tappable(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _countryFilter = chip.code);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.surfaceColor(context),
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.borderColor(context),
                                    ),
                                  ),
                                  child: Text(
                                    chip.flag.isNotEmpty ? '${chip.flag}  ${chip.label}' : chip.label,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x3),

                        if (hasSearch)
                          _SearchResultsView(
                            results: searchResults,
                            query: query,
                          )
                        else ...[
                          // ── Recommended for You ──
                          if (_recommended.isNotEmpty) ...[
                            _SectionTitle(
                              title: 'Recommended for you',
                              subtitle: _userIndustry.isNotEmpty
                                  ? 'Based on your industry: $_userIndustry'
                                  : 'Popular templates to get started',
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            SizedBox(
                              height: 172,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _recommended.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, i) =>
                                    _CompactTemplateCard(
                                  template: _recommended[i],
                                  width: 220,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x4),
                          ],

                          // ── Browse by Industry ──
                          _SectionTitle(
                            title: 'Browse by industry',
                            subtitle:
                                '${Industry.all.length} industries \u00b7 ${_filteredTemplates.length} templates',
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          _IndustryGrid(countryFilter: _countryFilter),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Industry Grid ───────────────────────────────────────────────────────────

class _IndustryGrid extends StatelessWidget {
  final String countryFilter;
  const _IndustryGrid({required this.countryFilter});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        int cols = 1;
        if (w >= 840) {
          cols = 3;
        } else if (w >= 520) {
          cols = 2;
        }
        return GridView.builder(
          itemCount: Industry.all.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, i) =>
              _IndustryCard(industry: Industry.all[i], countryFilter: countryFilter),
        );
      },
    );
  }
}

class _IndustryCard extends StatelessWidget {
  final Industry industry;
  final String countryFilter;
  const _IndustryCard({required this.industry, required this.countryFilter});

  List<Template> get _industryTemplates {
    return MockData.templates.where((t) {
      final matchesIndustry = t.industry == industry.name;
      if (countryFilter == 'All') return matchesIndustry;
      return matchesIndustry && (t.country == countryFilter || t.country == 'Global');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final count = _industryTemplates.length;
    return Tappable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _IndustryDetailScreen(
            industry: industry,
            countryFilter: countryFilter,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.dividerColor(context)),
        ),
        child: Row(
          children: [
            Icon(industry.icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    industry.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count templates',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textTertiary(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Industry Detail Screen ──────────────────────────────────────────────────

class _IndustryDetailScreen extends StatefulWidget {
  final Industry industry;
  final String countryFilter;
  const _IndustryDetailScreen({required this.industry, required this.countryFilter});

  @override
  State<_IndustryDetailScreen> createState() => _IndustryDetailScreenState();
}

class _IndustryDetailScreenState extends State<_IndustryDetailScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<Template> get _industryTemplates {
    final cf = widget.countryFilter;
    return MockData.templates.where((t) {
      final matchesIndustry = t.industry == widget.industry.name;
      if (cf == 'All') return matchesIndustry;
      return matchesIndustry && (t.country == cf || t.country == 'Global');
    }).toList();
  }

  List<String> get _categories =>
      _industryTemplates.map((t) => t.category).toSet().toList()..sort();

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == null
        ? _industryTemplates
        : _industryTemplates
            .where((t) => t.category == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              PageHeader(
                title: widget.industry.name,
                showBackButton: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: AppViewport(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.x3,
                      AppSpacing.x1,
                      AppSpacing.x3,
                      AppSpacing.x4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Industry header ──
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(widget.industry.icon,
                                  size: 22, color: AppColors.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.industry.tagline,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary(context),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_industryTemplates.length} templates available',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.x3),

                        // ── Category pills ──
                        if (_categories.length > 1) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _Pill(
                                  label: 'All',
                                  isSelected: _selectedCategory == null,
                                  onTap: () => setState(
                                      () => _selectedCategory = null),
                                ),
                                const SizedBox(width: 8),
                                ..._categories.map(
                                  (cat) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _Pill(
                                      label: cat,
                                      isSelected: _selectedCategory == cat,
                                      onTap: () => setState(
                                          () => _selectedCategory = cat),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x3),
                        ],

                        // ── Template list ──
                        ...filtered.map((t) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: _TemplateListTile(template: t),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search Results View ─────────────────────────────────────────────────────

class _SearchResultsView extends StatelessWidget {
  final List<Template> results;
  final String query;
  const _SearchResultsView({required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.x4),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderColor(context)),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off,
                size: 28, color: AppColors.textTertiary(context)),
            const SizedBox(height: 8),
            Text(
              'No templates match "$query"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different keyword or browse by industry.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${results.length} result${results.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 12),
        ...results.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TemplateListTile(template: t),
            )),
      ],
    );
  }
}

// ─── Template list tile (used in industry detail + search) ───────────────────

class _TemplateListTile extends StatelessWidget {
  final Template template;
  const _TemplateListTile({required this.template});

  @override
  Widget build(BuildContext context) {
    final minutes = ((template.questionCount / 3).ceil() * 2);
    final ind = Industry.find(template.industry);

    return Tappable(
      onTap: () async {
        final inspection = await showNewInspectionSheet(
          context,
          preselectedTemplate: template,
        );
        if (inspection != null && context.mounted) {
          Navigator.pushNamed(context, Routes.inspectionDetail,
              arguments: inspection);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.dividerColor(context)),
        ),
        child: Row(
          children: [
            Icon(
              ind?.icon ?? Icons.rule_folder_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.description,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary(context),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MetaPill(text: template.category),
                const SizedBox(height: 4),
                Text(
                  '${template.questionCount}q · ~${minutes}m',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary(context),
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

// ─── Compact card for horizontal scroll (recommended) ────────────────────────

class _CompactTemplateCard extends StatelessWidget {
  final Template template;
  final double width;
  const _CompactTemplateCard({required this.template, this.width = 200});

  @override
  Widget build(BuildContext context) {
    final minutes = ((template.questionCount / 3).ceil() * 2);
    final ind = Industry.find(template.industry);

    return Tappable(
      onTap: () async {
        final inspection = await showNewInspectionSheet(
          context,
          preselectedTemplate: template,
        );
        if (inspection != null && context.mounted) {
          Navigator.pushNamed(context, Routes.inspectionDetail,
              arguments: inspection);
        }
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.dividerColor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ind?.icon ?? Icons.rule_folder_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const Spacer(),
                if (template.isFavourite)
                  Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              template.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              template.description,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary(context),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                if (template.country != 'Global')
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      _countryFlag(template.country),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                Expanded(child: _MetaPill(text: template.category)),
                const SizedBox(width: 6),
                Text(
                  '~${minutes}m',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary(context),
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

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _Pill(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 34,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceColor(context),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderColor(context),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String text;
  const _MetaPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.backgroundColor(context),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _CountryChip {
  final String code;
  final String label;
  final String flag;
  const _CountryChip({required this.code, required this.label, required this.flag});
}

String _countryFlag(String code) {
  switch (code) {
    case 'UK': return '\ud83c\uddec\ud83c\udde7';
    case 'US': return '\ud83c\uddfa\ud83c\uddf8';
    case 'AU': return '\ud83c\udde6\ud83c\uddfa';
    default: return '\ud83c\udf10';
  }
}
