# Nook - Furniture Marketplace (Flutter)

A modern furniture marketplace app: sofas, chairs, dining tables, kitchen
pieces, beds and decor. Clean light UI, glassmorphism where it helps
(floating bottom navigation, bottom sheets, profile card, onboarding glass),
and smooth animations throughout.

## Features

- **Onboarding** - "Choose furniture that fits your space" with a floating
  chair illustration, reeded-glass panel and staggered entrance animation.
  Shown on first launch only.
- **Discover** - category chips (Chairs, Sofas, Tables, Kitchen, Beds, Decor),
  responsive product grid, sort sheet (featured / price / name), loading
  skeletons and an error state with retry.
- **Search** - live search by name, category, type or colour.
- **Product details** - hero transition, 4 views (front, mirrored, close-up,
  in a room), colour picker that re-colours the product, quantity stepper,
  favourite toggle, rating and "Add to cart" with animated confirmation.
- **Cart** - quantity steppers, swipe to remove with undo, delivery logic
  (free over $500), totals and a "Place order" demo flow.
- **Favourites** and **Profile** (stats, about, reset app data).
- **Persistence** - cart, favourites and the onboarding flag are saved with
  `shared_preferences`.
- **Floating glass bottom nav** with a sliding indicator; it hides while the
  keyboard is open.

All furniture is drawn in code (`CustomPainter`), so the app needs no image
files and no internet connection.

## Tech stack

| Area             | Choice                                   |
| ---------------- | ---------------------------------------- |
| Framework        | Flutter (Dart 3.6+), Material 3          |
| State management | `provider`                               |
| Navigation       | `go_router`                              |
| Storage          | `shared_preferences`                     |
| Data             | Local repository (`ProductRepository`)   |

## Getting started

1. Install Flutter (3.27 or newer): https://docs.flutter.dev/get-started/install
2. From this folder, generate the platform folders once (this does not touch
   `lib/` or `pubspec.yaml` content):

   ```bash
   flutter create --project-name furniture_market --platforms=android,ios,web .
   ```

3. Fetch packages and run:

   ```bash
   flutter pub get
   flutter run
   ```

4. Optional checks:

   ```bash
   flutter analyze
   flutter test
   ```

To see the onboarding again, open **Profile > Reset app data** or clear the
app's storage.

## Project structure

```
lib/
  main.dart                  App start-up, providers
  app.dart                   MaterialApp.router + routes
  core/
    theme/                   Colours and theme
    utils/money.dart         Price formatting (prices are integer cents)
    illustrations/           CustomPainter furniture + product illustration
    widgets/                 Glass container, nav bar, sheets, skeletons, ...
  data/
    models/                  Product, category, furniture kind
    mock_products.dart       Catalogue (24 products)
    product_repository.dart  Data source (swap for an API/Supabase)
    app_settings.dart        Onboarding flag
  providers/                 Products, cart and favourites state
  features/
    onboarding/  home/  product/  cart/  shared/
test/
  cart_and_money_test.dart   Unit tests for totals, delivery and formatting
```

## Customising

- **Add or edit products**: `lib/data/mock_products.dart`. Prices are in
  cents (`5750` = `$57.50`).
- **Use real photos**: replace `ProductIllustration` (used in the product card,
  detail screen and cart tile) with `Image.asset` / `Image.network`. Add an
  `imageUrl` or per-colour image list to `Product`.
- **Real backend**: implement `fetchAll()` and `byId()` in
  `ProductRepository` against Supabase or your REST API. The providers do not
  need to change.
- **Delivery rules**: `kFreeDeliveryThresholdCents` and `kDeliveryFeeCents`
  in `lib/providers/cart_provider.dart`.
- **Colours**: `lib/core/theme/app_colors.dart`.

## Notes

- "Place order" is a demo: it clears the cart and shows a confirmation. No
  payment or order backend is connected.
- The app is light-theme only.
