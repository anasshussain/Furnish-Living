import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/illustrations/product_illustration.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/press_scale.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../data/models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/products_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.heroTag,
  });

  final String productId;
  final String heroTag;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _view = 0;
  int _colorIndex = 0;
  int _quantity = 1;
  bool _added = false;
  Timer? _addedTimer;

  @override
  void dispose() {
    _addedTimer?.cancel();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _addToCart(Product product) {
    HapticFeedback.mediumImpact();
    context.read<CartProvider>().add(
          product,
          _colorIndex,
          quantity: _quantity,
        );
    setState(() => _added = true);
    _addedTimer?.cancel();
    _addedTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _added = false);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$_quantity x ${product.name} (${product.colors[_colorIndex].name}) added to cart',
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => context.push('/cart'),
          ),
        ),
      );
  }

  Future<void> _copyDetails(Product product) async {
    await Clipboard.setData(
      ClipboardData(
        text: '${product.name} - ${formatCents(product.priceCents)}',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Product details copied')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = context.read<ProductsProvider>().byId(widget.productId);
    if (product == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: _back,
                  ),
                ),
              ),
              const Expanded(
                child: Center(child: Text('This product is not available.')),
              ),
            ],
          ),
        ),
      );
    }

    final isFavorite = context.select<FavoritesProvider, bool>(
      (f) => f.isFavorite(product.id),
    );
    final selected = product.colors[_colorIndex];
    final totalCents = product.priceCents * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Row(
                children: [
                  QuantityStepper(
                    value: _quantity,
                    canDecrement: _quantity > 1,
                    canIncrement: _quantity < kMaxQuantity,
                    onDecrement: () => setState(() => _quantity--),
                    onIncrement: () => setState(() => _quantity++),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AddToCartButton(
                      added: _added,
                      label: 'Add to cart  |  ${formatCents(totalCents)}',
                      onTap: () => _addToCart(product),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: _back,
                  ),
                  const Spacer(),
                  CircleIconButton(
                    icon: Icons.share_outlined,
                    tooltip: 'Copy product details',
                    onTap: () => _copyDetails(product),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Stage(
                          product: product,
                          color: selected.color,
                          view: _view,
                          heroTag: widget.heroTag,
                          isFavorite: isFavorite,
                          onFavorite: () {
                            HapticFeedback.selectionClick();
                            context
                                .read<FavoritesProvider>()
                                .toggle(product.id);
                          },
                        ),
                        const SizedBox(height: 14),
                        _Thumbnails(
                          product: product,
                          color: selected.color,
                          selectedView: _view,
                          onSelect: (view) => setState(() => _view = view),
                        ),
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 150),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ColorPicker(
                                colors: product.colors,
                                selectedIndex: _colorIndex,
                                onSelect: (i) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _colorIndex = i);
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _RatingPill(
                                    rating: product.rating,
                                    reviews: product.reviews,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                product.description,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  height: 1.55,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _InfoChip(
                                    icon: Icons.local_shipping_outlined,
                                    label: 'Delivery in 3-5 days',
                                  ),
                                  _InfoChip(
                                    icon: Icons.verified_outlined,
                                    label: '30-day returns',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.product,
    required this.color,
    required this.view,
    required this.heroTag,
    required this.isFavorite,
    required this.onFavorite,
  });

  final Product product;
  final Color color;
  final int view;
  final String heroTag;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.08,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Hero(
              tag: heroTag,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                child: KeyedSubtree(
                  key: ValueKey<int>(view),
                  child: ProductIllustration(
                    kind: product.kind,
                    color: color,
                    view: view,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 24, 14),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Text(
              formatCents(product.priceCents),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: PressScale(
            onTap: onFavorite,
            scale: 0.88,
            child: Semantics(
              button: true,
              label: isFavorite ? 'Remove from favourites' : 'Add to favourites',
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey<bool>(isFavorite),
                    size: 22,
                    color: isFavorite ? AppColors.danger : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Thumbnails extends StatelessWidget {
  const _Thumbnails({
    required this.product,
    required this.color,
    required this.selectedView,
    required this.onSelect,
  });

  final Product product;
  final Color color;
  final int selectedView;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final selected = i == selectedView;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 3 ? 0 : 10),
            child: Semantics(
              button: true,
              selected: selected,
              label: 'View ${i + 1}',
              child: PressScale(
                onTap: () => onSelect(i),
                scale: 0.94,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.ink : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ProductIllustration(
                      kind: product.kind,
                      color: color,
                      view: i,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.colors,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ProductColor> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < colors.length; i++)
          Semantics(
            button: true,
            selected: i == selectedIndex,
            label: colors[i].name,
            child: GestureDetector(
              onTap: () => onSelect(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == selectedIndex
                        ? AppColors.ink
                        : Colors.transparent,
                    width: 1.6,
                  ),
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors[i].color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x1F000000),
                      width: 0.6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            colors[selectedIndex].name,
            key: ValueKey<int>(selectedIndex),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, required this.reviews});

  final double rating;
  final int reviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFE9A925)),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          Text(
            '($reviews)',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.added,
    required this.label,
    required this.onTap,
  });

  final bool added;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: added ? AppColors.success : AppColors.ink,
          borderRadius: BorderRadius.circular(28),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: added
              ? const Row(
                  key: ValueKey('added'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Added',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}