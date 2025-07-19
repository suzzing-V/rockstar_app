import 'package:flutter/material.dart';

class MainText extends StatelessWidget {
  final double fontSize;
  final String label;
  final Color? color;

  const MainText({super.key, this.fontSize = 25, this.label = "", this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'PixelFont',
        fontSize: fontSize,
        color: color ?? Theme.of(context).colorScheme.secondaryContainer,
      ),
    );
  }
}
