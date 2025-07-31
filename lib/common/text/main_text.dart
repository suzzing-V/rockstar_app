import 'package:flutter/material.dart';

class MainText extends StatelessWidget {
  final double fontSize;
  final String label;
  final Color? color;

  final int? maxLines;
  final TextOverflow? overflow;

  const MainText({
    super.key,
    this.fontSize = 25,
    this.label = "",
    this.color,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: maxLines, // ✅ 적용
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'PixelFont',
        fontSize: fontSize,
        color: color ?? Theme.of(context).colorScheme.secondaryContainer,
      ),
    );
  }
}
