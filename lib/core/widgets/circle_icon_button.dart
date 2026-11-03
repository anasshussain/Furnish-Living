import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'press_scale.dart';

/// Round white icon button with an optional count badge.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = 0,
    this.size = 44,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = PressScale(
      onTap: onTap,
      scale: 0.9,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: size * 0.5, color: AppColors.ink),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: AnimatedScale(
                scale: badge > 0 ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      label: tooltip,
      child: button,
    );
  }
}
