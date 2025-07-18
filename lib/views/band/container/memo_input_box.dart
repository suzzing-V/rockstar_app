import 'package:flutter/material.dart';

class MemoInputBox extends StatelessWidget {
  final TextEditingController controller;

  const MemoInputBox({super.key, required this.controller});

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
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: TextField(
        controller: controller,
        expands: true,
        maxLines: null,
        minLines: null,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        maxLength: 100,
        style: TextStyle(
          fontFamily: 'PixelFont',
          fontSize: 18,
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        decoration: const InputDecoration(
          hintText: '입력하세요',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );
  }
}
