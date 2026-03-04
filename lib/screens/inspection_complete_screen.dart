import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/routes.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';

/// Full-screen celebration shown when an inspection is completed.
class InspectionCompleteScreen extends StatefulWidget {
  final Inspection inspection;

  const InspectionCompleteScreen({super.key, required this.inspection});

  @override
  State<InspectionCompleteScreen> createState() =>
      _InspectionCompleteScreenState();
}

class _InspectionCompleteScreenState extends State<InspectionCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    // Checkmark scale-in
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);

    // Body fade-in
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Buttons slide-up
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    // Sequence the animations
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _scaleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        HapticFeedback.mediumImpact();
        _fadeCtrl.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.inspection.score;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // ── Animated checkmark ──
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Title + subtitle ──
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      Text(
                        'Inspection Complete',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.inspection.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      if (score != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _scoreColor(score).withValues(alpha: 0.1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$score%',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _scoreColor(score),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _scoreLabel(score),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _scoreColor(score),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Action buttons ──
                SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        PrimaryButton(
                          text: 'View Summary & Generate Report',
                          width: double.infinity,
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.inspectionSummary,
                              arguments: widget.inspection,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          text: 'Back to Dashboard',
                          width: double.infinity,
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.dashboard,
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Acceptable';
    if (score >= 50) return 'Needs Improvement';
    return 'Critical';
  }
}
