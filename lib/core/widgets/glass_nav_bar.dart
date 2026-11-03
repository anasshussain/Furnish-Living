import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass_container.dart';

/// Floating glass bottom navigation with a sliding circular indicator.
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

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(40),
      blur: 24,
      opacity: 0.3,
      tint: AppColors.glassTint,
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        height: 56,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / icons.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  left: itemWidth * index,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(icons.length, (i) {
                    final selected = i == index;
                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: labels[i],
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: TweenAnimationBuilder<Color?>(
                              tween: ColorTween(
                                end: selected ? Colors.white : AppColors.ink,
                              ),
                              duration: const Duration(milliseconds: 250),
                              builder: (context, color, _) =>
                                  Icon(icons[i], size: 24, color: color),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
