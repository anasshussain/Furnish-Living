import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_sheet.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/models/product_category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../shared/product_card.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({
    super.key,
    required this.onSearchTap,
    required this.onProfileTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();
    final cartCount = context.select<CartProvider, int>((c) => c.itemCount);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                CircleIconButton(
                  icon: Icons.notes_rounded,
                  tooltip: 'Categories',
                  onTap: () => _showCategories(context),
                ),
                const Spacer(),
                CircleIconButton(
                  icon: Icons.shopping_bag_outlined,
                  tooltip: 'Cart',
                  badge: cartCount,
                  onTap: () => context.push('/cart'),
                ),
                const SizedBox(width: 10),
                CircleIconButton(
                  icon: Icons.person_outline_rounded,
                  tooltip: 'Profile',
                  onTap: onProfileTap,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Discover products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                CircleIconButton(
                  icon: Icons.search_rounded,
                  tooltip: 'Search',
                  size: 40,
                  onTap: onSearchTap,
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: Icons.tune_rounded,
                  tooltip: 'Sort',
                  size: 40,
                  onTap: () => _showSort(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: ProductCategory.values.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = ProductCategory.values[index];
                return _CategoryChip(
                  label: category.label,
                  selected: category == products.category,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<ProductsProvider>().selectCategory(category);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Expanded(child: _Body(provider: products)),
        ],
      ),
    );
  }

  void _showSort(BuildContext context) {
    final provider = context.read<ProductsProvider>();
    showGlassSheet<void>(
      context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final mode in SortMode.values)
              _SheetTile(
                label: mode.label,
                selected: provider.sort == mode,
                onTap: () {
                  provider.setSort(mode);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showCategories(BuildContext context) {
    final provider = context.read<ProductsProvider>();
    showGlassSheet<void>(
      context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final category in ProductCategory.values)
              _SheetTile(
                label: category.label,
                icon: category.icon,
                selected: provider.category == category,
                onTap: () {
                  provider.selectCategory(category);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.provider});

  final ProductsProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) return const ProductGridSkeleton();
    final error = provider.error;
    if (error != null) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Something went wrong',
        message: error,
        actionLabel: 'Try again',
        onAction: provider.load,
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOut,
      child: KeyedSubtree(
        key: ValueKey(provider.category.name),
        child: ProductGrid(
          products: provider.visible,
          heroPrefix: 'discover',
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.line,
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 260),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_rounded, size: 22),
          ],
        ),
      ),
    );
  }
}
