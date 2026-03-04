import 'package:flutter/material.dart';
import 'package:health_safety_inspection/services/feature_gate.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/surface_card.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class PaywallScreen extends StatefulWidget {
  /// Optional: which feature triggered the paywall.
  final Feature? triggerFeature;

  const PaywallScreen({super.key, this.triggerFeature});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _yearlyBilling = true;
  bool _purchasing = false;
  bool _restoring = false;

  // Display prices (used when RevenueCat keys aren't configured yet)
  static const _prices = {
    'pro_monthly': '\$14.99',
    'pro_yearly': '\$119.99',
    'pro_yearly_monthly': '\$10.00',
    'business_monthly': '\$44.99',
    'business_yearly': '\$359.99',
    'business_yearly_monthly': '\$30.00',
  };

  String _proPrice() => _yearlyBilling
      ? '${_prices['pro_yearly_monthly']}/mo'
      : '${_prices['pro_monthly']}/mo';

  String _businessPrice() => _yearlyBilling
      ? '${_prices['business_yearly_monthly']}/mo'
      : '${_prices['business_monthly']}/mo';

  String _proBilledAs() => _yearlyBilling
      ? 'Billed ${_prices['pro_yearly']}/year'
      : 'Billed monthly';

  String _businessBilledAs() => _yearlyBilling
      ? 'Billed ${_prices['business_yearly']}/year'
      : 'Billed monthly';

  Future<void> _selectPlan(SubscriptionTier tier) async {
    final rc = RevenueCatService.instance;
    if (rc.isDevelopment) {
      AppToast.show(
          context, 'Purchase simulated (dev mode) — tier set to ${tier.name}');
      rc.debugSetTier(tier);
      if (mounted) Navigator.pop(context, true);
      return;
    }

    // Real purchase flow
    setState(() => _purchasing = true);
    try {
      final offerings = await rc.getOfferings();
      if (offerings == null || offerings.current == null) {
        if (mounted) {
          AppToast.show(context, 'No offerings available. Try again later.',
              isError: true);
        }
        setState(() => _purchasing = false);
        return;
      }

      // Find the right package
      final packages = offerings.current!.availablePackages;
      final suffix =
          tier == SubscriptionTier.pro ? 'pro' : 'business';
      final period = _yearlyBilling ? 'annual' : 'monthly';
      final target = packages.firstWhere(
        (p) =>
            p.storeProduct.identifier
                .toLowerCase()
                .contains(suffix) &&
            p.storeProduct.identifier
                .toLowerCase()
                .contains(period),
        orElse: () => packages.first,
      );

      final success = await rc.purchase(target);
      if (mounted) {
        if (success) {
          AppToast.show(context, 'Welcome to SafeCheck ${tier.name.toUpperCase()}!');
          Navigator.pop(context, true);
        } else {
          AppToast.show(context, 'Purchase cancelled or failed.',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Purchase error: $e', isError: true);
      }
    }
    if (mounted) setState(() => _purchasing = false);
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    final success = await RevenueCatService.instance.restorePurchases();
    if (mounted) {
      if (success) {
        AppToast.show(context, 'Purchases restored.');
        Navigator.pop(context, true);
      } else {
        AppToast.show(context, 'No previous purchases found.');
      }
      setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = RevenueCatService.instance;
    final currentTier = rc.tier;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(
              title: 'Upgrade',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: AppViewport(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x3, AppSpacing.x2, AppSpacing.x3, AppSpacing.x4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero text
                      Text(
                        'Unlock the full power\nof SafeCheck Pro',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(context),
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.triggerFeature != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            color: AppColors.primary.withValues(alpha: 0.08),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                '${_featureLabel(widget.triggerFeature!)} requires ${FeatureGate.requiredTier(widget.triggerFeature!).name.toUpperCase()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        'Professional risk scoring, unlimited inspections, full exports, and more.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: AppColors.textSecondary(context),
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Billing toggle
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            color: AppColors.surfaceColor(context),
                            border: Border.all(
                                color: AppColors.borderColor(context)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _BillingToggle(
                                label: 'Yearly',
                                badge: 'Save 33%',
                                active: _yearlyBilling,
                                onTap: () =>
                                    setState(() => _yearlyBilling = true),
                              ),
                              _BillingToggle(
                                label: 'Monthly',
                                active: !_yearlyBilling,
                                onTap: () =>
                                    setState(() => _yearlyBilling = false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── PRO TIER ──
                      _TierCard(
                        tierName: 'Pro',
                        price: _proPrice(),
                        billedAs: _proBilledAs(),
                        color: AppColors.primary,
                        isCurrent: currentTier == SubscriptionTier.pro,
                        isDowngrade: currentTier == SubscriptionTier.business,
                        purchasing: _purchasing,
                        features: const [
                          _FeatureItem(
                              icon: Icons.all_inclusive,
                              text: 'Unlimited inspections'),
                          _FeatureItem(
                              icon: Icons.description_outlined,
                              text: 'All 113 templates'),
                          _FeatureItem(
                              icon: Icons.picture_as_pdf_outlined,
                              text: 'Full PDF reports (no watermark)'),
                          _FeatureItem(
                              icon: Icons.cloud_sync_outlined,
                              text: 'Cloud sync across devices'),
                          _FeatureItem(
                              icon: Icons.psychology_outlined,
                              text: 'AI risk analysis'),
                          _FeatureItem(
                              icon: Icons.download_outlined,
                              text: 'CSV & JSON export'),
                          _FeatureItem(
                              icon: Icons.camera_alt_outlined,
                              text: '4 photos per question'),
                          _FeatureItem(
                              icon: Icons.task_alt_outlined,
                              text: 'Corrective actions (full)'),
                          _FeatureItem(
                              icon: Icons.schedule_outlined,
                              text: 'Inspection scheduling'),
                          _FeatureItem(
                              icon: Icons.bar_chart_outlined,
                              text: 'Analytics & insights'),
                        ],
                        onSelect: currentTier == SubscriptionTier.pro
                            ? null
                            : () => _selectPlan(SubscriptionTier.pro),
                      ),
                      const SizedBox(height: AppSpacing.x2),

                      // ── BUSINESS TIER ──
                      _TierCard(
                        tierName: 'Business',
                        price: _businessPrice(),
                        billedAs: _businessBilledAs(),
                        color: AppColors.success,
                        isCurrent: currentTier == SubscriptionTier.business,
                        isDowngrade: false,
                        purchasing: _purchasing,
                        features: const [
                          _FeatureItem(
                              icon: Icons.check,
                              text: 'Everything in Pro'),
                          _FeatureItem(
                              icon: Icons.web_outlined,
                              text: 'Web dashboard & analytics portal'),
                          _FeatureItem(
                              icon: Icons.group_outlined,
                              text: 'Team & org management'),
                          _FeatureItem(
                              icon: Icons.build_outlined,
                              text: 'Custom template builder'),
                          _FeatureItem(
                              icon: Icons.support_agent_outlined,
                              text: 'Priority support'),
                        ],
                        onSelect: currentTier == SubscriptionTier.business
                            ? null
                            : () => _selectPlan(SubscriptionTier.business),
                      ),
                      const SizedBox(height: AppSpacing.x3),

                      // ── FREE TIER reference ──
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Free Plan',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            _FreeLine(text: '3 active inspections'),
                            _FreeLine(text: '10 basic templates'),
                            _FreeLine(text: 'Watermarked PDF reports'),
                            _FreeLine(text: '1 photo per question'),
                            _FreeLine(text: 'Local storage only'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x3),

                      // Restore + legal
                      Center(
                        child: Column(
                          children: [
                            Tappable(
                              onTap: _restoring ? null : _restore,
                              child: _restoring
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Text(
                                      'Restore purchases',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Subscriptions auto-renew unless cancelled at least 24 hours\nbefore the end of the current period. Manage in App Store / Play Store settings.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.textTertiary(context),
                                    height: 1.5,
                                  ),
                            ),
                          ],
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

  String _featureLabel(Feature f) {
    switch (f) {
      case Feature.unlimitedInspections:
        return 'Unlimited inspections';
      case Feature.fullPdf:
        return 'Full PDF reports';
      case Feature.aiAnalysis:
        return 'AI risk analysis';
      case Feature.exportData:
        return 'Data export';
      case Feature.cloudSync:
        return 'Cloud sync';
      case Feature.allTemplates:
        return 'All templates';
      case Feature.manageActions:
        return 'Corrective actions';
      case Feature.team:
        return 'Team management';
      case Feature.templateBuilder:
        return 'Template builder';
      case Feature.dashboard:
        return 'Web dashboard';
      case Feature.schedules:
        return 'Scheduling';
      case Feature.analytics:
        return 'Analytics';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Subwidgets
// ═══════════════════════════════════════════════════════════════════

class _BillingToggle extends StatelessWidget {
  final String label;
  final String? badge;
  final bool active;
  final VoidCallback onTap;

  const _BillingToggle({
    required this.label,
    this.badge,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          color: active ? AppColors.primary : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.textSecondary(context),
                  ),
            ),
            if (badge != null && active) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                child: Text(
                  badge!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String tierName;
  final String price;
  final String billedAs;
  final Color color;
  final bool isCurrent;
  final bool isDowngrade;
  final bool purchasing;
  final List<_FeatureItem> features;
  final VoidCallback? onSelect;

  const _TierCard({
    required this.tierName,
    required this.price,
    required this.billedAs,
    required this.color,
    required this.isCurrent,
    required this.isDowngrade,
    required this.purchasing,
    required this.features,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isCurrent ? color : AppColors.borderColor(context),
          width: isCurrent ? 2 : 1,
        ),
        color: AppColors.surfaceColor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg)),
              color: color.withValues(alpha: 0.06),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tierName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                color: color.withValues(alpha: 0.15),
                              ),
                              child: Text(
                                'CURRENT',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: color,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      Text(
                        billedAs,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                                color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Features
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features,
            ),
          ),
          // CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Tappable(
              onTap: purchasing ? null : onSelect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: isCurrent
                      ? AppColors.borderColor(context)
                      : isDowngrade
                          ? AppColors.surfaceColor(context)
                          : color,
                  border: isDowngrade
                      ? Border.all(color: AppColors.borderColor(context))
                      : null,
                ),
                child: Center(
                  child: purchasing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isCurrent
                                  ? AppColors.textSecondary(context)
                                  : Colors.white),
                        )
                      : Text(
                          isCurrent
                              ? 'Current plan'
                              : isDowngrade
                                  ? 'Contact support to change'
                                  : 'Get $tierName',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isCurrent
                                    ? AppColors.textSecondary(context)
                                    : isDowngrade
                                        ? AppColors.textSecondary(context)
                                        : Colors.white,
                              ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeLine extends StatelessWidget {
  final String text;
  const _FreeLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: AppColors.textTertiary(context)),
          const SizedBox(width: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
        ],
      ),
    );
  }
}
