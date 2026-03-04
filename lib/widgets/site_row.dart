import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/models/site.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

class SiteRow extends StatelessWidget {
  final Site site;
  final VoidCallback? onTap;
  final bool showDivider;

  const SiteRow({
    Key? key,
    required this.site,
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
                        site.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        site.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${site.inspectionCount} inspection${site.inspectionCount != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
}
