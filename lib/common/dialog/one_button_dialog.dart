import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/custom_text_button.dart';
import 'package:rockstar_app/common/text/highlight_text.dart';
import 'package:rockstar_app/common/text/primary_text.dart';

class OneButtonDialog extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onConfirm;
  final String content;

  const OneButtonDialog(
      {super.key,
      required this.title,
      required this.onConfirm,
      this.buttonText = '확인',
      this.content = ""});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: HighlightText(
        label: title,
        fontSize: 18,
      ),
      content: PrimaryText(
        label: content,
        fontSize: 14,
      ),
      actions: [
        CustomTextButton(
          label: buttonText,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}
