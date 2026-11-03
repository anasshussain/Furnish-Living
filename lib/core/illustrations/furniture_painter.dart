import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/furniture_kind.dart';

const Color _legDark = Color(0xFF2B2B2B);
const Color _metal = Color(0xFFC9A24B);
const List<Color> _bookColors = [
  Color(0xFFC0512F),
  Color(0xFF3C6DB5),
  Color(0xFFD9A93E),
  Color(0xFF5E8B4F),
  Color(0xFFEFE7DA),
  Color(0xFF2B2B2B),
];

class FurniturePainter extends CustomPainter {
  const FurniturePainter({required this.kind, required this.color});

  final FurnitureKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    switch (kind) {
      case FurnitureKind.tubChair:
        _tubChair(canvas, color);
      case FurnitureKind.bubbleChair:
        _bubbleChair(canvas, color);
      case FurnitureKind.wingChair:
        _wingChair(canvas, color);
      case FurnitureKind.shellChair:
        _shellChair(canvas, color);
      case FurnitureKind.sofa:
        _sofa(canvas, color, 3);
      case FurnitureKind.loveseat:
        _sofa(canvas, color, 2);
      case FurnitureKind.diningTable:
        _diningTable(canvas, color);
      case FurnitureKind.coffeeTable:
        _coffeeTable(canvas, color);
      case FurnitureKind.barStool:
        _barStool(canvas, color);
      case FurnitureKind.kitchenIsland:
        _kitchenIsland(canvas, color);
      case FurnitureKind.bed:
        _bed(canvas, color);
      case FurnitureKind.floorLamp:
        _floorLamp(canvas, color);
      case FurnitureKind.bookshelf:
        _bookshelf(canvas, color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(FurniturePainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.color != color;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Color _shade(Color c, double delta) {
  final hsl = HSLColor.fromColor(c);
  final lightness = (hsl.lightness + delta).clamp(0.0, 1.0).toDouble();
  return hsl.withLightness(lightness).toColor();
}

Paint _fill(Color c) => Paint()
  ..color = c
  ..style = PaintingStyle.fill;

Paint _stroke(Color c, double width) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

Paint _vertical(Rect rect, Color top, Color bottom) => Paint()
  ..shader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [top, bottom],
  ).createShader(rect);

RRect _rr(double l, double t, double r, double b, double radius) =>
    RRect.fromLTRBR(l, t, r, b, Radius.circular(radius));

void _shadow(Canvas canvas, double cx, double cy, double rx, double ry) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
    Paint()
      ..color = const Color(0x30000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
}

void _tubChair(Canvas canvas, Color base) {
  _shadow(canvas, 50, 89, 32, 4.5);
  canvas.drawRRect(_rr(28, 80, 33, 92, 2.5), _fill(_legDark));
  canvas.drawRRect(_rr(67, 80, 72, 92, 2.5), _fill(_legDark));

  final back = Path()
    ..moveTo(16, 74)
    ..cubicTo(10, 40, 28, 14, 50, 14)
    ..cubicTo(72, 14, 90, 40, 84, 74)
    ..close();
  canvas.drawPath(
    back,
    _vertical(
      Rect.fromLTWH(10, 14, 80, 60),
      _shade(base, 0.05),
      _shade(base, -0.12),
    ),
  );

  final inner = Path()
    ..moveTo(26, 68)
    ..cubicTo(23, 44, 35, 27, 50, 27)
    ..cubicTo(65, 27, 77, 44, 74, 68)
    ..close();
  canvas.drawPath(
    inner,
    _vertical(
      Rect.fromLTWH(23, 27, 54, 41),
      _shade(base, -0.1),
      _shade(base, -0.02),
    ),
  );

  canvas.drawRRect(
    _rr(24, 58, 76, 74, 9),
    _vertical(
      Rect.fromLTWH(24, 58, 52, 16),
      _shade(base, 0.1),
      _shade(base, 0.02),
    ),
  );
  canvas.drawRRect(
    _rr(14, 68, 86, 84, 10),
    _vertical(
      Rect.fromLTWH(14, 68, 72, 16),
      _shade(base, 0.05),
      _shade(base, -0.09),
    ),
  );
  canvas.drawRRect(_rr(22, 70, 52, 73, 1.5), _fill(const Color(0x22FFFFFF)));
}

void _lobe(Canvas canvas, double x, double y, double r, Color base) {
  final center = Offset(x, y);
  canvas.drawCircle(
    center,
    r,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.95,
        colors: [_shade(base, 0.12), base, _shade(base, -0.14)],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r)),
  );
}

void _bubbleChair(Canvas canvas, Color base) {
  _shadow(canvas, 50, 89, 36, 4.5);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 66), width: 88, height: 44),
    _fill(_shade(base, -0.2)),
  );
  const back = [
    [22.0, 54.0, 12.0],
    [36.0, 42.0, 13.0],
    [54.0, 39.0, 13.0],
    [70.0, 44.0, 12.5],
    [80.0, 58.0, 11.0],
  ];
  const front = [
    [18.0, 68.0, 11.0],
    [32.0, 73.0, 13.0],
    [50.0, 75.0, 13.5],
    [68.0, 73.0, 13.0],
    [81.0, 68.0, 10.5],
  ];
  for (final l in back) {
    _lobe(canvas, l[0], l[1], l[2], base);
  }
  _lobe(canvas, 50, 58, 14, base);
  for (final l in front) {
    _lobe(canvas, l[0], l[1], l[2], base);
  }
}

