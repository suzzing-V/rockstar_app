import 'package:flutter/material.dart';

class MiniSecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const MiniSecondaryButton(
      {super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(130, 55),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
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
