import 'package:flutter/material.dart';

class MemoDisplayBox extends StatelessWidget {
  final String text;

  const MemoDisplayBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342,
      height: 170,
      decoration: BoxDecoration(
        border: Border.all(
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 18,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
      ),
    );
  }
}
