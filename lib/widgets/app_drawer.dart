import 'package:flutter/material.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/action_store.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/feature_gate.dart';
import 'package:health_safety_inspection/services/org_service.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/services/theme_notifier.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

/// A sleek side-drawer that replaces the bottom tab bar.
/// Contains navigation links, user info, and a dark-mode toggle.
class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', index: 0),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Inspections', index: 1),
    _NavItem(icon: Icons.location_on_outlined, activeIcon: Icons.location_on, label: 'Sites', index: 2),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', index: 3),
  ];

  void _navigate(BuildContext context, int index) {
    onTabSelected(index);
    Navigator.pop(context); // close drawer
  }

  Future<void> _signOut(BuildContext context) async {
    Navigator.pop(context); // close drawer
    SiteStore.instance.stopListening();
    await RevenueCatService.instance.logout();
    await AuthService.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeNotifier.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = AuthService.instance;
    final userName = auth.displayName;
    final userInitials = auth.initials;
    final userEmail = auth.email;

    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return Container(
          width: 280,
          color: AppColors.surfaceColor(context),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: Center(
                          child: Text(
                            userInitials,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
                              userName,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userEmail.isNotEmpty ? userEmail : 'Inspector',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Divider ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    height: 1,
                    color: AppColors.dividerColor(context),
                  ),
                ),

                // ── Nav items ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        ..._items.map((item) {
                          final isActive = item.index == currentIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Tappable(
                              onTap: () => _navigate(context, item.index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isActive
                                      ? AppColors.primary.withValues(alpha: 0.08)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive ? item.activeIcon : item.icon,
                                      size: 20,
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.textSecondary(context),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      item.label,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: isActive
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.textPrimary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        // ── Extra nav links (RBAC-filtered) ──
                        ..._extraLinks
                            .where((link) {
                              if (!link.requiresManager) return true;
                              final org = OrgService.instance;
                              // When no org context, show all links (solo user)
                              if (!org.hasOrg) return true;
                              return org.isManager;
                            })
                            .map((link) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Tappable(
                                onTap: () {
                                  Navigator.pop(context);
                                  if (link.feature != null &&
                                      !FeatureGate.isUnlocked(link.feature!)) {
                                    Navigator.pushNamed(context, Routes.paywall,
                                        arguments: link.feature);
                                    return;
                                  }
                                  Navigator.pushNamed(context, link.route);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        link.icon,
                                        size: 20,
                                        color: AppColors.textSecondary(context),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          link.label,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textPrimary(context),
                                          ),
                                        ),
                                      ),
                                      if (link.badge != null)
                                        _BadgeDot(route: link.badge!),
                                      if (link.feature != null &&
                                          !FeatureGate.isUnlocked(link.feature!))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: AppColors.primary
                                                .withValues(alpha: 0.08),
                                          ),
                                          child: Text(
                                            FeatureGate.requiredTier(
                                                        link.feature!) ==
                                                    SubscriptionTier.business
                                                ? 'BIZ'
                                                : 'PRO',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 9,
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),

                // ── Bottom section: dark mode toggle + sign out ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: AppColors.dividerColor(context),
                      ),
                      const SizedBox(height: 12),

                      // Dark mode toggle
                      Tappable(
                        onTap: () => theme.toggle(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                size: 20,
                                color: AppColors.textSecondary(context),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isDark ? 'Light mode' : 'Dark mode',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              _ThemeToggleVisual(isDark: isDark),
                            ],
                          ),
                        ),
                      ),

                      // Sign out
                      Tappable(
                        onTap: () => _signOut(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                size: 20,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sign out',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}

/// Extra nav links shown below the main tabs in the drawer.
class _ExtraLink {
  final IconData icon;
  final String label;
  final String route;
  final String? badge; // non-null to show a badge dot
  final bool requiresManager; // hide from plain inspectors in org context
  final Feature? feature; // non-null = requires this subscription feature

  const _ExtraLink({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    this.requiresManager = false,
    this.feature,
  });
}

const _extraLinks = <_ExtraLink>[
  _ExtraLink(icon: Icons.description_outlined, label: 'Templates', route: Routes.templates),
  _ExtraLink(icon: Icons.bar_chart_outlined, label: 'Analytics', route: Routes.analytics, feature: Feature.analytics),
  _ExtraLink(icon: Icons.checklist_outlined, label: 'Actions', route: Routes.correctiveActions, badge: 'actions', feature: Feature.manageActions),
  _ExtraLink(icon: Icons.event_repeat_outlined, label: 'Schedules', route: Routes.schedules, feature: Feature.schedules),
  _ExtraLink(icon: Icons.people_outline, label: 'Team', route: Routes.team, requiresManager: true, feature: Feature.team),
  _ExtraLink(icon: Icons.qr_code_scanner_outlined, label: 'QR Check-in', route: Routes.qrScanner),
  _ExtraLink(icon: Icons.gavel_outlined, label: 'Compliance', route: Routes.compliance),
  _ExtraLink(icon: Icons.build_outlined, label: 'Template Builder', route: Routes.templateBuilder, requiresManager: true, feature: Feature.templateBuilder),
];

class _BadgeDot extends StatelessWidget {
  final String route;
  const _BadgeDot({required this.route});

  @override
  Widget build(BuildContext context) {
    // Only show the badge dot when there are actually open actions.
    return AnimatedBuilder(
      animation: ActionStore.instance,
      builder: (context, _) {
        final hasOpen = ActionStore.instance.openActions.isNotEmpty;
        if (!hasOpen) return const SizedBox.shrink();
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.error,
          ),
        );
      },
    );
  }
}

class _ThemeToggleVisual extends StatelessWidget {
  final bool isDark;

  const _ThemeToggleVisual({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark ? AppColors.primary : AppColors.borderColor(context),
        ),
        child: AnimatedAlign(
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkBackground : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
