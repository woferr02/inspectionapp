import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor(context),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _BottomNavTab(
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Dashboard',
              onTap: () => onTabSelected(0),
            ),
            _BottomNavTab(
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.assignment_outlined,
              activeIcon: Icons.assignment,
              label: 'Inspections',
              onTap: () => onTabSelected(1),
            ),
            _BottomNavTab(
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.location_on_outlined,
              activeIcon: Icons.location_on,
              label: 'Sites',
              onTap: () => onTabSelected(2),
            ),
            _BottomNavTab(
              index: 3,
              currentIndex: currentIndex,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'Settings',
              onTap: () => onTabSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavTab extends StatefulWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavTab({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_BottomNavTab> createState() => _BottomNavTabState();
}

class _BottomNavTabState extends State<_BottomNavTab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentIndex == widget.index;
    final textColor = isActive
        ? AppColors.primary
        : AppColors.textSecondary(context);
    final iconColor = isActive
        ? AppColors.primary
        : AppColors.textTertiary(context);

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: isActive
                      ? BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        )
                      : null,
                  child: Icon(
                    isActive ? widget.activeIcon : widget.icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