void _wingChair(Canvas canvas, Color base) {
  _shadow(canvas, 50, 90, 32, 4);
  canvas.drawLine(const Offset(26, 82), const Offset(22, 92), _stroke(_legDark, 3.2));
  canvas.drawLine(const Offset(74, 82), const Offset(78, 92), _stroke(_legDark, 3.2));

  canvas.drawRRect(
    _rr(26, 12, 74, 70, 16),
    _vertical(
      Rect.fromLTWH(26, 12, 48, 58),
      _shade(base, 0.02),
      _shade(base, -0.12),
    ),
  );
  for (var row = 0; row < 3; row++) {
    for (var col = 0; col < 3; col++) {
      canvas.drawCircle(
        Offset(38.0 + 12 * col, 24.0 + 12 * row),
        1.5,
        _fill(_shade(base, -0.24)),
      );
    }
  }
  canvas.drawRRect(
    _rr(12, 44, 34, 82, 11),
    _vertical(
      Rect.fromLTWH(12, 44, 22, 38),
      _shade(base, 0.06),
      _shade(base, -0.08),
    ),
  );
  canvas.drawRRect(
    _rr(66, 44, 88, 82, 11),
    _vertical(
      Rect.fromLTWH(66, 44, 22, 38),
      _shade(base, 0.06),
      _shade(base, -0.08),
    ),
  );
  canvas.drawRRect(
    _rr(30, 58, 70, 76, 8),
    _vertical(
      Rect.fromLTWH(30, 58, 40, 18),
      _shade(base, 0.1),
      _shade(base, 0.02),
    ),
  );
  canvas.drawRRect(_rr(28, 72, 72, 82, 5), _fill(_shade(base, -0.06)));
}

