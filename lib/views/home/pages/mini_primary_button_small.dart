import 'package:flutter/material.dart';

class MiniPrimaryButtonSmall extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const MiniPrimaryButtonSmall(
      {super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withOpacity(0.6)),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0), // Adjusted padding
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 18, // Increased font size
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
