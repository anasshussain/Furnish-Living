import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/products_provider.dart';
import '../shared/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.onDiscoverTap});

  final VoidCallback onDiscoverTap;

  @override
  Widget build(BuildContext context) {
    final favoriteIds = context.watch<FavoritesProvider>().ids;
    final products = context.watch<ProductsProvider>().byIds(favoriteIds);
    final totalCents = products.fold<int>(0, (sum, p) => sum + p.priceCents);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Favourites',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: AppColors.ink,
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topLeft,
                        child: products.isEmpty
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${products.length} '
                                '${products.length == 1 ? 'piece' : 'pieces'}'
                                '  \u2022  ${formatCents(totalCents)} in total',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (products.isNotEmpty)
                  _ClearButton(onTap: () => _confirmClear(context)),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              child: products.isEmpty
                  ? EmptyState(
                key: const ValueKey('empty'),
                icon: Icons.favorite_border_rounded,
                title: 'No favourites yet',
                message:
                'Tap the heart on any product to save it here for later.',
                actionLabel: 'Discover products',
                onAction: onDiscoverTap,
              )
                  : ProductGrid(
                key: const ValueKey('grid'),
                products: products,
                heroPrefix: 'fav',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Clear all favourites?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'All saved products will be removed from this list.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<FavoritesProvider>().clear();
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Clear all favourites',
      child: Tooltip(
        message: 'Clear all',
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.delete_sweep_outlined,
                size: 22,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}