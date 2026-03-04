import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final BorderRadiusGeometry borderRadius;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: borderRadius,
        border: Border.all(
          color: AppColors.borderColor(context),
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    return onTap != null
        ? Tappable(onTap: onTap, child: content)
        : content;
  }
}
