import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable press-animation wrapper.
/// Wraps any child with a scale-down animation on press, providing
/// the spec-required "smooth press animations on ALL tappable elements".
/// Includes light haptic feedback on every tap.
class Tappable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableHaptic;

  const Tappable({
    super.key,
    required this.child,
    this.onTap,
    this.enableHaptic = true,
  });

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.onTap == null) return;
    if (widget.enableHaptic) HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
