import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/action_store.dart';
import 'package:health_safety_inspection/services/org_service.dart';
import 'package:health_safety_inspection/services/schedule_store.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';

/// Shown after login when the user has a pending organisation invite,
/// or when the user wants to manually enter an org join code.
class JoinOrgScreen extends StatefulWidget {
  /// If non-null, a pending invite was auto-detected.
  final Map<String, String>? pendingInvite;

  const JoinOrgScreen({super.key, this.pendingInvite});

  @override
  State<JoinOrgScreen> createState() => _JoinOrgScreenState();
}

class _JoinOrgScreenState extends State<JoinOrgScreen> {
  bool _loading = false;
  final TextEditingController _codeController = TextEditingController();

  Future<void> _acceptInvite() async {
    final invite = widget.pendingInvite;
    if (invite == null) return;
    setState(() => _loading = true);

    final success = await OrgService.instance.acceptInvite(
      orgId: invite['orgId']!,
      pendingMemberId: invite['pendingMemberId']!,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      // Reload data scoped to the new org
      await InspectionStore.instance.loadForCurrentUser();
      await SiteStore.instance.loadForCurrentUser();
      await ActionStore.instance.loadForCurrentUser();
      await ScheduleStore.instance.loadForCurrentUser();
      if (!mounted) return;
      AppToast.show(context, 'Joined ${invite['orgName']}!');
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      AppToast.show(context, 'Failed to join — please try again.');
    }
  }

  Future<void> _joinByCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      AppToast.show(context, 'Please enter an organisation code.');
      return;
    }

    setState(() => _loading = true);

    // Org codes are the Firestore org document ID.
    // Check if the org exists and the user has a pending invite in it.
    try {
      final result = await OrgService.instance.joinByCode(code);
      if (!mounted) return;
      setState(() => _loading = false);

      if (result) {
        await InspectionStore.instance.loadForCurrentUser();
        await SiteStore.instance.loadForCurrentUser();
        await ActionStore.instance.loadForCurrentUser();
        await ScheduleStore.instance.loadForCurrentUser();
        if (!mounted) return;
        AppToast.show(context, 'Successfully joined organisation!');
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      } else {
        AppToast.show(context, 'Invalid code or no invite found for your email.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.show(context, 'Something went wrong — please try again.');
    }
  }

  void _skipForNow() {
    Navigator.pushReplacementNamed(context, Routes.dashboard);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invite = widget.pendingInvite;
    final hasInvite = invite != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(
              title: 'Join Organisation',
              subtitle: 'Link your account to a team',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: AppViewport(
                  padding: const EdgeInsets.all(AppSpacing.x3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Pending invite card ──
                      if (hasInvite) ...[
                        SurfaceCard(
                          padding: const EdgeInsets.all(AppSpacing.x3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.business_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'You\'ve been invited!',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Join ${invite['orgName']} as ${invite['role']}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textSecondary(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.x3),
                              Text(
                                'Your admin has invited you to join their organisation. '
                                'Accepting will give you access to shared sites, inspections, '
                                'and the team dashboard.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary(context),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.x3),
                              PrimaryButton(
                                text: _loading ? 'Joining...' : 'Accept & Join',
                                width: double.infinity,
                                enabled: !_loading,
                                onPressed: () => _acceptInvite(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.borderColor(context))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textTertiary(context),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.borderColor(context))),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.x4),
                      ],

                      // ── Manual code entry ──
                      SurfaceCard(
                        padding: const EdgeInsets.all(AppSpacing.x3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Have an organisation code?',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ask your admin for the code shown in their dashboard under '
                              'Team → Organisation Settings.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary(context),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            InputField(
                              label: 'Organisation code',
                              hintText: 'e.g. org-1709234567890',
                              controller: _codeController,
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            PrimaryButton(
                              text: _loading ? 'Joining...' : 'Join with code',
                              width: double.infinity,
                              enabled: !_loading,
                              onPressed: () => _joinByCode(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.x4),

                      // ── Skip ──
                      Center(
                        child: SecondaryButton(
                          text: 'Skip — use as individual',
                          onPressed: _skipForNow,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.x2),
                      Text(
                        'You can join an organisation later from Settings → Team.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary(context),
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
  }
}