void _shellChair(Canvas canvas, Color base) {
  const wood = Color(0xFFB98B5E);
  _shadow(canvas, 50, 90, 26, 4);
  canvas.drawLine(const Offset(34, 76), const Offset(28, 92), _stroke(wood, 3));
  canvas.drawLine(const Offset(66, 76), const Offset(72, 92), _stroke(wood, 3));

  final back = Path()
    ..moveTo(22, 70)
    ..cubicTo(14, 34, 34, 12, 50, 12)
    ..cubicTo(66, 12, 86, 34, 78, 70)
    ..close();
  canvas.drawPath(
    back,
    _vertical(
      Rect.fromLTWH(14, 12, 72, 58),
      _shade(base, 0.04),
      _shade(base, -0.1),
    ),
  );
  final rib = _stroke(_shade(base, -0.16), 0.9);
  for (var i = 0; i <= 5; i++) {
    final t = i / 5;
    final x = 24 + 52 * t;
    final y = 30 - 18 * math.sin(math.pi * t);
    canvas.drawLine(Offset(50, 66), Offset(x, y), rib);
  }
  canvas.drawRRect(
    _rr(26, 62, 74, 78, 9),
    _vertical(
      Rect.fromLTWH(26, 62, 48, 16),
      _shade(base, 0.1),
      _shade(base, 0.0),
    ),
  );
}

// ---------------------------------------------------------------------------
// Sofas
// ---------------------------------------------------------------------------

void _sofa(Canvas canvas, Color base, int seats) {
  final l = seats == 3 ? 4.0 : 14.0;
  final r = 100.0 - l;
  _shadow(canvas, 50, 89, (r - l) / 2, 4);

  canvas.drawRRect(_rr(l + 8, 80, l + 13, 91, 2), _fill(_legDark));
  canvas.drawRRect(_rr(r - 13, 80, r - 8, 91, 2), _fill(_legDark));

  canvas.drawRRect(
    _rr(l + 8, 30, r - 8, 62, 9),
    _vertical(
      Rect.fromLTWH(l + 8, 30, r - l - 16, 32),
      _shade(base, -0.02),
      _shade(base, -0.13),
    ),
  );

  final innerStart = l + 18;
  final innerEnd = r - 18;
  final width = (innerEnd - innerStart) / seats;

  for (var i = 0; i < seats; i++) {
    final x0 = innerStart + width * i;
    canvas.drawRRect(
      _rr(x0 + 1, 36, x0 + width - 1, 58, 6),
      _vertical(
        Rect.fromLTWH(x0, 36, width, 22),
        _shade(base, 0.06),
        _shade(base, -0.04),
      ),
    );
  }

  canvas.drawRRect(
    _rr(l + 4, 62, r - 4, 82, 6),
    _vertical(
      Rect.fromLTWH(l + 4, 62, r - l - 8, 20),
      _shade(base, -0.02),
      _shade(base, -0.12),
    ),
  );

  for (var i = 0; i < seats; i++) {
    final x0 = innerStart + width * i;
    canvas.drawRRect(
      _rr(x0 + 0.6, 56, x0 + width - 0.6, 72, 5),
      _vertical(
        Rect.fromLTWH(x0, 56, width, 16),
        _shade(base, 0.1),
        _shade(base, 0.02),
      ),
    );
  }

  canvas.drawRRect(
    _rr(l, 44, l + 18, 80, 9),
    _vertical(
      Rect.fromLTWH(l, 44, 18, 36),
      _shade(base, 0.05),
      _shade(base, -0.09),
    ),
  );
  canvas.drawRRect(
    _rr(r - 18, 44, r, 80, 9),
    _vertical(
      Rect.fromLTWH(r - 18, 44, 18, 36),
      _shade(base, 0.05),
      _shade(base, -0.09),
    ),
  );
}

