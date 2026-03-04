import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';

class InputField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final int? minLines;

  const InputField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _hasFocus = false;
  late bool _obscured;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final isMultiline = widget.maxLines > 1;
    final borderColor = hasError
        ? AppColors.error
        : _hasFocus
            ? AppColors.primary
            : AppColors.borderColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: borderColor,
                width: _hasFocus ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                if (widget.prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 14),
                    child: widget.prefixIcon!,
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 8 : 14,
                      vertical: 0,
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: _obscured,
                      enabled: widget.enabled,
                      keyboardType: isMultiline
                          ? TextInputType.multiline
                          : widget.keyboardType,
                      onChanged: widget.onChanged,
                      maxLines: widget.obscureText ? 1 : widget.maxLines,
                      minLines: widget.minLines,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary(context),
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary(context),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isMultiline ? 14 : 14,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.obscureText)
                  GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Icon(
                        _obscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.textTertiary(context),
                      ),
                    ),
                  )
                else if (widget.suffixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: widget.suffixIcon!,
                  ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
