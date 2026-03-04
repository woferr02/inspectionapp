import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/models/inspection.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class InspectionRow extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback? onTap;
  final bool showDivider;

  const InspectionRow({
    Key? key,
    required this.inspection,
    this.onTap,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Tappable(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inspection.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${inspection.siteName} · ${_formatDate(inspection.date)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (inspection.score != null)
                  _buildScoreBadge(context)
                else
                  _buildStatusBadge(context),
                const SizedBox(width: 8),
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
            color: AppColors.dividerColor(context),
          ),
      ],
    );
  }

  Widget _buildScoreBadge(BuildContext context) {
    final score = inspection.score!;
    final Color color;
    if (score >= 80) {
      color = AppColors.success;
    } else if (score >= 60) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        '$score%',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String text;

    switch (inspection.status) {
      case InspectionStatus.draft:
        badgeColor = AppColors.warning;
        text = 'Draft';
        break;
      case InspectionStatus.inProgress:
        badgeColor = AppColors.primary;
        text = 'In Progress';
        break;
      case InspectionStatus.completed:
        badgeColor = AppColors.success;
        text = 'Completed';
        break;
      case InspectionStatus.submitted:
        badgeColor = AppColors.info;
        text = 'Submitted';
        break;
      case InspectionStatus.archived:
        badgeColor = const Color(0xFF9CA3AF);
        text = 'Archived';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: badgeColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
