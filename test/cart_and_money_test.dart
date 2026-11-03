import 'package:flutter_test/flutter_test.dart';
import 'package:furniture_market/core/utils/money.dart';
import 'package:furniture_market/data/product_repository.dart';
import 'package:furniture_market/providers/cart_provider.dart';

void main() {
  group('formatCents', () {
    test('formats dollars and cents', () {
      expect(formatCents(5750), '\$57.50');
      expect(formatCents(6400), '\$64.00');
      expect(formatCents(5), '\$0.05');
    });

    test('adds thousands separators', () {
      expect(formatCents(123456), '\$1,234.56');
    });
  });

  group('CartProvider', () {
    const repository = ProductRepository();

    test('merges identical lines and totals correctly', () {
      final cart = CartProvider(repository);
      final product = repository.byId('soft-element-jack')!;

      cart.add(product, 0);
      cart.add(product, 0, quantity: 2);

      expect(cart.items.length, 1);
      expect(cart.itemCount, 3);
      expect(cart.subtotalCents, 5750 * 3);
      expect(cart.deliveryCents, kDeliveryFeeCents);
      expect(cart.totalCents, 5750 * 3 + kDeliveryFeeCents);
    });

    test('different colours are separate lines', () {
      final cart = CartProvider(repository);
      final product = repository.byId('leset-galant')!;

      cart.add(product, 0);
      cart.add(product, 1);

      expect(cart.items.length, 2);
      expect(cart.itemCount, 2);
    });

    test('delivery is free above the threshold', () {
      final cart = CartProvider(repository);
      final bed = repository.byId('haven-platform-bed')!;

      cart.add(bed, 0);

      expect(cart.subtotalCents, 52900);
      expect(cart.deliveryCents, 0);
      expect(cart.totalCents, 52900);
    });

    test('quantity is capped and zero removes the line', () {
      final cart = CartProvider(repository);
      final product = repository.byId('brio-bar-stool')!;

      cart.add(product, 0, quantity: 25);
      expect(cart.itemCount, kMaxQuantity);

      cart.setQuantity('brio-bar-stool:0', 0);
      expect(cart.isEmpty, isTrue);
      expect(cart.totalCents, 0);
    });
  });
}
