import 'package:flutter/material.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/site_form_sheet.dart';
import 'package:health_safety_inspection/widgets/site_row.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/empty_state.dart';

class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key});

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddSite() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SiteFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = SiteStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final sites = store.sites.where((site) {
          final query = _searchController.text.toLowerCase();
          if (query.isEmpty) return true;
          return site.name.toLowerCase().contains(query) ||
              site.address.toLowerCase().contains(query);
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: 'Sites',
                  showMenuButton: true,
                  actions: [
                    PrimaryButton(
                      text: 'Add site',
                      height: 40,
                      onPressed: _openAddSite,
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
                        children: [
                          InputField(
                            label: '',
                            hintText: 'Search sites…',
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 18,
                              color: AppColors.textTertiary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          SurfaceCard(
                            padding: EdgeInsets.zero,
                            child: sites.isEmpty
                                ? Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.x4),
                                    child: EmptyState(
                                      icon: Icons.location_on_outlined,
                                      title: 'No sites yet',
                                      description:
                                          'Tap "Add site" to create your first inspection site.',
                                    ),
                                  )
                                : Column(
                                    children:
                                        sites.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final site = entry.value;
                                      return SiteRow(
                                        site: site,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          Routes.siteDetail,
                                          arguments: site,
                                        ),
                                        showDivider:
                                            index < sites.length - 1,
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
