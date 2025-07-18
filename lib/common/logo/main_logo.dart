import 'package:flutter/material.dart';

class MainLogo extends StatelessWidget {
  final double width;
  final double height;

  const MainLogo({
    super.key,
    this.width = 220,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/rockstar_logo.png',
      width: width,
      height: height,
    );
  }
}
