import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/page_header.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _buildTappableRow(BuildContext context, String label,
      {bool showDivider = true}) {
    return Column(
      children: [
        Tappable(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.dividerColor(context),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: "About",
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: AppViewport(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x3,
                    AppSpacing.x3,
                    AppSpacing.x3,
                    AppSpacing.x4,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                color: AppColors.primary,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.shield_outlined,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "SafeCheck Pro",
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Version 1.0.0 (42)",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Built by SafeCheck Ltd",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildTappableRow(context, "Website"),
                      _buildTappableRow(context, "Support"),
                      _buildTappableRow(context, "Terms of Service"),
                      _buildTappableRow(context, "Privacy Policy",
                          showDivider: false),
                      const SizedBox(height: AppSpacing.x4),
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
}
