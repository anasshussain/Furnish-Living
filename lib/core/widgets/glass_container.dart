import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blur = 18,
    this.opacity = 0.18,
    this.tint = Colors.white,
    this.borderOpacity = 0.4,
    this.padding,
    this.shadow = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final double opacity;
  final Color tint;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final topAlpha = (opacity + 0.14).clamp(0.0, 1.0).toDouble();
    final bottomAlpha = opacity.clamp(0.0, 1.0).toDouble();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: topAlpha),
                  tint.withValues(alpha: bottomAlpha),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: borderOpacity),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}