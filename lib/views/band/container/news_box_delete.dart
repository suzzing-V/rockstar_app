import 'package:flutter/material.dart';
import 'package:rockstar_app/common/text/highlight_text.dart';

class NewsBoxDelete extends StatelessWidget {
  final String text1;
  final String text2;

  const NewsBoxDelete({super.key, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8);

    return CustomPaint(
      painter: BalloonPainter(
        fillColor: borderColor,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300, // 원하는 최대 너비로 설정
        ),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HighlightText(label: text1, fontSize: 18),
            HighlightText(label: text2, fontSize: 25),
          ],
        ),
      ),
    );
  }
}

class BalloonPainter extends CustomPainter {
  final Color fillColor;

  BalloonPainter({required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromLTRBR(
      0,
      0,
      size.width - 10,
      size.height,
      Radius.circular(10),
    );

    // ✅ 내부만 그리기
    canvas.drawRRect(rrect, fillPaint);

    // ✅ 꼬리 그리기
    final path = Path();
    final tailY = size.height - 15;
    path.moveTo(size.width - 10, tailY - 6);
    path.lineTo(size.width, tailY);
    path.lineTo(size.width - 10, tailY + 6);
    path.close();

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
