import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'press_scale.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.canDecrement = true,
    this.canIncrement = true,
    this.compact = false,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool canDecrement;
  final bool canIncrement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final box = compact ? 30.0 : 38.0;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(box),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            size: box,
            enabled: canDecrement,
            onTap: onDecrement,
          ),
          SizedBox(
            width: compact ? 26 : 34,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Text(
                '$value',
                key: ValueKey<int>(value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            size: box,
            enabled: canIncrement,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: enabled ? onTap : null,
      scale: 0.88,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled ? AppColors.ink : AppColors.softGrey,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: enabled ? Colors.white : AppColors.muted,
        ),
      ),
    );
  }
}
