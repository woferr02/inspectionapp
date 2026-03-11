import 'package:flutter/material.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/org_service.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/theme/app_theme.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  late final AnimationController _contentCtrl;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  bool _redirecting = false;
  bool _googleLoading = false;
  String? _authError;

  @override
  void initState() {
    super.initState();

    // Background fade
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Logo: scale up + fade in
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade =
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);

    // Content: slide up + fade
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _contentFade =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    if (AuthService.instance.currentUser != null) {
      setState(() => _redirecting = true);
      await InspectionStore.instance.loadForCurrentUser();
      await SiteStore.instance.loadForCurrentUser();
      await OrgService.instance.loadForCurrentUser();
      final uid = AuthService.instance.currentUser?.uid;
      if (uid != null) {
        await RevenueCatService.instance.identify(uid);
      }
      if (!mounted) return;

      String dest = Routes.dashboard;
      if (!AuthService.instance.onboardingComplete) {
        dest = Routes.onboarding;
      } else if (AuthService.instance.orgId.isEmpty) {
        final invite = await OrgService.instance.checkPendingInvites();
        if (invite != null && mounted) {
          Navigator.pushReplacementNamed(context, Routes.joinOrg,
              arguments: invite);
          return;
        }
      }
      if (mounted) Navigator.pushReplacementNamed(context, dest);
    } else {
      // Staggered entrance animation
      _fadeCtrl.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _logoCtrl.forward();
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _contentCtrl.forward();
      });
    }
  }

  Future<void> _postLogin() async {
    await InspectionStore.instance.loadForCurrentUser();
    await SiteStore.instance.loadForCurrentUser();
    await OrgService.instance.loadForCurrentUser();
    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) await RevenueCatService.instance.identify(uid);
  }

  Future<String> _postLoginDestination() async {
    if (!AuthService.instance.onboardingComplete) return Routes.onboarding;
    if (AuthService.instance.orgId.isEmpty) {
      final invite = await OrgService.instance.checkPendingInvites();
      if (invite != null && mounted) {
        Navigator.pushReplacementNamed(context, Routes.joinOrg,
            arguments: invite);
        return '';
      }
    }
    return Routes.dashboard;
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _authError = null;
    });
    try {
      await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      await _postLogin();
      if (!mounted) return;
      final dest = await _postLoginDestination();
      if (dest.isNotEmpty && mounted) {
        Navigator.pushReplacementNamed(context, dest);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _authError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_redirecting) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        body: const SizedBox.shrink(),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0C12)
          : AppColors.backgroundColor(context),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Dot grid pattern ──
            CustomPaint(
              painter: _DotGridPainter(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.03),
                spacing: 28,
                radius: 1.0,
              ),
            ),

            // ── Primary glow (top center) ──
            Positioned(
              top: screenHeight * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary
                            .withValues(alpha: isDark ? 0.12 : 0.07),
                        AppColors.primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Secondary glow (bottom-right) ──
            Positioned(
              bottom: screenHeight * 0.08,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary
                          .withValues(alpha: isDark ? 0.06 : 0.03),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Main content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // ── Animated logo ──
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // PLACEHOLDER LOGO — replace with Image.asset() later
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: isDark ? 0.4 : 0.2),
                                    blurRadius: 32,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.shield_outlined,
                                    size: 40, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Text + CTAs with slide animation ──
                    SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SafeCheck Pro',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary(context),
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Health & safety inspections,\nsimplified.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color:
                                        AppColors.textSecondary(context),
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // ── CTAs ──
                    SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Continue with Google
                            Tappable(
                              onTap: _googleLoading ? null : _signInWithGoogle,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.md),
                                  color: AppColors.primary,
                                ),
                                child: _googleLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation(
                                                  Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.g_mobiledata_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Continue with Google',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            // Error message
                            if (_authError != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.md),
                                  border: Border.all(
                                    color: AppColors.error
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  _authError!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],

                            // ── DEBUG: remove before production ──
                            const SizedBox(height: 16),
                            Tappable(
                              onTap: () {
                                AuthService.instance.debugLogin();
                                Navigator.pushReplacementNamed(
                                    context, Routes.dashboard);
                              },
                              child: Text(
                                'Dev login (skip auth)',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.textTertiary(
                                          context),
                                    ),
                              ),
                            ),

                            const SizedBox(height: 28),
                            Text(
                              'By continuing you agree to our Terms & Privacy Policy',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        AppColors.textTertiary(context),
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a subtle repeating dot grid across the entire canvas.
class _DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double radius;

  _DotGridPainter({
    required this.color,
    required this.spacing,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) =>
      old.color != color || old.spacing != spacing || old.radius != radius;
}
