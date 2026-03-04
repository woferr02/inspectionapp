import 'package:flutter/material.dart';
import 'package:health_safety_inspection/models/site.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';

/// Bottom sheet for creating or editing a site.
class SiteFormSheet extends StatefulWidget {
  final Site? site; // null = create mode

  const SiteFormSheet({super.key, this.site});

  @override
  State<SiteFormSheet> createState() => _SiteFormSheetState();
}

class _SiteFormSheetState extends State<SiteFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _notesController;
  String? _nameError;
  String? _addressError;

  bool get _isEditing => widget.site != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.site?.name ?? '');
    _addressController =
        TextEditingController(text: widget.site?.address ?? '');
    _contactNameController =
        TextEditingController(text: widget.site?.contactName ?? '');
    _contactPhoneController =
        TextEditingController(text: widget.site?.contactPhone ?? '');
    _notesController = TextEditingController(text: widget.site?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _nameError = null;
      _addressError = null;
      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Site name is required';
        valid = false;
      }
      if (_addressController.text.trim().isEmpty) {
        _addressError = 'Address is required';
        valid = false;
      }
    });
    return valid;
  }

  void _save() {
    if (!_validate()) return;

    final store = SiteStore.instance;

    if (_isEditing) {
      final updated = widget.site!.copyWith(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        notes: _notesController.text.trim(),
      );
      store.updateSite(updated);
      Navigator.pop(context, updated);
    } else {
      final site = store.addSite(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        contactName: _contactNameController.text.trim().isNotEmpty
            ? _contactNameController.text.trim()
            : null,
        contactPhone: _contactPhoneController.text.trim().isNotEmpty
            ? _contactPhoneController.text.trim()
            : null,
        notes: _notesController.text.trim(),
      );
      Navigator.pop(context, site);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.x3,
            AppSpacing.x3,
            AppSpacing.x3,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.x3,
          ),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                _isEditing ? 'Edit Site' : 'New Site',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'Update the site details below'
                    : 'Add a new inspection site',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
              const SizedBox(height: AppSpacing.x3),
              InputField(
                label: 'Site name *',
                hintText: 'e.g. Riverside Construction Site',
                controller: _nameController,
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: AppSpacing.x2),
              InputField(
                label: 'Address *',
                hintText: 'e.g. 123 Main Street, London',
                controller: _addressController,
                errorText: _addressError,
                onChanged: (_) {
                  if (_addressError != null) {
                    setState(() => _addressError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.x2),
              InputField(
                label: 'Contact name',
                hintText: 'Site manager name',
                controller: _contactNameController,
              ),
              const SizedBox(height: AppSpacing.x2),
              InputField(
                label: 'Contact phone',
                hintText: '+44 ...',
                controller: _contactPhoneController,
              ),
              const SizedBox(height: AppSpacing.x2),
              InputField(
                label: 'Notes',
                hintText: 'Any additional notes...',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.x3),
              PrimaryButton(
                text: _isEditing ? 'Save Changes' : 'Create Site',
                width: double.infinity,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.x1),
              SecondaryButton(
                text: 'Cancel',
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
