import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/tappable.dart';

/// A horizontal group of radio-style options matching the form aesthetic.
///
/// Renders filled circle for selected, empty circle for unselected,
/// with label text beside each option.
class FormRadioGroup<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T)? itemLabel;

  const FormRadioGroup({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  String _label(T item) => itemLabel != null ? itemLabel!(item) : item.toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: items.map((item) {
            final isSelected = item == value;
            return Tappable(
              onTap: () => onChanged(item),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderColor(context),
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _label(item),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
