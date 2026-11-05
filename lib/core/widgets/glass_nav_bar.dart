import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.icons,
    required this.labels,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<IconData> icons;
  final List<String> labels;

  static const double _barRadius = 30;
  static const double _indicatorRadius = 22;
  static const double _height = 66;
  static const double _padding = 6;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_barRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 32,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_barRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.all(_padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_barRadius),
              // Frosted glass: bright at the top edge, softer at the bottom.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.62),
                  Colors.white.withOpacity(0.38),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.65),
                width: 1,
              ),
            ),
            child: SizedBox(
              height: _height - _padding * 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / icons.length;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        left: itemWidth * index,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(_indicatorRadius),
                              // Transparent sage-tinted glass.
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.sageDark.withOpacity(0.22),
                                  AppColors.sageDark.withOpacity(0.10),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(icons.length, (i) {
                          return Expanded(
                            child: _NavItem(
                              icon: icons[i],
                              label: labels[i],
                              selected: i == index,
                              onTap: () {
                                if (i != index) {
                                  HapticFeedback.selectionClick();
                                }
                                onChanged(i);
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.ink.withOpacity(0.5);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: color),
              duration: const Duration(milliseconds: 250),
              builder: (context, c, _) => Icon(icon, size: 23, color: c),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10.5,
                height: 1.1,
                letterSpacing: 0.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}