import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/product.dart';
import '../data/product_repository.dart';

const int kMaxQuantity = 10;

int _clampQty(int value) {
  if (value < 1) return 1;
  if (value > kMaxQuantity) return kMaxQuantity;
  return value;
}

const int kFreeDeliveryThresholdCents = 50000;
const int kDeliveryFeeCents = 1500;

class CartItem {
  CartItem({
    required this.product,
    required this.colorIndex,
    required this.quantity,
  });

  final Product product;
  final int colorIndex;
  int quantity;

  String get key => '${product.id}:$colorIndex';
  ProductColor get color => product.colors[colorIndex];
  int get totalCents => product.priceCents * quantity;
}

class CartProvider extends ChangeNotifier {
  CartProvider(this._repository, [this._prefs]) {
    _restore();
  }

  static const String _key = 'cart';

  final ProductRepository _repository;
  final SharedPreferences? _prefs;
  final List<CartItem> _items = <CartItem>[];

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.fold<int>(0, (sum, i) => sum + i.quantity);

  int get subtotalCents => _items.fold<int>(0, (sum, i) => sum + i.totalCents);

  int get deliveryCents {
    if (_items.isEmpty) return 0;
    return subtotalCents >= kFreeDeliveryThresholdCents ? 0 : kDeliveryFeeCents;
  }

  int get totalCents => subtotalCents + deliveryCents;

  void add(Product product, int colorIndex, {int quantity = 1}) {
    if (colorIndex < 0 || colorIndex >= product.colors.length) return;
    if (quantity < 1) return;
    final key = '${product.id}:$colorIndex';
    final index = _items.indexWhere((i) => i.key == key);
    if (index >= 0) {
      final item = _items[index];
      item.quantity = _clampQty(item.quantity + quantity);
    } else {
      _items.add(
        CartItem(
          product: product,
          colorIndex: colorIndex,
          quantity: _clampQty(quantity),
        ),
      );
    }
    _changed();
  }

  void setQuantity(String key, int quantity) {
    final index = _items.indexWhere((i) => i.key == key);
    if (index < 0) return;
    if (quantity < 1) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = _clampQty(quantity);
    }
    _changed();
  }

  void remove(String key) {
    _items.removeWhere((i) => i.key == key);
    _changed();
  }

  void clear() {
    _items.clear();
    _changed();
  }

  void _changed() {
    _persist();
    notifyListeners();
  }

  void _persist() {
    _prefs?.setStringList(
      _key,
      _items
          .map((i) => '${i.product.id}|${i.colorIndex}|${i.quantity}')
          .toList(),
    );
  }

  void _restore() {
    final saved = _prefs?.getStringList(_key);
    if (saved == null) return;
    for (final entry in saved) {
      final parts = entry.split('|');
      if (parts.length != 3) continue;
      final product = _repository.byId(parts[0]);
      final colorIndex = int.tryParse(parts[1]);
      final quantity = int.tryParse(parts[2]);
      if (product == null || colorIndex == null || quantity == null) continue;
      if (colorIndex < 0 || colorIndex >= product.colors.length) continue;
      if (quantity < 1) continue;
      final key = '${product.id}:$colorIndex';
      if (_items.any((i) => i.key == key)) continue;
      _items.add(
        CartItem(
          product: product,
          colorIndex: colorIndex,
          quantity: _clampQty(quantity),
        ),
      );
    }
  }
}