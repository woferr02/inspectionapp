import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:health_safety_inspection/services/auth_service.dart';

/// Subscription tier hierarchy: free → pro → business.
enum SubscriptionTier { free, pro, business }

/// Wraps RevenueCat (purchases_flutter) so the rest of the app
/// can check entitlements and offer subscription products.
///
/// To activate RevenueCat:
///   1. Create a project at https://app.revenuecat.com
///   2. Set your API keys below
///   3. Configure products in App Store Connect / Google Play Console:
///        - safecheck_pro_monthly       ($14.99/mo)
///        - safecheck_pro_yearly        ($119.99/yr)
///        - safecheck_business_monthly  ($44.99/mo)
///        - safecheck_business_yearly   ($359.99/yr)
///   4. Map those products to Entitlements + Offerings in the RevenueCat dashboard:
///        - Entitlement "pro"      → pro monthly + pro yearly packages
///        - Entitlement "business" → business monthly + business yearly packages
class RevenueCatService extends ChangeNotifier {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  // ── TODO: Replace with your real RevenueCat API keys ──
  static const _androidApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';
  static const _iosApiKey = 'YOUR_REVENUECAT_IOS_API_KEY';

  /// Entitlement identifiers configured in the RevenueCat dashboard.
  static const proEntitlement = 'pro';
  static const businessEntitlement = 'business';

  bool _initialized = false;
  SubscriptionTier _tier = SubscriptionTier.free;
  Offerings? _offerings;

  /// True when API keys haven't been configured yet (development mode).
  bool get isDevelopment =>
      _androidApiKey.startsWith('YOUR_') && _iosApiKey.startsWith('YOUR_');

  /// Current subscription tier.
  SubscriptionTier get tier => _tier;

  /// Convenience getters.
  bool get isPro => _tier == SubscriptionTier.pro || _tier == SubscriptionTier.business;
  bool get isBusiness => _tier == SubscriptionTier.business;
  bool get isFree => _tier == SubscriptionTier.free;

  /// Cached offerings.
  Offerings? get offerings => _offerings;

  /// Call once at app startup (after Firebase init).
  Future<void> initialize() async {
    if (_initialized) return;

    // Skip when keys aren't configured yet — default to free tier
    if (isDevelopment) {
      _initialized = true;
      debugPrint('[RevenueCat] Running in dev mode (no API keys). Tier = free');
      return;
    }

    final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
    final configuration = PurchasesConfiguration(apiKey);

    // Identify with the Firebase UID so purchases follow the user
    final user = AuthService.instance.currentUser;
    if (user != null) {
      configuration.appUserID = user.uid;
    }

    await Purchases.configure(configuration);
    _initialized = true;

    // Sync entitlements on init
    await refreshTier();
  }

  /// Re-identify after login so purchases tie to the correct Firebase user.
  Future<void> identify(String userId) async {
    if (!_initialized || isDevelopment) return;
    await Purchases.logIn(userId);
    await refreshTier();
  }

  /// Call on sign-out so RevenueCat returns to anonymous user.
  Future<void> logout() async {
    if (!_initialized || isDevelopment) return;
    await Purchases.logOut();
    _tier = SubscriptionTier.free;
    notifyListeners();
  }

  /// Refresh the subscription tier from RevenueCat entitlements.
  Future<void> refreshTier() async {
    if (!_initialized || isDevelopment) return;
    try {
      final info = await Purchases.getCustomerInfo();
      final active = info.entitlements.active;
      if (active.containsKey(businessEntitlement)) {
        _tier = SubscriptionTier.business;
      } else if (active.containsKey(proEntitlement)) {
        _tier = SubscriptionTier.pro;
      } else {
        _tier = SubscriptionTier.free;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[RevenueCat] refreshTier failed: $e');
    }
  }

  /// Fetch available offerings (subscription packages).
  Future<Offerings?> getOfferings() async {
    if (!_initialized || isDevelopment) return null;
    try {
      _offerings = await Purchases.getOfferings();
      return _offerings;
    } catch (e) {
      debugPrint('[RevenueCat] getOfferings failed: $e');
      return null;
    }
  }

  /// Purchase a specific package.
  Future<bool> purchase(Package package) async {
    if (!_initialized) return false;
    try {
      await Purchases.purchasePackage(package);
      await refreshTier();
      return true;
    } catch (e) {
      debugPrint('[RevenueCat] purchase failed: $e');
      return false;
    }
  }

  /// Restore previous purchases (e.g. after reinstall).
  Future<bool> restorePurchases() async {
    if (!_initialized || isDevelopment) return false;
    try {
      await Purchases.restorePurchases();
      await refreshTier();
      return true;
    } catch (e) {
      debugPrint('[RevenueCat] restorePurchases failed: $e');
      return false;
    }
  }

  /// Override tier for development/testing.
  void debugSetTier(SubscriptionTier newTier) {
    if (!kReleaseMode) {
      _tier = newTier;
      notifyListeners();
      debugPrint('[RevenueCat] DEBUG tier set to: ${newTier.name}');
    }
  }
}
