import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';

/// A bold section label used to group related form fields,
/// matching the Figma template's "Company information" / "Credit card information" style.
class FormSectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const FormSectionLabel({
    super.key,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
