import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_layout.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';

/// A signature capture pad that returns PNG bytes.
class SignaturePad extends StatefulWidget {
  final String label;
  final ValueChanged<Uint8List?> onSigned;

  const SignaturePad({
    super.key,
    this.label = 'Sign here',
    required this.onSigned,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  late final HandSignatureControl _control;
  bool _signed = false;

  @override
  void initState() {
    super.initState();
    _control = HandSignatureControl(
      threshold: 3.0,
      smoothRatio: 0.65,
      velocityRange: 2.0,
    );
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final byteData = await _control.toImage(
      color: Colors.black,
      background: Colors.white,
      fit: true,
    );
    if (byteData != null) {
      final bytes = byteData.buffer.asUint8List();
      setState(() => _signed = true);
      widget.onSigned(bytes);
    }
  }

  void _clear() {
    _control.clear();
    setState(() => _signed = false);
    widget.onSigned(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _signed ? AppColors.success : AppColors.borderColor(context),
              width: _signed ? 2 : 1,
            ),
            color: AppColors.surfaceColor(context),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: HandSignature(
              control: _control,
              color: AppColors.textPrimary(context),
              width: 2.0,
              maxWidth: 4.0,
              type: SignatureDrawType.shape,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Clear',
                onPressed: _clear,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: _signed ? 'Signed' : 'Confirm',
                onPressed: _signed ? () {} : () { _confirm(); },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
