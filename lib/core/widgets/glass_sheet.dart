import 'package:flutter/material.dart';

import 'glass_container.dart';

/// Opens a modal bottom sheet rendered as a frosted-glass card.
Future<T?> showGlassSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: const Color(0x66000000),
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(30),
            blur: 30,
            opacity: 0.72,
            child: Material(
              type: MaterialType.transparency,
              child: builder(sheetContext),
            ),
          ),
        ),
      );
    },
  );
}
