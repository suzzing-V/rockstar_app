import 'package:flutter/material.dart';

class PrimaryText extends StatelessWidget {
  final Color? color;
  final double fontSize;
  final VoidCallback? onPressed;
  final String label;

  const PrimaryText(
      {super.key,
      this.color,
      this.fontSize = 23,
      this.onPressed,
      this.label = ""});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'PixelFont',
        fontSize: fontSize,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
