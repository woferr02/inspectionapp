import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';

/// A sleek dropdown that matches the InputField aesthetic.
///
/// Thin 1px border, 8px radius, white surface background,
/// same label style as InputField.
class FormDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T)? itemLabel;
  final Widget? prefixIcon;

  const FormDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
    this.prefixIcon,
  });

  String _label(T item) => itemLabel != null ? itemLabel!(item) : item.toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: EdgeInsets.only(
            left: prefixIcon != null ? 10 : 14,
            right: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderColor(context)),
            color: AppColors.surfaceColor(context),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: 6),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceColor(context),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textSecondary(context),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary(context),
                    ),
                    items: items
                        .map((item) => DropdownMenuItem<T>(
                              value: item,
                              child: Text(
                                _label(item),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (next) {
                      if (next != null) onChanged(next);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
