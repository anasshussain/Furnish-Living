import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/app_settings.dart';
import 'data/product_repository.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/products_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final repository = ProductRepository();
  final settings = AppSettings(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<AppSettings>.value(value: settings),
        Provider<ProductRepository>.value(value: repository),
        ChangeNotifierProvider<ProductsProvider>(
          create: (_) => ProductsProvider(repository)..load(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(repository, prefs),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(prefs),
        ),
      ],
      child: FurnitureApp(
        initialLocation: settings.onboarded ? '/home' : '/',
      ),
    ),
  );
}
