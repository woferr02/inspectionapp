import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';

class ScoreBadge extends StatelessWidget {
  final int score;
  final double fontSize;

  const ScoreBadge({
    super.key,
    required this.score,
    this.fontSize = 12,
  });

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$score%',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: _color,
      ),
    );
  }
}
