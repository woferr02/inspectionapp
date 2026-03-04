import 'package:flutter/material.dart';

/// Lays out two children side-by-side with consistent spacing,
/// just like the Figma form template's split fields (First/Last, MM/YY + CCV).
class FormFieldRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const FormFieldRow({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}
