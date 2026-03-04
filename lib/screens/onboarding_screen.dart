import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_safety_inspection/data/inspection_store.dart';
import 'package:health_safety_inspection/models/template.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/services/auth_service.dart';
import 'package:health_safety_inspection/services/revenuecat_service.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/theme/app_theme.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/app_toast.dart';
import 'package:health_safety_inspection/widgets/input_field.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // ── State ──
  // Steps: 0-2 = tutorial walkthrough, 3 = job title + company, 4 = country, 5 = industry
  static const int _totalSteps = 6;
  int _step = 0;
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  String? _selectedCountry;
  String? _selectedIndustry;
  bool _saving = false;

  // PageView controller for swipeable tutorial steps (0-2)
  late final PageController _pageController;

  // Tutorial content
  static const _tutorials = [
    _TutorialPage(
      icon: Icons.assignment_outlined,
      title: 'Run Inspections',
      body:
          'Pick from 95+ ready-made templates across 13 industries and 3 countries, or build your own. Answer pass / fail / N/A questions, add photos and notes as you go.',
    ),
    _TutorialPage(
      icon: Icons.description_outlined,
      title: 'Generate Reports',
      body:
          'When your inspection is complete, generate a professional PDF report with scores, corrective actions, and digital signatures — ready to share.',
    ),
    _TutorialPage(
      icon: Icons.bar_chart_outlined,
      title: 'Track & Improve',
      body:
          'View analytics, manage corrective actions, set recurring schedules, and get AI-powered risk assessments — all in one place.',
    ),
  ];

  // ── Animations ──
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late final AnimationController _stepFadeCtrl;
  late final Animation<double> _stepFade;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _stepFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _stepFade =
        CurvedAnimation(parent: _stepFadeCtrl, curve: Curves.easeInOut);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _stepFadeCtrl.dispose();
    _pageController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  // ── Validation ──
  bool get _canContinueStep3 => _jobTitleController.text.trim().isNotEmpty;
  bool get _canContinueStep4 => _selectedCountry != null;
  bool get _canFinish => _selectedIndustry != null;

  // ── Navigation ──
  Future<void> _animateToStep(int step) async {
    HapticFeedback.selectionClick();
    // If moving between tutorial pages (0-2), use PageView animation
    if (_step < 3 && step < 3) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step = step);
      return;
    }
    // Otherwise use fade transition for data steps
    await _stepFadeCtrl.reverse();
    if (!mounted) return;
    setState(() => _step = step);
    if (step < 3) {
      _pageController.jumpToPage(step);
    }
    _stepFadeCtrl.forward();
  }

  void _onTutorialPageChanged(int page) {
    if (page != _step && page < 3) {
      HapticFeedback.selectionClick();
      setState(() => _step = page);
    }
  }

  void _nextStep() {
    if (_step < 3) {
      // Tutorial pages → just advance
      _animateToStep(_step + 1);
    } else if (_step == 3 && _canContinueStep3) {
      _animateToStep(4);
    } else if (_step == 4 && _canContinueStep4) {
      _animateToStep(5);
    }
  }

  void _back() {
    if (_step > 0) {
      _animateToStep(_step - 1);
    }
  }

  Future<void> _finish() async {
    if (!_canFinish) return;
    setState(() => _saving = true);

    try {
      await AuthService.instance.completeOnboarding(
        jobTitle: _jobTitleController.text.trim(),
        industry: _selectedIndustry!,
        country: _selectedCountry ?? '',
      );
      if (_companyController.text.trim().isNotEmpty) {
        await AuthService.instance.updateProfile(
          company: _companyController.text.trim(),
        );
      }
      await InspectionStore.instance.loadForCurrentUser();
      await SiteStore.instance.loadForCurrentUser();
      final uid = AuthService.instance.currentUser?.uid;
      if (uid != null) {
        await RevenueCatService.instance.identify(uid);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        AppToast.show(context, 'Something went wrong. Please try again.', isError: true);
      }
    }
  }

  Future<void> _skip() async {
    setState(() => _saving = true);
    try {
      await AuthService.instance.completeOnboarding(
        jobTitle: '',
        industry: '',
      );
      await InspectionStore.instance.loadForCurrentUser();
      await SiteStore.instance.loadForCurrentUser();
      final uid = AuthService.instance.currentUser?.uid;
      if (uid != null) {
        await RevenueCatService.instance.identify(uid);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        AppToast.show(context, 'Something went wrong. Please try again.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final verticalPad = screenWidth >= 512 ? 56.0 : 24.0;

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
                          // ── Progress indicator ──
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: Row(
                              children: List.generate(_totalSteps, (i) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: i == 0 ? 0 : 4),
                                    child: _ProgressBar(
                                      active: i <= _step,
                                      complete: i < _step,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          // ── Step content ──
                          Expanded(
                            child: _step < 3
                                ? _buildTutorialPageView(context)
                                : FadeTransition(
                                    opacity: _stepFade,
                                    child: _step == 3
                                        ? _buildStep3(context)
                                        : _step == 4
                                            ? _buildStep4Country(context)
                                            : _buildStep5Industry(context),
                                  ),
                          ),

                          // ── Skip link ──
                          const SizedBox(height: 16),
                          Tappable(
                            onTap: _skip,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'SKIP FOR NOW',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary(context),
                                  letterSpacing: 0.4,
                                ),
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
        ),
      ),
    );
  }

  // ── Tutorial Steps (0–2) via swipeable PageView ──

  Widget _buildTutorialPageView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onTutorialPageChanged,
            itemCount: _tutorials.length,
            itemBuilder: (context, index) {
              final page = _tutorials[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child:
                          Icon(page.icon, size: 36, color: AppColors.primary),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      page.body,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary(context),
                        height: 1.5,
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              );
            },
          ),
        ),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _step == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                color: _step == i
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: _step == 2 ? 'Set Up Profile' : 'Next',
          width: double.infinity,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // ── Step 3: About You ──

  Widget _buildStep3(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About you',
            style: Theme.of(context).extension<AppTextStyles>()!.displayHero.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tell us about your role so we can personalise your experience.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),
          InputField(
            label: 'Job title',
            hintText: 'e.g. Site Safety Officer',
            controller: _jobTitleController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          InputField(
            label: 'Company (optional)',
            hintText: 'e.g. Acme Construction Ltd',
            controller: _companyController,
          ),
          const SizedBox(height: 36),
          AnimatedOpacity(
            opacity: _canContinueStep3 ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: PrimaryButton(
              text: 'Continue',
              width: double.infinity,
              enabled: _canContinueStep3,
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Country ──

  static const _countries = [
    _CountryOption(code: 'UK', flag: '\ud83c\uddec\ud83c\udde7', name: 'United Kingdom', body: 'HSE, CDM, LOLER, COSHH, CAR templates'),
    _CountryOption(code: 'US', flag: '\ud83c\uddfa\ud83c\uddf8', name: 'United States', body: 'OSHA 29 CFR, NFPA 70E, DOT inspections'),
    _CountryOption(code: 'AU', flag: '\ud83c\udde6\ud83c\uddfa', name: 'Australia', body: 'WHS Act, AS/NZS standards, SafeWork'),
    _CountryOption(code: 'CA', flag: '\ud83c\udde8\ud83c\udde6', name: 'Canada', body: 'OHSA, WHMIS 2015, provincial OHS regs'),
    _CountryOption(code: 'NZ', flag: '\ud83c\uddf3\ud83c\uddff', name: 'New Zealand', body: 'HSWA 2015, WorkSafe NZ, HSW Regulations'),
    _CountryOption(code: 'Global', flag: '\ud83c\udf10', name: 'Other / Global', body: 'Cross-industry templates, no region filter'),
  ];

  Widget _buildStep4Country(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tappable(
            onTap: _back,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14, color: AppColors.textSecondary(context)),
                const SizedBox(width: 6),
                Text(
                  'Back',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your region',
            style: Theme.of(context).extension<AppTextStyles>()!.displayHero.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll suggest inspection templates that match your local regulations.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          ..._countries.map((c) {
            final isSelected = _selectedCountry == c.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tappable(
                onTap: () => setState(() => _selectedCountry = c.code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : AppColors.surfaceColor(context),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderColor(context),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(c.flag, style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.body,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, size: 20, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          AnimatedOpacity(
            opacity: _canContinueStep4 ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: PrimaryButton(
              text: 'Continue',
              width: double.infinity,
              enabled: _canContinueStep4,
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 5: Industry ──

  Widget _buildStep5Industry(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tappable(
            onTap: _back,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14, color: AppColors.textSecondary(context)),
                const SizedBox(width: 6),
                Text(
                  'Back',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your industry',
            style: Theme.of(context).extension<AppTextStyles>()!.displayHero.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll recommend inspection templates based on your industry.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          ...Industry.all.map((ind) {
            final isSelected = _selectedIndustry == ind.name;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _IndustryRow(
                industry: ind,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedIndustry = ind.name),
              ),
            );
          }),
          const SizedBox(height: 28),
          AnimatedOpacity(
            opacity: _canFinish ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: PrimaryButton(
              text: 'Get Started',
              width: double.infinity,
              isLoading: _saving,
              enabled: _canFinish,
              onPressed: _finish,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Industry Row ────────────────────────────────────────────────────────────

class _IndustryRow extends StatelessWidget {
  final Industry industry;
  final bool isSelected;
  final VoidCallback onTap;

  const _IndustryRow({
    required this.industry,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surfaceColor(context),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderColor(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.backgroundColor(context),
              ),
              child: Icon(
                industry.icon,
                size: 18,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    industry.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    industry.tagline,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ─── Tutorial Page Data ──────────────────────────────────────────────────────

class _TutorialPage {
  final IconData icon;
  final String title;
  final String body;
  const _TutorialPage({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _CountryOption {
  final String code;
  final String flag;
  final String name;
  final String body;
  const _CountryOption({
    required this.code,
    required this.flag,
    required this.name,
    required this.body,
  });
}

// ─── Progress Bar ────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final bool active;
  final bool complete;
  const _ProgressBar({required this.active, required this.complete});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: complete
            ? AppColors.primary
            : active
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.borderColor(context),
      ),
    );
  }
}
