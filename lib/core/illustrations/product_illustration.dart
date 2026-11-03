import 'package:flutter/material.dart';

import '../../data/models/furniture_kind.dart';
import 'furniture_painter.dart';

/// Renders a furniture illustration in a square area.
///
/// [view] selects the "photo": 0 front, 1 mirrored, 2 close-up, 3 in a room.
/// Changing [color] animates smoothly between tones.
class ProductIllustration extends StatelessWidget {
  const ProductIllustration({
    super.key,
    required this.kind,
    required this.color,
    this.view = 0,
  });

  final FurnitureKind kind;
  final Color color;
  final int view;

  @override
  Widget build(BuildContext context) {
    Widget art = RepaintBoundary(
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: color),
        duration: const Duration(milliseconds: 380),
        builder: (context, value, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: FurniturePainter(kind: kind, color: value ?? color),
          );
        },
      ),
    );

    if (view == 1) {
      art = Transform.flip(flipX: true, child: art);
    } else if (view == 2) {
      art = ClipRect(
        child: Transform.scale(
          scale: 1.5,
          alignment: const Alignment(0, 0.3),
          child: art,
        ),
      );
    } else if (view == 3) {
      art = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _RoomPainter()),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 4),
              child: art,
            ),
          ],
        ),
      );
    }

    return Center(
      child: AspectRatio(aspectRatio: 1, child: art),
    );
  }
}

class _RoomPainter extends CustomPainter {
  const _RoomPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final wallRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.74);
    canvas.drawRect(
      wallRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4EFE8), Color(0xFFE7DED3)],
        ).createShader(wallRect),
    );
    final floorRect = Rect.fromLTWH(
      0,
      size.height * 0.74,
      size.width,
      size.height * 0.26,
    );
    canvas.drawRect(
      floorRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCDB394), Color(0xFFB59676)],
        ).createShader(floorRect),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.74 - 3, size.width, 4),
      Paint()..color = const Color(0x55FFFFFF),
    );

    // Window.
    final window = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.62,
        size.height * 0.1,
        size.width * 0.26,
        size.height * 0.34,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(window, Paint()..color = const Color(0xFFEAF2F7));
    final frame = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(window, frame);
    canvas.drawLine(
      Offset(window.left + window.width / 2, window.top),
      Offset(window.left + window.width / 2, window.bottom),
      frame..strokeWidth = 1.5,
    );

    // Picture frame.
    final picture = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.16,
        size.width * 0.17,
        size.height * 0.22,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(picture, Paint()..color = const Color(0xFF6E8260));
    canvas.drawRRect(
      picture.deflate(3),
      Paint()..color = const Color(0xFFB9C8A9),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