void _diningTable(Canvas canvas, Color base) {
  _shadow(canvas, 50, 90, 40, 4);
  canvas.drawRRect(_rr(22, 46, 26.5, 76, 1.5), _fill(_shade(base, -0.22)));
  canvas.drawRRect(_rr(73.5, 46, 78, 76, 1.5), _fill(_shade(base, -0.22)));

  final top = Path()
    ..moveTo(18, 36)
    ..lineTo(82, 36)
    ..lineTo(95, 52)
    ..lineTo(5, 52)
    ..close();
  canvas.drawPath(
    top,
    _vertical(
      Rect.fromLTWH(5, 36, 90, 16),
      _shade(base, 0.1),
      _shade(base, 0.0),
    ),
  );
  final grain = _stroke(_shade(base, -0.08).withValues(alpha: 0.55), 0.6);
  for (var i = 1; i <= 3; i++) {
    final y = 36.0 + i * 4;
    final inset = 13.0 * (1 - i / 4) + 1;
    canvas.drawLine(Offset(5 + inset * 1.0, y), Offset(95 - inset, y), grain);
  }
  canvas.drawRRect(_rr(5, 52, 95, 58, 2), _fill(_shade(base, -0.1)));
  canvas.drawRRect(_rr(9, 58, 15, 90, 2), _fill(_shade(base, -0.16)));
  canvas.drawRRect(_rr(85, 58, 91, 90, 2), _fill(_shade(base, -0.16)));
}

void _coffeeTable(Canvas canvas, Color base) {
  _shadow(canvas, 50, 89, 34, 4);
  canvas.drawLine(const Offset(50, 56), const Offset(50, 80), _stroke(_metal, 2.4));
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 77), width: 52, height: 12),
    _fill(_shade(base, -0.18)),
  );
  canvas.drawLine(const Offset(26, 56), const Offset(30, 86), _stroke(_metal, 2.6));
  canvas.drawLine(const Offset(74, 56), const Offset(70, 86), _stroke(_metal, 2.6));
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 54), width: 80, height: 22),
    _fill(_shade(base, -0.2)),
  );
  final topRect = Rect.fromCenter(
    center: const Offset(50, 49),
    width: 80,
    height: 22,
  );
  canvas.drawOval(
    topRect,
    _vertical(topRect, _shade(base, 0.1), _shade(base, -0.02)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 49), width: 62, height: 15),
    _stroke(const Color(0x33FFFFFF), 0.8),
  );
}

void _barStool(Canvas canvas, Color base) {
  _shadow(canvas, 50, 90, 22, 3.5);
  final leg = _stroke(_legDark, 3);
  canvas.drawLine(const Offset(38, 46), const Offset(32, 90), leg);
  canvas.drawLine(const Offset(62, 46), const Offset(68, 90), leg);
  canvas.drawLine(const Offset(50, 48), const Offset(50, 88), leg);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 72), width: 36, height: 8),
    _stroke(_metal, 2),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 41), width: 54, height: 16),
    _fill(_shade(base, -0.18)),
  );
  final seat = Rect.fromCenter(
    center: const Offset(50, 36),
    width: 54,
    height: 16,
  );
  canvas.drawOval(
    seat,
    _vertical(seat, _shade(base, 0.12), _shade(base, 0.0)),
  );
}

void _kitchenIsland(Canvas canvas, Color base) {
  _shadow(canvas, 50, 89, 42, 4);
  canvas.drawRect(Rect.fromLTWH(14, 84, 72, 5), _fill(_legDark));
  canvas.drawRRect(
    _rr(10, 44, 90, 85, 3),
    _vertical(
      Rect.fromLTWH(10, 44, 80, 41),
      _shade(base, 0.04),
      _shade(base, -0.1),
    ),
  );
  for (var i = 0; i < 3; i++) {
    final x = 14.0 + i * 25.3;
    canvas.drawRRect(
      _rr(x, 49, x + 23.5, 80, 2),
      _stroke(_shade(base, -0.16), 0.8),
    );
    canvas.drawLine(Offset(x + 17, 58), Offset(x + 17, 66), _stroke(_metal, 1.3));
  }
  canvas.drawRRect(
    _rr(5, 36, 95, 46, 2.5),
    _vertical(
      Rect.fromLTWH(5, 36, 90, 10),
      const Color(0xFFFFFFFF),
      const Color(0xFFE2DED8),
    ),
  );
  canvas.drawRRect(_rr(18, 27, 28, 36, 2), _fill(_shade(base, 0.12)));
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(20, 23), width: 8, height: 14),
    _fill(const Color(0xFF5E8B4F)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(26, 22), width: 8, height: 14),
    _fill(const Color(0xFF4A7440)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(23, 20), width: 7, height: 15),
    _fill(const Color(0xFF6E9C5D)),
  );
}

