import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final Color? color;
  final double iconSize;
  final VoidCallback? onPressed;

  const CustomBackButton({
    super.key,
    this.color,
    this.iconSize = 23,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      iconSize: iconSize,
      onPressed: onPressed ?? () => Navigator.pop(context),
      color: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}
