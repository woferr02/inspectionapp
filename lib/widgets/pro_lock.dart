import 'package:flutter/material.dart';
import 'package:health_safety_inspection/services/feature_gate.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

/// Inline lock widget that wraps a child and overlays a blurred lock
/// when the required [feature] is not unlocked for the current tier.
///
/// If already unlocked, renders [child] unchanged.
/// Tap opens the paywall screen.
class ProLock extends StatelessWidget {
  final Feature feature;
  final Widget child;

  /// If true the child is fully hidden and replaced with a compact badge.
  /// Otherwise the child is shown but dimmed with a lock overlay.
  final bool replaceChild;

  const ProLock({
    super.key,
    required this.feature,
    required this.child,
    this.replaceChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RevenueCatService.instance,
      builder: (context, _) {
        if (FeatureGate.isUnlocked(feature)) return child;

        final tierLabel =
            FeatureGate.requiredTier(feature) == SubscriptionTier.business
                ? 'Business'
                : 'Pro';
        final color =
            FeatureGate.requiredTier(feature) == SubscriptionTier.business
                ? AppColors.success
                : AppColors.primary;

        if (replaceChild) {
          return Tappable(
            onTap: () => _openPaywall(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: color.withValues(alpha: 0.08),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    tierLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        // Dimmed overlay mode
        return Tappable(
          onTap: () => _openPaywall(context),
          child: Stack(
            children: [
              Opacity(opacity: 0.35, child: IgnorePointer(child: child)),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: color.withValues(alpha: 0.12),
                      border: Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          tierLabel,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPaywall(BuildContext context) {
    Navigator.pushNamed(context, '/paywall', arguments: feature);
  }
}
