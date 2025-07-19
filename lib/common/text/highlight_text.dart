import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final Color? color;
  final double fontSize;
  final String label;

  const HighlightText(
      {super.key, this.color, this.fontSize = 23, this.label = ""});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'PixelFont',
        fontSize: fontSize,
        color: color ?? Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
