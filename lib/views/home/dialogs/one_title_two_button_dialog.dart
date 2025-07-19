import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/custom_text_button.dart';
import 'package:rockstar_app/common/text/highlight_text.dart';
import 'package:rockstar_app/common/text/primary_text.dart';

class OneTitleTwoButtonDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const OneTitleTwoButtonDialog({
    super.key,
    required this.title,
    this.content = "",
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 5, right: 8),
      title: HighlightText(
        label: title,
        fontSize: 18,
      ),
      content: PrimaryText(
        label: content,
        fontSize: 14,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomTextButton(
              label: '확인',
              onPressed: () {
                onConfirm(); // ✅ 주입된 로직 실행
              },
            ),
            CustomTextButton(
              label: '취소',
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ],
    );
  }
}
