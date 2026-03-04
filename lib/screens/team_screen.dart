import 'package:flutter/material.dart';
import 'package:health_safety_inspection/models/organization.dart';
import 'package:health_safety_inspection/services/org_service.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/empty_state.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _orgNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _creating = false;
  bool _inviting = false;

  @override
  void dispose() {
    _orgNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createOrg() async {
    final name = _orgNameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _creating = true);
    await OrgService.instance.createOrg(name);
    setState(() => _creating = false);
  }

  Future<void> _inviteMember() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _inviting = true);
    await OrgService.instance.inviteMember(email: email);
    _emailController.clear();
    setState(() => _inviting = false);
  }

  @override
  Widget build(BuildContext context) {
    final orgService = OrgService.instance;

    return AnimatedBuilder(
      animation: orgService,
      builder: (context, _) {
        final hasOrg = orgService.hasOrg;
        final org = orgService.org;
        final members = orgService.members;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                const PageHeader(
                  title: 'Team',
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: AppViewport(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x3, AppSpacing.x3, AppSpacing.x3, AppSpacing.x4),
                      child: hasOrg
                          ? _buildTeamView(context, org!, members.toList())
                          : _buildCreateOrgView(context),
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

  Widget _buildCreateOrgView(BuildContext context) {
    return Column(
      children: [
        EmptyState(
          icon: Icons.groups_outlined,
          title: 'Create your organization',
          description: 'Set up a team to collaborate on inspections, assign tasks, and share reports.',
        ),
        const SizedBox(height: 32),
        InputField(
          label: 'Organization name',
          hintText: 'e.g. Acme Safety Corp',
          controller: _orgNameController,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: _creating ? 'Creating...' : 'Create organization',
          width: double.infinity,
          onPressed: _creating ? () {} : () { _createOrg(); },
        ),
      ],
    );
  }

  Widget _buildTeamView(
      BuildContext context, Organization org, List<OrgMember> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Org header
        SurfaceCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.business, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      '${members.length} member${members.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Invite member
        Text(
          'Invite team member',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InputField(
                label: '',
                hintText: 'Email address',
                controller: _emailController,
              ),
            ),
            const SizedBox(width: 12),
            PrimaryButton(
              text: _inviting ? '...' : 'Invite',
              height: 48,
              onPressed: _inviting ? () {} : () { _inviteMember(); },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Members list
        Text(
          'Members',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: members.asMap().entries.map((entry) {
              final idx = entry.key;
              final member = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Text(
                              member.displayName.isNotEmpty
                                  ? member.displayName[0].toUpperCase()
                                  : member.email[0].toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.displayName.isNotEmpty
                                    ? member.displayName
                                    : member.email,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              if (member.displayName.isNotEmpty)
                                Text(
                                  member.email,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            color: _roleColor(member.role).withValues(alpha: 0.1),
                          ),
                          child: Text(
                            member.roleLabel,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _roleColor(member.role),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (idx < members.length - 1)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      color: AppColors.dividerColor(context),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _roleColor(OrgRole role) {
    switch (role) {
      case OrgRole.admin:
        return AppColors.primary;
      case OrgRole.manager:
        return AppColors.warning;
      case OrgRole.inspector:
        return AppColors.success;
    }
  }
}
