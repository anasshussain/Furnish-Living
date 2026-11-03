import 'package:flutter/foundation.dart';

import '../data/models/product.dart';
import '../data/models/product_category.dart';
import '../data/product_repository.dart';

enum SortMode {
  featured('Featured'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low'),
  name('Name: A to Z');

  const SortMode(this.label);

  final String label;
}

class ProductsProvider extends ChangeNotifier {
  ProductsProvider(this._repository);

  final ProductRepository _repository;

  List<Product> _all = const [];
  bool _loading = true;
  String? _error;
  ProductCategory _category = ProductCategory.chairs;
  SortMode _sort = SortMode.featured;

  bool get isLoading => _loading;
  String? get error => _error;
  ProductCategory get category => _category;
  SortMode get sort => _sort;
  List<Product> get all => _all;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await _repository.fetchAll();
    } catch (_) {
      _error = 'We could not load the products. Please try again.';
    }
    _loading = false;
    notifyListeners();
  }

  void selectCategory(ProductCategory category) {
    if (_category == category) return;
    _category = category;
    notifyListeners();
  }

  void setSort(SortMode mode) {
    if (_sort == mode) return;
    _sort = mode;
    notifyListeners();
  }

  List<Product> get visible {
    final list = _all.where((p) => p.category == _category).toList();
    switch (_sort) {
      case SortMode.featured:
        break;
      case SortMode.priceLow:
        list.sort((a, b) => a.priceCents.compareTo(b.priceCents));
      case SortMode.priceHigh:
        list.sort((a, b) => b.priceCents.compareTo(a.priceCents));
      case SortMode.name:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  List<Product> search(String query) {
    final tokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return List<Product>.of(_all);
    return _all.where((p) {
      final haystack = '${p.name} ${p.category.label} ${p.kind.label} '
              '${p.colors.map((c) => c.name).join(' ')}'
          .toLowerCase();
      return tokens.every((t) => haystack.contains(t));
    }).toList();
  }

  List<Product> byIds(Iterable<String> ids) {
    final wanted = ids.toSet();
    return _all.where((p) => wanted.contains(p.id)).toList();
  }

  Product? byId(String id) => _repository.byId(id);
}