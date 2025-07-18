import 'package:flutter/material.dart';

class MiniPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const MiniPrimaryButton(
      {super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        minimumSize: const Size(130, 55),
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PixelFont',
        ),
      ),
    );
  }
}
