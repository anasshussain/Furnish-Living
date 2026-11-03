import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Favourites',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (products.isNotEmpty)
                  Text(
                    '${products.length} saved',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'No favourites yet',
                    message:
                        'Tap the heart on any product to save it here for later.',
                    actionLabel: 'Discover products',
                    onAction: onDiscoverTap,
                  )
                : ProductGrid(products: products, heroPrefix: 'fav'),
          ),
        ],
      ),
    );
  }
}
