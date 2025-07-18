import 'package:flutter/material.dart';
import 'package:rockstar_app/common/text/primary_text.dart';

class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double fontSize;

  const CustomTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: PrimaryText(
        label: label,
        fontSize: fontSize,
      ),
    );
  }
}
