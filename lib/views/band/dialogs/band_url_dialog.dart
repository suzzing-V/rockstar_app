import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rockstar_app/common/buttons/custom_text_button.dart';
import 'package:rockstar_app/common/text/highlight_text.dart';

class BandUrlDialog extends StatelessWidget {
  final String bandUrl;

  const BandUrlDialog({
    super.key,
    required this.bandUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const HighlightText(
        label: "밴드 초대 링크",
        fontSize: 18,
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(
            bandUrl,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'PixelFont',
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          CustomTextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: bandUrl,
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("초대 링크가 복사되었습니다")),
              );
            },
            // icon: const Icon(Icons.copy),
            label: "복사하기",
          ),
        ],
      ),
    );
  }
}
