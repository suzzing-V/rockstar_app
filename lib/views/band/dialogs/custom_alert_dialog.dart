import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/custom_text_button.dart';
import 'package:rockstar_app/common/text/highlight_text.dart';

class StartAfterEndAlertDialog extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onConfirm;

  const StartAfterEndAlertDialog({
    super.key,
    required this.message,
    required this.onConfirm,
    this.buttonText = '확인',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: HighlightText(
        label: message,
        fontSize: 18,
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
