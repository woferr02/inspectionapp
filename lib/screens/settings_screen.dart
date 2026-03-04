import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/services/export_service.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/services/theme_notifier.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/section_block.dart';
import 'package:health_safety_inspection/widgets/sync_indicator.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';
import 'package:health_safety_inspection/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSave = true;
  bool _wifiOnly = false;
  bool _notificationsEnabled = true;
  String _photoQuality = 'High';
  String _language = 'English';

  Widget _buildToggleRow(BuildContext context, String label, bool value,
      ValueChanged<bool> onChanged) {
    return Tappable(
      onTap: () => onChanged(!value),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            _ToggleVisual(value: value),
          ],
        ),
      ),
    );
  }

  Widget _buildNavRow(BuildContext context, String label,
      {String? value, VoidCallback? onTap, bool destructive = false}) {
    return Tappable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: destructive
                      ? AppColors.error
                      : AppColors.textPrimary(context),
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (!destructive)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncRow(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            "Sync status",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const Spacer(),
          const SyncIndicator(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: "Settings", showMenuButton: true),
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
                    children: [
                      // ── SUBSCRIPTION ──
                      ListenableBuilder(
                        listenable: RevenueCatService.instance,
                        builder: (context, _) {
                          final rc = RevenueCatService.instance;
                          final tierName = rc.isBusiness
                              ? 'Business'
                              : rc.isPro
                                  ? 'Pro'
                                  : 'Free';
                          final tierColor = rc.isBusiness
                              ? AppColors.success
                              : rc.isPro
                                  ? AppColors.primary
                                  : AppColors.textSecondary(context);
                          return SectionBlock(
                            title: 'SUBSCRIPTION',
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  Tappable(
                                    onTap: () => Navigator.pushNamed(
                                        context, Routes.paywall),
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 44),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Current plan',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    color:
                                                        AppColors.textPrimary(
                                                            context),
                                                  ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: tierColor
                                                  .withValues(alpha: 0.12),
                                            ),
                                            child: Text(
                                              tierName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: tierColor,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.chevron_right,
                                            size: 20,
                                            color: AppColors.textSecondary(
                                                context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (rc.isFree)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Tappable(
                                        onTap: () => Navigator.pushNamed(
                                            context, Routes.paywall),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppRadius.md),
                                            color: AppColors.primary,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Upgrade to Pro',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  _buildNavRow(
                                    context,
                                    'Restore purchases',
                                    onTap: () async {
                                      final success =
                                          await RevenueCatService.instance
                                              .restorePurchases();
                                      if (context.mounted) {
                                        AppToast.show(
                                          context,
                                          success
                                              ? 'Purchases restored'
                                              : 'No purchases found',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── APPEARANCE ──
                      AnimatedBuilder(
                        animation: ThemeNotifier.instance,
                        builder: (context, _) {
                          return SectionBlock(
                            title: "APPEARANCE",
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  _buildToggleRow(
                                    context,
                                    "Dark mode",
                                    ThemeNotifier.instance.isDark,
                                    (_) => ThemeNotifier.instance.toggle(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── ACCOUNT ──
                      SectionBlock(
                        title: "ACCOUNT",
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildNavRow(
                                context,
                                "Profile",
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.profile),
                              ),
                              _dividerInner(context),
                              _buildToggleRow(
                                context,
                                "Notifications",
                                _notificationsEnabled,
                                (v) =>
                                    setState(() => _notificationsEnabled = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── INSPECTIONS ──
                      SectionBlock(
                        title: "INSPECTIONS",
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildNavRow(context, "Default template",
                                  onTap: () => Navigator.pushNamed(
                                      context, Routes.templates)),
                              _dividerInner(context),
                              _buildToggleRow(
                                context,
                                "Auto-save",
                                _autoSave,
                                (v) => setState(() => _autoSave = v),
                              ),
                              _dividerInner(context),
                              _buildNavRow(context, "Photo quality",
                                  value: _photoQuality,
                                  onTap: () => _showPhotoQualityPicker(context)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── DATA ──
                      SectionBlock(
                        title: "DATA",
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildSyncRow(context),
                              _dividerInner(context),
                              _buildToggleRow(
                                context,
                                "Wi-Fi only upload",
                                _wifiOnly,
                                (v) => setState(() => _wifiOnly = v),
                              ),
                              _dividerInner(context),
                              _buildNavRow(
                                context,
                                "Clear local cache",
                                destructive: true,
                                onTap: () => _confirmClearCache(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── LANGUAGE ──
                      SectionBlock(
                        title: "LANGUAGE",
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildNavRow(
                                context,
                                "App language",
                                value: _language,
                                onTap: () => _showLanguagePicker(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── EXPORT ──
                      SectionBlock(
                        title: "EXPORT",
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildNavRow(
                                context,
                                "Export all inspections (CSV)",
                                onTap: () async {
                                  await ExportService.instance.shareAllCsv(
                                    InspectionStore.instance.inspections,
                                  );
                                },
                              ),
                              _dividerInner(context),
                              _buildNavRow(
                                context,
                                "Analytics",
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.analytics),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── TEAM ──
                      SectionBlock(
                        title: "TEAM",
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildNavRow(
                                context,
                                "Organization & Team",
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.team),
                              ),
                              _dividerInner(context),
                              _buildNavRow(
                                context,
                                "Schedules",
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.schedules),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── ABOUT ──
                      SectionBlock(
                        title: "ABOUT",
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildNavRow(context, "Version",
                                  value: "1.0.0 (42)"),
                              _dividerInner(context),
                              _buildNavRow(context, "Terms of service",
                                  onTap: () => _showInfoDialog(
                                      context, 'Terms of Service',
                                      'Terms of service are available at safecheckpro.com/terms.')),
                              _dividerInner(context),
                              _buildNavRow(context, "Privacy policy",
                                  onTap: () => _showInfoDialog(
                                      context, 'Privacy Policy',
                                      'Privacy policy is available at safecheckpro.com/privacy.')),
                              _dividerInner(context),
                              _buildNavRow(
                                context,
                                "About",
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.about),
                              ),
                            ],
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

  void _showPhotoQualityPicker(BuildContext context) {
    final options = ['Low', 'Medium', 'High'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photo quality',
                style: Theme.of(ctx).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(ctx),
                    )),
            const SizedBox(height: 16),
            ...options.map((opt) => Tappable(
                  onTap: () {
                    setState(() => _photoQuality = opt);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opt,
                              style:
                                  Theme.of(ctx).textTheme.bodyLarge!.copyWith(
                                        color: AppColors.textPrimary(ctx),
                                        fontWeight: opt == _photoQuality
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      )),
                        ),
                        if (opt == _photoQuality)
                          Icon(Icons.check,
                              size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(ctx),
        title: Text('Clear local cache?',
            style: Theme.of(ctx)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        content: Text(
          'This removes locally cached data. Synced data will be re-downloaded.',
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
              AppToast.show(context, 'Local cache cleared');
            },
            child: Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(ctx),
        title: Text(title,
            style: Theme.of(ctx)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        content: Text(body, style: Theme.of(ctx).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final langs = ['English', 'Español', 'Français'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select language',
              style: Theme.of(ctx).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(ctx),
              ),
            ),
            const SizedBox(height: 16),
            ...langs.map((lang) => Tappable(
                  onTap: () {
                    setState(() => _language = lang);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang,
                            style: Theme.of(ctx).textTheme.bodyLarge!.copyWith(
                              color: AppColors.textPrimary(ctx),
                              fontWeight: lang == _language
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (lang == _language)
                          Icon(Icons.check, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _dividerInner(BuildContext context) {
    return Container(height: 1, color: AppColors.dividerColor(context));
  }
}

class _ToggleVisual extends StatelessWidget {
  final bool value;

  const _ToggleVisual({required this.value});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? AppColors.primary : AppColors.borderColor(context),
        ),
        child: AnimatedAlign(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
