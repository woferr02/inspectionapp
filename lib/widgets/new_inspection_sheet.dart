import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/data/mock_data.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/models/site.dart';
import 'package:health_safety_inspection/models/template.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

/// Opens the "Start New Inspection" bottom sheet.
/// Returns the created [Inspection] or null if cancelled.
/// If [preselectedTemplate] is provided the template picker is pre-filled.
Future<Inspection?> showNewInspectionSheet(
  BuildContext context, {
  Template? preselectedTemplate,
}) {
  return showModalBottomSheet<Inspection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NewInspectionSheet(preselectedTemplate: preselectedTemplate),
  );
}

class _NewInspectionSheet extends StatefulWidget {
  const _NewInspectionSheet({this.preselectedTemplate});
  final Template? preselectedTemplate;

  @override
  State<_NewInspectionSheet> createState() => _NewInspectionSheetState();
}

class _NewInspectionSheetState extends State<_NewInspectionSheet> {
  Template? _selectedTemplate;
  Site? _selectedSite;
  final _nameController = TextEditingController();
  final _templateSearchController = TextEditingController();
  bool _showTemplatePicker = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedTemplate != null) {
      _selectedTemplate = widget.preselectedTemplate;
      _nameController.text = widget.preselectedTemplate!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _templateSearchController.dispose();
    super.dispose();
  }

  void _selectTemplate(Template template) {
    setState(() {
      _selectedTemplate = template;
      _showTemplatePicker = false;
      if (_nameController.text.isEmpty) {
        _nameController.text = template.name;
      }
    });
  }

  void _start() {
    if (_selectedTemplate == null) return;

    final inspection = InspectionStore.instance.createFromTemplate(
      _selectedTemplate!,
      site: _selectedSite,
      customName:
          _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
    );
    Navigator.pop(context, inspection);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start New Inspection',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose a template and site to begin.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.backgroundColor(context),
                        border: Border.all(color: AppColors.borderColor(context)),
                      ),
                      child: Icon(Icons.close, size: 16,
                          color: AppColors.textSecondary(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Template selector ──
              Text(
                'Template',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              if (_showTemplatePicker) ...[
                _TemplatePickerInline(
                  searchController: _templateSearchController,
                  onSelected: _selectTemplate,
                ),
                const SizedBox(height: 8),
                Tappable(
                  onTap: () => setState(() => _showTemplatePicker = false),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ] else
                Tappable(
                  onTap: () => setState(() => _showTemplatePicker = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedTemplate == null
                            ? AppColors.borderColor(context)
                            : AppColors.primary.withValues(alpha: 0.4),
                      ),
                      color: _selectedTemplate == null
                          ? AppColors.backgroundColor(context)
                          : AppColors.primary.withValues(alpha: 0.04),
                    ),
                    child: _selectedTemplate == null
                        ? Row(
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 18,
                                  color: AppColors.textTertiary(context)),
                              const SizedBox(width: 10),
                              Text(
                                'Select a template...',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textTertiary(context),
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18,
                                  color: AppColors.textTertiary(context)),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedTemplate!.name,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${_selectedTemplate!.industry} · ${_selectedTemplate!.questionCount} checks',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color:
                                            AppColors.textSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.swap_horiz_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary(context)),
                            ],
                          ),
                  ),
                ),
              const SizedBox(height: 20),

              // ── Site selector ──
              Text(
                'Site',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderColor(context)),
                  color: AppColors.backgroundColor(context),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Site>(
                    value: _selectedSite,
                    isExpanded: true,
                    hint: Text(
                      'Select a site (optional)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary(context),
                      ),
                    ),
                    dropdownColor: AppColors.surfaceColor(context),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.textSecondary(context)),
                    items: SiteStore.instance.sites
                        .map(
                          (site) => DropdownMenuItem<Site>(
                            value: site,
                            child: Text(
                              site.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (site) => setState(() => _selectedSite = site),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Inspection name ──
              InputField(
                label: 'Inspection name',
                hintText: 'Auto-filled from template',
                controller: _nameController,
              ),
              const SizedBox(height: 28),

              // ── Start button ──
              Opacity(
                opacity: _selectedTemplate == null ? 0.4 : 1.0,
                child: IgnorePointer(
                  ignoring: _selectedTemplate == null,
                  child: PrimaryButton(
                    text: _selectedTemplate == null
                        ? 'Select a template to start'
                        : 'Start Inspection',
                    width: double.infinity,
                    onPressed: _start,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline template search + list used inside the sheet.
class _TemplatePickerInline extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<Template> onSelected;

  const _TemplatePickerInline({
    required this.searchController,
    required this.onSelected,
  });

  @override
  State<_TemplatePickerInline> createState() => _TemplatePickerInlineState();
}

class _TemplatePickerInlineState extends State<_TemplatePickerInline> {
  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearch);
  }

  void _onSearch() => setState(() {});

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearch);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.searchController.text.toLowerCase();
    final results = MockData.templates.where((t) {
      if (query.isEmpty) return true;
      return t.name.toLowerCase().contains(query) ||
          t.industry.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query);
    }).take(8).toList();

    return Column(
      children: [
        InputField(
          label: '',
          hintText: 'Search templates...',
          controller: widget.searchController,
          prefixIcon: Icon(Icons.search, size: 16,
              color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, i) {
              final t = results[i];
              return Tappable(
                onTap: () => widget.onSelected(t),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: AppColors.dividerColor(context),
                          width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${t.industry} · ${t.category}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${t.questionCount}q',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
