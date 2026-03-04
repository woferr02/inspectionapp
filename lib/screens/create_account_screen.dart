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

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _showValidation = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? get _nameError {
    if (!_showValidation) return null;
    if (_nameController.text.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? get _emailError {
    if (!_showValidation) return null;
    final email = _emailController.text.trim();
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@') || !email.contains('.')) return 'Enter a valid email';
    return null;
  }

  String? get _passwordError {
    if (!_showValidation) return null;
    if (_passwordController.text.isEmpty) return 'Password is required';
    if (_passwordController.text.length < 6) return 'At least 6 characters';
    return null;
  }

  String? get _confirmError {
    if (!_showValidation) return null;
    if (_confirmController.text.isEmpty) return 'Confirm your password';
    if (_confirmController.text != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool get _hasErrors =>
      _nameError != null ||
      _emailError != null ||
      _passwordError != null ||
      _confirmError != null;

  bool get _canSubmit =>
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty;

  Future<void> _createAccount() async {
    setState(() {
      _showValidation = true;
      _error = null;
    });
    if (_hasErrors) return;

    setState(() => _loading = true);

    try {
      await AuthService.instance.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );
      if (!mounted) return;

      // Load user data + identify with RevenueCat (matches LoginScreen)
      await InspectionStore.instance.loadForCurrentUser();
      await SiteStore.instance.loadForCurrentUser();
      final uid = AuthService.instance.currentUser?.uid;
      if (uid != null) {
        await RevenueCatService.instance.identify(uid);
      }
      if (!mounted) return;

      // New accounts always go through onboarding
      Navigator.pushReplacementNamed(context, Routes.onboarding);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (raw.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    return raw.replaceFirst('Exception: ', '').replaceFirst('[firebase_auth/', '');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final verticalPad = screenWidth >= 512 ? 72.0 : 32.0;

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
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create Account',
                                      style: Theme.of(context).extension<AppTextStyles>()!.displayHero.copyWith(
                                        color: AppColors.textPrimary(context),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Set up your inspector profile to get started.',
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondary(context),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    InputField(
                                      label: 'Full name',
                                      hintText: 'Alex Johnson',
                                      controller: _nameController,
                                      onChanged: (_) => setState(() {}),
                                      errorText: _nameError,
                                    ),
                                    const SizedBox(height: 12),

                                    InputField(
                                      label: 'Email',
                                      hintText: 'you@company.com',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (_) => setState(() {}),
                                      errorText: _emailError,
                                    ),
                                    const SizedBox(height: 12),

                                    InputField(
                                      label: 'Password',
                                      hintText: 'At least 6 characters',
                                      obscureText: true,
                                      controller: _passwordController,
                                      onChanged: (_) => setState(() {}),
                                      errorText: _passwordError,
                                    ),
                                    const SizedBox(height: 12),

                                    InputField(
                                      label: 'Confirm password',
                                      hintText: 'Re-enter your password',
                                      obscureText: true,
                                      controller: _confirmController,
                                      onChanged: (_) => setState(() {}),
                                      errorText: _confirmError,
                                    ),
                                    const SizedBox(height: 32),

                                    AnimatedOpacity(
                                      opacity: _canSubmit ? 1.0 : 0.5,
                                      duration: const Duration(milliseconds: 200),
                                      child: PrimaryButton(
                                        text: 'Create Account',
                                        width: double.infinity,
                                        isLoading: _loading,
                                        enabled: _canSubmit,
                                        onPressed: _createAccount,
                                      ),
                                    ),

                                    if (_error != null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                          border: Border.all(
                                            color: AppColors.error.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          _error!,
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

                          // Bottom: already have an account?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?  ',
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                              Tappable(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  'SIGN IN',
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: AppColors.textPrimary(context),
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
