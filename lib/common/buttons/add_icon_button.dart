import 'package:flutter/material.dart';

class AddIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(300, 60),
        maximumSize: const Size(300, 60),
        side: BorderSide(
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
          width: 3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.transparent,
      ),
      onPressed: onPressed,
      child: Align(
        alignment: Alignment.center,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primaryFixed,
          size: 40,
        ),
      ),
    );
  }
}
