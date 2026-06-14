import 'package:flutter/material.dart';
import 'package:fbro/core/theme/app_colors.dart';

/// The FBRO wordmark — a monochrome "FBRO" with a dashed baseline running
/// through it and two small dots. Pure black/grey/white, no asset required.
class FbroLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;

  const FbroLogo({super.key, this.fontSize = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return SizedBox(
      height: fontSize * 1.5,
      width: fontSize * 4.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _LogoDecorPainter(c.withAlpha(90))),
          ),
          Text(
            'FBRO',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: fontSize * 0.16,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoDecorPainter extends CustomPainter {
  final Color color;
  _LogoDecorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Dashed baseline through the vertical centre.
    const dash = 7.0;
    const gap = 6.0;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), line);
      x += dash + gap;
    }

    // Two small dots, top-right and bottom-right.
    final dot = Paint()..color = color;
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.16), 2.6, dot);
    canvas.drawCircle(Offset(size.width * 0.90, size.height * 0.84), 2.2, dot);
  }

  @override
  bool shouldRepaint(covariant _LogoDecorPainter old) => old.color != color;
}
