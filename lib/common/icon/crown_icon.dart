import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CrownIcon extends StatelessWidget {
  final double size;

  const CrownIcon({
    super.key,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(FontAwesomeIcons.crown, size: size, color: Colors.amber);
  }
}
