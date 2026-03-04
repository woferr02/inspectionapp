import 'package:flutter/material.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/theme/app_theme.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _googleLoading = false;
  String? _authError;
  bool _invalidLogin = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late final AnimationController _bottomFadeController;
  late final Animation<double> _bottomFadeAnim;
  late final Animation<Offset> _bottomSlideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _bottomFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bottomFadeAnim = CurvedAnimation(
        parent: _bottomFadeController, curve: Curves.easeOut);
    _bottomSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _bottomFadeController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _bottomFadeController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (AuthService.instance.currentUser != null && mounted) {
        await _postLogin();
        if (mounted) {
          final dest = AuthService.instance.onboardingComplete
              ? Routes.dashboard
              : Routes.onboarding;
          Navigator.pushReplacementNamed(context, dest);
        }
      }
    });
  }

  /// Load user data and identify with RevenueCat after any successful sign-in.
  Future<void> _postLogin() async {
    await InspectionStore.instance.loadForCurrentUser();
    await SiteStore.instance.loadForCurrentUser();
    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      await RevenueCatService.instance.identify(uid);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bottomFadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      final dest = AuthService.instance.onboardingComplete
          ? Routes.dashboard
          : Routes.onboarding;
      Navigator.pushReplacementNamed(context, dest);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _authError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  bool _emailLoading = false;

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _invalidLogin = true);
      return;
    }

    setState(() {
      _emailLoading = true;
      _authError = null;
      _invalidLogin = false;
    });

    try {
      await AuthService.instance.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await _postLogin();
      if (!mounted) return;
      final dest = AuthService.instance.onboardingComplete
          ? Routes.dashboard
          : Routes.onboarding;
      Navigator.pushReplacementNamed(context, dest);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('user-not-found') ||
          msg.contains('wrong-password') ||
          msg.contains('invalid-credential')) {
        setState(() => _invalidLogin = true);
      } else {
        setState(() {
          _authError = msg.replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _emailLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _authError = 'Enter your email first, then tap Forget Password.');
      return;
    }
    try {
      await AuthService.instance.sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _authError = 'Password reset email sent to $email');
    } catch (e) {
      if (!mounted) return;
      setState(() => _authError = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final verticalPad = screenWidth >= 512 ? 72.0 : 32.0;
    final canSubmit =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: verticalPad),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // ── Top: form content ──
                      Expanded(
                        child: SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title block
                                    Text(
                                      'Sign In',
                                      style: Theme.of(context).extension<AppTextStyles>()!.displayHero.copyWith(
                                        color: AppColors.textPrimary(context),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Access your account by entering your email and password.',
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondary(context),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Email field
                                    InputField(
                                      label: 'Email',
                                      hintText: 'you@company.com',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (_) => setState(() {
                                        _invalidLogin = false;
                                      }),
                                      errorText: _invalidLogin
                                          ? 'Incorrect email or password'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),

                                    // Password field
                                    InputField(
                                      label: 'Password',
                                      hintText: 'Enter password',
                                      obscureText: true,
                                      controller: _passwordController,
                                      onChanged: (_) => setState(() {
                                        _invalidLogin = false;
                                      }),
                                    ),
                                    const SizedBox(height: 12),

                                    // Forgot password
                                    Tappable(
                                      onTap: _handleForgotPassword,
                                      child: Text(
                                        'FORGET PASSWORD?',
                                        style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                          color: AppColors.textPrimary(context),
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              AppColors.textPrimary(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Sign in button
                                    AnimatedOpacity(
                                      opacity: canSubmit ? 1.0 : 0.5,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: PrimaryButton(
                                        text: 'Sign In',
                                        width: double.infinity,
                                        isLoading: _emailLoading,
                                        enabled: canSubmit,
                                        onPressed: _handleSignIn,
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
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.md),
                                          border: Border.all(
                                            color: AppColors.error
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          _authError!,
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Bottom: social + create account ──
                      SlideTransition(
                        position: _bottomSlideAnim,
                        child: FadeTransition(
                          opacity: _bottomFadeAnim,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Social login buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _SocialButton(
                                      icon: Icons.g_mobiledata_rounded,
                                      iconSize: 28,
                                      isLoading: _googleLoading,
                                      onTap: _signInWithGoogle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _SocialButton(
                                      icon: Icons.apple,
                                      iconSize: 22,
                                      onTap: () => AppToast.show(context, 'Apple Sign-In coming soon'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Create account link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'First time here?  ',
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                  Tappable(
                                    onTap: () => Navigator.pushNamed(context, Routes.createAccount),
                                    child: Text(
                                      'CREATE AN ACCOUNT',
                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        color: AppColors.textPrimary(context),
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            AppColors.textPrimary(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final bool isLoading;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    this.iconSize = 22,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      onTap: widget.isLoading ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.surfaceColor(context)
              : AppColors.backgroundColor(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.borderColor(context),
            width: 1,
          ),
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                        AppColors.textSecondary(context)),
                  ),
                )
              : Icon(
                  widget.icon,
                  color: AppColors.textPrimary(context),
                  size: widget.iconSize,
                ),
        ),
      ),
    );
  }
}
