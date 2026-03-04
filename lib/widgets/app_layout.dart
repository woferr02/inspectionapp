import 'package:flutter/material.dart';

class AppSpacing {
  static const double x1 = 8;
  static const double x2 = 16;
  static const double x3 = 24;
  static const double x4 = 32;
  static const double x5 = 40;
}

/// Design-system border radius tokens.
class AppRadius {
  static const double sm = 6;    // small badges, score pills
  static const double md = 10;   // inputs, dropdowns, cards inner
  static const double lg = 12;   // surface cards, section blocks
  static const double xl = 20;   // bottom sheets
  static const double pill = 999; // buttons, chips, pills
}

class AppLayout {
  static const double maxContentWidth = 1040;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1280) return 40;
    if (width >= 768) return 24;
    return 16;
  }
}

class AppViewport extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppViewport({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = AppLayout.horizontalPadding(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        ),
      ),
    );
  }
}
