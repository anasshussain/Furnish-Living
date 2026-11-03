import 'package:flutter/material.dart';

import 'furniture_kind.dart';
import 'product_category.dart';

class ProductColor {
  const ProductColor(this.name, this.color);

  final String name;
  final Color color;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.kind,
    required this.priceCents,
    required this.colors,
    required this.description,
    required this.rating,
    required this.reviews,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final FurnitureKind kind;

  /// Price in cents (5750 == $57.50).
  final int priceCents;
  final List<ProductColor> colors;
  final String description;
  final double rating;
  final int reviews;
}
