import 'package:flutter/material.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';

/// Centralized feature-gating based on subscription tier.
///
/// Usage:
///   if (FeatureGate.canExport) { ... }
///   FeatureGate.guardOr(context, Feature.aiAnalysis, () => runAi());
class FeatureGate {
  FeatureGate._();

  static RevenueCatService get _rc => RevenueCatService.instance;

  // ─────────────────────────────────────────────
  //  Free-tier limits
  // ─────────────────────────────────────────────

  /// Maximum active (non-archived) inspections for free users.
  static const int freeInspectionLimit = 3;

  /// Maximum templates visible to free users.
  static const int freeTemplateLimit = 10;

  /// Maximum photos per question for free users.
  static const int freePhotosPerQuestion = 1;

  /// Maximum photos per question for paid users.
  static const int paidPhotosPerQuestion = 4;

  // ─────────────────────────────────────────────
  //  Feature checks
  // ─────────────────────────────────────────────

  /// Unlimited inspections (Pro+).
  static bool get canCreateUnlimited => _rc.isPro;

  /// Full PDF reports without watermark (Pro+).
  static bool get canFullPdf => _rc.isPro;

  /// AI risk analysis (Pro+).
  static bool get canAiAnalysis => _rc.isPro;

  /// Export CSV / JSON (Pro+).
  static bool get canExport => _rc.isPro;

  /// Cloud sync (Pro+).
  static bool get canCloudSync => _rc.isPro;

  /// All 113 templates (Pro+). Free gets 10.
  static bool get canAllTemplates => _rc.isPro;

  /// Corrective actions – full CRUD (Pro+). Free can view only.
  static bool get canManageActions => _rc.isPro;

  /// Team / org features (Business only).
  static bool get canTeam => _rc.isBusiness;

  /// Template builder (Business only).
  static bool get canTemplateBuilder => _rc.isBusiness;

  /// Web dashboard access (Pro+ — matches dashboard shell gate).
  static bool get canDashboard => _rc.isPro;

  /// Scheduling (Pro+).
  static bool get canSchedules => _rc.isPro;

  /// Analytics screen (Pro+).
  static bool get canAnalytics => _rc.isPro;

  /// Max photos per question based on tier.
  static int get maxPhotosPerQuestion =>
      _rc.isPro ? paidPhotosPerQuestion : freePhotosPerQuestion;

  /// Max inspections for current tier (null = unlimited).
  static int? get maxInspections => _rc.isPro ? null : freeInspectionLimit;

  /// Max visible templates for current tier.
  static int? get maxTemplates => _rc.isPro ? null : freeTemplateLimit;

  // ─────────────────────────────────────────────
  //  Guard helpers
  // ─────────────────────────────────────────────

  /// Returns the minimum tier required for a given feature.
  static SubscriptionTier requiredTier(Feature feature) {
    switch (feature) {
      case Feature.unlimitedInspections:
      case Feature.fullPdf:
      case Feature.aiAnalysis:
      case Feature.exportData:
      case Feature.cloudSync:
      case Feature.allTemplates:
      case Feature.manageActions:
      case Feature.schedules:
      case Feature.analytics:
        return SubscriptionTier.pro;
      case Feature.team:
      case Feature.templateBuilder:
      case Feature.dashboard:
        return SubscriptionTier.business;
    }
  }

  /// Whether the current tier unlocks [feature].
  static bool isUnlocked(Feature feature) {
    final required = requiredTier(feature);
    switch (required) {
      case SubscriptionTier.free:
        return true;
      case SubscriptionTier.pro:
        return _rc.isPro;
      case SubscriptionTier.business:
        return _rc.isBusiness;
    }
  }

  /// Run [action] if unlocked, otherwise navigate to paywall.
  static void guardOr(
    BuildContext context,
    Feature feature,
    VoidCallback action,
  ) {
    if (isUnlocked(feature)) {
      action();
    } else {
      Navigator.pushNamed(context, '/paywall', arguments: feature);
    }
  }
}

/// Named features that can be gated.
enum Feature {
  unlimitedInspections,
  fullPdf,
  aiAnalysis,
  exportData,
  cloudSync,
  allTemplates,
  manageActions,
  team,
  templateBuilder,
  dashboard,
  schedules,
  analytics,
}
