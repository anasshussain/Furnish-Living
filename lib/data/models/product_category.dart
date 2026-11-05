import 'package:flutter/material.dart';

enum ProductCategory {
  chairs('Chairs', Icons.chair_alt_rounded),
  sofas('Sofas', Icons.weekend_rounded),
  tables('Tables', Icons.table_restaurant_rounded),
  kitchen('Kitchen', Icons.kitchen_rounded),
  beds('Beds', Icons.bed_rounded),
  decor('Decor', Icons.lightbulb_rounded);

  const ProductCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}