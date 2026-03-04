import 'package:flutter/material.dart';
import 'package:health_safety_inspection/models/template.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/form_field_row.dart';
import 'package:health_safety_inspection/widgets/form_section_label.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/services/site_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;
  late final TextEditingController _jobTitleController;
  String? _selectedIndustry;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final auth = AuthService.instance;
    final nameParts = auth.displayName.split(RegExp(r'\s+'));
    _firstNameController =
        TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    _lastNameController = TextEditingController(
        text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    _emailController = TextEditingController(text: auth.email);
    _companyController = TextEditingController(text: auth.company);
    _jobTitleController = TextEditingController(text: auth.jobTitle);
    _selectedIndustry =
        auth.industry.isNotEmpty ? auth.industry : null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saved = false;
    });

    final newName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();

    await AuthService.instance.updateProfile(
      displayName: newName.isNotEmpty ? newName : null,
      company: _companyController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      industry: _selectedIndustry ?? '',
    );

    if (mounted) {
      setState(() {
        _saving = false;
        _saved = true;
      });
      // Reset saved indicator after 2s
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _saved = false);
      });
    }
  }

  Future<void> _signOut() async {
    SiteStore.instance.stopListening();
    await RevenueCatService.instance.logout();
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: "Profile",
              showBackButton: true,
              actions: [
                Tappable(
                  onTap: _saving ? null : _save,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: _saving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_saved)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                ),
                              Text(
                                _saved ? "Saved" : "Save",
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: _saved
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                              ),
                            ],
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
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Center(
                            child: Text(
                              AuthService.instance.initials,
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x3),

                      // ── Personal info ──
                      const FormSectionLabel(text: 'Personal information'),
                      FormFieldRow(
                        children: [
                          InputField(
                            label: "First name",
                            hintText: "John",
                            controller: _firstNameController,
                          ),
                          InputField(
                            label: "Last name",
                            hintText: "Doe",
                            controller: _lastNameController,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      InputField(
                        label: "Email",
                        hintText: "you@company.com",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false,
                      ),

                      const SizedBox(height: AppSpacing.x3),

                      // ── Work info ──
                      const FormSectionLabel(text: 'Work information'),
                      InputField(
                        label: "Job title",
                        hintText: "Site Safety Officer",
                        controller: _jobTitleController,
                      ),
                      const SizedBox(height: 14),
                      InputField(
                        label: "Company",
                        hintText: "Company name",
                        controller: _companyController,
                      ),
                      const SizedBox(height: 14),

                      // Industry selector
                      Text(
                        'Industry',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor(context),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: AppColors.borderColor(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedIndustry,
                            hint: Text(
                              'Select your industry',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppColors.textTertiary(context),
                              ),
                            ),
                            isExpanded: true,
                            icon: Icon(
                              Icons.expand_more_rounded,
                              size: 20,
                              color: AppColors.textSecondary(context),
                            ),
                            dropdownColor: AppColors.surfaceColor(context),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.textPrimary(context),
                            ),
                            items: Industry.all.map((ind) {
                              return DropdownMenuItem(
                                value: ind.name,
                                child: Row(
                                  children: [
                                    Icon(ind.icon,
                                        size: 16,
                                        color: AppColors.textSecondary(
                                            context)),
                                    const SizedBox(width: 10),
                                    Text(ind.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedIndustry = val),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.x3),
                      SecondaryButton(
                        text: "Change password",
                        onPressed: () async {
                          final email = AuthService.instance.email;
                          if (email.isNotEmpty) {
                            try {
                              await AuthService.instance
                                  .sendPasswordReset(email);
                            } catch (_) {}
                          }
                        },
                        width: double.infinity,
                      ),
                      const SizedBox(height: AppSpacing.x4),
                      Center(
                        child: Tappable(
                          onTap: _signOut,
                          child: Container(
                            constraints:
                                const BoxConstraints(minHeight: 44),
                            alignment: Alignment.center,
                            child: Text(
                              'SIGN OUT',
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.error,
                                letterSpacing: 0.6,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.error,
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
  }
}
