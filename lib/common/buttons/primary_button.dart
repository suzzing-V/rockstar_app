import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final TextStyle? textStyle;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 220,
    this.height = 55,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(220, 55), // 버튼 자체 크기
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: TextStyle(fontSize: 18),
      ),
      child: Text(label,
          style: TextStyle(
            fontFamily: 'PixelFont',
          )),
    );
  }
}
