import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';

enum AppChipVariant {
  /// Pill-shaped filter chip (selectable, filled when active).
  filter,

  /// Small status badge with tinted border (read-only).
  badge,
}

/// Unified chip / badge widget that replaces all one-off Container+Text combos.
class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final AppChipVariant variant;

  /// Only meaningful for [AppChipVariant.filter].
  final bool selected;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    required this.color,
    this.variant = AppChipVariant.badge,
    this.selected = false,
    this.onTap,
  });

  /// Convenience: status badge (bordered pill, no tap).
  const AppChip.badge({
    super.key,
    required this.label,
    required this.color,
  })  : variant = AppChipVariant.badge,
        selected = false,
        onTap = null;

  /// Convenience: selectable filter pill.
  const AppChip.filter({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    this.onTap,
  }) : variant = AppChipVariant.filter;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppChipVariant.badge:
        return _buildBadge(context);
      case AppChipVariant.filter:
        return _buildFilter(context);
    }
  }

  Widget _buildBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
      ),
    );
  }

  Widget _buildFilter(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? color : AppColors.borderColor(context),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }
}