void _bed(Canvas canvas, Color base) {
  _shadow(canvas, 50, 90, 42, 4);
  canvas.drawRRect(_rr(10, 80, 16, 91, 2), _fill(_legDark));
  canvas.drawRRect(_rr(84, 80, 90, 91, 2), _fill(_legDark));

  canvas.drawRRect(
    _rr(10, 24, 90, 58, 9),
    _vertical(
      Rect.fromLTWH(10, 24, 80, 34),
      _shade(base, -0.02),
      _shade(base, -0.14),
    ),
  );
  canvas.drawRRect(_rr(6, 52, 94, 80, 6), _fill(const Color(0xFFF2EFEA)));
  canvas.drawRRect(_rr(16, 44, 44, 60, 6), _fill(const Color(0xFFFFFFFF)));
  canvas.drawRRect(_rr(56, 44, 84, 60, 6), _fill(const Color(0xFFFFFFFF)));
  canvas.drawRRect(
    _rr(16, 44, 44, 60, 6),
    _stroke(const Color(0x14000000), 0.8),
  );
  canvas.drawRRect(
    _rr(56, 44, 84, 60, 6),
    _stroke(const Color(0x14000000), 0.8),
  );
  canvas.drawRRect(
    _rr(6, 62, 94, 80, 6),
    _vertical(
      Rect.fromLTWH(6, 62, 88, 18),
      _shade(base, 0.08),
      _shade(base, -0.06),
    ),
  );
  canvas.drawRRect(_rr(6, 62, 94, 67, 3), _fill(_shade(base, 0.14)));
}

void _floorLamp(Canvas canvas, Color base) {
  final glowCenter = const Offset(50, 30);
  canvas.drawCircle(
    glowCenter,
    36,
    Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x55FFE9A8), Color(0x00FFE9A8)],
      ).createShader(Rect.fromCircle(center: glowCenter, radius: 36)),
  );
  _shadow(canvas, 50, 90, 16, 3);
  canvas.drawLine(const Offset(50, 46), const Offset(50, 87), _stroke(_metal, 2.4));
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 88), width: 30, height: 6),
    _fill(_legDark),
  );
  final shade = Path()
    ..moveTo(36, 12)
    ..lineTo(64, 12)
    ..lineTo(74, 46)
    ..lineTo(26, 46)
    ..close();
  canvas.drawPath(
    shade,
    _vertical(
      Rect.fromLTWH(26, 12, 48, 34),
      _shade(base, 0.06),
      _shade(base, -0.08),
    ),
  );
  canvas.drawPath(shade, _stroke(const Color(0x40FFFFFF), 0.8));
}

void _bookshelf(Canvas canvas, Color base) {
  _shadow(canvas, 50, 90, 30, 4);
  canvas.drawRRect(_rr(20, 10, 80, 89, 2.5), _fill(_shade(base, -0.1)));
  canvas.drawRect(Rect.fromLTWH(23, 13, 54, 73), _fill(_shade(base, -0.24)));

  const bottoms = [35.0, 59.0, 83.0];
  for (var row = 0; row < 3; row++) {
    var x = 26.0;
    var i = row * 3;
    while (x < 73) {
      final w = 3.0 + ((i * 7) % 3);
      final h = 13.0 + ((i * 5) % 7) * 1.3;
      final col = _bookColors[i % _bookColors.length];
      canvas.drawRect(Rect.fromLTWH(x, bottoms[row] - h, w, h), _fill(col));
      x += w + 0.8;
      i++;
    }
    canvas.drawRect(Rect.fromLTWH(23, bottoms[row], 54, 3), _fill(base));
  }
}