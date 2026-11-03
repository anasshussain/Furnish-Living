import 'mock_products.dart';
import 'models/product.dart';

/// Source of truth for products. Replace the body of [fetchAll] with a
/// network or Supabase call when you are ready for a real backend.
class ProductRepository {
  const ProductRepository();

  List<Product> get all => kProducts;

  Future<List<Product>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return kProducts;
  }

  Product? byId(String id) {
    for (final product in kProducts) {
      if (product.id == id) return product;
    }
    return null;
  }
}
