import 'package:flutter/material.dart';

class ListButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ListButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
        minimumSize: const Size(350, 80),
        maximumSize: const Size(350, 80),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
