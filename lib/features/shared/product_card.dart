import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/illustrations/product_illustration.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/press_scale.dart';
import '../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.heroPrefix,
  });

  final Product product;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final heroTag = '$heroPrefix-${product.id}';
    return PressScale(
      onTap: () => context.push('/product/${product.id}', extra: heroTag),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Color(0xFFF5F5F5)),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 24, 8, 4),
                        child: Hero(
                          tag: heroTag,
                          child: ProductIllustration(
                            kind: product.kind,
                            color: product.colors.first.color,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 14,
                      child: _ColorDots(colors: product.colors),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.north_east_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                formatCents(product.priceCents),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _ColorDots extends StatelessWidget {
  const _ColorDots({required this.colors});

  final List<ProductColor> colors;

  @override
  Widget build(BuildContext context) {
    final shown = colors.take(3).toList();
    final extra = colors.length - shown.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in shown)
          Container(
            margin: const EdgeInsets.only(right: 4),
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: c.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.2),
            ),
          ),
        if (extra > 0)
          Text(
            '+$extra',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
      ],
    );
  }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.heroPrefix,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 130),
  });

  final List<Product> products;
  final String heroPrefix;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 230,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final card = ProductCard(
          key: ValueKey('$heroPrefix-${products[index].id}'),
          product: products[index],
          heroPrefix: heroPrefix,
        );
        if (index >= 8) return card;
        return FadeSlideIn(
          delay: Duration(milliseconds: 45 * index),
          offset: const Offset(0, 0.08),
          child: card,
        );
      },
    );
  }
}